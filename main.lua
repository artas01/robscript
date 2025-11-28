-- Roblox Script Hub for robscript.com/hub.json
-- - Загружает общий hub.json
-- - Показывает список игр (страниц)
-- - Список скриптов по выбранной игре
-- - Поиск по играм и по скриптам
-- - Запуск выбранного скрипта (с учётом has_key)
-- - Окно перетаскивается
-- - Кнопка Toggle GUI сверху по центру с плавным скрытием / появлением окна

local HUB_URL = "https://raw.githubusercontent.com/artas01/robscript/refs/heads/main/hub.json"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

---------------------------------------------------------------------
-- HTTP / DATA UTILITIES
---------------------------------------------------------------------

local function safeHttpGet(url)
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not ok then
        warn("[ROBScript Hub] HttpGet failed:", res)
        return nil
    end
    return res
end

local function slugFromUrl(url)
    local path = url:match("https?://[^/]+/(.+)") or ""
    path = path:gsub("[/?#].*$", "")
    path = path:gsub("/+$", "")
    if path == "" then
        return "index"
    end
    return path
end

local function normalizeGameTitle(page)
    if page.title and type(page.title) == "string" and page.title ~= "" then
        return page.title
    end
    if page.slug and type(page.slug) == "string" and page.slug ~= "" then
        local s = page.slug
        s = s:gsub("%-scripts$", "")
        s = s:gsub("%-", " ")
        return s
    end
    if page.page_url and type(page.page_url) == "string" then
        local s = slugFromUrl(page.page_url)
        s = s:gsub("%-scripts$", "")
        s = s:gsub("%-", " ")
        return s
    end
    return "Unknown Game"
end

local function filterPages(pages, query)
    query = string.lower(query or "")
    if query == "" then
        return pages
    end
    local result = {}
    for _, page in ipairs(pages) do
        local title = normalizeGameTitle(page)
        if string.find(string.lower(title), query, 1, true) then
            table.insert(result, page)
        end
    end
    return result
end

local function filterScripts(page, query)
    if not page or type(page.scripts) ~= "table" then
        return {}
    end
    query = string.lower(query or "")
    if query == "" then
        return page.scripts
    end
    local result = {}
    for _, scr in ipairs(page.scripts) do
        local t = string.lower(scr.title or "")
        if string.find(t, query, 1, true) then
            table.insert(result, scr)
        end
    end
    return result
end

---------------------------------------------------------------------
-- SCRIPT EXECUTION
---------------------------------------------------------------------

local function runScript(scr)
    if not scr or type(scr.code) ~= "string" then
        warn("[ROBScript Hub] Invalid script data")
        return
    end

    if scr.has_key then
        -- Здесь можно повесить твою систему ключей
        warn("[ROBScript Hub] Script requires key-system:", scr.title or "Unknown")
        return
    end

    local fn, err = loadstring(scr.code)
    if not fn then
        warn("[ROBScript Hub] loadstring error for", scr.title or "Unknown", ":", err)
        return
    end

    local ok, runtimeErr = pcall(fn)
    if not ok then
        warn("[ROBScript Hub] runtime error for", scr.title or "Unknown", ":", runtimeErr)
    end
end

local function clearChildren(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

---------------------------------------------------------------------
-- LOAD HUB DATA
---------------------------------------------------------------------

local allPages = {}

do
    local body = safeHttpGet(HUB_URL)
    if not body then
        warn("[ROBScript Hub] Could not load hub.json")
    else
        local ok, data = pcall(function()
            return HttpService:JSONDecode(body)
        end)
        if not ok or type(data) ~= "table" then
            warn("[ROBScript Hub] Failed to decode hub.json:", data)
        else
            allPages = data
        end
    end
end

if #allPages == 0 then
    warn("[ROBScript Hub] No pages in hub.json; UI will still show but be empty.")
end

---------------------------------------------------------------------
-- UI ROOT
---------------------------------------------------------------------

local guiParent = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui") or localPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ROBScriptHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

-- Кнопка Toggle (чуть выше)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleHubButton"
toggleButton.Size = UDim2.new(0, 140, 0, 30)
toggleButton.AnchorPoint = Vector2.new(0.5, 0)
toggleButton.Position = UDim2.new(0.5, 0, 0, 2) -- было 0,6 → поднял выше
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.BackgroundTransparency = 0.3
toggleButton.BorderSizePixel = 1
toggleButton.BorderColor3 = Color3.fromRGB(90, 90, 90)
toggleButton.Text = "Toggle Hub"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextSize = 14
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Основное окно
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 700, 0, 400)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = mainFrame

local uiCornerMain = Instance.new("UICorner")
uiCornerMain.CornerRadius = UDim.new(0, 8)
uiCornerMain.Parent = mainFrame

local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Text = "ROBScript Hub"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 18
titleBar.Parent = mainFrame

local uiCornerTitle = Instance.new("UICorner")
uiCornerTitle.CornerRadius = UDim.new(0, 8)
uiCornerTitle.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -8, 0.5, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = titleBar

local uiCornerClose = Instance.new("UICorner")
uiCornerClose.CornerRadius = UDim.new(0, 6)
uiCornerClose.Parent = closeButton

---------------------------------------------------------------------
-- DRAGGING MAIN WINDOW (по titleBar)
---------------------------------------------------------------------

do
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

---------------------------------------------------------------------
-- LAYOUT (левая/правая часть)
---------------------------------------------------------------------

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Position = UDim2.new(0, 0, 0, 32)
contentFrame.Size = UDim2.new(1, 0, 1, -32)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Левая часть: список игр
local leftFrame = Instance.new("Frame")
leftFrame.Name = "GamesFrame"
leftFrame.Size = UDim2.new(0.4, -8, 1, -16)
leftFrame.Position = UDim2.new(0, 8, 0, 8)
leftFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
leftFrame.BorderSizePixel = 0
leftFrame.Parent = contentFrame

local uiCornerLeft = Instance.new("UICorner")
uiCornerLeft.CornerRadius = UDim.new(0, 8)
uiCornerLeft.Parent = leftFrame

local gameSearchBox = Instance.new("TextBox")
gameSearchBox.Name = "GameSearchBox"
gameSearchBox.Size = UDim2.new(1, -16, 0, 28)
gameSearchBox.Position = UDim2.new(0, 8, 0, 8)
gameSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
gameSearchBox.BorderSizePixel = 0
gameSearchBox.PlaceholderText = "Search games..."
gameSearchBox.Text = ""
gameSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
gameSearchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
gameSearchBox.Font = Enum.Font.Gotham
gameSearchBox.TextSize = 14
gameSearchBox.ClearTextOnFocus = false
gameSearchBox.Parent = leftFrame

local uiCornerGameSearch = Instance.new("UICorner")
uiCornerGameSearch.CornerRadius = UDim.new(0, 6)
uiCornerGameSearch.Parent = gameSearchBox

local gameList = Instance.new("ScrollingFrame")
gameList.Name = "GameList"
gameList.Size = UDim2.new(1, -16, 1, -52)
gameList.Position = UDim2.new(0, 8, 0, 44)
gameList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
gameList.BorderSizePixel = 0
gameList.CanvasSize = UDim2.new(0, 0, 0, 0)
gameList.ScrollBarThickness = 4
gameList.Parent = leftFrame

local uiCornerGameList = Instance.new("UICorner")
uiCornerGameList.CornerRadius = UDim.new(0, 6)
uiCornerGameList.Parent = gameList

local gameListLayout = Instance.new("UIListLayout")
gameListLayout.Padding = UDim.new(0, 4)
gameListLayout.FillDirection = Enum.FillDirection.Vertical
gameListLayout.SortOrder = Enum.SortOrder.LayoutOrder
gameListLayout.Parent = gameList

gameListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    gameList.CanvasSize = UDim2.new(0, 0, 0, gameListLayout.AbsoluteContentSize.Y + 8)
end)

-- Правая часть: список скриптов
local rightFrame = Instance.new("Frame")
rightFrame.Name = "ScriptsFrame"
rightFrame.Size = UDim2.new(0.6, -16, 1, -16)
rightFrame.Position = UDim2.new(0.4, 8, 0, 8)
rightFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
rightFrame.BorderSizePixel = 0
rightFrame.Parent = contentFrame

local uiCornerRight = Instance.new("UICorner")
uiCornerRight.CornerRadius = UDim.new(0, 8)
uiCornerRight.Parent = rightFrame

local scriptSearchBox = Instance.new("TextBox")
scriptSearchBox.Name = "ScriptSearchBox"
scriptSearchBox.Size = UDim2.new(1, -16, 0, 28)
scriptSearchBox.Position = UDim2.new(0, 8, 0, 8)
scriptSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
scriptSearchBox.BorderSizePixel = 0
scriptSearchBox.PlaceholderText = "Search scripts..."
scriptSearchBox.Text = ""
scriptSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
scriptSearchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
scriptSearchBox.Font = Enum.Font.Gotham
scriptSearchBox.TextSize = 14
scriptSearchBox.ClearTextOnFocus = false
scriptSearchBox.Parent = rightFrame

local uiCornerScriptSearch = Instance.new("UICorner")
uiCornerScriptSearch.CornerRadius = UDim.new(0, 6)
uiCornerScriptSearch.Parent = scriptSearchBox

local scriptList = Instance.new("ScrollingFrame")
scriptList.Name = "ScriptList"
scriptList.Size = UDim2.new(1, -16, 1, -52)
scriptList.Position = UDim2.new(0, 8, 0, 44)
scriptList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scriptList.BorderSizePixel = 0
scriptList.CanvasSize = UDim2.new(0, 0, 0, 0)
scriptList.ScrollBarThickness = 4
scriptList.Parent = rightFrame

local uiCornerScriptList = Instance.new("UICorner")
uiCornerScriptList.CornerRadius = UDim.new(0, 6)
uiCornerScriptList.Parent = scriptList

local scriptListLayout = Instance.new("UIListLayout")
scriptListLayout.Padding = UDim.new(0, 4)
scriptListLayout.FillDirection = Enum.FillDirection.Vertical
scriptListLayout.SortOrder = Enum.SortOrder.LayoutOrder
scriptListLayout.Parent = scriptList

scriptListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scriptList.CanvasSize = UDim2.new(0, 0, 0, scriptListLayout.AbsoluteContentSize.Y + 8)
end)

---------------------------------------------------------------------
-- DATA <-> UI
---------------------------------------------------------------------

local currentPage = nil
local currentPagesView = {}
local currentScriptsView = {}

local function createScriptButtonsForPage(page, query)
    clearChildren(scriptList)
    if not page then
        currentScriptsView = {}
        return
    end
    local filtered = filterScripts(page, query or "")
    currentScriptsView = filtered
    for _, scr in ipairs(filtered) do
        local sbtn = Instance.new("TextButton")
        sbtn.Name = "ScriptButton"
        sbtn.Size = UDim2.new(1, -8, 0, 28)
        sbtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        sbtn.BorderSizePixel = 0
        sbtn.TextXAlignment = Enum.TextXAlignment.Left

        local keyLabel = scr.has_key and "[KEY] " or "[NO KEY] "
        sbtn.Text = keyLabel .. (scr.title or "Untitled")

        sbtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        sbtn.Font = Enum.Font.Gotham
        sbtn.TextSize = 14
        sbtn.Parent = scriptList

        local scorner = Instance.new("UICorner")
        scorner.CornerRadius = UDim.new(0, 6)
        scorner.Parent = sbtn

        sbtn.MouseButton1Click:Connect(function()
            runScript(scr)
        end)
    end
end

local function createGameButton(page)
    local btn = Instance.new("TextButton")
    btn.Name = "GameButton"
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = normalizeGameTitle(page)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = gameList

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        currentPage = page
        scriptSearchBox.Text = ""
        for _, child in ipairs(gameList:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        createScriptButtonsForPage(currentPage, "")
    end)
end

local function renderGames(query)
    currentPagesView = filterPages(allPages, query)
    clearChildren(gameList)
    for _, page in ipairs(currentPagesView) do
        createGameButton(page)
    end
end

---------------------------------------------------------------------
-- SEARCH HANDLERS
---------------------------------------------------------------------

gameSearchBox.FocusLost:Connect(function()
    local q = gameSearchBox.Text or ""
    currentPage = nil
    renderGames(q)
    clearChildren(scriptList)
end)

scriptSearchBox.FocusLost:Connect(function()
    local q = scriptSearchBox.Text or ""
    createScriptButtonsForPage(currentPage, q)
end)

---------------------------------------------------------------------
-- TOGGLE SHOW / HIDE ANIMATION
---------------------------------------------------------------------

local isOpen = true
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function showMain()
    if isOpen then return end
    isOpen = true
    uiScale.Scale = 0.8
    mainFrame.Visible = true
    local tween = TweenService:Create(uiScale, tweenInfo, {Scale = 1})
    tween:Play()
end

local function hideMain()
    if not isOpen then return end
    isOpen = false
    local tween = TweenService:Create(uiScale, tweenInfo, {Scale = 0.8})
    tween:Play()
    tween.Completed:Connect(function()
        if not isOpen then
            mainFrame.Visible = false
        end
    end)
end

-- Крестик теперь просто скрывает окно, а не уничтожает весь GUI
closeButton.MouseButton1Click:Connect(function()
    hideMain()
end)

toggleButton.MouseButton1Click:Connect(function()
    if isOpen then
        hideMain()
    else
        showMain()
    end
end)

---------------------------------------------------------------------
-- INITIAL RENDER
---------------------------------------------------------------------

renderGames("")
if #allPages > 0 then
    currentPage = allPages[1]
    createScriptButtonsForPage(currentPage, "")
end

print("[ROBScript Hub] Loaded with", #allPages, "pages from hub.json")

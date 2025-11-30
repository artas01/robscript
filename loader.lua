-- ROBScript Key Loader (fixed so GUI always appears)

local MAIN_URL     = "https://raw.githubusercontent.com/artas01/robscript/refs/heads/main/mainv2.lua"
local REQUIRED_KEY = "ROBKEY" -- СМЕНИ НА СВОЙ КЛЮЧ

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

---------------------------------------------------------------------
-- UI ROOT (с очисткой старого GUI)
---------------------------------------------------------------------

local guiParent = (gethui and gethui())
    or game:FindFirstChildOfClass("CoreGui")
    or localPlayer:WaitForChild("PlayerGui")

local old = guiParent:FindFirstChild("ROBScriptKeyLoader")
if old then
    old:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ROBScriptKeyLoader"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

-- ОСНОВНОЕ ОКНО БЕЗ ТЁМНОГО ФОНА
local mainFrame = Instance.new("Frame")
mainFrame.Name = "KeyFrame"
mainFrame.Size = UDim2.new(0, 380, 0, 220)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = mainFrame

local cornerMain = Instance.new("UICorner")
cornerMain.CornerRadius = UDim.new(0, 10)
cornerMain.Parent = mainFrame

---------------------------------------------------------------------
-- TITLEBAR + КРЕСТИК
---------------------------------------------------------------------

local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Text = "ROBScript Key System"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 18
titleBar.Parent = mainFrame

local cornerTitle = Instance.new("UICorner")
cornerTitle.CornerRadius = UDim.new(0, 10)
cornerTitle.Parent = titleBar

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

local cornerClose = Instance.new("UICorner")
cornerClose.CornerRadius = UDim.new(0, 6)
cornerClose.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

---------------------------------------------------------------------
-- DRAG (перетаскивание окна мышкой по titleBar)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        then
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
-- CONTENT
---------------------------------------------------------------------

local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "Info"
infoLabel.Size = UDim2.new(1, -20, 0, 60)
infoLabel.Position = UDim2.new(0, 10, 0, 42)
infoLabel.BackgroundTransparency = 1
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 14
infoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
infoLabel.Text = "A key is required to access the ROBScript Hub.\nGet the key by clicking the button and enter it below."
infoLabel.Parent = mainFrame

local linkButton = Instance.new("TextButton")
linkButton.Name = "GetKeyButton"
linkButton.Size = UDim2.new(1, -20, 0, 28)
linkButton.Position = UDim2.new(0, 10, 0, 100)
linkButton.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
linkButton.BorderSizePixel = 0
linkButton.Text = "Get Key"
linkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
linkButton.Font = Enum.Font.Gotham
linkButton.TextSize = 14
linkButton.Parent = mainFrame

local cornerLink = Instance.new("UICorner")
cornerLink.CornerRadius = UDim.new(0, 6)
cornerLink.Parent = linkButton

linkButton.MouseButton1Click:Connect(function()
    local url = "https://loot-link.com/s?WfeVrHSR" -- твоя страница ключа
    if setclipboard then
        setclipboard(url)
    end
    if syn and syn.request then
        syn.request({Url = url, Method = "GET"})
    end
    infoLabel.Text = "Link to key: https://loot-link.com/s?WfeVrHSR\nCopied to the clipboard (paste in the browser)."
end)

local keyBox = Instance.new("TextBox")
keyBox.Name = "KeyInput"
keyBox.Size = UDim2.new(1, -20, 0, 32)
keyBox.Position = UDim2.new(0, 10, 0, 140)
keyBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
keyBox.BorderSizePixel = 0
keyBox.PlaceholderText = "Enter the key..."
keyBox.Text = ""
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 16
keyBox.ClearTextOnFocus = false
keyBox.Parent = mainFrame

local cornerKey = Instance.new("UICorner")
cornerKey.CornerRadius = UDim.new(0, 6)
cornerKey.Parent = keyBox

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 176)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
statusLabel.Text = ""
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local confirmButton = Instance.new("TextButton")
confirmButton.Name = "ConfirmButton"
confirmButton.Size = UDim2.new(1, -20, 0, 30)
confirmButton.Position = UDim2.new(0, 10, 1, -40)
confirmButton.BackgroundColor3 = Color3.fromRGB(60, 90, 60)
confirmButton.BorderSizePixel = 0
confirmButton.Text = "Check Key"
confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmButton.Font = Enum.Font.GothamBold
confirmButton.TextSize = 16
confirmButton.Parent = mainFrame

local cornerConfirm = Instance.new("UICorner")
cornerConfirm.CornerRadius = UDim.new(0, 6)
cornerConfirm.Parent = confirmButton

---------------------------------------------------------------------
-- АНИМАЦИЯ ПОЯВЛЕНИЯ
---------------------------------------------------------------------

uiScale.Scale = 0.8
mainFrame.Visible = true
TweenService:Create(
    uiScale,
    TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {Scale = 1}
):Play()

local function destroyWithFade()
    local tween = TweenService:Create(
        uiScale,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Scale = 0.8}
    )
    tween:Play()
    tween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end

---------------------------------------------------------------------
-- ЛЁГКАЯ АНИМАЦИЯ ОШИБКИ (SHAKE)
---------------------------------------------------------------------

local function showError(msg)
    statusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
    statusLabel.Text = msg

    task.spawn(function()
        local original = mainFrame.Position
        for i = 1, 6 do
            mainFrame.Position = original + UDim2.new(0, (i % 2 == 0) and 4 or -4, 0, 0)
            task.wait(0.03)
        end
        mainFrame.Position = original
    end)
end

---------------------------------------------------------------------
-- ЗАГРУЗКА ОСНОВНОГО СКРИПТА ХАБА
---------------------------------------------------------------------

local function loadMainHub()
    local ok, res = pcall(function()
        return game:HttpGet(MAIN_URL, true)
    end)
    if not ok then
        showError("Hub loading error.")
        warn("[ROBScript KeyLoader] HttpGet main.lua failed:", res)
        return
    end

    local fn, err = loadstring(res)
    if not fn then
        showError("Hub compilation error.")
        warn("[ROBScript KeyLoader] loadstring main.lua error:", err)
        return
    end

    destroyWithFade()
    task.defer(function()
        local okRun, runErr = pcall(fn)
        if not okRun then
            warn("[ROBScript KeyLoader] main.lua runtime error:", runErr)
        end
    end)
end

---------------------------------------------------------------------
-- ПРОВЕРКА КЛЮЧА
---------------------------------------------------------------------

local function checkKeyAndLoad()
    local key = (keyBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if key == "" then
        showError("Key is not entered.")
        return
    end

    if key ~= REQUIRED_KEY then
        showError("Wrong key.")
        return
    end

    statusLabel.TextColor3 = Color3.fromRGB(120, 220, 120)
    statusLabel.Text = "The key is correct, loading hub..."
    loadMainHub()
end

confirmButton.MouseButton1Click:Connect(checkKeyAndLoad)

keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        checkKeyAndLoad()
    end
end)

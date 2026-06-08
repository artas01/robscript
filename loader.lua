-- ROBScript Key Loader
-- Modern glass redesign to match ROBScript Hub UI

local MAIN_URL     = "https://raw.githubusercontent.com/artas01/robscript/refs/heads/main/main.lua"
local REQUIRED_KEY = "KEYROBKA" -- СМЕНИ НА СВОЙ КЛЮЧ

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------

local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

---------------------------------------------------------------------
-- THEME / HELPERS
---------------------------------------------------------------------

local THEME = {
    bg = Color3.fromRGB(10, 12, 20),
    bg2 = Color3.fromRGB(18, 22, 36),
    panel = Color3.fromRGB(20, 24, 38),
    panel2 = Color3.fromRGB(13, 16, 27),
    input = Color3.fromRGB(28, 33, 50),
    button = Color3.fromRGB(35, 41, 62),
    buttonHover = Color3.fromRGB(47, 56, 82),
    buttonPressed = Color3.fromRGB(40, 95, 155),
    accent = Color3.fromRGB(80, 170, 255),
    accent2 = Color3.fromRGB(145, 95, 255),
    success = Color3.fromRGB(95, 220, 150),
    warning = Color3.fromRGB(255, 190, 90),
    danger = Color3.fromRGB(205, 75, 85),
    dangerHover = Color3.fromRGB(225, 95, 105),
    text = Color3.fromRGB(245, 248, 255),
    textMuted = Color3.fromRGB(155, 165, 188),
    stroke = Color3.fromRGB(135, 155, 200),
}

local TWEEN_FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tweenGui(object, props, info)
    local tween = TweenService:Create(object, info or TWEEN_FAST, props)
    tween:Play()
    return tween
end

local function makeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

local function makeStroke(parent, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color or THEME.stroke
    stroke.Transparency = transparency or 0.75
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function makeGradient(parent, colorA, colorB, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorA),
        ColorSequenceKeypoint.new(1, colorB),
    })
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

local function makePadding(parent, left, right, top, bottom)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.Parent = parent
    return padding
end

local function styleButton(button, options)
    options = options or {}

    local base = options.base or THEME.button
    local hover = options.hover or THEME.buttonHover
    local pressed = options.pressed or THEME.buttonPressed

    button.AutoButtonColor = false
    button.BackgroundColor3 = base
    button.BackgroundTransparency = options.baseTransparency or 0.12
    button.BorderSizePixel = 0
    button.TextColor3 = options.textColor or THEME.text
    button.Font = options.font or Enum.Font.GothamBold
    button.TextSize = options.textSize or 14
    button.TextXAlignment = options.textXAlignment or Enum.TextXAlignment.Center
    button.TextTruncate = Enum.TextTruncate.AtEnd

    makeCorner(button, options.radius or 10)
    local stroke = makeStroke(button, options.stroke or THEME.stroke, options.strokeTransparency or 0.78, options.strokeThickness or 1)

    button.MouseEnter:Connect(function()
        tweenGui(button, {
            BackgroundColor3 = hover,
            BackgroundTransparency = options.hoverTransparency or 0.04,
        }, TWEEN_FAST)
        tweenGui(stroke, {Transparency = options.hoverStrokeTransparency or 0.38}, TWEEN_FAST)
    end)

    button.MouseLeave:Connect(function()
        tweenGui(button, {
            BackgroundColor3 = base,
            BackgroundTransparency = options.baseTransparency or 0.12,
        }, TWEEN_FAST)
        tweenGui(stroke, {Transparency = options.strokeTransparency or 0.78}, TWEEN_FAST)
    end)

    button.MouseButton1Down:Connect(function()
        tweenGui(button, {
            BackgroundColor3 = pressed,
            BackgroundTransparency = options.pressedTransparency or 0,
        }, TWEEN_FAST)
    end)

    button.MouseButton1Up:Connect(function()
        tweenGui(button, {
            BackgroundColor3 = hover,
            BackgroundTransparency = options.hoverTransparency or 0.04,
        }, TWEEN_FAST)
    end)

    return stroke
end

local function styleInput(box)
    box.BackgroundColor3 = THEME.input
    box.BackgroundTransparency = 0.16
    box.BorderSizePixel = 0
    box.TextColor3 = THEME.text
    box.PlaceholderColor3 = THEME.textMuted
    box.Font = Enum.Font.Gotham
    box.TextSize = 15
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false

    makeCorner(box, 10)
    makePadding(box, 12, 12, 0, 0)
    local stroke = makeStroke(box, THEME.stroke, 0.84, 1)

    box.Focused:Connect(function()
        tweenGui(box, {BackgroundTransparency = 0.08}, TWEEN_FAST)
        tweenGui(stroke, {Color = THEME.accent, Transparency = 0.32}, TWEEN_FAST)
    end)

    box.FocusLost:Connect(function()
        tweenGui(box, {BackgroundTransparency = 0.16}, TWEEN_FAST)
        tweenGui(stroke, {Color = THEME.stroke, Transparency = 0.84}, TWEEN_FAST)
    end)
end

---------------------------------------------------------------------
-- UI ROOT
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
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999999
screenGui.Parent = guiParent

---------------------------------------------------------------------
-- MAIN WINDOW
---------------------------------------------------------------------

local mainFrame = Instance.new("Frame")
mainFrame.Name = "KeyFrame"
mainFrame.Size = UDim2.new(0, 460, 0, 292)
mainFrame.Position = UDim2.new(0.5, -230, 0.5, -146)
mainFrame.BackgroundColor3 = THEME.bg
mainFrame.BackgroundTransparency = 0.12
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
makeCorner(mainFrame, 18)
makeStroke(mainFrame, THEME.stroke, 0.58, 1)
makeGradient(mainFrame, Color3.fromRGB(18, 22, 36), Color3.fromRGB(8, 10, 17), 90)

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = mainFrame

---------------------------------------------------------------------
-- HEADER
---------------------------------------------------------------------

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 54)
titleBar.BackgroundColor3 = THEME.bg2
titleBar.BackgroundTransparency = 0.08
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Parent = mainFrame
makeCorner(titleBar, 18)
makeGradient(titleBar, Color3.fromRGB(30, 38, 61), Color3.fromRGB(18, 22, 36), 0)

local titleAccent = Instance.new("Frame")
titleAccent.Name = "TitleAccent"
titleAccent.Size = UDim2.new(1, -34, 0, 1)
titleAccent.Position = UDim2.new(0, 17, 1, -1)
titleAccent.BackgroundColor3 = THEME.accent
titleAccent.BackgroundTransparency = 0.12
titleAccent.BorderSizePixel = 0
titleAccent.Parent = titleBar
makeGradient(titleAccent, THEME.accent, THEME.accent2, 0)

local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(0, 235, 1, 0)
titleText.Position = UDim2.new(0, 18, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "ROBscript hub - Key System"
titleText.TextColor3 = THEME.text
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 15
titleText.Parent = titleBar

local domainLabel = Instance.new("TextLabel")
domainLabel.Name = "DomainColorFlow"
domainLabel.Size = UDim2.new(0, 122, 1, 0)
domainLabel.Position = UDim2.new(0, 254, 0, 0)
domainLabel.BackgroundTransparency = 1
domainLabel.Text = "robscript.com"
domainLabel.TextColor3 = THEME.accent
domainLabel.TextStrokeColor3 = Color3.fromRGB(5, 7, 12)
domainLabel.TextStrokeTransparency = 0.62
domainLabel.TextXAlignment = Enum.TextXAlignment.Left
domainLabel.Font = Enum.Font.GothamBold
domainLabel.TextSize = 15
domainLabel.Parent = titleBar

task.spawn(function()
    local colors = {
        Color3.fromRGB(80, 170, 255),
        Color3.fromRGB(145, 95, 255),
        Color3.fromRGB(255, 95, 180),
        Color3.fromRGB(255, 190, 90),
        Color3.fromRGB(90, 235, 180),
    }

    local index = 1
    while domainLabel.Parent do
        tweenGui(domainLabel, {TextColor3 = colors[index]}, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))
        index = index % #colors + 1
        task.wait(0.65)
    end
end)

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Size = UDim2.new(0, 32, 0, 32)
closeButton.Position = UDim2.new(1, -12, 0.5, 0)
closeButton.BackgroundColor3 = THEME.danger
closeButton.BackgroundTransparency = 0.18
closeButton.Text = "x"
closeButton.TextColor3 = THEME.text
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = titleBar
styleButton(closeButton, {
    base = THEME.danger,
    hover = THEME.dangerHover,
    pressed = Color3.fromRGB(180, 55, 65),
    radius = 10,
    stroke = Color3.fromRGB(255, 170, 175),
    strokeTransparency = 0.68,
})

---------------------------------------------------------------------
-- DRAG WINDOW
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

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Position = UDim2.new(0, 12, 0, 66)
contentFrame.Size = UDim2.new(1, -24, 1, -78)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local infoPanel = Instance.new("Frame")
infoPanel.Name = "InfoPanel"
infoPanel.Size = UDim2.new(1, 0, 0, 68)
infoPanel.Position = UDim2.new(0, 0, 0, 0)
infoPanel.BackgroundColor3 = THEME.panel
infoPanel.BackgroundTransparency = 0.22
infoPanel.BorderSizePixel = 0
infoPanel.Parent = contentFrame
makeCorner(infoPanel, 14)
makeStroke(infoPanel, THEME.stroke, 0.84, 1)
makeGradient(infoPanel, Color3.fromRGB(24, 29, 45), Color3.fromRGB(15, 18, 29), 90)

local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "Info"
infoLabel.Size = UDim2.new(1, -24, 1, -18)
infoLabel.Position = UDim2.new(0, 12, 0, 10)
infoLabel.BackgroundTransparency = 1
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 13
infoLabel.TextColor3 = Color3.fromRGB(210, 218, 235)
infoLabel.Text = "A key is required to access ROBscript Hub. Open the key link, get your key, then enter it below."
infoLabel.Parent = infoPanel

local linkButton = Instance.new("TextButton")
linkButton.Name = "GetKeyButton"
linkButton.Size = UDim2.new(0.48, -4, 0, 36)
linkButton.Position = UDim2.new(0, 0, 0, 82)
linkButton.BackgroundColor3 = THEME.button
linkButton.Text = "Copy key page"
linkButton.TextColor3 = THEME.text
linkButton.Font = Enum.Font.GothamBold
linkButton.TextSize = 14
linkButton.Parent = contentFrame
styleButton(linkButton, {
    base = THEME.button,
    hover = Color3.fromRGB(47, 56, 82),
    pressed = Color3.fromRGB(40, 95, 155),
    stroke = THEME.accent,
    strokeTransparency = 0.7,
})

local openHintButton = Instance.new("TextButton")
openHintButton.Name = "OpenHintButton"
openHintButton.Size = UDim2.new(0.52, -4, 0, 36)
openHintButton.Position = UDim2.new(0.48, 8, 0, 82)
openHintButton.BackgroundColor3 = THEME.button
openHintButton.Text = "Open key link"
openHintButton.TextColor3 = THEME.accent
openHintButton.Font = Enum.Font.GothamBold
openHintButton.TextSize = 14
openHintButton.Parent = contentFrame
styleButton(openHintButton, {
    base = THEME.button,
    hover = Color3.fromRGB(47, 56, 82),
    pressed = Color3.fromRGB(40, 95, 155),
    stroke = THEME.accent,
    strokeTransparency = 0.7,
})

local keyBox = Instance.new("TextBox")
keyBox.Name = "KeyInput"
keyBox.Size = UDim2.new(1, 0, 0, 40)
keyBox.Position = UDim2.new(0, 0, 0, 132)
keyBox.PlaceholderText = "Enter your key..."
keyBox.Text = ""
keyBox.Parent = contentFrame
styleInput(keyBox)

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, 0, 0, 22)
statusLabel.Position = UDim2.new(0, 0, 0, 179)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 13
statusLabel.TextColor3 = THEME.textMuted
statusLabel.Text = ""
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = contentFrame

local confirmButton = Instance.new("TextButton")
confirmButton.Name = "ConfirmButton"
confirmButton.Size = UDim2.new(1, 0, 0, 40)
confirmButton.Position = UDim2.new(0, 0, 1, -40)
confirmButton.BackgroundColor3 = Color3.fromRGB(42, 125, 90)
confirmButton.Text = "Check Key"
confirmButton.TextColor3 = THEME.text
confirmButton.Font = Enum.Font.GothamBold
confirmButton.TextSize = 15
confirmButton.Parent = contentFrame
styleButton(confirmButton, {
    base = Color3.fromRGB(42, 125, 90),
    hover = Color3.fromRGB(55, 150, 105),
    pressed = Color3.fromRGB(35, 105, 78),
    stroke = Color3.fromRGB(120, 235, 170),
    strokeTransparency = 0.62,
})

local confirmGlow = Instance.new("Frame")
confirmGlow.Name = "ConfirmGlow"
confirmGlow.Size = UDim2.new(1, -16, 0, 1)
confirmGlow.Position = UDim2.new(0, 8, 0, 6)
confirmGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
confirmGlow.BackgroundTransparency = 0.75
confirmGlow.BorderSizePixel = 0
confirmGlow.Parent = confirmButton
makeCorner(confirmGlow, 999)
makeGradient(confirmGlow, Color3.fromRGB(120, 235, 170), Color3.fromRGB(255, 255, 255), 0)

---------------------------------------------------------------------
-- BUTTON ACTIONS
---------------------------------------------------------------------

local KEY_URL = "https://loot-link.com/s?WfeVrHSR"

local function copyKeyUrl()
    if setclipboard then
        setclipboard(KEY_URL)
        statusLabel.TextColor3 = THEME.success
        statusLabel.Text = "Key page link copied to clipboard."
    else
        statusLabel.TextColor3 = THEME.warning
        statusLabel.Text = "Copy this link manually: " .. KEY_URL
    end

    if syn and syn.request then
        pcall(function()
            syn.request({Url = KEY_URL, Method = "GET"})
        end)
    end

    infoLabel.Text = "Key page: " .. KEY_URL .. "\nPaste it into your browser if it was not opened automatically."
end

linkButton.MouseButton1Click:Connect(copyKeyUrl)
openHintButton.MouseButton1Click:Connect(copyKeyUrl)

---------------------------------------------------------------------
-- APPEAR / CLOSE ANIMATION
---------------------------------------------------------------------

uiScale.Scale = 0.82
mainFrame.Visible = true
tweenGui(uiScale, {Scale = 1}, TWEEN_MED)

local closing = false

local function destroyWithFade()
    if closing then return end
    closing = true

    local tween = tweenGui(uiScale, {Scale = 0.82}, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
    tweenGui(mainFrame, {BackgroundTransparency = 0.5}, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In))

    tween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end

closeButton.MouseButton1Click:Connect(destroyWithFade)

---------------------------------------------------------------------
-- ERROR / STATUS ANIMATION
---------------------------------------------------------------------

local function showError(msg)
    statusLabel.TextColor3 = THEME.danger
    statusLabel.Text = msg

    task.spawn(function()
        local original = mainFrame.Position
        for i = 1, 6 do
            mainFrame.Position = original + UDim2.new(0, (i % 2 == 0) and 5 or -5, 0, 0)
            task.wait(0.03)
        end
        mainFrame.Position = original
    end)
end

local function authorizeMainHub()
    local authEnv = (getgenv and getgenv()) or _G
    local token

    local okGuid, guid = pcall(function()
        return HttpService:GenerateGUID(false)
    end)

    if okGuid and type(guid) == "string" and guid ~= "" then
        token = guid
    else
        token = "ROBScript-" .. tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
    end

    authEnv.ROBScriptHubAuth = {
        passed = true,
        token = token,
        expires = os.time() + 120,
        used = false,
        source = "ROBScriptKeySystem",
    }

    return token
end

---------------------------------------------------------------------
-- MAIN HUB LOADING
---------------------------------------------------------------------

local function loadMainHub()
    statusLabel.TextColor3 = THEME.success
    statusLabel.Text = "Key accepted. Loading hub..."

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

    authorizeMainHub()

    destroyWithFade()

    task.defer(function()
        local okRun, runErr = pcall(fn)
        if not okRun then
            warn("[ROBScript KeyLoader] main.lua runtime error:", runErr)
        end
    end)
end

---------------------------------------------------------------------
-- KEY CHECK
---------------------------------------------------------------------

local function checkKeyAndLoad()
    local key = (keyBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")

    if key == "" then
        showError("Enter the key first.")
        return
    end

    if key ~= REQUIRED_KEY then
        showError("Wrong key.")
        return
    end

    loadMainHub()
end

confirmButton.MouseButton1Click:Connect(checkKeyAndLoad)

keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        checkKeyAndLoad()
    end
end)

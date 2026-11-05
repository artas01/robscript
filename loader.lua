-- RobScript Hub loader
-- Loads the hub. No key needed. Source is open: https://github.com/artas01/robscript

local MAIN_URL = "https://raw.githubusercontent.com/artas01/robscript/refs/heads/main/main.lua"

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local player           = Players.LocalPlayer or Players.PlayerAdded:Wait()

local C = {
    bg      = Color3.fromRGB(15, 15, 17),
    panel   = Color3.fromRGB(24, 24, 27),
    input   = Color3.fromRGB(32, 32, 36),
    line    = Color3.fromRGB(48, 48, 54),
    text    = Color3.fromRGB(245, 245, 247),
    muted   = Color3.fromRGB(160, 160, 170),
    accent  = Color3.fromRGB(255, 59, 127),
    accent2 = Color3.fromRGB(140, 82, 255),
    ok      = Color3.fromRGB(38, 208, 124),
    bad     = Color3.fromRGB(240, 80, 90),
}
local WHITE     = Color3.new(1, 1, 1)
local FAMILY    = "rbxasset://fonts/families/BuilderSans.json"
local FONT      = Font.new(FAMILY, Enum.FontWeight.Regular)
local FONT_BOLD = Font.new(FAMILY, Enum.FontWeight.Bold)

local FAST   = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SPRING = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SHRINK = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)

local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

-- Downloads and compiles the hub; returns the function or nil + error text.
local function download()
    local src = safe(function() return game:HttpGet(MAIN_URL) end)
    if not src then return nil, "Could not download the hub. Check your connection." end
    local fn, err = loadstring(src)
    if not fn then return nil, "Load error: " .. tostring(err):sub(1, 60) end
    return fn
end

local function guiParent()
    if typeof(gethui) == "function" then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok = pcall(function() return CoreGui.Name end)
    if ok then return CoreGui end
    return player:WaitForChild("PlayerGui")
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function tween(o, info, props) local t = TweenService:Create(o, info, props); t:Play(); return t end
local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 10) }, p) end
local function stroke(p, col) return new("UIStroke", { Color = col or C.line, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, p) end
local function label(props, parent)
    local d = { BackgroundTransparency = 1, FontFace = FONT, TextSize = 14, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }
    for k, v in pairs(props) do d[k] = v end
    return new("TextLabel", d, parent)
end
local function gradient(p, rot)
    return new("UIGradient", { Color = ColorSequence.new(C.accent, C.accent2), Rotation = rot or 45 }, p)
end
local function btn(text, color, parent, hoverColor)
    local b = new("TextButton", { BackgroundColor3 = color, AutoButtonColor = false, FontFace = FONT_BOLD, TextSize = 14, TextColor3 = C.text, Text = text }, parent)
    corner(b, 10)
    local sc = new("UIScale", {}, b)
    local hov = hoverColor or color:Lerp(WHITE, 0.08)
    b.MouseEnter:Connect(function() tween(b, FAST, { BackgroundColor3 = hov }) end)
    b.MouseLeave:Connect(function() tween(b, FAST, { BackgroundColor3 = color }); tween(sc, FAST, { Scale = 1 }) end)
    b.MouseButton1Down:Connect(function() tween(sc, FAST, { Scale = 0.95 }) end)
    b.MouseButton1Up:Connect(function() tween(sc, FAST, { Scale = 1 }) end)
    return b
end

local W, LOAD_H = 340, 134

local gui = new("ScreenGui", { Name = "RobScriptLoader", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true }, guiParent())

-- Transparent holder: carries the shadow and the window, and is what gets dragged/scaled
local holder = new("Frame", { Size = UDim2.fromOffset(W, LOAD_H), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1 }, gui)
local scale = new("UIScale", { Scale = 0.85 }, holder)
new("ImageLabel", {
    BackgroundTransparency = 1, Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 0.45,
    ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 4), Size = UDim2.new(1, 44, 1, 44), ZIndex = 0,
}, holder)

local box = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.bg }, holder)
corner(box, 14)

-- Animated border: a pink/purple highlight running around the edge
local border = stroke(box, WHITE)
local borderGrad = new("UIGradient", { Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accent),
    ColorSequenceKeypoint.new(0.3, C.line),
    ColorSequenceKeypoint.new(0.7, C.line),
    ColorSequenceKeypoint.new(1, C.accent2),
}) }, border)
local spin = RunService.Heartbeat:Connect(function(dt) borderGrad.Rotation = (borderGrad.Rotation + dt * 90) % 360 end)

-- Header (also the drag handle)
local dragArea = new("Frame", { Size = UDim2.new(1, -60, 0, 60), BackgroundTransparency = 1 }, box)
local logo = new("Frame", { Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(20, 18), BackgroundColor3 = WHITE }, box)
corner(logo, 9); gradient(logo)
label({ Text = "R", FontFace = FONT_BOLD, TextSize = 17, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) }, logo)
label({ Text = "RobScript Hub", FontFace = FONT_BOLD, TextSize = 19, Position = UDim2.fromOffset(60, 15), Size = UDim2.new(1, -110, 0, 20) }, box)
local sub = label({ Text = "Loading the hub…", TextColor3 = C.muted, TextSize = 13, Position = UDim2.fromOffset(60, 35), Size = UDim2.new(1, -110, 0, 16) }, box)
local closeBtn = btn("×", C.panel, box, C.bad)
closeBtn.Size = UDim2.fromOffset(28, 28); closeBtn.Position = UDim2.new(1, -46, 0, 19); closeBtn.TextSize = 18; corner(closeBtn, 8)

-- Loading view
local loadView = new("Frame", { Size = UDim2.new(1, -40, 0, 44), Position = UDim2.fromOffset(20, 72), BackgroundTransparency = 1 }, box)
local trackBar = new("Frame", { Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = C.input, BorderSizePixel = 0 }, loadView)
corner(trackBar, 3)
local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, trackBar)
corner(fill, 3)
local fillGrad = gradient(fill, 0)
local loadStatus = label({ Text = "Downloading…", TextColor3 = C.muted, TextSize = 13, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, -80, 0, 24) }, loadView)
local retry = btn("Retry", C.input, loadView)
retry.Size = UDim2.fromOffset(70, 26); retry.Position = UDim2.new(1, -70, 0, 17); retry.TextSize = 13; retry.Visible = false
corner(retry, 8); stroke(retry)

-- Drag
do
    local dragging, start, startPos
    dragArea.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, start, startPos = true, i.Position, holder.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    local conn
    conn = UserInputService.InputChanged:Connect(function(i)
        if not gui.Parent then conn:Disconnect(); return end
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local closing = false
local function close(after)
    if closing then return end
    closing = true
    spin:Disconnect()
    tween(scale, SHRINK, { Scale = 0 })
    task.delay(0.2, function()
        gui:Destroy()
        if after then after() end
    end)
end
closeBtn.MouseButton1Click:Connect(function() close() end)

local busy = false
local function startLoading()
    if busy or closing then return end
    busy = true
    retry.Visible = false
    sub.Text = "Loading the hub…"
    fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = WHITE; fillGrad.Enabled = true
    loadStatus.Text = "Downloading…"; loadStatus.TextColor3 = C.muted
    tween(fill, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0.85, 0, 1, 0) })

    local fn, err = download()
    if closing then return end
    if not fn then
        fillGrad.Enabled = false
        tween(fill, FAST, { BackgroundColor3 = C.bad, Size = UDim2.fromScale(1, 1) })
        loadStatus.Text = err; loadStatus.TextColor3 = C.bad
        retry.Visible = true
        busy = false
        return
    end
    loadStatus.Text = "Starting…"
    tween(fill, FAST, { Size = UDim2.fromScale(1, 1) }).Completed:Wait()
    task.wait(0.15)
    close(function() task.spawn(fn) end)
end
retry.MouseButton1Click:Connect(startLoading)

tween(scale, SPRING, { Scale = 1 })
task.spawn(startLoading)

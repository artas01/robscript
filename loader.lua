-- RobScript Hub loader
-- Checks the key, then loads the hub. Source is open: https://github.com/artas01/robscript
 
local MAIN_URL     = "https://raw.githubusercontent.com/artas01/robscript/refs/heads/main/main.lua"
local REQUIRED_KEY = "KEYROBKA"
local KEY_PAGE     = "https://robscript.com/robscript-hub/"
local KEY_FILE     = "robscript_hub_key.txt"
 
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui      = game:GetService("CoreGui")
local player       = Players.LocalPlayer or Players.PlayerAdded:Wait()
 
local C = {
    bg     = Color3.fromRGB(15, 15, 17),
    panel  = Color3.fromRGB(24, 24, 27),
    input  = Color3.fromRGB(32, 32, 36),
    line   = Color3.fromRGB(48, 48, 54),
    text   = Color3.fromRGB(245, 245, 247),
    muted  = Color3.fromRGB(160, 160, 170),
    accent = Color3.fromRGB(255, 59, 127),
    ok     = Color3.fromRGB(38, 208, 124),
    bad    = Color3.fromRGB(240, 80, 90),
}
 
local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end
 
local function savedKey()
    if typeof(isfile) == "function" and typeof(readfile) == "function" and safe(isfile, KEY_FILE) then
        return safe(readfile, KEY_FILE)
    end
    return nil
end
 
local function saveKey(k)
    if typeof(writefile) == "function" then safe(writefile, KEY_FILE, k) end
end
 
local function runHub()
    local src = safe(function() return game:HttpGet(MAIN_URL) end)
    if not src then
        warn("[RobScript Hub] Could not download the hub. Check your connection or executor.")
        return
    end
    local fn, err = loadstring(src)
    if not fn then
        warn("[RobScript Hub] Load error: " .. tostring(err))
        return
    end
    task.spawn(fn)
end
 
if savedKey() == REQUIRED_KEY then
    runHub()
    return
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
 
local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = p end
local function stroke(p, col) local s = Instance.new("UIStroke"); s.Color = col or C.line; s.Thickness = 1; s.Parent = p end
 
local gui = Instance.new("ScreenGui")
gui.Name = "RobScriptKey"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = guiParent()
 
local box = Instance.new("Frame")
box.Size = UDim2.fromOffset(340, 210)
box.Position = UDim2.fromScale(0.5, 0.5)
box.AnchorPoint = Vector2.new(0.5, 0.5)
box.BackgroundColor3 = C.bg
box.Parent = gui
corner(box, 14); stroke(box)
 
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(20, 16)
title.Size = UDim2.new(1, -40, 0, 24)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = C.text
title.Text = "RobScript Hub"
title.Parent = box
 
local sub = Instance.new("TextLabel")
sub.BackgroundTransparency = 1
sub.Position = UDim2.fromOffset(20, 42)
sub.Size = UDim2.new(1, -40, 0, 18)
sub.Font = Enum.Font.Gotham
sub.TextSize = 13
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.TextColor3 = C.muted
sub.Text = "Enter the key from robscript.com/robscript-hub"
sub.Parent = box
 
local input = Instance.new("TextBox")
input.Position = UDim2.fromOffset(20, 74)
input.Size = UDim2.new(1, -40, 0, 40)
input.BackgroundColor3 = C.input
input.Font = Enum.Font.Gotham
input.TextSize = 15
input.TextColor3 = C.text
input.PlaceholderText = "Key"
input.PlaceholderColor3 = C.muted
input.Text = ""
input.ClearTextOnFocus = false
input.Parent = box
corner(input, 10); stroke(input)
 
local function button(text, x, w, color)
    local b = Instance.new("TextButton")
    b.Position = UDim2.new(0, x, 0, 128)
    b.Size = UDim2.fromOffset(w, 38)
    b.BackgroundColor3 = color
    b.AutoButtonColor = true
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = C.text
    b.Text = text
    b.Parent = box
    corner(b, 10)
    return b
end
 
local check = button("Check key", 20, 145, C.accent)
local getKey = button("Copy key link", 175, 145, C.input)
stroke(getKey)
 
local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(20, 176)
status.Size = UDim2.new(1, -40, 0, 18)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = C.muted
status.Text = ""
status.Parent = box
 
getKey.MouseButton1Click:Connect(function()
    if typeof(setclipboard) == "function" then
        setclipboard(KEY_PAGE)
        status.TextColor3 = C.ok
        status.Text = "Link copied. Open it in your browser."
    else
        status.TextColor3 = C.muted
        status.Text = KEY_PAGE
    end
end)
 
local function submit()
    local k = (input.Text or ""):gsub("%s+", "")
    if k == REQUIRED_KEY then
        saveKey(k)
        status.TextColor3 = C.ok
        status.Text = "Key accepted. Loading…"
        TweenService:Create(box, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
        task.wait(0.25)
        gui:Destroy()
        runHub()
    else
        status.TextColor3 = C.bad
        status.Text = "Wrong key. Get it on robscript.com/robscript-hub"
    end
end
 
check.MouseButton1Click:Connect(submit)
input.FocusLost:Connect(function(enter) if enter then submit() end end)
 

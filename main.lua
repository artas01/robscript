-- RobScript Hub
-- Open source. Script data comes live from robscript.com, so the hub updates
-- by itself whenever a script page on the site is updated.

local INDEX_URL = "https://robscript.com/wp-content/uploads/robscript-hub/index.json"
local SITE      = "https://robscript.com"

local Players            = game:GetService("Players")
local HttpService        = game:GetService("HttpService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui            = game:GetService("CoreGui")
local player             = Players.LocalPlayer or Players.PlayerAdded:Wait()

if getgenv and getgenv().RobScriptHubLoaded then
    local old = getgenv().RobScriptHubGui
    if old and old.Parent then old:Destroy() end
    for _, c in ipairs(getgenv().RobScriptHubConns or {}) do pcall(function() c:Disconnect() end) end
end

---------------------------------------------------------------------
-- Theme
---------------------------------------------------------------------
local C = {
    bg      = Color3.fromRGB(15, 15, 17),
    panel   = Color3.fromRGB(22, 22, 25),
    card    = Color3.fromRGB(28, 28, 32),
    hover   = Color3.fromRGB(36, 36, 41),
    input   = Color3.fromRGB(32, 32, 36),
    line    = Color3.fromRGB(46, 46, 52),
    text    = Color3.fromRGB(245, 245, 247),
    muted   = Color3.fromRGB(155, 155, 165),
    accent  = Color3.fromRGB(255, 59, 127),
    accent2 = Color3.fromRGB(140, 82, 255),
    ok      = Color3.fromRGB(38, 208, 124),
    warn    = Color3.fromRGB(255, 176, 32),
    bad     = Color3.fromRGB(240, 80, 90),
}
local WHITE     = Color3.new(1, 1, 1)
local FAMILY    = "rbxasset://fonts/families/BuilderSans.json"
local FONT      = Font.new(FAMILY, Enum.FontWeight.Regular)
local FONT_SEMI = Font.new(FAMILY, Enum.FontWeight.SemiBold)
local FONT_BOLD = Font.new(FAMILY, Enum.FontWeight.Bold)

local FAST   = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SPRING = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SHRINK = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local PULSE  = TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
local conns = {}
local function track(c) conns[#conns + 1] = c; return c end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function tween(o, info, props) local t = TweenService:Create(o, info, props); t:Play(); return t end
local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 10) }, p) end
local function stroke(p, col) return new("UIStroke", { Color = col or C.line, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, p) end
local function pad(p, l, r, t, b)
    return new("UIPadding", { PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or l or 0), PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or t or 0) }, p)
end
local function label(props, parent)
    local d = { BackgroundTransparency = 1, FontFace = FONT, TextSize = 14, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd }
    for k, v in pairs(props) do d[k] = v end
    return new("TextLabel", d, parent)
end
-- Pink -> purple gradient. UIGradient only tints its own parent, not children,
-- so text that sits on a gradient lives in a child label.
local function gradient(p, rot)
    return new("UIGradient", { Color = ColorSequence.new(C.accent, C.accent2), Rotation = rot or 45 }, p)
end
-- Soft 9-slice drop shadow; lives inside a transparent holder next to the window.
local function shadow(p)
    return new("ImageLabel", {
        Name = "Shadow", BackgroundTransparency = 1, Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 0.45,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 4), Size = UDim2.new(1, 44, 1, 44), ZIndex = 0,
    }, p)
end
local function focusStroke(box, st)
    box.Focused:Connect(function() tween(st, FAST, { Color = C.accent }) end)
    box.FocusLost:Connect(function() tween(st, FAST, { Color = C.line }) end)
end
local function btn(text, color, parent, w, h, hoverColor)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(w or 70, h or 28), BackgroundColor3 = color, AutoButtonColor = false,
        FontFace = FONT_BOLD, TextSize = 13, TextColor3 = C.text, Text = text,
    }, parent)
    corner(b, 8)
    local sc = new("UIScale", {}, b)
    local hov = hoverColor or color:Lerp(WHITE, 0.08)
    b.MouseEnter:Connect(function() if not b:GetAttribute("busy") then tween(b, FAST, { BackgroundColor3 = hov }) end end)
    b.MouseLeave:Connect(function()
        if not b:GetAttribute("busy") then tween(b, FAST, { BackgroundColor3 = color }) end
        tween(sc, FAST, { Scale = 1 })
    end)
    b.MouseButton1Down:Connect(function() tween(sc, FAST, { Scale = 0.94 }) end)
    b.MouseButton1Up:Connect(function() tween(sc, FAST, { Scale = 1 }) end)
    return b
end
-- Gradient button: returns the button, its text label and its gradient.
local function accentBtn(text, parent, w, h)
    local b = btn("", WHITE, parent, w, h, WHITE)
    local g = gradient(b, 0)
    local t = label({ Text = text, FontFace = FONT_BOLD, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) }, b)
    b.MouseEnter:Connect(function() tween(g, FAST, { Offset = Vector2.new(0.3, 0) }) end)
    b.MouseLeave:Connect(function() tween(g, FAST, { Offset = Vector2.new(0, 0) }) end)
    return b, t, g
end
-- Drag `target` by `handle`. Returns a function telling whether the last press moved it.
local function draggable(handle, target)
    local dragging, start, startPos, moved = false, nil, nil, false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, start, startPos, moved = true, i.Position, target.Position, false
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    track(UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            if d.Magnitude > 4 then moved = true end
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    return function() return moved end
end
-- Rounded game thumbnail with the first letter as a fallback underneath.
local function gameIcon(parent, g, size, r)
    local f = new("Frame", { Size = UDim2.fromOffset(size, size), BackgroundColor3 = C.card }, parent)
    corner(f, r)
    label({ Text = tostring(g.name or "?"):sub(1, 1):upper(), FontFace = FONT_BOLD, TextSize = math.floor(size * 0.5), TextColor3 = C.muted, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) }, f)
    local pid = type(g.places) == "table" and g.places[1]
    if pid then
        local img = new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop, ZIndex = 2,
            Image = "rbxthumb://type=Asset&id=" .. tostring(pid) .. "&w=150&h=150" }, f)
        corner(img, r)
    end
    return f
end
local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" and #res > 0 then return res end
    if typeof(request) == "function" then
        local ok2, r = pcall(request, { Url = url, Method = "GET" })
        if ok2 and r and r.Body then return r.Body end
    end
    return nil
end
local function getJson(url)
    local body = httpGet(url)
    if not body then return nil end
    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    return ok and data or nil
end
local function norm(s)
    return (tostring(s or ""):lower():gsub("%b[]", ""):gsub("%b()", ""):gsub("[^%w]", ""))
end
local function guiParent()
    if typeof(gethui) == "function" then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    if pcall(function() return CoreGui.Name end) then return CoreGui end
    return player:WaitForChild("PlayerGui")
end

---------------------------------------------------------------------
-- Window
---------------------------------------------------------------------
local gui = new("ScreenGui", { Name = "RobScriptHub", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true }, guiParent())
if getgenv then getgenv().RobScriptHubLoaded = true; getgenv().RobScriptHubGui = gui; getgenv().RobScriptHubConns = conns end

local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
local W = math.clamp(vp.X - 24, 340, 660)
local H = math.clamp(vp.Y - 60, 280, 440)
local compact = W < 520

local holder = new("Frame", { Size = UDim2.fromOffset(W, H), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1 }, gui)
local holderScale = new("UIScale", { Scale = 0.85 }, holder)
shadow(holder)
local win = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.bg }, holder)
corner(win, 14); stroke(win)

-- Top bar
local top = new("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1 }, win)
local logo = new("Frame", { Size = UDim2.fromOffset(26, 26), Position = UDim2.fromOffset(14, 11), BackgroundColor3 = WHITE }, top)
corner(logo, 8); gradient(logo)
label({ Text = "R", FontFace = FONT_BOLD, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) }, logo)
label({ Text = "RobScript Hub", FontFace = FONT_BOLD, TextSize = 16, Position = UDim2.fromOffset(48, 0), Size = UDim2.new(0, 120, 1, 0) }, top)
local showHint = UserInputService.KeyboardEnabled and not compact
local gameLabel = label({ Text = "Loading…", TextColor3 = C.muted, TextSize = 13, Position = UDim2.fromOffset(172, 0), Size = UDim2.new(1, showHint and -340 or -250, 1, 0) }, top)
if showHint then
    label({ Text = "RShift to hide", TextColor3 = C.muted, TextTransparency = 0.4, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -170, 0, 0), Size = UDim2.new(0, 90, 1, 0) }, top)
end
local minBtn = btn("–", C.card, top, 28, 28); minBtn.Position = UDim2.new(1, -74, 0, 10); minBtn.TextSize = 18
local closeBtn = btn("×", C.card, top, 28, 28, C.bad); closeBtn.Position = UDim2.new(1, -40, 0, 10); closeBtn.TextSize = 18
new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, 48), BackgroundColor3 = C.line, BorderSizePixel = 0 }, win)
draggable(top, holder)

-- Body: games (left) + scripts (right). On narrow screens one view at a time.
local body = new("Frame", { Size = UDim2.new(1, 0, 1, -49), Position = UDim2.fromOffset(0, 49), BackgroundTransparency = 1 }, win)
local leftW = compact and W or 220
local left = new("Frame", { Size = UDim2.new(0, leftW, 1, 0), BackgroundColor3 = C.panel, BorderSizePixel = 0 }, body)
corner(left, 14)
-- Square off the corners that touch the top bar and the scripts panel
new("Frame", { Size = UDim2.new(1, 0, 0, 14), BackgroundColor3 = C.panel, BorderSizePixel = 0 }, left)
if not compact then
    new("Frame", { Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(1, -14, 0, 0), BackgroundColor3 = C.panel, BorderSizePixel = 0 }, left)
end
local right = new("Frame", { Size = compact and UDim2.new(1, 0, 1, 0) or UDim2.new(1, -leftW, 1, 0), Position = compact and UDim2.new(0, 0, 0, 0) or UDim2.fromOffset(leftW, 0), BackgroundTransparency = 1, Visible = not compact }, body)

local search = new("TextBox", {
    Size = UDim2.new(1, -20, 0, 34), Position = UDim2.fromOffset(10, 10), BackgroundColor3 = C.input,
    FontFace = FONT, TextSize = 14, TextColor3 = C.text, PlaceholderText = "Search games…", PlaceholderColor3 = C.muted,
    Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
}, left)
corner(search, 8); focusStroke(search, stroke(search)); pad(search, 12)

local gameList = new("ScrollingFrame", {
    Size = UDim2.new(1, -10, 1, -56), Position = UDim2.fromOffset(5, 52), BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3, ScrollBarImageColor3 = C.line, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, left)
new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, gameList)
pad(gameList, 5, 5, 0, 6)
local noResults = label({ Text = "Nothing found", TextColor3 = C.muted, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 70), Size = UDim2.new(1, 0, 0, 30), Visible = false }, left)

local header = new("Frame", { Size = UDim2.new(1, -24, 0, 48), Position = UDim2.fromOffset(12, 10), BackgroundTransparency = 1 }, right)
local backBtn = btn("‹ Games", C.card, header, 72); backBtn.Visible = compact; backBtn.Position = UDim2.fromOffset(0, 10)
local hx = compact and 82 or 0
local iconSlot = new("Frame", { Size = UDim2.fromOffset(44, 44), Position = UDim2.fromOffset(hx, 2), BackgroundTransparency = 1, Visible = false }, header)
local tx = hx + 54
local gameTitle = label({ Text = "", FontFace = FONT_BOLD, TextSize = 17, Position = UDim2.fromOffset(tx, 4), Size = UDim2.new(1, -tx - 96, 0, 22) }, header)
local gameMeta = label({ Text = "", TextColor3 = C.muted, TextSize = 12, Position = UDim2.fromOffset(tx, 26), Size = UDim2.new(1, -tx - 96, 0, 18) }, header)
local pageBtn = btn("Copy link", C.card, header, 84); pageBtn.Position = UDim2.new(1, -84, 0, 10); pageBtn.Visible = false

local scriptList = new("ScrollingFrame", {
    Size = UDim2.new(1, -16, 1, -106), Position = UDim2.fromOffset(8, 66), BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3, ScrollBarImageColor3 = C.line, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, right)
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, scriptList)
pad(scriptList, 4, 6, 2, 8)

local statusBar = new("Frame", { Size = UDim2.new(1, -32, 0, 24), Position = UDim2.new(0, 16, 1, -34), BackgroundTransparency = 1 }, right)
local statusDot = new("Frame", { Size = UDim2.fromOffset(6, 6), Position = UDim2.new(0, 0, 0.5, -3), BackgroundColor3 = C.muted, BorderSizePixel = 0, Visible = false }, statusBar)
corner(statusDot, 3)
local statusText = label({ Text = "", TextColor3 = C.muted, TextSize = 12, Position = UDim2.fromOffset(13, 0), Size = UDim2.new(1, -13, 1, 0) }, statusBar)
local function setStatus(t, col)
    t = t or ""
    statusText.Text = t; statusText.TextColor3 = col or C.muted
    statusDot.Visible = t ~= ""; statusDot.BackgroundColor3 = col or C.muted
end

local emptyNote = label({ Text = "Loading games…", TextColor3 = C.muted, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 0.4, 0) }, right)

-- Floating button to reopen (useful on mobile); can be dragged out of the way
local fab = new("TextButton", { Size = UDim2.fromOffset(48, 48), Position = UDim2.new(0, 16, 0.5, -24), BackgroundColor3 = WHITE, AutoButtonColor = false, Text = "", Visible = false }, gui)
corner(fab, 24); gradient(fab)
label({ Text = "RS", FontFace = FONT_BOLD, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) }, fab)
local fabScale = new("UIScale", {}, fab)
local fabMoved = draggable(fab, fab)

local isOpen = true
local function setOpen(open)
    isOpen = open
    if open then
        fab.Visible = false
        holder.Visible = true
        holderScale.Scale = 0.85
        tween(holderScale, SPRING, { Scale = 1 })
    else
        tween(holderScale, SHRINK, { Scale = 0 }).Completed:Connect(function(state)
            if state ~= Enum.PlaybackState.Completed or isOpen then return end
            holder.Visible = false
            fab.Visible = true
            fabScale.Scale = 0
            tween(fabScale, SPRING, { Scale = 1 })
        end)
    end
end
minBtn.MouseButton1Click:Connect(function() setOpen(false) end)
fab.MouseButton1Click:Connect(function() if not fabMoved() then setOpen(true) end end)
closeBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(conns) do c:Disconnect() end
    if getgenv then getgenv().RobScriptHubLoaded = nil end
    tween(holderScale, SHRINK, { Scale = 0 })
    task.delay(0.2, function() gui:Destroy() end)
end)
track(UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightShift and gui.Parent then setOpen(not isOpen) end
end))

local function showScripts(on)
    if not compact then return end
    left.Visible = not on
    right.Visible = on
end
backBtn.MouseButton1Click:Connect(function() showScripts(false) end)

tween(holderScale, SPRING, { Scale = 1 })

---------------------------------------------------------------------
-- Data
---------------------------------------------------------------------
local index = getJson(INDEX_URL)
if not index or type(index.games) ~= "table" then
    gameLabel.Text = "Could not load the script list"
    gameLabel.TextColor3 = C.bad
    emptyNote.Text = "robscript.com is not reachable right now. Try again later."
    right.Visible = true; left.Visible = not compact
    return
end
emptyNote.Text = "Pick a game on the left."

local games = index.games
local detailCache = {}
local selectedRow, currentUrl

local function badge(parent, text, col)
    local b = new("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18), BackgroundColor3 = col, BackgroundTransparency = 0.82,
        FontFace = FONT_BOLD, TextSize = 10, TextColor3 = col, Text = text,
    }, parent)
    corner(b, 6); pad(b, 7)
    return b
end

local function flashText(b, text)
    local back = b.Text
    b.Text = text
    task.delay(1.2, function() if b.Parent then b.Text = back end end)
end

local function copy(text, what, b)
    if typeof(setclipboard) == "function" then
        setclipboard(text); setStatus(what .. " copied.", C.ok)
        if b then flashText(b, "Copied!") end
    else
        setStatus("Your executor cannot copy to clipboard.", C.warn)
    end
end

-- Runs a script; the Execute button itself shows Running / Done / Error.
local function runCode(s, b, txt, g)
    if b:GetAttribute("busy") then return end
    local title = (s.title and s.title ~= "") and s.title or "Script"
    b:SetAttribute("busy", true)
    txt.Text = "Running…"
    setStatus("Running " .. title .. "…")
    local finished = false
    local function finish(ok, e)
        if finished then return end
        finished = true
        if not b.Parent then return end
        g.Enabled = false
        tween(b, FAST, { BackgroundColor3 = ok and C.ok or C.bad })
        txt.Text = ok and "Done" or "Error"
        if ok then setStatus(title .. " started.", C.ok) else setStatus(title .. ": " .. tostring(e):sub(1, 80), C.bad) end
        task.delay(1.6, function()
            if not b.Parent then return end
            b.BackgroundColor3 = WHITE; g.Enabled = true; txt.Text = "Execute"; b:SetAttribute("busy", nil)
        end)
    end
    local fn, err = loadstring(s.code or "")
    if not fn then finish(false, err); return end
    task.spawn(function()
        local ok, e = pcall(fn)
        if finished and not ok then setStatus(title .. ": " .. tostring(e):sub(1, 80), C.bad) end
        finish(ok, e)
    end)
    -- Most scripts keep running forever; treat "no error for a second" as started.
    task.delay(1, function() finish(true) end)
end

local function clearScripts()
    for _, c in ipairs(scriptList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
end

-- Pulsing placeholder cards while a game's scripts are downloading
local function skeletons(n)
    for i = 1, n do
        local f = new("Frame", { Size = UDim2.new(1, 0, 0, 104), BackgroundColor3 = C.card, LayoutOrder = i }, scriptList)
        corner(f, 10); stroke(f)
        for _, sp in ipairs({ { 12, UDim2.new(0.45, 0, 0, 14) }, { 34, UDim2.new(0.3, 0, 0, 12) }, { 54, UDim2.new(0.75, 0, 0, 10) }, { 72, UDim2.fromOffset(90, 22) } }) do
            local bar = new("Frame", { Position = UDim2.fromOffset(12, sp[1]), Size = sp[2], BackgroundColor3 = C.hover, BorderSizePixel = 0 }, f)
            corner(bar, 5)
            tween(bar, PULSE, { BackgroundTransparency = 0.6 })
        end
    end
end

local function scriptCard(s, order)
    local card = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.card, LayoutOrder = order }, scriptList)
    corner(card, 10); pad(card, 14, 14, 12, 12)
    local st = stroke(card)
    card.MouseEnter:Connect(function() tween(st, FAST, { Color = C.accent:Lerp(C.line, 0.55) }); tween(card, FAST, { BackgroundColor3 = C.hover }) end)
    card.MouseLeave:Connect(function() tween(st, FAST, { Color = C.line }); tween(card, FAST, { BackgroundColor3 = C.card }) end)
    new("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, card)

    label({ Text = (s.title and s.title ~= "") and s.title or "Script", FontFace = FONT_BOLD, TextSize = 15, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1 }, card)

    local tags = new("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 2 }, card)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5) }, tags)
    if s.key then badge(tags, "KEY SYSTEM", C.warn) else badge(tags, "NO KEY", C.ok) end
    if s.mobile then badge(tags, "MOBILE", C.muted) end
    if s.pc then badge(tags, "PC", C.muted) end
    if s.status == "partial" then badge(tags, "PARTIAL", C.warn) end

    if type(s.functions) == "table" and #s.functions > 0 then
        local list = {}
        for i = 1, math.min(#s.functions, 5) do list[#list + 1] = s.functions[i] end
        label({ Text = table.concat(list, " · "), TextColor3 = C.muted, TextSize = 13, TextWrapped = true, TextTruncate = Enum.TextTruncate.None, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 3 }, card)
    end
    if s.developer and s.developer ~= "" then
        label({ Text = "by " .. s.developer, TextColor3 = C.muted, TextTransparency = 0.3, TextSize = 12, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 4 }, card)
    end

    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = 5 }, card)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }, row)
    local exec, execText, execGrad = accentBtn("Execute", row, 96, 30)
    exec.MouseButton1Click:Connect(function() runCode(s, exec, execText, execGrad) end)
    local copyBtn = btn("Copy", C.input, row, 70, 30); stroke(copyBtn)
    copyBtn.MouseButton1Click:Connect(function() copy(s.code, "Script", copyBtn) end)
end

local function selectRow(row)
    if selectedRow and selectedRow ~= row then
        selectedRow.Bar.Visible = false
        selectedRow.Title.FontFace = FONT
        tween(selectedRow, FAST, { BackgroundTransparency = 1 })
    end
    selectedRow = row
    if row then
        row.Bar.Visible = true
        row.Title.FontFace = FONT_SEMI
        tween(row, FAST, { BackgroundTransparency = 0 })
    end
end

local openToken = 0
local function openGame(g, row)
    openToken += 1
    local my = openToken
    selectRow(row)
    clearScripts()
    emptyNote.Visible = false
    gameTitle.Text = g.name
    gameMeta.Text = string.format("%d scripts · %d no key · updated %s", g.count or 0, g.nokey or 0, g.updated or "?")
    for _, c in ipairs(iconSlot:GetChildren()) do c:Destroy() end
    gameIcon(iconSlot, g, 44, 10)
    iconSlot.Visible = true
    currentUrl = g.url
    pageBtn.Visible = currentUrl ~= nil
    showScripts(true)
    setStatus("Loading scripts…")
    local d = detailCache[g.id]
    if not d then
        skeletons(3)
        d = getJson((index.base or (SITE .. "/wp-content/uploads/robscript-hub/games/")) .. tostring(g.id) .. ".json")
        if my ~= openToken then return end -- another game was opened meanwhile
        detailCache[g.id] = d
        clearScripts()
    end
    if not d or type(d.scripts) ~= "table" then setStatus("Could not load scripts for this game.", C.bad); return end
    table.sort(d.scripts, function(a, b) if a.key ~= b.key then return not a.key end return false end)
    for i, s in ipairs(d.scripts) do scriptCard(s, i) end
    setStatus(g.low and "Low activity game: some scripts may be outdated." or "", g.low and C.warn or C.muted)
end

pageBtn.MouseButton1Click:Connect(function()
    if currentUrl then copy(currentUrl, "Page link", pageBtn) end
end)

local rows = {}
local function buildList()
    for i, g in ipairs(games) do
        local r = new("TextButton", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.hover, BackgroundTransparency = 1, AutoButtonColor = false, Text = "", LayoutOrder = i }, gameList)
        corner(r, 8)
        local bar = new("Frame", { Name = "Bar", Size = UDim2.fromOffset(3, 16), Position = UDim2.new(0, 0, 0.5, -8), BackgroundColor3 = C.accent, BorderSizePixel = 0, Visible = false }, r)
        corner(bar, 2)
        gameIcon(r, g, 22, 6).Position = UDim2.new(0, 9, 0.5, -11)
        label({ Name = "Title", Text = g.name, Position = UDim2.fromOffset(38, 0), Size = UDim2.new(1, -88, 1, 0) }, r)
        label({ Text = tostring(g.count or ""), TextColor3 = C.muted, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -36, 0, 0), Size = UDim2.fromOffset(28, 34) }, r)
        r.MouseEnter:Connect(function() if r ~= selectedRow then tween(r, FAST, { BackgroundTransparency = 0.5 }) end end)
        r.MouseLeave:Connect(function() if r ~= selectedRow then tween(r, FAST, { BackgroundTransparency = 1 }) end end)
        r.MouseButton1Click:Connect(function() openGame(g, r) end)
        rows[i] = { row = r, key = norm(g.name) }
    end
end
buildList()

search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = norm(search.Text)
    local shown = 0
    for _, it in ipairs(rows) do
        local v = q == "" or it.key:find(q, 1, true) ~= nil
        it.row.Visible = v
        if v then shown += 1 end
    end
    noResults.Visible = shown == 0
end)

---------------------------------------------------------------------
-- Detect current game: by place ID first, then by game name
---------------------------------------------------------------------
local function detect()
    local pid = tostring(game.PlaceId)
    for i, g in ipairs(games) do
        for _, p in ipairs(g.places or {}) do
            if tostring(p) == pid then return g, rows[i].row end
        end
    end
    local info = (function() local ok, r = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end); return ok and r or nil end)()
    local name = info and norm(info.Name) or ""
    if name ~= "" then
        local best, bestRow, bestLen = nil, nil, 0
        for i, g in ipairs(games) do
            local k = rows[i].key
            if #k >= 4 and name:find(k, 1, true) and #k > bestLen then best, bestRow, bestLen = g, rows[i].row, #k end
        end
        if best then return best, bestRow end
    end
    return nil
end

local current, currentRow = detect()
if current then
    gameLabel.Text = "Detected: " .. current.name
    gameLabel.TextColor3 = C.ok
    currentRow.LayoutOrder = -1
    local here = new("Frame", { Size = UDim2.fromOffset(6, 6), Position = UDim2.new(1, -44, 0.5, -3), BackgroundColor3 = C.ok, BorderSizePixel = 0 }, currentRow)
    corner(here, 3)
    openGame(current, currentRow)
else
    gameLabel.Text = string.format("%d games supported", #games)
    if compact then showScripts(false) end
end

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
end

---------------------------------------------------------------------
-- Theme
---------------------------------------------------------------------
local C = {
    bg     = Color3.fromRGB(15, 15, 17),
    panel  = Color3.fromRGB(22, 22, 25),
    card   = Color3.fromRGB(28, 28, 32),
    hover  = Color3.fromRGB(36, 36, 41),
    input  = Color3.fromRGB(32, 32, 36),
    line   = Color3.fromRGB(46, 46, 52),
    text   = Color3.fromRGB(245, 245, 247),
    muted  = Color3.fromRGB(155, 155, 165),
    accent = Color3.fromRGB(255, 59, 127),
    ok     = Color3.fromRGB(38, 208, 124),
    warn   = Color3.fromRGB(255, 176, 32),
    bad    = Color3.fromRGB(240, 80, 90),
}
local FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 10) }, p) end
local function stroke(p, col) return new("UIStroke", { Color = col or C.line, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, p) end
local function pad(p, l, r, t, b)
    return new("UIPadding", { PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or l or 0), PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or t or 0) }, p)
end
local function label(props, parent)
    local d = { BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd }
    for k, v in pairs(props) do d[k] = v end
    return new("TextLabel", d, parent)
end
local function btn(text, color, parent, w)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(w or 70, 28), BackgroundColor3 = color, AutoButtonColor = false,
        Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.text, Text = text,
    }, parent)
    corner(b, 8)
    local base = color
    b.MouseEnter:Connect(function() TweenService:Create(b, FAST, { BackgroundColor3 = base:Lerp(Color3.new(1, 1, 1), 0.08) }):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, FAST, { BackgroundColor3 = base }):Play() end)
    return b
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
if getgenv then getgenv().RobScriptHubLoaded = true; getgenv().RobScriptHubGui = gui end

local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
local W = math.clamp(vp.X - 24, 340, 640)
local H = math.clamp(vp.Y - 60, 280, 420)
local compact = W < 520

local win = new("Frame", { Size = UDim2.fromOffset(W, H), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = C.bg }, gui)
corner(win, 14); stroke(win)

-- Top bar
local top = new("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1 }, win)
local dot = new("Frame", { Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(16, 17), BackgroundColor3 = C.accent }, top)
corner(dot, 5)
label({ Text = "RobScript Hub", Font = Enum.Font.GothamBold, TextSize = 15, Position = UDim2.fromOffset(34, 0), Size = UDim2.new(0, 130, 1, 0) }, top)
local gameLabel = label({ Text = "Loading…", TextColor3 = C.muted, TextSize = 12, Position = UDim2.fromOffset(164, 0), Size = UDim2.new(1, -250, 1, 0) }, top)
local minBtn = btn("–", C.card, top, 28); minBtn.Position = UDim2.new(1, -72, 0, 8); minBtn.TextSize = 16
local closeBtn = btn("×", C.card, top, 28); closeBtn.Position = UDim2.new(1, -38, 0, 8); closeBtn.TextSize = 16
new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 44), BackgroundColor3 = C.line, BorderSizePixel = 0 }, win)

-- Drag
do
    local dragging, start, startPos
    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, start, startPos = true, i.Position, win.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Body: games (left) + scripts (right). On narrow screens one view at a time.
local body = new("Frame", { Size = UDim2.new(1, 0, 1, -45), Position = UDim2.fromOffset(0, 45), BackgroundTransparency = 1 }, win)
local leftW = compact and W or 210
local left = new("Frame", { Size = UDim2.new(0, leftW, 1, 0), BackgroundColor3 = C.panel, BorderSizePixel = 0 }, body)
corner(left, 14)
local right = new("Frame", { Size = compact and UDim2.new(1, 0, 1, 0) or UDim2.new(1, -leftW, 1, 0), Position = compact and UDim2.new(0, 0, 0, 0) or UDim2.fromOffset(leftW, 0), BackgroundTransparency = 1, Visible = not compact }, body)

local search = new("TextBox", {
    Size = UDim2.new(1, -20, 0, 32), Position = UDim2.fromOffset(10, 10), BackgroundColor3 = C.input,
    Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.text, PlaceholderText = "Search games…", PlaceholderColor3 = C.muted,
    Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
}, left)
corner(search, 8); stroke(search); pad(search, 10)

local gameList = new("ScrollingFrame", {
    Size = UDim2.new(1, -10, 1, -52), Position = UDim2.fromOffset(5, 48), BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3, ScrollBarImageColor3 = C.line, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, left)
new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, gameList)
pad(gameList, 5, 5, 0, 6)

local header = new("Frame", { Size = UDim2.new(1, -24, 0, 46), Position = UDim2.fromOffset(12, 8), BackgroundTransparency = 1 }, right)
local backBtn = btn("‹ Games", C.card, header, 70); backBtn.Visible = compact; backBtn.Position = UDim2.fromOffset(0, 9)
local hx = compact and 80 or 0
local gameTitle = label({ Text = "", Font = Enum.Font.GothamBold, TextSize = 16, Position = UDim2.fromOffset(hx, 2), Size = UDim2.new(1, -hx - 90, 0, 22) }, header)
local gameMeta = label({ Text = "", TextColor3 = C.muted, TextSize = 12, Position = UDim2.fromOffset(hx, 24), Size = UDim2.new(1, -hx - 90, 0, 18) }, header)
local pageBtn = btn("Page", C.card, header, 70); pageBtn.Position = UDim2.new(1, -70, 0, 9); pageBtn.Visible = false

local scriptList = new("ScrollingFrame", {
    Size = UDim2.new(1, -16, 1, -96), Position = UDim2.fromOffset(8, 58), BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3, ScrollBarImageColor3 = C.line, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, right)
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, scriptList)
pad(scriptList, 4, 6, 2, 8)

local statusBar = label({ Text = "", TextColor3 = C.muted, TextSize = 12, Position = UDim2.new(0, 16, 1, -32), Size = UDim2.new(1, -32, 0, 24) }, right)
local function setStatus(t, col) statusBar.Text = t or ""; statusBar.TextColor3 = col or C.muted end

local emptyNote = label({ Text = "Pick a game on the left.", TextColor3 = C.muted, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0.4, 0) }, right)

-- Floating button to reopen (useful on mobile)
local fab = btn("RS", C.accent, gui, 44); fab.Size = UDim2.fromOffset(44, 44); fab.Position = UDim2.new(0, 14, 0.5, -22); fab.Visible = false; corner(fab, 22)

local function setOpen(open) win.Visible = open; fab.Visible = not open end
minBtn.MouseButton1Click:Connect(function() setOpen(false) end)
fab.MouseButton1Click:Connect(function() setOpen(true) end)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy(); if getgenv then getgenv().RobScriptHubLoaded = nil end end)
UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightShift and gui.Parent then setOpen(not win.Visible) end
end)

local function showScripts(on)
    if not compact then return end
    left.Visible = not on
    right.Visible = on
end
backBtn.MouseButton1Click:Connect(function() showScripts(false) end)

---------------------------------------------------------------------
-- Data
---------------------------------------------------------------------
local index = getJson(INDEX_URL)
if not index or type(index.games) ~= "table" then
    gameLabel.Text = "Could not load the script list"
    emptyNote.Text = "robscript.com is not reachable right now. Try again later."
    right.Visible = true; left.Visible = not compact
    return
end

local games = index.games
local detailCache = {}
local selectedRow

local function badge(parent, text, col)
    local b = new("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18), BackgroundColor3 = col, BackgroundTransparency = 0.82,
        Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = col, Text = text,
    }, parent)
    corner(b, 6); pad(b, 7)
    return b
end

local function runCode(code, title)
    setStatus("Running " .. title .. "…", C.muted)
    task.spawn(function()
        local fn, err = loadstring(code)
        if not fn then setStatus("Error in " .. title .. ": " .. tostring(err):sub(1, 80), C.bad); return end
        local ok, e = pcall(fn)
        if ok then setStatus(title .. " started.", C.ok) else setStatus(title .. ": " .. tostring(e):sub(1, 80), C.bad) end
    end)
end

local function copy(text, what)
    if typeof(setclipboard) == "function" then
        setclipboard(text); setStatus(what .. " copied.", C.ok)
    else
        setStatus("Your executor cannot copy to clipboard.", C.warn)
    end
end

local function scriptCard(s, order)
    local card = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.card, LayoutOrder = order }, scriptList)
    corner(card, 10); stroke(card); pad(card, 12, 12, 10, 10)
    new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, card)

    label({ Text = s.title ~= "" and s.title or "Script", Font = Enum.Font.GothamBold, TextSize = 14, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1 }, card)

    local tags = new("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 2 }, card)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5) }, tags)
    if s.key then badge(tags, "KEY SYSTEM", C.warn) else badge(tags, "NO KEY", C.ok) end
    if s.mobile then badge(tags, "MOBILE", C.muted) end
    if s.pc then badge(tags, "PC", C.muted) end
    if s.status == "partial" then badge(tags, "PARTIAL", C.warn) end

    if type(s.functions) == "table" and #s.functions > 0 then
        local list = {}
        for i = 1, math.min(#s.functions, 5) do list[#list + 1] = s.functions[i] end
        label({ Text = table.concat(list, " · "), TextColor3 = C.muted, TextSize = 12, TextWrapped = true, TextTruncate = Enum.TextTruncate.None, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 3 }, card)
    end
    if s.developer and s.developer ~= "" then
        label({ Text = "by " .. s.developer, TextColor3 = C.muted, TextSize = 11, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 4 }, card)
    end

    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, LayoutOrder = 5 }, card)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }, row)
    btn("Execute", C.accent, row, 84).MouseButton1Click:Connect(function() runCode(s.code, s.title) end)
    btn("Copy", C.input, row, 64).MouseButton1Click:Connect(function() copy(s.code, "Script") end)
end

local function openGame(g, row)
    if selectedRow then selectedRow.BackgroundTransparency = 1 end
    if row then row.BackgroundTransparency = 0; selectedRow = row end
    for _, c in ipairs(scriptList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    emptyNote.Visible = false
    gameTitle.Text = g.name
    gameMeta.Text = string.format("%d scripts · %d no key · updated %s", g.count or 0, g.nokey or 0, g.updated or "?")
    pageBtn.Visible = true
    showScripts(true)
    setStatus("Loading scripts…")
    local d = detailCache[g.id]
    if not d then
        d = getJson((index.base or (SITE .. "/wp-content/uploads/robscript-hub/games/")) .. tostring(g.id) .. ".json")
        detailCache[g.id] = d
    end
    if not d or type(d.scripts) ~= "table" then setStatus("Could not load scripts for this game.", C.bad); return end
    table.sort(d.scripts, function(a, b) if a.key ~= b.key then return not a.key end return false end)
    for i, s in ipairs(d.scripts) do scriptCard(s, i) end
    setStatus(g.low and "Low activity game: some scripts may be outdated." or "", g.low and C.warn or C.muted)
end

pageBtn.MouseButton1Click:Connect(function()
    local g = selectedRow and selectedRow:GetAttribute("url")
    if g then copy(g, "Page link") end
end)

local rows = {}
local function buildList()
    for i, g in ipairs(games) do
        local r = new("TextButton", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.hover, BackgroundTransparency = 1, AutoButtonColor = false, Text = "", LayoutOrder = i }, gameList)
        corner(r, 7)
        r:SetAttribute("url", g.url)
        label({ Text = g.name, TextSize = 13, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -44, 1, 0) }, r)
        label({ Text = tostring(g.count or ""), TextColor3 = C.muted, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -34, 0, 0), Size = UDim2.fromOffset(26, 30) }, r)
        r.MouseEnter:Connect(function() if r ~= selectedRow then r.BackgroundTransparency = 0.5 end end)
        r.MouseLeave:Connect(function() if r ~= selectedRow then r.BackgroundTransparency = 1 end end)
        r.MouseButton1Click:Connect(function() openGame(g, r) end)
        rows[i] = { row = r, key = norm(g.name) }
    end
end
buildList()

search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = norm(search.Text)
    for _, it in ipairs(rows) do it.row.Visible = q == "" or it.key:find(q, 1, true) ~= nil end
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
    currentRow.LayoutOrder = -1
    openGame(current, currentRow)
else
    gameLabel.Text = string.format("%d games supported", #games)
    if compact then showScripts(false) end
end

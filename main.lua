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
---------
---------------------------------------------------------------------
-- LOAD HUB DATA (embedded, no HTTP)
---------------------------------------------------------------------

local allPages = {
    {
        page_url = "https://robscript.com/",
        slug = "index",
        scripts = {},
    },
    {
        page_url = "https://robscript.com/pulse-hub/",
        slug = "pulse-hub",
        scripts = {},
    },
    {
        page_url = "https://robscript.com/moondiety-hub/",
        slug = "moondiety-hub",
        scripts = {},
    },
    {
        page_url = "https://robscript.com/ns-hub/",
        slug = "ns-hub",
        scripts = {},
    },
    {
        page_url = "https://robscript.com/solix-hub/",
        slug = "solix-hub",
        scripts = {},
    },
    {
        page_url = "https://robscript.com/overflow-hub/",
        slug = "overflow-hub",
        scripts = {},
    },
    {
        page_url = "https://robscript.com/forge-hub/",
        slug = "forge-hub",
        scripts = {},
    },
    {
        page_url = "https://robscript.com/rift-hub/",
        slug = "rift-hub",
        scripts = {},
    },
    {
        page_url = "https://robscript.com/xenith-hub/",
        slug = "xenith-hub",
        scripts = {},
    },
    {
        page_url = "https://robscript.com/neox-hub/",
        slug = "neox-hub",
        scripts = {},
    },
    {
        page_url = "https://robscript.com/blox-fruits-scripts/",
        slug = "blox-fruits-scripts",
        scripts = {
            {
                title = "KEYLESS Cat Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CatsScripts/CatsRobloxScripts/refs/heads/main/loader.luau\"))()",
            },
            {
                title = "NO KEY Nat Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ArdyBotzz/NatHub/refs/heads/master/bf.lua\"))()",
            },
            {
                title = "NO KEY Styxz Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ToshyWare/StyxzHub/main/Styxz.lua\"))()",
            },
            {
                title = "BEST KEYLESS Blox Fruits script – (Speed Hub X)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua\"))()",
            },
            {
                title = "NO KEY Fast Chest Farm",
                has_key = false,
                code = "getgenv().mmb = {\n    setting = {\n        [\"Select Team\"] = \"Marines\", --// Select Pirates Or Marines\n        [\"TweenSpeed\"] = 200,\n        [\"Standing on the water\"] = true,  --// Standing on the water\n        [\"Remove Notify Game\"] = true, --// Turn off game notifications \n        [\"Rejoin When kicked\"] = true, --// Auto rejoin when you get kicked\n        [\"Anti-Afk\"] = true  --// Anti-AFK\n    },\n    ChestSettings = {\n        [\"Esp Chest\"] = true, --// ESP entire Chest        \n        [\"Start Farm Chest\"] = {\n            [\"Enable\"] = true, --// Turn On Farm Chest \n            [\"lock money\"] = 1000000000, --// Amount of Money To Stop\n            [\"Hop After Collected\"] = \"All\" --// Enter The Number of Chests You Want To Pick Up Like \"Number\" or \"All\"\n        },\n        [\"Stop When Have God's Chalice & Fist Of Darkness\"] = { \n            [\"Enable\"] = true, --// Stop when you have God's Chalice & Fist Of Darkness \n            [\"Automatically move to safety\"] = false --// Auto Move To Safe Place When Have Special Items\n        },\n    },\n    RaceCyborg = {\n        [\"Auto get race Cyborg\"] = false,  --// true If You Want Auto Get Cyborg Race\n        [\"Upgrade Race: V2/V3\"] = false  --// ⭐ New\n    },\n    Webhook = {\n        [\"send Webhook\"] = false, --// Send Webhook Auto Setup\n        [\"Url Webhook\"] = \"\", --// Link Url Webhook\n        [\"UserId\"] = \"\" --// Id Discord You\n    }\n}\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/NaruTeam/Abyss/refs/heads/main/AbyssChest.lua\"))()",
            },
            {
                title = "Blox Fruits script – (Fruit finder)",
                has_key = false,
                code = "_G.CatsFruitFinderV4 = {\n    Notify = true,\n    Webhook = \"Webhook REQUIRED\",\n    Mode = \"Teleport Fruit\", -- \"Teleport Fruit\" or \"Tween Fruit\"\n    AutoStore = true,\n    AutoJoinTeam = true,\n    Team = \"Pirates\", -- team to join\n    FruitList = {\n        \"Mammoth\",\n        \"Buddha\",\n        \"Dough\",\n        \"Leopard\",\n        \"Venom\",\n        \"Dragon\",\n        \"Gravity\",\n        \"Rumble\",\n        \"T-Rex\",\n        \"Control\",\n        \"Spirit\",\n        \"Gas\",\n        \"Shadow\",\n        \"Kitsune\",\n        \"West Dragon\",\n        \"East Dragon\" -- add more here if u want \n    },\n}\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/CatsScripts/CatsRobloxScripts/main/CatsBetterFruitFinder.luau?t=\" .. tick()))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
            {
                title = "Mukuro Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/xQuartyx/QuartyzScript/main/Loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/99-nights-in-the-forest-scripts/",
        slug = "99-nights-in-the-forest-scripts",
        scripts = {
            {
                title = "KEYLESS 99 Nights in the Forest script – (FAST HUB)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/adibhub1/99-nighit-in-forest/refs/heads/main/99%20night%20in%20forest\"))()",
            },
            {
                title = "NO KEY Bring Items",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Bac0nHck/Scripts/refs/heads/main/bringitems.lua\"))()",
            },
            {
                title = "Cobra Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Backwoodsix/Cobra.gg-99-nights-in-the-Forrest-FREE-keyless-/refs/heads/main/.lua\", true))()",
            },
            {
                title = "Sapphire Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/KmtjbIBi/raw\", true))()",
            },
            {
                title = "Blessed Hub X",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mynamewendel-ctrl/Blessed-Hub-X-/refs/heads/main/99-Nights-In-Forest.lua\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/yoursvexyyy/VEX-OP/refs/heads/main/99%20nights%20in%20the%20forest\"))()",
            },
            {
                title = "Anon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/sa435125/AnonHub/refs/heads/main/anonhub.lua\"))();",
            },
            {
                title = "Monkey Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MonkeyV2/loader/refs/heads/main/loader.lua\",true))()",
            },
            {
                title = "Starfall hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Severitysvc/Starfall/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "H4xScript hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/H4xScripts/Loader/refs/heads/main/loader.lua\", true))()",
            },
            {
                title = "Overflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OverflowBGSI/Overflow/refs/heads/main/loader.txt\"))()",
            },
            {
                title = "Nexis Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/boringcat4646/Nexis-Hub/main/v2\"))()",
            },
            {
                title = "Stellar Universe",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/5eb08ffffc36b5fc8b948351cbe7b0ad.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/grow-a-garden-scripts/",
        slug = "grow-a-garden-scripts",
        scripts = {
            {
                title = "KEYLESS Grow a Garden script – (Nat Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/GrowaGarden\"))()",
            },
            {
                title = "Mimi Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Jstarzz/Grow-A-Garden/refs/heads/main/source/MimiHub.lua\", true))()",
            },
            {
                title = "Wet Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Night-Hub/WetHubReformed/refs/heads/main/Loadstring\"))()",
            },
            {
                title = "Than Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/thantzy/thanhub/refs/heads/main/thanv1\"))()",
            },
            {
                title = "Crystal Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/thantzy/thanhub/refs/heads/main/thanv1\"))()",
            },
            {
                title = "Lumin Hub",
                has_key = true,
                code = "if identifyexecutor and identifyexecutor():lower():find(\"delta\") then\n    loadstring(game:HttpGet(\"https://lumin-hub.lol/deltaloader.lua\", true))()\nelse\n    loadstring(game:HttpGet(\"https://lumin-hub.lol/loader.lua\", true))()\nend",
            },
            {
                title = "Black Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skibidiking123/Fisch1/refs/heads/main/FischMain\"))()",
            },
            {
                title = "ExploitingIsFun hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://cdn.exploitingis.fun/loader', true))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Monkey Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MonkeyV2/loader/refs/heads/main/loader.lua\",true))()",
            },
            {
                title = "Starfall Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Severitysvc/Starfall/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "Horizon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/fish-it-scripts/",
        slug = "fish-it-scripts",
        scripts = {
            {
                title = "KEYLESS Fish It script – (Polluted Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/b9162d4ef4823b2af2f93664cf9ec393.lua\"))()",
            },
            {
                title = "Poop Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/sylolua/PoopHub/refs/heads/main/Loader\",true))()",
            },
            {
                title = "Aurora Hex",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JScripter-Lua/Aorora_Hex/refs/heads/main/Fish_It.lua\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "AshLabs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=fish-it.lua\", true))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Chiyo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kaisenlmao/loader/refs/heads/main/chiyo.lua\"))()",
            },
            {
                title = "Thunder Hub",
                has_key = true,
                code = "_G.AutoFishing = true\n_G.AutoPerfectCast = true\n_G.AutoSell = true\n_G.EquipBestBait = true\n_G.EquipBestRod = true\n_G.AutoEquipRod = true\n_G.AutoBuyBestBait = true\n_G.AutoBuyBestRod = true\n_G.AutoTP = true\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/NAVAAI098/Thunder-Hub/main/Kaitun.lua\"))()",
            },
            {
                title = "Xperia Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ARMANSYAH112/XperiaHub/main/indexob.lua\"))()",
            },
            {
                title = "Da7Mu Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/f11dec38be134a051fe3de9538f83997b73cdf03d136c10262e62cfe97673ea6/download\"))()",
            },
            {
                title = "Frxser Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/XeFrostz/freetrash/refs/heads/main/Fishit!.lua'))()",
            },
            {
                title = "Space Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ago106/SpaceHub/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Ather Hub",
                has_key = true,
                code = "script_key = \"Add key here to auto verify\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua\"))()",
            },
            {
                title = "Neox Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hassanxzayn-lua/NEOXHUBMAIN/refs/heads/main/loader\", true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/forsaken-scripts/",
        slug = "forsaken-scripts",
        scripts = {
            {
                title = "KEYLESS Forsaken script – (Voidware Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/forsaken.lua\", true))()",
            },
            {
                title = "RX Forsakened",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Redexe19/RXGUIV1/refs/heads/main/RX%20Forsaken/RX_Forsakened\"))()",
            },
            {
                title = "Voidsaken hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/voidsaken-script/Voidsaken-Loader/refs/heads/main/main\"))()",
            },
            {
                title = "NXP Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/fuckg1thub/NeptX/refs/heads/main/NeptZ/Forsaken/source.lua\"))()",
            },
            {
                title = "Funny Hub V2",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/PlutomasterAccount/Funny-Hub/main/Funny%20Hub%20V2\"))()",
            },
            {
                title = "ESP Players",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/PlutomasterAccount/Forsaken-ESP/refs/heads/main/Forsaken%20ESP%20Plutomaster.lua\"))()",
            },
            {
                title = "Rift Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rifton.top/loader.lua\"))()",
            },
            {
                title = "Sasaken Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/ScriptCopilot32/Forsaken/refs/heads/main/Forsakenscript'))()",
            },
            {
                title = "Ringta Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/wefwef127382/forsakenloader.github.io/refs/heads/main/RINGTABUBLIK.lua\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/yoursvexyyy/VEX-OP/refs/heads/main/forsaken%20final\"))()",
            },
            {
                title = "FrostWare Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Snowie3310/Frostware/main/Forsaken.lua\"))()",
            },
            {
                title = "Lumin Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://lumin-hub.lol/loader.lua\",true))()",
            },
            {
                title = "Lazy Devs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://www.lazydevs.site/forsaken.script\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/hunty-zombie-scripts/",
        slug = "hunty-zombie-scripts",
        scripts = {
            {
                title = "KEYLESS Hunty Zombie script – (Polluted Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/7b5caf0fbbd276ba9747f231e47c0b1a.lua\"))()",
            },
            {
                title = "Siffori Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NysaDanielle/loader/refs/heads/main/auth\"))()",
            },
            {
                title = "Nexis Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/boringcat4646/Nexis-Hub/refs/heads/main/Key%20System\"))()",
            },
            {
                title = "Astral Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/PlayzlxD0tmatter/AstralHub/refs/heads/main/AstralHub\"))()",
            },
            {
                title = "yKCelestial Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MajestySkie/list/refs/heads/main/games\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Combo Wick Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "script_key = \"PASTEYOURKEYHERE\"\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Chiyo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kaisenlmao/loader/refs/heads/main/chiyo.lua\"))()",
            },
            {
                title = "Xtreme Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://cdn.authguard.org/virtual-file/836c860722ef4f0db67f5fcf21e13b07\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Chito Hub",
                has_key = true,
                code = "script_key=\"YOUR KEY HERE\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/f506b1e1bf8259b8178f83b65751dcf8.lua\"))()",
            },
            {
                title = "Napoleon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/raydjs/napoleonHub/refs/heads/main/src.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/ink-game-scripts/",
        slug = "ink-game-scripts",
        scripts = {
            {
                title = "KEYLESS Ink Game script – (Ringta Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/wefwef127382/inkgames.github.io/refs/heads/main/ringta.lua\"))()",
            },
            {
                title = "Voidware Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/windinkgame.lua\", true))()",
            },
            {
                title = "FrostWare",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Actualmrp/FWInkGame/refs/heads/main/FrostwareInkGameSource.txt\"))()",
            },
            {
                title = "ExploitingIsFun Hub",
                has_key = true,
                code = "-- make sure to put me in AUTO EXECUTE or else the bypass and emulation will NOT work\n\nloadstring(game:HttpGet('https://raw.githubusercontent.com/ExploitingisFUNN/12312312313/refs/heads/main/ushdfyfeuyetwfge3.lua'))() -- the emulation\ntask.wait(10)\nloadstring(game:HttpGet(\"https://cdn.exploitingis.fun/loader\"))()",
            },
            {
                title = "OwlHook hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/0785b4b8f41683be513badd57f6a71c0.lua\"))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/7d8a2a1a9a562a403b52532e58a14065.lua\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/steal-a-brainrot-scripts/",
        slug = "steal-a-brainrot-scripts",
        scripts = {
            {
                title = "KEYLESS Steal a Brainrot script – (Lemon Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/ffdfeadf0af798741806ea404682a938.lua\"))()",
            },
            {
                title = "FrostWare Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Jake-Brock/Scripts/main/Fw%20SAB.lua\",true))()",
            },
            {
                title = "Ronix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/7d8a2a1a9a562a403b52532e58a14065.lua\"))()",
            },
            {
                title = "Neox Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hassanxzayn-lua/NEOXHUBMAIN/refs/heads/main/StealABrainrot\"))()",
            },
            {
                title = "Overflow Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OverflowBGSI/Overflow/refs/heads/main/loader.txt\"))()",
            },
            {
                title = "Moondiety Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/m00ndiety/99-nights-in-the-forest/refs/heads/main/Main\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Pulsar X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua\"))()",
            },
            {
                title = "Anon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/sa435125/AnonHub/refs/heads/main/anonhub.lua\"))();",
            },
            {
                title = "ComboChronicles Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "KOBEH Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/0904a0ce54d17ca3a7373f417f4666c0ca1b821df3b72ce5a20745aa0fed298c/download\"))()",
            },
            {
                title = "Lumin Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://lumin-hub.lol/loader.lua\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/rivals-scripts/",
        slug = "rivals-scripts",
        scripts = {
            {
                title = "KEYLESS Rivals script – (Lemon Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/c8c09494b048a1fc6a4dc43bec1f3713.lua\"))()",
            },
            {
                title = "Kiciahook Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kiciahook/kiciahook/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Duck Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/HexFG/duckhub/refs/heads/main/loader.lua'))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/solixloader/refs/heads/main/solix%20v2%20new%20loader.lua\"))()",
            },
            {
                title = "Nicky-Byte Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nicky-byte/0212hub/refs/heads/main/main.lua\"))()",
            },
            {
                title = "Nova Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vividx07/nova-softworks/refs/heads/main/loader.lua\",true))()",
            },
            {
                title = "Z3US Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/main.lua\"))()",
            },
            {
                title = "Zenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/LookP/Roblox/refs/heads/main/ZenithHUB%20%7C%20Rivals\"))()",
            },
            {
                title = "Dark Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/25Dark25/Scripts/refs/heads/main/key-script\"))()",
            },
            {
                title = "Instakill hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/jopanegra87dancing/RIVALS/main/main.lua'))()",
            },
            {
                title = "booboo29rampageog",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/booboo29rampageog/RIVALS/main/main.lua'))()",
            },
            {
                title = "Ember Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/scripter66/EmberHub/refs/heads/main/Rivals.lua\"))()",
            },
            {
                title = "W1Ite Game hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/W1lteGameYT/W1lteGame-Hub-Best-Rivals-Aimbot-Script-NO-KEY-/refs/heads/main/script\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-vanguards-scripts/",
        slug = "anime-vanguards-scripts",
        scripts = {
            {
                title = "KEYLESS Anime Vanguards script – (Speed Hub X)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AhmadV99/Script-Games/main/Anime%20Vanguards.lua\"))()",
            },
            {
                title = "NovaPatch Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CHASEAAAA/vanguard/refs/heads/main/.lua\",true))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
            {
                title = "Ather Hub",
                has_key = true,
                code = "--DISCORD please join: https://discord.gg/n86w8P8Evx\n-- FOR SOLARA (ADD THIS, it is a safety measure so disable at your own risk): _G.SkipExecutorBypass = true\nscript_key = \"Add key here to auto verify\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua\"))()",
            },
            {
                title = "Godor Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/godor1010/godor/refs/heads/main/_anime_vanguards'))()",
            },
            {
                title = "Nousigi Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://nousigi.com/loader.lua\"))()",
            },
            {
                title = "Blue Red Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Alexcirer/Alexcirer/refs/heads/main/vs21\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/brainrot-evolution-scripts/",
        slug = "brainrot-evolution-scripts",
        scripts = {
            {
                title = "KEYLESS Brainrot Evolution script – (Banana Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/diepedyt/bui/refs/heads/main/BananaHubLoader.lua\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Space Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ago106/SpaceHub/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "PulsarX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua\"))()",
            },
            {
                title = "Pulse Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Chavels123/Loader/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Sigma Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/d82a88737d4c79e00995ca9384bd098e.lua\"))()",
            },
            {
                title = "Laws Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/LAWSHUB-brainrot-evolution/refs/heads/main/LAWSHUB%20brainrot%20evolution\"))()",
            },
            {
                title = "Nexis Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/holdergit/Key-System/refs/heads/main/Nexis%20Hub\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/drill-digging-simulator-scripts/",
        slug = "drill-digging-simulator-scripts",
        scripts = {
            {
                title = "KEYLESS Drill Digging Simulator script – (Balta Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Baltazarexe/Drill-Digging-Simulator/main/Drill%20Digging%20Simulator.lua\"))()",
            },
            {
                title = "Drill Loop",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/script321321/scripts/main/125723653259639\"))()",
            },
            {
                title = "Tora IsMe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/DrillDigging\"))()",
            },
            {
                title = "Edit Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/editlt/scriptexploot/refs/heads/main/drill_digging_simulator.lua\"))()",
            },
            {
                title = "Digit Hub",
                has_key = false,
                code = "getgenv().AutoGetCash = true\ngetgenv().AutoGotoWin = true\ngetgenv().AutoBuyDrill = true\ngetgenv().AutoBuyPets = false -- very laggy and constantly tries to buy every pet egg\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/sulfu3r/Newer-Pentest-Projects/refs/heads/main/Shit%20Fun%20Projects/Drill%20Digging%20Simulator.luau\"))()",
            },
            {
                title = "PineCodeReborn",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Veyronxs/Drill-Digging-Simulator/refs/heads/main/Keyless\"))()",
            },
            {
                title = "Salvatore hub",
                has_key = false,
                code = "getgenv().AutoGetCash = true\ngetgenv().AutoGotoWin = true\ngetgenv().AutoBuyDrill = true\ngetgenv().AutoBuyPets = false -- very laggy and constantly tries to buy every pet egg\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/sulfu3r/Newer-Pentest-Projects/refs/heads/main/Shit%20Fun%20Projects/Drill%20Digging%20Simulator.luau\"))()",
            },
            {
                title = "Polleser Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Thebestofhack123/2.0/refs/heads/main/Scripts/DDS\", true))()",
            },
            {
                title = "Lumin Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://lumin-hub.lol/loader.lua\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/build-a-zoo-scripts/",
        slug = "build-a-zoo-scripts",
        scripts = {
            {
                title = "KEYLESS Build a Zoo script – (Twvz Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ZhangJunZ84/twvz/refs/heads/main/buildazoo.lua\"))()",
            },
            {
                title = "Zebux Hub",
                has_key = false,
                code = "-- https://discord.gg/ceAb3N7j5n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/ZebuxHub/Main/refs/heads/main/BuildAZoo.lua\"))()",
            },
            {
                title = "Polluted Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/59181ae583fe3b51a97d7d7e769d857e.lua\"))()",
            },
            {
                title = "Elite Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/d787e0d3415663864c515bc513ed4637.lua\"))()",
            },
            {
                title = "Kali Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Salvatore hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "DoDo hub",
                has_key = true,
                code = "script_key=\"put key here\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/a05bf6f6f0615db868a8d25c1f1c67b2.lua\"))()",
            },
            {
                title = "Venuz Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2Kotaro/Venuz-hub/main/Loader.lua'))()",
            },
            {
                title = "Demi Godz Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/4e4eb2403829fcabbc0c14f7dc3657d3.lua\"))()",
            },
            {
                title = "Celestine Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CelestineHub/C-Hub/refs/heads/main/BuildAZoo.lua\"))()",
            },
            {
                title = "Swag Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/IcantAffordSynapse/swaghub/refs/heads/main/swagmain.lua\"))()",
            },
            {
                title = "Peanut X",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TokyoYoo/gga2/refs/heads/main/Trst.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/make-a-army-scripts/",
        slug = "make-a-army-scripts",
        scripts = {
            {
                title = "KEYLESS Make a Army script – (INF money)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/MakeaArmy\"))()",
            },
            {
                title = "MB Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Matej1912/Make-a-Army-/refs/heads/main/Script\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/cut-trees-scripts/",
        slug = "cut-trees-scripts",
        scripts = {
            {
                title = "Cut Trees script – (INF money)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MortyMo22/roblox-scripts/refs/heads/main/Cut%20Trees.lua\"))()",
            },
            {
                title = "ApocScripts",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/uTS1ip5a/raw\"))()",
            },
            {
                title = "INF Money",
                has_key = true,
                code = "script_key=\"yourkey\";\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/ArceusXArchivezx/Game/refs/heads/main/ArceusXArchive\"))()",
            },
            {
                title = "Konglomerate Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Konglomerate/Script/Main/Loader\"))()",
            },
            {
                title = "Rax Scripts",
                has_key = true,
                code = "getgenv().Settings = {\n\tchopFrequency = 1.3, -- how long to wait for every tree to get chopped, make the time a little higher if lag is experienced.\n\tchestESP = true,\n\tautoCollectChests = true,\n    speedboost = 33,\n    jumpboost = 10,\n}\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/raxscripts/LuaUscripts/refs/heads/main/CutTrees.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/azure-latch-scripts/",
        slug = "azure-latch-scripts",
        scripts = {
            {
                title = "KEYLESS Azure Latch script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ghostofcelleron/Celeron/refs/heads/main/Azure%20Latch%20(OS)\",true))()",
            },
            {
                title = "Napoleon Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/raydjs/napoleonHub/refs/heads/main/src.lua\"))()",
            },
            {
                title = "Rinns Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/SkibidiCen/MainMenu/main/Code\"))()",
            },
            {
                title = "Fake Azure Latch Style VFX and Goalbound Style VFX",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/AlperPro/Roblox-Scripts/refs/heads/main/LloydHUBLoader.lua'))()",
            },
            {
                title = "mokaEZF hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/mokaEZF/Ez/refs/heads/main/aura'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pixel-blade-scripts/",
        slug = "pixel-blade-scripts",
        scripts = {
            {
                title = "KEYLESS Pixel Blade script – (Pollute Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/12dcc7533e76814388269888ef9ad402.lua\"))()",
            },
            {
                title = "Kill all and auto room",
                has_key = false,
                code = "toclipboard([[\n    https://discord.gg/bKPRWatprk\n]])\nlocal player = game:GetService(\"Players\").LocalPlayer\nlocal replicatedStorage = game:GetService(\"ReplicatedStorage\")\nlocal runService = game:GetService(\"RunService\")\nlocal roomcheck = false\nlocal autofarm = false\nlocal autoupgrade = false\nlocal killall = false\nlocal library = loadstring(game:HttpGet((\"https://raw.githubusercontent.com/theneutral0ne/wally-modified/refs/heads/main/wally-modified.lua\")))()\nlocal window = library:CreateWindow('Credit: Neutral')\nwindow:Section('Auto Farm')\nwindow:Toggle(\"Auto Farm\",{},function(value)\nautofarm = value\nend)\nwindow:Section('Stuff')\nwindow:Toggle(\"Kill All\",{},function(value)\nkillall = value\nend)\nwindow:Button(\"Remove upgrade ui\",function(value)\nif player.PlayerGui.gameUI.upgradeFrame.Visible then player.PlayerGui.gameUI.upgradeFrame.Visible = false end\nif game.Lighting:FindFirstChild(\"deathBlur\") then game.Lighting.deathBlur:Destroy() end\nif game.Lighting:FindFirstChild(\"screenBlur\") then game.Lighting.screenBlur:Destroy() end\nend)\n\nlocal function room(character)\n    for _,v in workspace:GetDescendants() do\n        if v.ClassName == \"ProximityPrompt\" and v.Enabled then\n            character.HumanoidRootPart.CFrame = v.Parent.CFrame\n            fireproximityprompt(v)\n            task.wait(0.1)\n        end\n    end\n    for _,v in workspace:GetChildren() do   \n        if v:FindFirstChild(\"ExitZone\") then\n            character.HumanoidRootPart.CFrame = v.ExitZone.CFrame\n            task.wait(0.25)\n            character.HumanoidRootPart.CFrame = CFrame.new(v:GetPivot().Position)\n            task.wait(0.25)\n        end\n    end\n    roomcheck = false\nend\n\nrunService.RenderStepped:Connect(function(delta)\n    local character = player.Character\n    if character then\n        if autofarm then\n            if roomcheck == false then\n                roomcheck = true\n                room(character)\n            end\n        end\n        if killall then\n            for _,v in workspace:GetChildren() do   \n                if v:FindFirstChild(\"Humanoid\") or v:FindFirstChildWhichIsA(\"Model\") and v:FindFirstChildWhichIsA(\"Model\"):FindFirstChild(\"Humanoid\") then\n                    if v:GetAttribute(\"hadEntrance\") and v:FindFirstChild(\"Health\") then\n                        replicatedStorage.remotes.useAbility:FireServer(\"tornado\")\n                        replicatedStorage.remotes.abilityHit:FireServer(if v:FindFirstChild(\"Humanoid\") then v:FindFirstChild(\"Humanoid\") else v:FindFirstChildWhichIsA(\"Model\"):FindFirstChild(\"Humanoid\"),math.huge,{[\"stun\"] = {[\"dur\"] = 1}})\n                    end\n                end\n            end\n        end\n    end\nend)",
            },
            {
                title = "TexRBLX Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TexRBLX/Roblox-stuff/refs/heads/main/pixel%20blade/final.lua\"))()",
            },
            {
                title = "Chiyo Hub",
                has_key = true,
                code = "script_key=\"KEY\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/f6694685700f6fb4c09bb09771a50980.lua\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "script_key = \"PASTEYOURKEYHERE\"\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()\n-- https://discord.gg/mbyHbxAhhT\\",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-last-stand-scripts/",
        slug = "anime-last-stand-scripts",
        scripts = {
            {
                title = "Anime Last Stand script – (Imp Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua\"))()",
            },
            {
                title = "Byorl Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Byorl/ALS-Scripts/refs/heads/main/ALS%20Halloween%20UI.lua\"))()",
            },
            {
                title = "Demonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/7Fa0T52n\",true))()",
            },
            {
                title = "Buang Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/buang5516/buanghub/main/BUANGHUB.lua\"))()",
            },
            {
                title = "OMG hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Omgshit/Scripts/main/MainLoader.lua\"))()",
            },
            {
                title = "MoneyMaker BBBG Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://cdn.authguard.org/virtual-file/391e9350aec448aab7ed0c24c07aeb29\"))()",
            },
            {
                title = "Imp Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/jujutsu-seas-scripts/",
        slug = "jujutsu-seas-scripts",
        scripts = {
            {
                title = "Jujutsu Seas script – (Star Stream)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/starstreamowner/StarStream/refs/heads/main/Hub\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/racket-rivals-scripts/",
        slug = "racket-rivals-scripts",
        scripts = {
            {
                title = "Racket Rivals script – (Legend Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/starstreamowner/StarStream/refs/heads/main/Hub\"))()",
            },
            {
                title = "SunoScripting Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/SinoScripting/-OP-Racket-Rivals-AUTOFARM-BOT-Script.-Farm-YEN-while-AFK/refs/heads/main/Sinorackeetering.lua\"))()",
            },
            {
                title = "Karbid Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/karbid-dev/Karbid-Hub-Luna/refs/heads/main/Key_System.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/raise-animals-scripts/",
        slug = "raise-animals-scripts",
        scripts = {
            {
                title = "NO KEY Raise Animals script – (ATG Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Raise-Animals.lua'))()",
            },
            {
                title = "Kron hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/DevKron/Kron_Hub/refs/heads/main/version_1.0'))(u0022u0022)",
            },
            {
                title = "DJ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/3c911e3d1e02d80e890b30bfcda36d5a751d9cba122677fc5a4daee26c8c19f0/download\"))()",
            },
            {
                title = "Dodo hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/dodohubx-rgb/dodohub/refs/heads/main/loader.luau\"))()",
            },
            {
                title = "Onastrollbunch",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/onastrollbunch/Raise-Animals/main/main.lua'))()",
            },
            {
                title = "Onastrollbunch",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ethereon.downy.press/Key-System.lua\"))()",
            },
            {
                title = "Jinx Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/stormskmonkey/JinkX/main/Loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/build-ur-base-scripts/",
        slug = "build-ur-base-scripts",
        scripts = {
            {
                title = "KEYLESS Build ur Base script – (Auto Buy)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Ecohub-1/Ecohub-1/refs/heads/main/bab.lua\"))()",
            },
            {
                title = "Auto Buy tower",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/user75335836/5f8292a553251dae4bd4276e9e7c79bb/raw/431f3225312f0f116f8722c16df0d6f791f2b295/gistfile1.txt\"))()",
            },
            {
                title = "Polluted Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/0f8751b134191b33890f77ac3be49dbc.lua\"))()",
            },
            {
                title = "Circus Auto Menu",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/duydai458/Build-ur-base/refs/heads/main/V1%20event\"))()",
            },
            {
                title = "ApocScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/B0QI1FIJ/raw\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Pulse Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Chavels123/Loader/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "EZ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/murder-mystery-2-scripts/",
        slug = "murder-mystery-2-scripts",
        scripts = {
            {
                title = "KEYLESS Murder Mystery 2 / MM2 script – (MoonWare)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/littl3prince/Moon/main/Moon_V1\"))()",
            },
            {
                title = "Flint MM2 ESP",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Chxnged/2/refs/heads/main/hub.lua\"))()",
            },
            {
                title = "NO KEY Greasy Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/givemealuck1/GreasyScriptsFarm/refs/heads/main/GreasyFarmMM2\"))()",
            },
            {
                title = "Moondiety Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/m00ndiety/Moondiety/refs/heads/main/Loader'))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Koronis Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://koronis.xyz/hub.lua\"))()",
            },
            {
                title = "Monkey Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://monkeyhub.vercel.app/scripts/loader.lua\",true))()",
            },
            {
                title = "Ather Hub",
                has_key = true,
                code = "--DISCORD please join: https://discord.gg/n86w8P8Evx\nscript_key = \"Add key here to auto verify\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/the-strongest-battlegrounds-scripts/",
        slug = "the-strongest-battlegrounds-scripts",
        scripts = {
            {
                title = "KEYLESS The Strongest Battlegrounds script – (Pxntxrez Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Pxntxrez/NULL/refs/heads/main/obfuscated_script-1753991814596.lua\"))()",
            },
            {
                title = "NO KEY XDev Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/XDevHubBeta.lua\"))()",
            },
            {
                title = "NO KEY Phantasm Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/ATrainz/Phantasm/refs/heads/main/Games/TSB.lua'))()",
            },
            {
                title = "Speed Hub X",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua\", true))()",
            },
            {
                title = "D3D Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Noro-ded/TSBMain/refs/heads/main/MAIND3DHUB!\", true))()",
            },
            {
                title = "Kukuri Client",
                has_key = true,
                code = "-- When you execute the script, Wait 4-5 seconds to load\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Mikasuru/Arc/refs/heads/main/Arc.lua\"))()",
            },
            {
                title = "ChillX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/RomaNotgay/ChillX-/main/77_ZZ09N10KL6ZC.lua'))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/xrMu0WE2'))()",
            },
            {
                title = "Nicuse Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://loader.nicuse.xyz\"))()",
            },
            {
                title = "Faldes X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Artss1/Faldes_X/refs/heads/main/Faldes_X%20TSB'))()",
            },
            {
                title = "Return Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/2xrW/return/refs/heads/main/hub\"))()",
            },
            {
                title = "DOWN Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pandadevelopment.net/virtual/file/6b66825b2647d618\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/slap-battles-scripts/",
        slug = "slap-battles-scripts",
        scripts = {
            {
                title = "KEYLESS Slap Battles script – (VinQ Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/vinqDevelops/erwwefqweqewqwe/refs/heads/main/lol.txt'))()",
            },
            {
                title = "NO KEY Get all Badge Gloves",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CatsScripts/CatsRobloxScripts/main/AllBadgeGloves.luau\"))()",
            },
            {
                title = "NO KEY Ultimate Badge Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Pro666Pro/UltimateBadgeHub/main/main.lua'))()",
            },
            {
                title = "FOGOTY Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/FOGOTY/slap-god/main/script\"))()",
            },
            {
                title = "Gooey Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Blobmanner12/GooeyLoader/refs/heads/main/Loader\",true))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "Vault Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Loolybooly/TheVaultScripts/refs/heads/main/FullScript\"))()",
            },
            {
                title = "Islockeddxd hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/islockeddxd/slapbattle/refs/heads/main/main\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/sols-rng-scripts/",
        slug = "sols-rng-scripts",
        scripts = {
            {
                title = "KEYLESS Sols RNG script – (Demonic Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Alan0947383/Demonic-HUB-V2/main/S-C-R-I-P-T.lua\",true))()",
            },
            {
                title = "NO Key Discord Stats Webhook",
                has_key = false,
                code = "_G.WebhookUrl = \"Discord Webhook Url\"\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Celesth/Stellarium/main/roblox/Utility/Protected_1652600242814224.lua.txt\"))()\ntask.wait(1)\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Celesth/Stellarium/main/roblox/SolsRNG/source.luau\"))()\ntask.wait(1)\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Celesth/Stellarium/main/roblox/Utility/PlayerUtils.luau\"))()",
            },
            {
                title = "LegendHandles Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/LHking123456/n4dgW8TF7rNyL/refs/heads/main/Sols'))()",
            },
            {
                title = "HOHO Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/acsu123/HOHO_H/main/Loading_UI\"))()",
            },
            {
                title = "Beecon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/BaconBossScript/BeeconHub/main/BeeconHub\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-rangers-x-scripts/",
        slug = "anime-rangers-x-scripts",
        scripts = {
            {
                title = "KEYLESS Anime Rangers X script – (L-hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Frxser Store",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/XeFrostz/ANM-Ranger-X/refs/heads/main/RangerX.lua'))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "AnimeWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KAJUU490/c9/refs/heads/main/jumapell2\"))()",
            },
            {
                title = "Lix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/loader\"))()",
            },
            {
                title = "Beecon Hub",
                has_key = true,
                code = "script_key=\"YOUR KEY\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/323718949a0352c3f69d25f28c036222.lua\"))()",
            },
            {
                title = "Celestara",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KitsunaCh/Celestara-Hub/refs/heads/main/AnimeRangerX.lua\"))()",
            },
            {
                title = "WSJ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NhatMinhVNQ/nm.wsj/refs/heads/main/WSJ-HUB.TD.lua\"))()",
            },
            {
                title = "Nousigi Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://nousigi.com/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blue-lock-rivals-scripts/",
        slug = "blue-lock-rivals-scripts",
        scripts = {
            {
                title = "KEYLESS Blue Lock Rivals script – (Nevan Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Nevan32/BLUE-LOCK-RIVALS/refs/heads/main/Loader\"))()",
            },
            {
                title = "Ather Hub",
                has_key = true,
                code = "--Discord: https://discord.gg/x4ux7pUVJu\nscript_key = \"Add key here to auto verify\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua\"))()",
            },
            {
                title = "Nexus Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CrazyHub123/NexusHubRevival/refs/heads/main/Main.lua\"))()",
            },
            {
                title = "XZuyaX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/XZuuyaX/XZuyaX-s-Hub/refs/heads/main/Main.Lua\", true))()",
            },
            {
                title = "SOULS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/SPQT6v5J\"))()",
            },
            {
                title = "IMP Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua\"))()",
            },
            {
                title = "Crazy Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/HOKALAZA-BLR/refs/heads/main/BLR%20HOKALAZA\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/evade-scripts/",
        slug = "evade-scripts",
        scripts = {
            {
                title = "KEYLESS Evade script – (Mid-Journey hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JScripter-Lua/Mid-Journey_Open-Source/refs/heads/main/Evade%20Lag%20Free%20Test.lua\"))()",
            },
            {
                title = "CLY",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/9Strew/roblox/main/gamescripts/evade.lua'))()",
            },
            {
                title = "Monkey hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://monkeyhub.vercel.app/scripts/loader.lua\",true))()",
            },
            {
                title = "SpeedHax",
                has_key = true,
                code = "--- Keybind: K\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/thesigmacorex/RobloxScripts/main/speedhax\"))()",
            },
            {
                title = "AussieWIRE",
                has_key = true,
                code = "loadstring(game:HttpGet(request({Url='https://aussie.productions/script'}).Body))()",
            },
            {
                title = "Imp Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua'))()",
            },
            {
                title = "Draconic Hub X",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Nyxarth910/Draconic-Hub-X/refs/heads/main/files/Evade/Overhaul.lua'))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "zReal-King",
                has_key = true,
                code = "pcall(loadstring(game:HttpGet('https://raw.githubusercontent.com/zReal-King/Evade/main/Main.lua')))",
            },
            {
                title = "Nex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CopyReal/NexHub/main/NexHubLoader\", true))()",
            },
            {
                title = "Forbidden Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Robloxhacker3/Forbidden-hub-Evade/refs/heads/main/Overhaul/evade.lua\",true))()",
            },
            {
                title = "Neox Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hassanxzayn-lua/NEOXHUBMAIN/refs/heads/main/loader\", true))()",
            },
            {
                title = "Whakizashi Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/scv8contact-cpu/Whakizashi-hub-x/refs/heads/main/WhakizashiHubX-Evade\"))()",
            },
            {
                title = "Return Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/2xrW/return/refs/heads/main/hub\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/fisch-scripts/",
        slug = "fisch-scripts",
        scripts = {
            {
                title = "KEYLESS Fisch script – (Rip V2 Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/Fisch.lua\"))()",
            },
            {
                title = "Soluna Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://soluna-script.vercel.app/fisch.lua\",true))()",
            },
            {
                title = "Desire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/welomenchaina/Desire-Hub./refs/heads/main/Desire%20Hub%20Fisch%20Script\",true))()",
            },
            {
                title = "Nat Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ArdyBotzz/NatHub/refs/heads/master/NatHub.lua\"))();",
            },
            {
                title = "Polleser Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Thebestofhack123/2.0/refs/heads/main/Scripts/Fisch\", true))()",
            },
            {
                title = "Moma Hub",
                has_key = true,
                code = "(loadstring or load)(game:HttpGet(\"https://raw.githubusercontent.com/n3xkxp3rl/Moma-Hub/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "21 Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://twentyonehub.vercel.app\"))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "Rail Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AZX0OZ/keyrh/refs/heads/main/RAILhub\"))()",
            },
            {
                title = "Fryzer hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/FryzerHub/V/refs/heads/main/Fisch\"))()",
            },
            {
                title = "MadBuk hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Nobody6969696969/Madbuk/refs/heads/main/loader.lua\", true))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/cde8084e2dd57e02d9cd8cb292d44a85.lua\"))()",
            },
            {
                title = "Arceny CC hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://arceney.cc/cdn/loader.luau\"))();",
            },
        },
    },
    {
        page_url = "https://robscript.com/chop-chop-scripts/",
        slug = "chop-chop-scripts",
        scripts = {},
    },
    {
        page_url = "https://robscript.com/anime-eternal-scripts/",
        slug = "anime-eternal-scripts",
        scripts = {
            {
                title = "KEYLESS Anime Eternal script – (AI Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AIHub091/AI-Hub/refs/heads/main/Anime-Eternal/Script.lua\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "NX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NX-Script/Nx_Hub/refs/heads/main/Anime_Eternal\"))()",
            },
            {
                title = "AnimeWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KAJUU490/jumapell/refs/heads/main/new\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Imp Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua\"))()",
            },
            {
                title = "Macarrao Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/rystery/privatehub/refs/heads/main/README.md\"))()",
            },
            {
                title = "Crazy Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/HOKA-ANIME-ETERNAL/refs/heads/main/HOKALAZA\"))()",
            },
            {
                title = "JinkX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/stormskmonkey/JinkX/main/Loader.lua\"))()",
            },
            {
                title = "BAR1S Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/jnsphFRH\"))()",
            },
            {
                title = "Prestine Scripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/PrestineScripts/Loader/refs/heads/main/Main-Loader\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/dungeon-heroes-scripts/",
        slug = "dungeon-heroes-scripts",
        scripts = {
            {
                title = "KEYLESS Dungeon Heroes script – (XTreme Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Xtreme-Hubkink0s/dungeoheros.lua.u/refs/heads/main/script.luau\"))()",
            },
            {
                title = "Valor Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Dungeon%20Heroes/Unified_protected.lua\", true))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Danang Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/9PkSi6nM/raw\"))()",
            },
            {
                title = "Lotus Ware",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/vaEQRglj/raw\"))()",
            },
            {
                title = "Ash Labs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=Dungeon-Heroes.lua\", true))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/Roes/refs/heads/main/her\"))()",
            },
            {
                title = "Dendrite CC",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Dendrite-cc/Dendrite.cc/refs/heads/main/Loader\"))()",
            },
            {
                title = "H4xScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/H4xScripts/Loader/refs/heads/main/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/brookhaven-rp-scripts/",
        slug = "brookhaven-rp-scripts",
        scripts = {
            {
                title = "KEYLESS Brookhaven RP script – (SP Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/as6cd0/SP_Hub/refs/heads/main/Brookhaven\"))()",
            },
            {
                title = "Braxus Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Lindao10/BRUXUS-HUB/refs/heads/main/BRUXUS%20HUB.LUA\"))()",
            },
            {
                title = "RedZ Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/9OoVFBCU/raw\"))()",
            },
            {
                title = "Brookhaven Admin script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/TreeByte403/9bd0c89931954270681c454dd5728c0c/raw/ef264adbaf83486e785d91be748710e3e512938b/brookhaven.lua\"))()",
            },
            {
                title = "Dragon Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/paoplays958-coder/update/refs/heads/main/update\"))()",
            },
            {
                title = "Laws Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/LAWSHUB-brookhaven/refs/heads/main/LAWSHUB%20Brookhaven\"))()",
            },
            {
                title = "Project Santerium",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ProjectSunterium/Project-Sunterium/refs/heads/main/Project%20Sunterium\"))()",
            },
            {
                title = "Salvatore hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RFR-R1CH4RD/Loader/main/Salvatore.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blox-loot-scripts/",
        slug = "blox-loot-scripts",
        scripts = {
            {
                title = "KEYLESS Blox Loot script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://github.com/S1mpleXDev/5-Min-Projects/raw/refs/heads/main/%5BV3%5D%20Blox%20Loot%20part%202\",true))()",
            },
            {
                title = "Tora Is Me",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/BloxLoot\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "LuckyWinner hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MortyMo22/roblox-scripts/refs/heads/main/BloxLoot\"))()",
            },
            {
                title = "Karbid Dev Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/karbid-dev/Karbid-Hub-Luna/refs/heads/main/Key_System.lua\"))()",
            },
            {
                title = "Holdik Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Prarod/bloxloot/refs/heads/main/ffff'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/dont-wake-the-brainrots-scripts/",
        slug = "dont-wake-the-brainrots-scripts",
        scripts = {
            {
                title = "KEYLESS Dont Wake the Brainrots script – Tora IsMe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/DontWaketheBrainrots\"))()",
            },
            {
                title = "Pulse Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Chavels123/Loader/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Sapphire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/uABi7rKf/raw\"))()",
            },
            {
                title = "Pulsar X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua\"))()",
            },
            {
                title = "KarbidDev hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/karbid-dev/Karbid/main/zpp0kogh0t\"))()",
            },
            {
                title = "StarStream hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/tls123account/StarStream/refs/heads/main/Hub\"))()",
            },
            {
                title = "Raxx hub",
                has_key = true,
                code = "getgenv().Settings = {\n    stealThreshold = 100, -- this is the minimum amount a brainrot must generate every second for it to be valid to steal\n\tinstantProximityPrompts = true, -- if true, proximity prompts will be activated instantly\n    speedboost = 33,\n    jumpboost = 12,\n    AutoCollect = true, -- if true, cash will be auto collected\n    AutoCollectInterval = 60, -- how often (in seconds) to auto collect cash\n}\n\nloadstring(game:HttpGet(\"https://pastebin.com/raw/WpkdiWGM\",true))()",
            },
            {
                title = "Crazy Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/DONT-WAKE-THE-BRAINROT-/refs/heads/main/HOKALAZA\"))()",
            },
            {
                title = "Mystrix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ummarxfarooq/mystrix-hub/refs/heads/main/dont%20wake%20the%20brainrots\"))()",
            },
            {
                title = "ATG Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Dont-Wake-the-Brainrots.lua\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-card-clash-scripts/",
        slug = "anime-card-clash-scripts",
        scripts = {
            {
                title = "KEYLESS Anime Card Clash script – Tora IsMe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Threeeps/acc/main/script\"))()",
            },
            {
                title = "Rosel4k",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/rosel4k/scripts/refs/heads/main/AnimeCardClash.lua'))()",
            },
            {
                title = "Hina Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Threeeps/acc/main/script\"))()",
            },
            {
                title = "Ashlabs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=Anime-card-slash.lua\", true))()",
            },
            {
                title = "Grafeno Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TIOXSAN/ANIME-CARD-CLASH/refs/heads/main/scriptAUTO\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/cas/refs/heads/main/h\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/something-evil-will-happen-scripts/",
        slug = "something-evil-will-happen-scripts",
        scripts = {
            {
                title = "KEYLESS something evil will happen script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/exodus-lua/scripts/refs/heads/main/sewhloader.lua\",true))()",
            },
            {
                title = "SEWH Win",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/FOXTROXHACKS/Roblox-Scripts/refs/heads/main/SEWH-Win-AF.lua\"))()",
            },
            {
                title = "SEWH God",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Bac0nHck/Scripts/refs/heads/main/SEWH.lua\"))()",
            },
            {
                title = "ZZZ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/zzxzsss/zxs/refs/heads/main/xxzz\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/adopt-me-scripts/",
        slug = "adopt-me-scripts",
        scripts = {
            {
                title = "KEYLESS Adopt Me script – Ragesploit",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Ragesploit-x/Ragesploit/refs/heads/main/MainScript/ShitVersion.lua\"))();",
            },
            {
                title = "Niburu Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Niburu52/hub/refs/heads/main/Adopt%20Me!'))()",
            },
            {
                title = "billieroblox",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/billieroblox/jimmer/main/77_HAJ07IP.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/jujutsu-shenanigans-scripts/",
        slug = "jujutsu-shenanigans-scripts",
        scripts = {
            {
                title = "KEYLESS Jujutsu Shenanigans script",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/NotEnoughJack/localplayerscripts1/refs/heads/main/script'))()",
            },
            {
                title = "Aimlock",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/egehanqq/JujutsuW.I.P/refs/heads/main/Jujutsu\"))()",
            },
            {
                title = "Custom move set",
                has_key = false,
                code = "--[[\njoin discord server plss\ndiscord.gg/soulshatters\n--]]\ngetgenv().Rain = true\ngetgenv().Move5 = true \ngetgenv().Move6 = true \ngetgenv().Move7 = true\nloadstring(game:HttpGet('https://raw.githubusercontent.com/Reapvitalized/JJS/refs/heads/main/Lindwurm.lua'))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Nexor Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/NexorHub/Games/refs/heads/main/Universal/Scripts.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/hypershot-scripts/",
        slug = "hypershot-scripts",
        scripts = {
            {
                title = "KEYLESS Hypershot script – (XVC Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/XVCHub/Games/main/HyperShot\"))()",
            },
            {
                title = "Danangori hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/danangori/Hypershots/refs/heads/main/V2-2025\"))()",
            },
            {
                title = "Nexis Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/boringcat4646/Nexis-Hub/refs/heads/main/Key%20System\"))()",
            },
            {
                title = "ComboWick Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "Haunt Hub",
                has_key = true,
                code = "local key = 'scriptkey'\n\nshared = shared or {}\nshared.__KEY_INPUT = key\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/n1hitt/haunt.lol/refs/heads/main/rewind\"))(",
            },
        },
    },
    {
        page_url = "https://robscript.com/steal-a-fish-scripts/",
        slug = "steal-a-fish-scripts",
        scripts = {
            {
                title = "KEYLESS Steal A Fish script – (Tora IsMe Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/StealAFish\"))()",
            },
            {
                title = "Combo Wick",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "Klinac Hub",
                has_key = true,
                code = "local code = game:HttpGet(\n    'https://raw.githubusercontent.com/Klinac/scripts/main/steal_a_fish.lua'\n)\nloadstring(code)()",
            },
            {
                title = "Vault Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/pqdZNZJe\"))()",
            },
            {
                title = "Nexis Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/basedgoons/Nexis-Hub-Initial/refs/heads/main/Initial%20Nexis%20Hub%20Redirect\"))()",
            },
            {
                title = "Ash Labs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=steal-a-fish.lua\", true))()",
            },
            {
                title = "Pulsar X hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua\"))()",
            },
            {
                title = "Sapphire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/2aktLkT3/raw\"))()",
            },
            {
                title = "Xenith hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vexalotl/Cybese/refs/heads/main/main\"))()",
            },
            {
                title = "Xenith hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vexalotl/Cybese/refs/heads/main/main\"))()",
            },
            {
                title = "Quniyx Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/a1jPSNuH\"))()",
            },
            {
                title = "Tx3hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://tx3hub.vercel.app/loader\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/plants-vs-brainrots-scripts/",
        slug = "plants-vs-brainrots-scripts",
        scripts = {
            {
                title = "KEYLESS Plants Vs Brainrots script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gitlab.com/r_soft/main/-/raw/main/LoadUB.lua\"))()",
            },
            {
                title = "Dupe",
                has_key = false,
                code = "script_key = \"xx\"\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/fad2e1bf0ec73bd3cca1395400ee4fd0.lua\"))()",
            },
            {
                title = "ED Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Eddy23421/EdHubV4/refs/heads/main/loader\"))()",
            },
            {
                title = "Hokalaza Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/HOKALAZA-plants-vs-brainrot/refs/heads/main/Key\"))()",
            },
            {
                title = "Chiyo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ago106/SpaceHub/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Space Hub",
                has_key = true,
                code = "script_key=\"KEY\";\nloadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/f6694685700f6fb4c09bb09771a50980.lua\"))()",
            },
            {
                title = "Pulse Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Chavels123/Loader/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Tora IsMe Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/PlantsVsBrainrots\"))()",
            },
            {
                title = "Mad Buk Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Nobody6969696969/Madbuk/refs/heads/main/loader.lua\", true))()",
            },
            {
                title = "Solvex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Solvexxxx/Scripts/refs/heads/main/SolvexGUI_PVB.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/case-rolling-rng-scripts/",
        slug = "case-rolling-rng-scripts",
        scripts = {
            {
                title = "KEYLESS Case Rolling RNG script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Case-Rolling-RNG-NEW-Auto-farm-and-auto-open-cases-45044\"))()",
            },
            {
                title = "Autofarm money, Insta open case",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/GomesPT7/Case-Rolling-RNG/refs/heads/main/v1'))()",
            },
            {
                title = "Fast Autofarm money",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MADMONEYDISTRO/feather-hub/refs/heads/main/case%20rng%20remake%20autofarm\"))()",
            },
            {
                title = "Kasumi Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/kasumichwan/scripts/refs/heads/main/kasumi-hub.lua\"))()",
            },
            {
                title = "Arch Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"http://site33927.web1.titanaxe.com/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/steal-a-drawed-brainrot-scripts/",
        slug = "steal-a-drawed-brainrot-scripts",
        scripts = {
            {
                title = "Steal a drawed Brainrot script",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/YA83Gsbs\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/noob-army-tycoon-scripts/",
        slug = "noob-army-tycoon-scripts",
        scripts = {
            {
                title = "MGCactus Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MGCactus/myscripts/main/Noob%20Tycoon%20Army.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pet-simulator-x-scripts/",
        slug = "pet-simulator-x-scripts",
        scripts = {
            {
                title = "KEYLESS Pet Simulator X script – (Rafa Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Rafacasari/roblox-scripts/main/psx.lua\"))()",
            },
            {
                title = "Qwix Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/TSQ-new/QwiX_PSX/main/PSX_SCRIPT'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pet-simulator-99-scripts/",
        slug = "pet-simulator-99-scripts",
        scripts = {
            {
                title = "KEYLESS Pet Simulator 99 script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/PetSimGames\"))()",
            },
            {
                title = "INFINITYWARE",
                has_key = true,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/bubblescripts/scripts/refs/heads/main/PS99/psgo\")()",
            },
            {
                title = "Zap Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://zaphub.xyz/Exec'))()",
            },
            {
                title = "Despise Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RJ077SIUU/PS99/main/Gems\"))()",
            },
            {
                title = "Reaper Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AyoReaper/Reaper-Hub/refs/heads/main/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/da-hood-scripts/",
        slug = "da-hood-scripts",
        scripts = {
            {
                title = "KEYLESS Da Hood script – (Sylex Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bbbbbbbbbbbbbb121/Roblox/refs/heads/main/Sylex\", true))()",
            },
            {
                title = "UDHL Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/sgysh3nka/UDHL/refs/heads/main/UDHL.lua\"))()",
            },
            {
                title = "Camlock / Aimbot",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/HomeMadeScripts/Camlock-aimlock/main/obf_Wxr6QgzF76G1y2Ch77KN4Zt5Nz0A6GIl61gitv3mRR2t3V103al5d0g26s4KY04r.lua.txt\"))()",
            },
            {
                title = "Zinc Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Zinzs/luascripting/main/canyoutellitsadahoodscriptornot.lua\"))()",
            },
            {
                title = "Gots Hub da hood autofarm",
                has_key = true,
                code = "_G.AutofarmSettings = {\n    Fps = 60,\n    AttackMode = 2, -- 1 = Click, 2 = Hold\n    Webhook = '', --webhook for stat logging\n    LogInterval = 15,\n    CustomOffsets = { --atm offsets\n        ['atm12'] = CFrame.new(-2, 0, 0),\n        ['atm13'] = CFrame.new(2, 0, 0),\n    },\n    disableScreen = false --broken rn\n}\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/frvaunted/Main/refs/heads/main/DaHoodAutofarm\", true))()",
            },
            {
                title = "Mango Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/rogelioajax/lua/main/MangoHub\"))()",
            },
            {
                title = "Void Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/coldena/voidhuba/refs/heads/main/voidhubload\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/arsenal-scripts/",
        slug = "arsenal-scripts",
        scripts = {
            {
                title = "KEYLESS Arsenal script – (Lithium Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Sempiller/Lithium/refs/heads/main/main.lua\"))()",
            },
            {
                title = "Vapa v2 hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Nickyangtpe/Vapa-v2/refs/heads/main/Vapav2-Arsenal.lua\", true))()",
            },
            {
                title = "AdvanceTech hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/AdvanceFTeam/Our-Scripts/refs/heads/main/AdvanceTech/Arsenal.lua'))()",
            },
            {
                title = "Weed Client hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ex55/weed-client/refs/heads/main/main.lua\"))()",
            },
            {
                title = "BerTox Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/8ysy7ENG\",true))()",
            },
            {
                title = "Tbao Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/tbao143/thaibao/main/TbaoHubArsenal\"))()",
            },
            {
                title = "Stormware Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/FurkUltra/UltraScripts/main/arsenal\",true))()",
            },
            {
                title = "Unbound hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/samerop/unbound-hub/main/unbound-hub.lua\"))()",
            },
            {
                title = "ReCoded hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vsqzz/Exploits-2025/refs/heads/main/Arsenal.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/build-a-boat-for-treasure-scripts/",
        slug = "build-a-boat-for-treasure-scripts",
        scripts = {
            {
                title = "KEYLESS Build a Boat for Treasure script – (Rolly hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/XRoLLu/UWU/main/BUILD%20A%20BOAT%20FOR%20TREASURE.lua'))()",
            },
            {
                title = "W1lte Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/W1lteGameYT/W1lteGame-Hub-Best-Build-A-Boat-For-Treasure-Gold-Block-Farm-Script/refs/heads/main/script\"))()",
            },
            {
                title = "Just autofarm",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/Lyy77rnr\",true))()",
            },
            {
                title = "Auto Builder",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/max2007killer/auto-build-not-limit/main/buildaboatv2obs.txt\"))()",
            },
            {
                title = "Vikai Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vinxonez/ViKai-HUB/refs/heads/main/babft\"))()",
            },
            {
                title = "ExyXyz hub – Morph characters",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ExyXyz/ExyGantenk/main/ExyBABFT\"))()",
            },
            {
                title = "Rinns hub",
                has_key = true,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/SkibidiCen/MainMenu/main/Code\")()",
            },
            {
                title = "Nov Boat",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/novakoolhub/Scripts/main/Scripts/NovBoatR1\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/prison-life-scripts/",
        slug = "prison-life-scripts",
        scripts = {
            {
                title = "KEYLESS Prison Life script – (PrisonWare)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Denverrz/scripts/master/PRISONWARE_v1.3.txt\"))();",
            },
            {
                title = "Flash Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/scripture2025/FlashHub/refs/heads/main/PrisonLife\"))()",
            },
            {
                title = "Nihilize h4x – Teleports",
                has_key = false,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/QLtH2v8i'))()",
            },
            {
                title = "Lightux Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(('https://raw.githubusercontent.com/rajrsansraowar/Lightux/main/README.md'),true))()",
            },
            {
                title = "Bowser Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/chriszrk/Bowser-Hub/main/BowserHubCool\", true))()",
            },
            {
                title = "Tiger Admin command console",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/APIApple/Main/refs/heads/main/loadstring\"))()",
            },
            {
                title = "PS Admin",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/VYjdEsc5\"))()",
            },
            {
                title = "Void Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/xwH4sux8\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/military-tycoon-scripts/",
        slug = "military-tycoon-scripts",
        scripts = {
            {
                title = "Military Tycoon script – (21 Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://twentyonehub.vercel.app\"))()",
            },
            {
                title = "ArnisRblxYt Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ArnisRblxYt/Aimbot-esp-universal-arnisrblxyt-/refs/heads/main/Aimbot%2C%20esp%20universal%20arnisrblxyt\"))()",
            },
            {
                title = "Lucky Winner Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MortyMo22/roblox-scripts/refs/heads/main/MilitaryTycoon\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/car-dealership-tycoon-scripts/",
        slug = "car-dealership-tycoon-scripts",
        scripts = {
            {
                title = "KEYLESS Car Dealership Tycoon script – (LDS Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/49f02b0d8c1f60207c84ae76e12abc1e.lua'))()",
            },
            {
                title = "Norefrina Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://norepinefrina.com\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/tower-of-hell-scripts/",
        slug = "tower-of-hell-scripts",
        scripts = {
            {
                title = "KEYLESS Tower of Hell script – (Sprin Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/dqvh/dqvh/main/SprinHub\",true))()",
            },
            {
                title = "RB Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/yyeptech/thebighubs/refs/heads/main/toh.lua\"))()",
            },
            {
                title = "Proxima Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TrixAde/Proxima-Hub/main/Main.lua\"))()",
            },
            {
                title = "GHub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bleepis/AJ-HUB/refs/heads/main/main\", true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/dead-rails-scripts/",
        slug = "dead-rails-scripts",
        scripts = {
            {
                title = "KEYLESS Dead Rails script – (Hutao Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Dead-Rails-Alpha-Hutao-hub-FREE-39131\"))()",
            },
            {
                title = "EasyScripts – autofarm bonds",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustKondzio0010/deadrailsbondfarm/refs/heads/main/dead\", true))()",
            },
            {
                title = "Moondiety",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/m00ndiety/Moondiety/refs/heads/main/Loader'))()",
            },
            {
                title = "Neox Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hassanxzayn-lua/NEOXHUBMAIN/refs/heads/main/99NIFT\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "Rift hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rifton.top/loader.lua\"))()",
            },
            {
                title = "Nexor Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/NexorHub/Games/refs/heads/main/Universal/Scripts.lua'))()",
            },
            {
                title = "SpiderX Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/SpiderScriptRB/Dead-Rails-SpiderXHub-Script/refs/heads/main/SpiderXHub%202.0.txt\"))()",
            },
            {
                title = "AussieWire hub",
                has_key = true,
                code = "loadstring(game:HttpGet(request({Url='https://aussie.productions/script'}).Body))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/255ac567ced3dcb9e69aa7e44c423f19.lua\"))()",
            },
            {
                title = "Norepinefrina Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://norepinefrina.com\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/king-legacy-scripts/",
        slug = "king-legacy-scripts",
        scripts = {
            {
                title = "KEYLESS King Legacy script – (Zee Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://zuwz.me/Ls-Zee-Hub-KL'))()",
            },
            {
                title = "Tsuo Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Tsuo7/TsuoHub/main/king%20legacy\"))()",
            },
            {
                title = "Nexor Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/NexorHub/Games/refs/heads/main/Universal/Scripts.lua'))()",
            },
            {
                title = "Fazium Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ZaRdoOx/Fazium-files/main/Loader\"))()",
            },
            {
                title = "Hoho Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/acsu123/HOHO_H/main/Loading_UI'))()",
            },
            {
                title = "Legends Handles Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(('https://pastefy.app/3fQ9psgV/raw'),true))()",
            },
            {
                title = "Hyper Hub",
                has_key = true,
                code = "repeat wait() until game:IsLoaded()\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/DookDekDEE/Hyper/main/script.lua\"))()",
            },
            {
                title = "OMG Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Omgshit/Scripts/refs/heads/main/FarmingFlags\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/work-at-pizza-place-scripts/",
        slug = "work-at-pizza-place-scripts",
        scripts = {
            {
                title = "KEYLESS Work At Pizza Place script – (7Sone)",
                has_key = false,
                code = "loadstring(game:HttpGet(('https://raw.githubusercontent.com/Hm5011/hussain/refs/heads/main/Work%20at%20a%20pizza%20place'),true))()",
            },
            {
                title = "Troll Gui",
                has_key = false,
                code = "loadstring(game:HttpGetAsync(\"https://raw.githubusercontent.com/blueEa1532/thechosenone/refs/heads/main/trollpizzagui\"))()",
            },
            {
                title = "Pizza Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ImARandom44/LoadingGui/refs/heads/main/Source\"))()",
            },
            {
                title = "TRHP Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RobloxHackingProject/HPHub/main/HPHub.lua\"))()",
            },
            {
                title = "Desire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/welomenchaina/Loader/refs/heads/main/ScriptLoader\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/doors-scripts/",
        slug = "doors-scripts",
        scripts = {
            {
                title = "KEYLESS Doors script – (Saturn Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JScripter-Lua/Saturn_Hub_Products/refs/heads/main/Saturn_Hub_Doors.lua\"))()",
            },
            {
                title = "Nullfire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TeamNullFire/NullFire/main/loader.lua\"))()",
            },
            {
                title = "Aussie Wire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/4f5c7bbe546251d81e9d3554b109008f.lua\"))()",
            },
            {
                title = "Horizon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Starfall hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Severitysvc/Starfall/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "tigercubelite830 hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/tigercubelite830/DOORS/main/main.lua'))()",
            },
            {
                title = "Lemon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/yDM1sCp7\"))()",
            },
            {
                title = "Velocity X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://velocityloader.vercel.app/\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/a-universal-time-scripts/",
        slug = "a-universal-time-scripts",
        scripts = {
            {
                title = "KEYLESS A Universal Time script – (Vellure Hub)",
                has_key = false,
                code = "loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/NyxaSylph/Vellure/refs/heads/main/AUT/Main.lua'))()",
            },
            {
                title = "NukeVsCity hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NukeVsCity/Scripts2025/refs/heads/main/AUniversalTim\"))()",
            },
            {
                title = "Star Stream hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/starstreamowner/StarStream/refs/heads/main/Hub\"))()",
            },
            {
                title = "Akatsuki Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AkatsukiHub1/A-Universal-Time/refs/heads/main/README.md\"))()",
            },
            {
                title = "Imp Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/project-slayers-scripts/",
        slug = "project-slayers-scripts",
        scripts = {
            {
                title = "Project Slayers script – (Xenith Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Fire scripts hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Ninja974/Fire-Scripts.github.io/refs/heads/main/loaders/Universal.lua\"))()",
            },
            {
                title = "Cloud hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/cloudman4416/scripts/main/Loader.lua\"), \"Cloudhub\")()",
            },
        },
    },
    {
        page_url = "https://robscript.com/shindo-life-scripts/",
        slug = "shindo-life-scripts",
        scripts = {
            {
                title = "KEYLESS Shindo Life script – (Slash Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://hub.wh1teslash.xyz/.lua\"))()",
            },
            {
                title = "INF Spin",
                has_key = false,
                code = "local Fluent = loadstring(game:HttpGet(\"https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua\"))()\nlocal SaveManager = loadstring(game:HttpGet(\"https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua\"))()\nlocal InterfaceManager = loadstring(game:HttpGet(\"https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua\"))()\n\nlocal Window = Fluent:CreateWindow({\n    Title = \"Infinite Spin - Shindo Life\",\n    SubTitle = \"Auto spin for bloodlines\",\n    TabWidth = 160,\n    Size = UDim2.fromOffset(580, 460),\n    Acrylic = true,\n    Theme = \"Dark\",\n    MinimizeKey = Enum.KeyCode.LeftControl\n})\n\nlocal Tabs = {\n    Main = Window:AddTab({ Title = \"Main\", Icon = \"\" }),\n    Settings = Window:AddTab({ Title = \"Settings\", Icon = \"settings\" })\n}\n\nlocal Options = Fluent.Options\n\n-- Variables\nlocal tpsrv = game:GetService(\"TeleportService\")\nlocal elementwanted = {}\nlocal slots = {\"kg1\", \"kg2\", \"kg3\", \"kg4\"}\nlocal autoSpinEnabled = false\n\n-- Function to get all element names from BossTab\nlocal function getElementNames()\n    local player = game:GetService(\"Players\").LocalPlayer\n    local bossTab = player.PlayerGui.Main.ingame.Menu.BossTab\n    \n    if bossTab then\n        local elements = {}\n        for _, frame in pairs(bossTab:GetChildren()) do\n            if frame:IsA(\"Frame\") and frame.Name then\n                table.insert(elements, frame.Name)\n            end\n        end\n        return elements\n    end\n    return {\"boil\", \"lightning\", \"fire\", \"ice\", \"sand\", \"crystal\", \"explosion\"} -- fallback\nend\n\n-- Function to start auto spin\nlocal function startAutoSpin()\n    print(\"Auto spin started!\")\n    \n    repeat task.wait() until game:isLoaded()\n    repeat task.wait() until game:GetService(\"Players\").LocalPlayer:FindFirstChild(\"startevent\")\n    \n    print(\"Game loaded, starting to spin...\")\n    game:GetService(\"Players\").LocalPlayer.startevent:FireServer(\"band\", \"\\128\")\n    \n    while autoSpinEnabled do\n        task.wait(0.3)\n        \n        print(\"Checking elements and spinning...\")\n        \n        -- Check if we got any desired elements\n        for _, slot in pairs(slots) do\n            if game:GetService(\"Players\").LocalPlayer.statz.main[slot] and game:GetService(\"Players\").LocalPlayer.statz.main[slot].Value then\n                local currentElement = game:GetService(\"Players\").LocalPlayer.statz.main[slot].Value\n                print(\"Current element in \" .. slot .. \": \" .. currentElement)\n                \n                -- Check if this element is wanted\n                local isWanted = false\n                for _, element in pairs(elementwanted) do\n                    if currentElement == element then\n                        isWanted = true\n                        break\n                    end\n                end\n                \n                -- Show notification for each element\n                local wantedText = isWanted and \"WANTED: TRUE\" or \"WANTED: FALSE\"\n                Fluent:Notify({\n                    Title = slot:upper() .. \" Spin Result\",\n                    Content = \"Got: \" .. currentElement .. \" | \" .. wantedText,\n                    Duration = 2\n                })\n                \n                -- If we got what we want, stop and kick\n                if isWanted then\n                    print(\"Got \" .. currentElement .. \" in \" .. slot .. \"!\")\n                    game:GetService(\"Players\").LocalPlayer.startevent:FireServer(\"band\", \"Eye\")\n                    task.wait(1)\n                    game.Players.LocalPlayer:Kick(\"Got \" .. currentElement .. \" in \" .. slot .. \"!\")\n                    return\n                end\n            end\n        end\n        \n        -- Check if any slot has low spins\n        local lowSpins = false\n        if game:GetService(\"Players\").LocalPlayer.statz.spins and game:GetService(\"Players\").LocalPlayer.statz.spins.Value <= 1 then\n            lowSpins = true\n        end\n        \n        if lowSpins then\n            print(\"Low spins detected, teleporting...\")\n            tpsrv:Teleport(game.PlaceId, game.Players.LocalPlayer)\n        end\n        \n        -- Spin all slots\n        print(\"Spinning slots:\", table.concat(slots, \", \"))\n        for _, slot in pairs(slots) do\n            game:GetService(\"Players\").LocalPlayer.startevent:FireServer(\"spin\", slot)\n        end\n    end\n    \n    print(\"Auto spin stopped!\")\nend\n\n-- Function to stop auto spin\nlocal function stopAutoSpin()\n    autoSpinEnabled = false\n    getgenv().atspn = false\n    print(\"Auto spin disabled\")\nend\n\ndo\n    -- Get element names\n    local availableElements = getElementNames()\n    \n    -- Element selection dropdown\n    local ElementDropdown = Tabs.Main:AddDropdown(\"ElementDropdown\", {\n        Title = \"Select Bloodlines\",\n        Description = \"Choose which bloodlines to auto-spin for\",\n        Values = availableElements,\n        Multi = true,\n        Default = {},\n    })\n    \n    ElementDropdown:OnChanged(function(Value)\n        elementwanted = {}\n        for element, state in next, Value do\n            if state then\n                table.insert(elementwanted, element)\n            end\n        end\n        print(\"Selected elements:\", table.concat(elementwanted, \", \"))\n    end)\n    \n    -- Slot selection dropdown\n    local SlotDropdown = Tabs.Main:AddDropdown(\"SlotDropdown\", {\n        Title = \"Select Slots\",\n        Description = \"Choose which slots to spin\",\n        Values = slots,\n        Multi = true,\n        Default = {\"kg1\", \"kg2\"},\n    })\n    \n    SlotDropdown:OnChanged(function(Value)\n        slots = {}\n        for slot, state in next, Value do\n            if state then\n                table.insert(slots, slot)\n            end\n        end\n        print(\"Selected slots:\", table.concat(slots, \", \"))\n    end)\n    \n    -- Auto spin toggle\n    local AutoSpinToggle = Tabs.Main:AddToggle(\"AutoSpinToggle\", {\n        Title = \"Auto Spin\",\n        Description = \"Automatically spin for selected bloodlines\",\n        Default = false\n    })\n    \n    AutoSpinToggle:OnChanged(function()\n        autoSpinEnabled = Options.AutoSpinToggle.Value\n        print(\"Auto spin toggle changed to:\", autoSpinEnabled)\n        \n        if autoSpinEnabled then\n            getgenv().atspn = true\n            Fluent:Notify({\n                Title = \"Auto Spin\",\n                Content = \"Started auto spinning for selected bloodlines\",\n                Duration = 3\n            })\n            task.spawn(startAutoSpin)\n        else\n            stopAutoSpin()\n            Fluent:Notify({\n                Title = \"Auto Spin\",\n                Content = \"Stopped auto spinning\",\n                Duration = 3\n            })\n        end\n    end)\n    \n    -- Manual spin button\n    Tabs.Main:AddButton({\n        Title = \"Manual Spin\",\n        Description = \"Spin once manually\",\n        Callback = function()\n            if game:GetService(\"Players\").LocalPlayer:FindFirstChild(\"startevent\") then\n                for _, slot in pairs(slots) do\n                    game:GetService(\"Players\").LocalPlayer.startevent:FireServer(\"spin\", slot)\n                end\n                Fluent:Notify({\n                    Title = \"Manual Spin\",\n                    Content = \"Spun all selected slots\",\n                    Duration = 2\n                })\n            else\n                Fluent:Notify({\n                    Title = \"Error\",\n                    Content = \"Game not loaded yet\",\n                    Duration = 3\n                })\n            end\n        end\n    })\n    \n    -- Save stats button\n    Tabs.Main:AddButton({\n        Title = \"Save Stats\",\n        Description = \"Save your current stats and progress\",\n        Callback = function()\n            if game:GetService(\"Players\").LocalPlayer:FindFirstChild(\"startevent\") then\n                game:GetService(\"Players\").LocalPlayer.startevent:FireServer(\"band\", \"Eye\")\n                Fluent:Notify({\n                    Title = \"Stats Saved\",\n                    Content = \"Your current stats have been saved!\",\n                    Duration = 3\n                })\n            else\n                Fluent:Notify({\n                    Title = \"Error\",\n                    Content = \"Game not loaded yet\",\n                    Duration = 3\n                })\n            end\n        end\n    })\n    \n    -- Refresh elements button\n    Tabs.Main:AddButton({\n        Title = \"Refresh Elements\",\n        Description = \"Refresh the list of available bloodlines\",\n        Callback = function()\n            local newElements = getElementNames()\n            ElementDropdown:SetValues(newElements)\n            Fluent:Notify({\n                Title = \"Refresh\",\n                Content = \"Updated bloodline list\",\n                Duration = 2\n            })\n        end\n    })\n    \n    -- Status display\n    Tabs.Main:AddParagraph({\n        Title = \"Status\",\n        Content = \"Select your desired bloodlines and slots, then enable auto spin to start farming!\"\n    })\nend\n\n-- Addons setup\nSaveManager:SetLibrary(Fluent)\nInterfaceManager:SetLibrary(Fluent)\nSaveManager:IgnoreThemeSettings()\nSaveManager:SetIgnoreIndexes({})\nInterfaceManager:SetFolder(\"InfiniteSpin\")\nSaveManager:SetFolder(\"InfiniteSpin/shindo-life\")\n\nInterfaceManager:BuildInterfaceSection(Tabs.Settings)\nSaveManager:BuildConfigSection(Tabs.Settings)\n\nWindow:SelectTab(1)\n\nFluent:Notify({\n    Title = \"Infinite Spin\",\n    Content = \"Script loaded successfully! Select your bloodlines and start spinning.\",\n    Duration = 5\n})\n\nSaveManager:LoadAutoloadConfig()",
            },
            {
                title = "Best Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/best-shindo-life-script-lots-of-features_1759797069870_PhV9TdX3Is.txt\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/big-paintball-scripts/",
        slug = "big-paintball-scripts",
        scripts = {
            {
                title = "KEYLESS Big Paintball script – (RealZz Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://realzzhub.xyz/script.lua\"))()",
            },
            {
                title = "Fazium Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ZaRdoOx/Fazium-files/main/Loader\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/big-paintball-2-scripts/",
        slug = "big-paintball-2-scripts",
        scripts = {
            {
                title = "KEYLESS Big Paintball 2 script – (Binary Zero)",
                has_key = false,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/SquidGurr/My-Scripts/refs/heads/main/My%20Keyless%20Big%20Paintball%202%20Script\")()",
            },
            {
                title = "Loop kill all players",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/M1RmQ5pY\", true))()",
            },
            {
                title = "Combo Wick hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "Soluna script hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://soluna-script.vercel.app/big-paintball-2.lua\",true))()",
            },
            {
                title = "Collide hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bozokongy-hash/mastxr/refs/heads/main/collidehub.lua\"))()",
            },
            {
                title = "Piyo script hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/fadhilarrafi/BigPaintball2/refs/heads/main/keysystemobf.lua\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-fight-scripts/",
        slug = "anime-fight-scripts",
        scripts = {
            {
                title = "Anime Fight script – (Multi Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Allanursulino/fight.lua/refs/heads/main/AnimeFight.lua\"))()",
            },
            {
                title = "Cid Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/xsheed/loader/refs/heads/main/mainloader.lua\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/rscripts_obfuscated_op-best-script-auto-farm-auto-trial-auto-tower-and-more_1762468522655_eKtLfz2r6w.txt\",true))()",
            },
            {
                title = "Rebel Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rebelhub.pro/loader\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "Jinkx Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/stormskmonkey/JinkX/main/Loader.lua\"))()",
            },
            {
                title = "Moon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/fcef5e88349466d80f524cc610f4695e69e71d6153048167c52c59ea7e7e4167/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/die-of-death-scripts/",
        slug = "die-of-death-scripts",
        scripts = {
            {
                title = "Die of Death script – (OrionCheatZ hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JScripter-Lua/OrionCheatZ_Script/refs/heads/main/DoD.lua\"))()",
            },
            {
                title = "Nexer Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/DOD/Launcher.luau\"))()",
            },
            {
                title = "RedHead21 hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/RedScripter102/Script/refs/heads/main/Die%20of%20death%20updated\"))()",
            },
            {
                title = "Ethereon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ethereon.downy.press/Key-System.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/attack-on-titan-revolution-scripts/",
        slug = "attack-on-titan-revolution-scripts",
        scripts = {
            {
                title = "Attack on Titan Revolution script – (Napaleon Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/raydjs/napoleonHub/refs/heads/main/src.lua\"))()",
            },
            {
                title = "Tekit Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/705e7fe7aa288f0fe86900cedb1119b1.lua\"))()",
            },
            {
                title = "Best Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/best-free-op-aot-script_1759796822055_cpRaQ4Ogi1.txt\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/flick-scripts/",
        slug = "flick-scripts",
        scripts = {
            {
                title = "Flick script – (Syrex Genesis X)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Joshingtonn123/JoshScript/refs/heads/main/SyrexGenesisXFlick\"))()",
            },
            {
                title = "UNX Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://apigetunx.vercel.app/UNX.lua\",true))()",
            },
            {
                title = "Ed Hub V4",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Eddy23421/EdHubV4/refs/heads/main/loader\"))()",
            },
            {
                title = "OP BEST KEYLESS AIMBOT – (only for PC)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/caae3d70d980245e35f6f4e1bac98c5b.lua\"))()",
            },
            {
                title = "Nobulem Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://nobulem.wtf/loader.lua\"))()",
            },
            {
                title = "Holdik hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/axxciax-alt/aimbots/refs/heads/main/fff'))()",
            },
            {
                title = "Strike Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bozokongy-hash/mastxr/refs/heads/main/Strike.lua\"))()",
            },
            {
                title = "Neversuck hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/trzxasd/neversuck.cc/main/neversuckuniversal.lua\"))()",
            },
            {
                title = "SWEBWARE",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bozokongy-hash/mastxr/refs/heads/main/Flicks.lua\"))()",
            },
            {
                title = "FPS Hacks",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Minirick0-0/FPS-Hacks/refs/heads/main/FPS%20v1.2%20beta'))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
            {
                title = "NisulRocks Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Nisulrocks/FPS-flick/refs/heads/main/main\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/tank-game-scripts/",
        slug = "tank-game-scripts",
        scripts = {
            {
                title = "Tank Game script – (Airflow hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://airflowscript.com/loader\"))()",
            },
            {
                title = "Rax Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/raxscripts/LuaUscripts/refs/heads/main/TankGame.lua'))()",
            },
            {
                title = "Alternative hubd",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/A1ternative-hub/script/refs/heads/main/tu'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/anime-weapons-scripts/",
        slug = "anime-weapons-scripts",
        scripts = {
            {
                title = "Anime Weapons script – (NicS Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nicsssz/AnimeWeapons/refs/heads/main/animeweps\"))()",
            },
            {
                title = "Moon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/fcef5e88349466d80f524cc610f4695e69e71d6153048167c52c59ea7e7e4167/download\"))()",
            },
            {
                title = "Rebel Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rebelhub.pro/loader\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/raft-tycoon-scripts/",
        slug = "raft-tycoon-scripts",
        scripts = {
            {
                title = "Raft Tycoon script – (Tkst Panel)",
                has_key = false,
                code = "-- Raft Tycoon\n\n\n\n\nloadstring(game:HttpGet(\"https://bitbucket.org/tekscripts/tkst/raw/26ecd6809ab1da6c5cd02ca1e88a15e8865459ac/Scripts/raft-survival.lua\"))()",
            },
            {
                title = "2btr hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pandadevelopment.net/virtual/file/9f478aeecd2a3197\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/rebirth-champions-ultimate-scripts/",
        slug = "rebirth-champions-ultimate-scripts",
        scripts = {
            {
                title = "Rebirth Champions: Ultimate script – (Strelizia hub)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/0vma/Strelizia/refs/heads/main/Standalone/RebirthChampionsUltimate.lua', true))()",
            },
            {
                title = "WrapGate hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Amazonek123/ScriptManager/refs/heads/main/RCU.lua\"))()",
            },
            {
                title = "Gandalf Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Gandalf312/RCU-/refs/heads/main/Loader'))()",
            },
            {
                title = "DuckyScripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bigbeanscripts/RCU./refs/heads/main/DuckyScriptz\"))()",
            },
            {
                title = "AshLabs",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ashlabs.me/api/game?name=Rebirth-Champion.lua\", true))()",
            },
            {
                title = "Ketty Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KettyDev/KettyHub/refs/heads/main/KeySystem\"))()",
            },
            {
                title = "Rebel Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/86de6d175e585ef6c1c7f4bdebfc57cc.lua\"))()",
            },
            {
                title = "badscripthub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/d949084ea062c1893d5d0d849c974baf.lua\"))()",
            },
            {
                title = "Devil Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/DEVIL-Script/DEVIL-Hub/main/DEVIL-Hub-Main\", true))()",
            },
            {
                title = "The Intruders hub",
                has_key = true,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/lifaiossama/errors/main/Intruders.html\")()",
            },
        },
    },
    {
        page_url = "https://robscript.com/a-dusty-trip-scripts/",
        slug = "a-dusty-trip-scripts",
        scripts = {
            {
                title = "a dusty trip script – (KGuestCheatsJ Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KGuestCheatsJReal/ComeBack/refs/heads/main/ADustyTripGodMode\"))()",
            },
            {
                title = "Demonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Alan0947383/Demonic-HUB-V2/main/S-C-R-I-P-T.lua\",true))()",
            },
            {
                title = "Tx3Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GamerReady/Tx3HubV2/main/Games/Tx3HubV2\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/heroes-battlegrounds-scripts/",
        slug = "heroes-battlegrounds-scripts",
        scripts = {
            {
                title = "Heroes Battlegrounds script – (Academic Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/solarastuff/hbg/refs/heads/main/academic.lua\"))()",
            },
            {
                title = "Respawn Hub",
                has_key = false,
                code = "loadstring(game:HttpGetAsync(\"https://raw.githubusercontent.com/Yetfmafi/RespawnHub/refs/heads/main/Main\"))()",
            },
            {
                title = "Arc Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/Dan7anaan/2a43ab4365ee1de7aadef9d58800b00f/raw/ffa3d2bb91b9389139dd25ba3f40f33b13cd7fbf/gistfile1.txt\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/basketball-zero-scripts/",
        slug = "basketball-zero-scripts",
        scripts = {
            {
                title = "Basketball Zero script – (Zeke Hub)",
                has_key = true,
                code = "script_key=\"keyhere\" -- script can be bought from the website or discord zekehub.com\nloadstring(game:HttpGet(\"https://zekehub.com/scripts/Loader.lua\"))()",
            },
            {
                title = "sigma script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/0abf22d9dc1307a6cf1a4a17955e312d.lua\"))()",
            },
            {
                title = "roscripts749 (OFTEN BAN YOU)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/roscripts749/loader/refs/heads/main/loader\"))()",
            },
            {
                title = "Rinns hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/e1cfd93b113a79773d93251b61af1e2f.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/dragon-adventures-scripts/",
        slug = "dragon-adventures-scripts",
        scripts = {
            {
                title = "Dragon Adventures script – (IMP Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/jailbreak-scripts/",
        slug = "jailbreak-scripts",
        scripts = {
            {
                title = "Jailbreak script – (OP Autofarm)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/BlitzIsKing/UniversalFarm/main/Loader/Regular\"))()",
            },
            {
                title = "Vylera Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vylerascripts/vylera-scripts/main/VyleraJailBreak.lua\"))()",
            },
            {
                title = "Minirick hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Minirick0-0/FPS-Hacks/refs/heads/main/Auto%20Arrest'))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/driving-empire-scripts/",
        slug = "driving-empire-scripts",
        scripts = {
            {
                title = "Driving Empire script – (Star Stream)",
                has_key = false,
                code = "loadstring(game:HttpGet(request({Url='https://aussie.productions/script'}).Body))()",
            },
            {
                title = "Tora Is Me – (Lego Event farm)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/DrivingEmpireLEGO\"))()",
            },
            {
                title = "RIP Hub",
                has_key = false,
                code = "_G.RedGUI = true\n_G.Theme = \"Dark\" -- Must disable or remove _G.RedGUI to use\n--Themes: Light, Dark, Mocha, Aqua and Jester\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/DrivingEmpire.lua\"))()",
            },
            {
                title = "Vex Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
            {
                title = "Kenniel Scripts hub",
                has_key = true,
                code = "local scriptSource = loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Kenniel123/Driving-Empire/refs/heads/main/Driving%20Empire%20AutoFarm%20Freemium\"))()",
            },
            {
                title = "ComboWICK hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "Vibe Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mamamaisapoo/VibeHubLoader/refs/heads/main/VibeHubLoader.lua\",true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/find-the-brainrot-scripts/",
        slug = "find-the-brainrot-scripts",
        scripts = {
            {
                title = "Find The Brainrot script – (Blade X Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/snipescript/BLADEXUB-FTBDIS/refs/heads/main/bladexhubftbdis\"))()",
            },
            {
                title = "Void Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ksawierprosyt/Void-Hub/refs/heads/main/VoidHubLoader.lua\"))()",
            },
            {
                title = "Peachy Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/d37435894c260e0200d7c0cee1c5a4aea45602edb3ee1fa3c37726e2fe857ad5/download\"))()",
            },
            {
                title = "MB Hub",
                has_key = true,
                code = "--[[\n                                                                                                                    \n                                                                                                bbbbbbbb            \nMMMMMMMM               MMMMMMMMBBBBBBBBBBBBBBBBB        HHHHHHHHH     HHHHHHHHH                 b::::::b            \nM:::::::M             M:::::::MB::::::::::::::::B       H:::::::H     H:::::::H                 b::::::b            \nM::::::::M           M::::::::MB::::::BBBBBB:::::B      H:::::::H     H:::::::H                 b::::::b            \nM:::::::::M         M:::::::::MBB:::::B     B:::::B     HH::::::H     H::::::HH                  b:::::b            \nM::::::::::M       M::::::::::M  B::::B     B:::::B       H:::::H     H:::::H  uuuuuu    uuuuuu  b:::::bbbbbbbbb    \nM:::::::::::M     M:::::::::::M  B::::B     B:::::B       H:::::H     H:::::H  u::::u    u::::u  b::::::::::::::bb  \nM:::::::M::::M   M::::M:::::::M  B::::BBBBBB:::::B        H::::::HHHHH::::::H  u::::u    u::::u  b::::::::::::::::b \nM::::::M M::::M M::::M M::::::M  B:::::::::::::BB         H:::::::::::::::::H  u::::u    u::::u  b:::::bbbbb:::::::b\nM::::::M  M::::M::::M  M::::::M  B::::BBBBBB:::::B        H:::::::::::::::::H  u::::u    u::::u  b:::::b    b::::::b\nM::::::M   M:::::::M   M::::::M  B::::B     B:::::B       H::::::HHHHH::::::H  u::::u    u::::u  b:::::b     b:::::b\nM::::::M    M:::::M    M::::::M  B::::B     B:::::B       H:::::H     H:::::H  u::::u    u::::u  b:::::b     b:::::b\nM::::::M     MMMMM     M::::::M  B::::B     B:::::B       H:::::H     H:::::H  u:::::uuuu:::::u  b:::::b     b:::::b\nM::::::M               M::::::MBB:::::BBBBBB::::::B     HH::::::H     H::::::HHu:::::::::::::::uub:::::bbbbbb::::::b\nM::::::M               M::::::MB:::::::::::::::::B      H:::::::H     H:::::::H u:::::::::::::::ub::::::::::::::::b \nM::::::M               M::::::MB::::::::::::::::B       H:::::::H     H:::::::H  uu::::::::uu:::ub:::::::::::::::b  \nMMMMMMMM               MMMMMMMMBBBBBBBBBBBBBBBBB        HHHHHHHHH     HHHHHHHHH    uuuuuuuu  uuuubbbbbbbbbbbbbbbb   \n                                                                                                                    \n                                                                                                                    \n                                                                                                           \n\t\t\t\t\tJoin our Discord for more scripts! https://discord.gg/KFvcKdCnnj\n                                                    \n\n]]--\n\n\n\n\n\nloadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/864d8fd4295fdb1c497df9ae056404f536cdbf32e87af37378e1ce8175ff7c89/download\"))()",
            },
            {
                title = "MB Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AliframadiRealYT/AS-Hub/refs/heads/main/FindtheBrainrot\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/road-side-shawarma-scripts/",
        slug = "road-side-shawarma-scripts",
        scripts = {
            {
                title = "Road-Side Shawarma script – (sigmatic323)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Hjgyhfyh/Scripts-roblox/refs/heads/main/Road-Side%20Shawarma%20%5BHORROR%5D.txt'))()",
            },
            {
                title = "Vailen Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/xnriu/Roadside-Shawarma/refs/heads/main/Roadside-Shawarma\", true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/build-a-roller-coaster-scripts/",
        slug = "build-a-roller-coaster-scripts",
        scripts = {
            {
                title = "Build a roller coaster script – (Star Stream)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/DjvC9Abi'))()",
            },
            {
                title = "HOKALAZA1 hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/build-a-roller-coaster/refs/heads/main/HOKALAZA\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blockspin-scripts/",
        slug = "blockspin-scripts",
        scripts = {
            {
                title = "BlockSpin script – (Skidware hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/public-account-7/skidware/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "JHub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JHUB2618/JHURBBBBB/refs/heads/main/Jhurbbbb\",true))()",
            },
            {
                title = "Utopia Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Klinac/scripts/main/blockspin.lua\", true))()",
            },
            {
                title = "Utopia Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/xQuartyx/QuartyzScript/main/Loader.lua\"))()",
            },
            {
                title = "Sapphire Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastefy.app/QV8o3bC3/raw'))()",
            },
            {
                title = "Sasware hub",
                has_key = true,
                code = "loadstring(\n    game:HttpGet(\n        \"https://api.sasware.dev/script/Bootstrapper.luau\"\n    )\n)()",
            },
            {
                title = "Zeke hub",
                has_key = true,
                code = "script_key=\"keyhere\" -- script can be bought from the website or discord zekehub.com\nloadstring(game:HttpGet(\"https://zekehub.com/scripts/Loader.lua\"))()",
            },
            {
                title = "Hermanos Dev Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/hermanos-dev/hermanos-hub/refs/heads/main/BlockSpin/blockspin-pvp.lua'))()\nloadstring(game:HttpGet(\"https://zekehub.com/scripts/Loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/violence-district-scripts/",
        slug = "violence-district-scripts",
        scripts = {
            {
                title = "Violence District script – (Anch Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ayamnubchh/Violence-District-Roblox-Script/main/ANCH-Hax.lua\"))()",
            },
            {
                title = "Golds Easy Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Violence-District-Open-Source-fully-auto-generator-script-with-working-ESP-65319\"))()",
            },
            {
                title = "IceWare hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Iceware-RBLX/Roblox/refs/heads/main/loader.lua\",true))()",
            },
            {
                title = "Vgxmod Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VGXMODPLAYER68/Vgxmod-Hub/refs/heads/main/Violence%20District.lua\"))()",
            },
            {
                title = "Solorae Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/skidma/solarae/refs/heads/main/vd.lua\"))()",
            },
            {
                title = "cuddly enigma",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Massivendurchfall/cuddly-enigma/refs/heads/main/ViolenceDistrict\"))()",
            },
            {
                title = "Orion CheatZ Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JScripter-Lua/OrionCheatZ_Script/refs/heads/main/VD_V0.1.lua\"))()",
            },
            {
                title = "77wiki hub",
                has_key = false,
                code = "getgenv().key = \"https://discord.gg/SRG7QTvEuR\"\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/areyourealforme/77wiki/refs/heads/main/violencedistrict.lua\"))()",
            },
            {
                title = "Xenith Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Azed hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/de-ishi/scripts/refs/heads/main/Aze_Loader'))()",
            },
            {
                title = "BAR1S HUB",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/ARRk3iHx/raw\", true))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Ziaan Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://ziaanhub.github.io/ziaanhub.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/the-battle-bricks-scripts/",
        slug = "the-battle-bricks-scripts",
        scripts = {
            {
                title = "The Battle Bricks script – (Legacy Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/96cb4782a308813fba97fb2479e2c08b.lua\"))()",
            },
            {
                title = "TBBScript",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/xdinorun/TBBScript/refs/heads/main/TBBSCRIPT.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/flee-the-facility-scripts/",
        slug = "flee-the-facility-scripts",
        scripts = {
            {
                title = "Flee the Facility script – (UNXHub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Flee-the-Facility-UNXHub-63784\"))()",
            },
            {
                title = "Soluna Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://soluna-script.vercel.app/flee-the-facility.lua\",true))()",
            },
            {
                title = "Kittenhook lua",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/frids56/kittenhookFTF/refs/heads/main/kittenhookFTF.lua\",true))()",
            },
            {
                title = "Arsenal Quest Helper PRO",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/VE95x8bk\"))()",
            },
            {
                title = "FacilityCore",
                has_key = true,
                code = "-- v1.1.0 VERSION [NEW/ 20/10/25]\nloadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/0e6e9cbba1aa11a8b1a649d8d70bb4b1dccb22ce9592430e19ed088e9515d7ec/download\"))()",
            },
            {
                title = "Aussie Wire",
                has_key = true,
                code = "loadstring(game:HttpGet(request({Url='https://aussie.productions/script'}).Body))()",
            },
            {
                title = "RiftWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/02aa64099481d5d1798a9daa820497fa5e0b67b0da8dc05106a0a96fbfa30d49/download\"))()",
            },
            {
                title = "Infinity X Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gitlab.com/Lmy77/menu/-/raw/main/infinityx\"))()",
            },
            {
                title = "Mimi Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Jstarzz/fleethefacility/refs/heads/main/main.lua\", true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/super-league-soccer-scripts/",
        slug = "super-league-soccer-scripts",
        scripts = {
            {
                title = "Super League Soccer script – (Kohler Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Vnadreb/Scripts/refs/heads/main/KohlerHub.txt\"))()",
            },
            {
                title = "Stratum Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Sub2BK/Stratum/refs/heads/Scripts/Stratum_Loader.lua\"))()",
            },
            {
                title = "AnimeWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/KAJUU490/e7/refs/heads/main/kaju\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/3008-scripts/",
        slug = "3008-scripts",
        scripts = {
            {
                title = "3008 script – (Sealient)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Sealient/Sealients-Roblox-Scripts/refs/heads/main/3008-%20UPDATED/3008.lua\"))()",
            },
            {
                title = "NEURON Hub",
                has_key = false,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/Yumiara/Python/refs/heads/main/SCP3008.py\")()",
            },
            {
                title = "Sky Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub/main/SkyHub.txt\"))()",
            },
            {
                title = "Zeerox Hub",
                has_key = false,
                code = "loadstring(game:HttpGet'https://raw.githubusercontent.com/RunDTM/ZeeroxHub/main/Loader.lua')()",
            },
            {
                title = "Frag CC Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GabiPizdosu/MyScripts/refs/heads/main/Loader.lua\",true))()",
            },
            {
                title = "Void Path",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/voidpathhub/VoidPath/refs/heads/main/VoidPath.luau\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/grand-piece-online-scripts/",
        slug = "grand-piece-online-scripts",
        scripts = {
            {
                title = "Grand Piece Online script – (0 to 625 Level)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/2dfd72b15d037b59003d65961e663033.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/murderers-vs-sheriffs-duels-scripts/",
        slug = "murderers-vs-sheriffs-duels-scripts",
        scripts = {
            {
                title = "Murderers VS Sheriffs DUELS script – (Wicik Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Wic1k/Scripts/refs/heads/main/mvsd.txt\"))()",
            },
            {
                title = "Le Honk",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/niclaspoopy123/Mvsd-scripts/refs/heads/main/Main%20script\"))()",
            },
            {
                title = "Tbao Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/tbao143/thaibao/main/TbaoHubMurdervssheriff\"))()",
            },
            {
                title = "CHub",
                has_key = true,
                code = "_G.ScKo = \"CMVSD\"\nloadstring(game:HttpGet('https://raw.githubusercontent.com/CatRoman05/CScripts/refs/heads/master/CHub/keysistem.lua'))()",
            },
            {
                title = "Why Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustLuaDeveloper/WhyHub/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "ByteCore",
                has_key = true,
                code = "loadstring(game:HttpGetAsync(\"https://raw.githubusercontent.com/lelo0002/byte/refs/heads/main/1.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/fling-things-and-people-scripts/",
        slug = "fling-things-and-people-scripts",
        scripts = {
            {
                title = "Fling Things and People script – (Xarvok Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/lolwsg/f7addd848006471806f31592e0a27336/raw/9f42e2d0db75cf99b46ea10eb3ecdf98876cdbcd/fling\", true))()",
            },
            {
                title = "Flades Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Artss1/Flades_Hub/refs/heads/main/We%20Are%20Arts.lua\"))()",
            },
            {
                title = "Brovaky Hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Brovaky/Friendly/refs/heads/main/Friendly'))()",
            },
            {
                title = "Name Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NameHubScript/_/refs/heads/main/f\"))()",
            },
            {
                title = "R Scripter",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/example-prog/FLING-THINGS-AND-PEOPLE/refs/heads/main/Flingthingsandpeoplescript\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/emergency-hamburg-scripts/",
        slug = "emergency-hamburg-scripts",
        scripts = {
            {
                title = "Emergency Hamburg script – (Luma Core)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/PZdRiTeS\"))()",
            },
            {
                title = "Beanz Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://beanzz.wtf/Main.lua\"))()",
            },
            {
                title = "DP Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/COOLXPLO/DP-HUB-coolxplo/refs/heads/main/EH.lua\"))()",
            },
            {
                title = "ASERVICE HUB",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/aservice-dev/aservice/refs/heads/main/mainscript.lua\"))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://airflowscript.com/loader\"))()",
            },
            {
                title = "Trixo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://gist.githubusercontent.com/timprime837-sys/cc1a207296b12dc269568938421ab1fa/raw/6821cce97694518025c521531dca09f5d39680ec/Trixov10'))()",
            },
            {
                title = "Dark x Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(('https://raw.githubusercontent.com/Merdooon/skibidi-sigma-spec-ter/refs/heads/main/specter')))()",
            },
            {
                title = "Ethereon Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/136e9ef07454c3b3977dbbe6615e1531c53d3d22d8b942d91c047cca0c1ebcec/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/squid-game-x-scripts/",
        slug = "squid-game-x-scripts",
        scripts = {
            {
                title = "Squid Game X script – (RIP V2)",
                has_key = false,
                code = "_G.Theme = \"Dark\"\n--Themes: Light, Dark, Red, Mocha, Aqua and Jester\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/SquidGameX.lua\"))()",
            },
            {
                title = "KaiXar",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/madenciicom/squidgamex/refs/heads/main/SquidGameX_KaiXar.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/creatures-of-sonaria-scripts/",
        slug = "creatures-of-sonaria-scripts",
        scripts = {
            {
                title = "Creatures of Sonaria script – (Lunar Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Mangnex/Lunar-Hub/refs/heads/main/FreeLoader.lua\"))()",
            },
            {
                title = "Gold Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://getgold.cc\"))()",
            },
            {
                title = "manthem123 hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/manthem123/cos/main/main.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pls-donate-scripts/",
        slug = "pls-donate-scripts",
        scripts = {
            {
                title = "PLS donate script – (szze hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/1f0yt/community/main/tzechco\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/realistic-street-soccer-scripts/",
        slug = "realistic-street-soccer-scripts",
        scripts = {
            {
                title = "Realistic Street Soccer script – (Verbal hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VerbalHubz/Verbal-Hub/refs/heads/main/Realistic%20Street%20Soccer%20Op%20Script\",true))()",
            },
            {
                title = "CatHook",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ZfpsGT1030/RealisticStreetSoccer/refs/heads/main/orbit167_69325\"))()",
            },
            {
                title = "Flash Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Gandalf312/RSS/refs/heads/main/RSS'))()",
            },
            {
                title = "971 Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/971amer7514/971/refs/heads/main/Realistic%20Street%20Soccer'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pull-a-sword-scripts/",
        slug = "pull-a-sword-scripts",
        scripts = {
            {
                title = "Pull a Sword script – (Why Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/JustLuaDeveloper/WhyHub/refs/heads/main/Loader.lua\"))()",
            },
            {
                title = "Nisulrocks Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Nisulrocks/Pull-a-Sword/refs/heads/main/main\"))()",
            },
            {
                title = "Wicik hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Wic1k/Scripts/refs/heads/main/PaS.txt\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/weak-legacy-2-scripts/",
        slug = "weak-legacy-2-scripts",
        scripts = {
            {
                title = "Weak Legacy 2 script – (MjContegaZXC)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/MjContiga1/29251405031a0d94caddfe4bf86714ba/raw/57b8f2f065592905e08d30eb6b82a190232dfb52/Weak%2520legacy%25202.lua\"))()",
            },
            {
                title = "The Intruders hub",
                has_key = true,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/lifaiossama/errors/main/Intruders.html\")()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Rebel Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/CrazyHub123/NexusHubMain/main/Main.lua\", true))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Pulsar X",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua\"))()",
            },
            {
                title = "Aeonic Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mazino45/main/refs/heads/main/MainScript.lua\"))()",
            },
            {
                title = "DEFENDERS & BAR1S",
                has_key = true,
                code = "loadstring(game:HttpGet('https://pastebin.com/raw/43SgS9St'))()",
            },
            {
                title = "ASSKIEN hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/5c73617e905f5924eb942ccf0119625b.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/brainrot-royale-scripts/",
        slug = "brainrot-royale-scripts",
        scripts = {
            {
                title = "Brainrot Royale script – (EAC Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/rscripts_obfuscated_keyless-brainrot-royale-auto-farm-or-eacscripts_1763490799592_6BD8t3pNOE.txt\",true))()",
            },
            {
                title = "ArthurBrenno",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/MAMZZAPN\"))()",
            },
            {
                title = "Void Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/coldena/voidhuba/refs/heads/main/voidhubload\",true))()",
            },
            {
                title = "Hokalaza hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hehehe9028/HOKA/refs/heads/main/Brainrot%20royale\"))()",
            },
            {
                title = "Senpai Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Senpai1997/Scripts/refs/heads/main/SenpaiHubBrainrotRoyaleAutoKillAll.lua\"))()",
            },
            {
                title = "Alternative hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/A1ternative-hub/script/refs/heads/main/tu'))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://airflowscript.com/loader\"))()",
            },
            {
                title = "EZ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/prospecting-scripts/",
        slug = "prospecting-scripts",
        scripts = {
            {
                title = "Prospecting script – (Synthora Hub)",
                has_key = false,
                code = "getgenv().WebHook = \"\"\ngetgenv().MakeConfig = true\ngetgenv().ConfigName = \"Config\"\ngetgenv().LoadConfig = true\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Wenarch/Library/refs/heads/main/Script\"))()",
            },
            {
                title = "Four Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/Prospecting.lua\",true))()",
            },
            {
                title = "Pxntxrez Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Pxntxrez/NULL/refs/heads/main/obfuscated_script-1753991814596.lua\"))()",
            },
            {
                title = "Tora IsMe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/Prospecting\"))()",
            },
            {
                title = "EZ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download\"))()",
            },
            {
                title = "Combo Wick",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ'))();",
            },
            {
                title = "Peanut X",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TokyoYoo/gga2/refs/heads/main/Trst.lua\"))()",
            },
            {
                title = "ZZZ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/zzxzsss/zxs/refs/heads/main/xxzz\"))()",
            },
            {
                title = "Nythera V3 Hub",
                has_key = true,
                code = "loadstring(\n    game:HttpGet(\n        'https://raw.githubusercontent.com/Sicalelak/Sicalelak/refs/heads/main/Prospecting'\n    )\n)()",
            },
            {
                title = "Doit Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/DOITZ9/game/refs/heads/main/Prospecting.luau\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/InOne/refs/heads/main/kei\"))()",
            },
            {
                title = "Space Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/ago106/SpaceHub/refs/heads/main/loader.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/core-factory-scripts/",
        slug = "core-factory-scripts",
        scripts = {
            {
                title = "Demonalt Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastefy.app/WbzpDQCP/raw\", true))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/crop-incremental-scripts/",
        slug = "crop-incremental-scripts",
        scripts = {
            {
                title = "Crop Incremental script – (KEYLESS)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/alr272062-collab/Crop-incremental/refs/heads/main/Crop%20incremental\")) ();",
            },
            {
                title = "ChimeraGaming",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://rscripts.net/raw/free-token-collector-fixed-october-22-open-source_1761168105543_hI2X6RwlkC.txt\",true))()",
            },
            {
                title = "Premium Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/rp7qBjfS\"))()",
            },
            {
                title = "Premium Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/rp7qBjfS\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/draw-donate-scripts/",
        slug = "draw-donate-scripts",
        scripts = {
            {
                title = "Draw & Donate script – (Image to Roblox)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/0o4o/image-converter/refs/heads/main/pixelporter\"))()",
            },
            {
                title = "7r6ik",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/eb46b9dafc8cd9bfae487791b4810720fa372387d9f6663beae48af9af924b57/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/pet-quest-scripts/",
        slug = "pet-quest-scripts",
        scripts = {
            {
                title = "Pet Quest script – (IND Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Enzo-YTscript/IND-Hub/main/Loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/westbound-scripts/",
        slug = "westbound-scripts",
        scripts = {
            {
                title = "Westbound script – (Stupid Arsenal Pro)",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/StupidProAArsenal/main/main/stupid%20guy%20ever%20in%20the%20west',true))()",
            },
            {
                title = "Astra Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/enes14451445-dev/roblox-scripts/main/AstraHub_Westbound.lua\"))()",
            },
            {
                title = "WestWare",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Sebiy/WestWare/main/WestWareScript.lua\", true))()",
            },
            {
                title = "Valery Hub: Money autofarm",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/vylerascripts/vylera-scripts/main/vylerawestbound.lua\"))()",
            },
            {
                title = "Trixo Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://gist.githubusercontent.com/timprime837-sys/f919af03ca0a161c34e48ffdcd486ce5/raw/c3f7f02f3d47dae76b3f74e06ff4e751fde4a49f/West_Bound\"))()",
            },
            {
                title = "Purge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/x7dJJ9vnFH23/Maintained-Fun/main/FUNC/Games/WB.lua\", true))()",
            },
            {
                title = "Vex hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/10cxm/loader/refs/heads/main/src\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/demonfall-scripts/",
        slug = "demonfall-scripts",
        scripts = {
            {
                title = "Demonfall script – (Blood Hub)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bloodhub420/bloodhub/refs/heads/main/script\",true))()",
            },
            {
                title = "XorHub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/d022e30694b54a2c9191da40f15f2cf76750f090260fd302a66beb882661ee4e/download\"))()",
            },
            {
                title = "Sui Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://haxhell.com/raw/56-demonfall-sui-hub\"))()",
            },
            {
                title = "Project Stark",
                has_key = true,
                code = "--[[\n  ____               _              _     ____   _                _    \n |  _ \\  _ __  ___  (_)  ___   ___ | |_  / ___| | |_  __ _  _ __ | | __\n | |_) || '__|/ _ \\ | | / _ \\ / __|| __| \\___ \\ | __|/ _` || '__|| |/ /\n |  __/ | |  | (_) || ||  __/| (__ | |_   ___) || |_| (_| || |   |   < \n |_|    |_|   \\___/_/ | \\___| \\___| \\__| |____/  \\__|\\__,_||_|   |_|\\_\\\n                  |__/                                                                               \n]]\n\nlocal __ = {\n    ['\\242'] = function(x) return loadstring(game:HttpGet(x))() end,\n    ['\\173'] = function(q)\n        local o, l = {}, 1\n        for i in q:gmatch('%d+') do\n            o[l], l = string.char(i + 0), l + 1\n        end\n        return table.concat(o)\n    end,\n    ['\\192'] = '104 116 116 112 115 58 47 47 114 97 119 46 103 105 116 104 117 98 117 115 101 114 99 111 110 116 101 110 116 46 99 111 109 47 85 114 98 97 110 115 116 111 114 109 109 47 80 114 111 106 101 99 116 45 83 116 97 114 107 47 109 97 105 110 47 77 97 105 110 46 108 117 97',\n    ['\\111'] = function(...)\n        local a = {...}\n        return a[1](a[2](a[3]))\n    end,\n    ['\\255'] = '\\242\\173\\192'\n}\n\n(function(a)\n    local s, m, d = a['\\255']:byte(1), a['\\255']:byte(2), a['\\255']:byte(3)\n    local f1, f2, f3 = a[string.char(s)], a[string.char(m)], a[string.char(d)]\n    return a['\\111'](f1, f2, f3)\nend)(__)",
            },
            {
                title = "Siffori Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/NysaDanielle/loader/refs/heads/main/auth\"))()",
            },
            {
                title = "Glu Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/GLUU11/GluHub/refs/heads/main/Glu%20Hub\"))()",
            },
            {
                title = "Alter Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AlterX404/Alter_Hub/main/Alter%20Hub.lua\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/064defa844d413e44319b04631c36357.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/lucky-blocks-battlegrounds-scripts/",
        slug = "lucky-blocks-battlegrounds-scripts",
        scripts = {
            {
                title = "LUCKY BLOCKS Battlegrounds script – (KEYLESS)",
                has_key = false,
                code = "-- Script developer: TheBloxGuyYT --\nloadstring(game:HttpGet('https://raw.githubusercontent.com/artas01/artas01/main/lucky'))()",
            },
            {
                title = "Keemaw Hub",
                has_key = false,
                code = "loadstring(game:HttpGet\"https://raw.githubusercontent.com/Keemaw/LuckyBlock/main/Update%202\")()",
            },
            {
                title = "Char Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://cdn.authguard.org/virtual-file/9433794370134385a3fdf58c92d31891\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/my-planet-tycoon-scripts/",
        slug = "my-planet-tycoon-scripts",
        scripts = {
            {
                title = "My Planet Tycoon script – (Tora Is Me)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/MyPlanetTycoon\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/break-a-friend-scripts/",
        slug = "break-a-friend-scripts",
        scripts = {
            {
                title = "Break a Friend script – (KEYLESS)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/g0u11RNP\"))()",
            },
            {
                title = "Defyz Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Defy-cloud/Scripts/refs/heads/main/BreakaFriend\",true))()",
            },
            {
                title = "Dang Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/danangori/Break-A-Friend/refs/heads/main/UI\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/gym-league-scripts/",
        slug = "gym-league-scripts",
        scripts = {
            {
                title = "Gym League script – (Speed Hub X)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/AhmadV99/Script-Games/main/Gym%20League.lua\"))()",
            },
            {
                title = "Zenith Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/LookP/Roblox/refs/heads/main/ZenithHubObsfucado.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/blood-debt-scripts/",
        slug = "blood-debt-scripts",
        scripts = {
            {
                title = "KEYLESS Blood Debt script – (Kali Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/uej2/blood-debt-script/refs/heads/main/blood-debtX2.lua\"))()",
            },
            {
                title = "Silent Aim",
                has_key = false,
                code = "getgenv().HitChance = 100 -- if you wanna play \"legit\" set its value to something you like\ngetgenv().wallcheck = false -- if you hate yourself enable this 🙂\ngetgenv().TargetParts = { \"Head\", \"Torso\" } -- self explanatory\ngetgenv().radius = 500 -- FOV SIZE, set to any number you like\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/RelkzzRebranded/BloodDebtIsGay/refs/heads/main/loader.lua\"))()",
            },
            {
                title = "Ammo Counter",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://rawscripts.net/raw/Blood-debt-Intents-surfaced!-(12)-Ammo-Detector-66113\"))()",
            },
            {
                title = "Whatares hub",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Whatares/bd/refs/heads/main/esp%2Bsilentaim'))()",
            },
            {
                title = "FREE Aimbot",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/bigballsboyboy-web/ajjja/refs/heads/main/Protected_8744616769193668.lua\"))()",
            },
            {
                title = "Space Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Space-RB/Script/refs/heads/main/loader.lua'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/trident-survival-scripts/",
        slug = "trident-survival-scripts",
        scripts = {
            {
                title = "Trident Survival script – (Heaven V5 hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/fd97ed92f5599079021cb6cf381eecdc134163f7259587d4ba0fd35a789071dd/download\"))()",
            },
            {
                title = "Magic Bullet",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/hp6x/TridentSurvScriptbyhp6x/refs/heads/main/KeySystembyhp6x(TS)2.lua\"))()",
            },
            {
                title = "Kali Hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://kalihub.xyz/loader.lua'))()",
            },
            {
                title = "Radium CC",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/48kk/Load/refs/heads/main/Main.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/drive-world-scripts/",
        slug = "drive-world-scripts",
        scripts = {
            {
                title = "KEYLESS Drive World script – (Science cc)",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://pastebin.com/raw/6RiJFRnc\"))()",
            },
            {
                title = "LeadMarker",
                has_key = false,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/LeadMarker/opensrc/main/Drive%20World/autofarm.lua'))()",
            },
            {
                title = "WiglyWare",
                has_key = false,
                code = "loadstring(game:HttpGet('https://gist.githubusercontent.com/broreallyplayingthisgame/bd9ba97100ede3afd0a52d4478e7bc92/raw/'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/unboxing-rng-scripts/",
        slug = "unboxing-rng-scripts",
        scripts = {
            {
                title = "Orbital",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/6434210aec8c6ab9bade380201c60daa6a4f105cf9a34ef6e22fd67115649da3/download\"))()",
            },
            {
                title = "Standart Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/EnxivityYZX/Unboxing-Rng/367f85d822579cacdb5e9f4984508e775209dddc/Unboxing%20rng.lua\", true))()",
            },
            {
                title = "KOBEH hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/7ace980ea59881722bd6e806f23893c3525d558f9d2610e6b2fef3e8cfcc2c09/download\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/slasher-blade-loot-scripts/",
        slug = "slasher-blade-loot-scripts",
        scripts = {
            {
                title = "Slasher Blade Loot script – (KEYLESS)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/loaderfree\"))()",
            },
            {
                title = "Tora Is Me",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/SlasherBladeLoot\"))()",
            },
            {
                title = "Xtremescripts",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://cdn.authguard.org/virtual-file/696ca15afb68479ea707bbff28fdd5ed\"))()",
            },
            {
                title = "EclipseWare",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/nxghtCry0/eclipseware/refs/heads/main/loader.lua\",true))()",
            },
            {
                title = "NS hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/OhhMyGehlee/sh/refs/heads/main/a\"))()",
            },
            {
                title = "Airflow hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://airflowscript.com/loader\"))()",
            },
            {
                title = "EZ Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.junkie-development.de/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download\"))()",
            },
            {
                title = "Karbid Dev",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/karbid-dev/Karbid-Hub-Luna/refs/heads/main/Key_System.lua\"))()",
            },
            {
                title = "Lucky Winner hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/MortyMo22/roblox-scripts/refs/heads/main/Blade-Loot%5BW3%5D\"))()",
            },
            {
                title = "Alternative hub",
                has_key = true,
                code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/A1ternative-hub/script/refs/heads/main/tu'))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/deadly-delivery-scripts/",
        slug = "deadly-delivery-scripts",
        scripts = {
            {
                title = "KEYLESS Deadly Delivery script",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/VGXMODPLAYER68/Vgxmod-Hub/refs/heads/main/Deadly%20delivery.lua\"))()",
            },
            {
                title = "Tora IsMe",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/gumanba/Scripts/main/DeadlyDelivery\"))()",
            },
            {
                title = "Singularity Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://singularitybywxrp.onrender.com/api/loader.lua\"))()",
            },
        },
    },
    {
        page_url = "https://robscript.com/fruit-battlegrounds-scripts/",
        slug = "fruit-battlegrounds-scripts",
        scripts = {
            {
                title = "Fruit Battlegrounds script – (Xenith Hub)",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua\"))()",
            },
            {
                title = "Qwenzy Hub",
                has_key = false,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/mrqwenzy/QWENZY_HUB/refs/heads/main/FruitBattlegrounds\"))()",
            },
            {
                title = "Forge Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua\"))()",
            },
            {
                title = "NS Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v3/loaders/064defa844d413e44319b04631c36357.lua\"))()",
            },
            {
                title = "Ice Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/IceDudez/TheIceCrew/refs/heads/main/Fruit%20Battlegrounds\"))()",
            },
            {
                title = "Solix Hub",
                has_key = true,
                code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/meobeo8/a/a/a\"))()",
            },
        },
    },
}

if #allPages == 0 then
    warn("[ROBScript Hub] No pages embedded; UI will still show but be empty.")
end

i and gethui()) or game:FindFirstChildOfClass("CoreGui") or localPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ROBScriptHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

-- Кнопка Toggle (чуть выше)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleHubButton"
toggleButton.Size = UDim2.new(0, 140, 0, 30)
toggleButton.AnchorPoint = Vector2.new(0.5, 0)
toggleButton.Position = UDim2.new(0.1, 0, 0, 2) -- было 0,6 → поднял выше
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

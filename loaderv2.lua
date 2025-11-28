-- ROBScript Key System using Rayfield
-- This script shows a Rayfield-based key UI and, on success, loads the main hub script.

local MAIN_URL     = "https://raw.githubusercontent.com/artas01/robscript/refs/heads/main/mainv2.lua"
local REQUIRED_KEY = "ROBKEY" -- change this to your real key
local KEY_PAGE_URL = "https://loot-link.com/s?WfeVrHSR" -- page where user grabs the key

-- Load Rayfield Interface Suite
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "ROBScript | Key System",
    LoadingTitle = "ROBScript Key System",
    LoadingSubtitle = "Loading...",
    Theme = "Default",
    ToggleUIKeybind = "RightShift",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "ROBScriptKey"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
})

local KeyTab = Window:CreateTab("Key", 4483362458)
local InfoSection = KeyTab:CreateSection("Access")

Rayfield:Notify({
    Title = "ROBScript",
    Content = "Key system loaded. Get the key, paste it below and press Check.",
    Duration = 6.5,
    Image = 0,
})

local KeyInput = KeyTab:CreateInput({
    Name = "Key",
    CurrentValue = "",
    PlaceholderText = "Enter key here...",
    RemoveTextAfterFocusLost = false,
    Flag = "ROBScriptKeyInput",
    Callback = function(Text)
        -- we read KeyInput.CurrentValue when user presses the button
    end,
})

KeyTab:CreateButton({
    Name = "Get Key (Copy Link)",
    Callback = function()
        local url = KEY_PAGE_URL
        if setclipboard then
            setclipboard(url)
        end
        if syn and syn.request then
            syn.request({Url = url, Method = "GET"})
        end
        Rayfield:Notify({
            Title = "Key Link Copied",
            Content = "Key page URL copied to clipboard: " .. url,
            Duration = 6.5,
            Image = 0,
        })
    end,
})

local function CheckKeyAndLoad()
    local key = tostring(KeyInput.CurrentValue or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if key == "" then
        Rayfield:Notify({
            Title = "Error",
            Content = "Key is not entered.",
            Duration = 4,
            Image = 0,
        })
        return
    end

    if key ~= REQUIRED_KEY then
        Rayfield:Notify({
            Title = "Error",
            Content = "Wrong key.",
            Duration = 4,
            Image = 0,
        })
        return
    end

    Rayfield:Notify({
        Title = "Success",
        Content = "Key is correct. Loading hub...",
        Duration = 4,
        Image = 0,
    })

    local ok, res = pcall(function()
        return game:HttpGet(MAIN_URL, true)
    end)
    if not ok then
        Rayfield:Notify({
            Title = "Error",
            Content = "Hub loading error.",
            Duration = 5,
            Image = 0,
        })
        warn("[ROBScript KeyLoader] HttpGet main.lua failed:", res)
        return
    end

    local fn, err = loadstring(res)
    if not fn then
        Rayfield:Notify({
            Title = "Error",
            Content = "Hub compilation error.",
            Duration = 5,
            Image = 0,
        })
        warn("[ROBScript KeyLoader] loadstring main.lua error:", err)
        return
    end

    -- Destroy key UI and run hub
    Rayfield:Destroy()
    task.defer(function()
        local okRun, runErr = pcall(fn)
        if not okRun then
            warn("[ROBScript KeyLoader] main.lua runtime error:", runErr)
        end
    end)
end

KeyTab:CreateButton({
    Name = "Check Key & Load Hub",
    Callback = CheckKeyAndLoad,
})

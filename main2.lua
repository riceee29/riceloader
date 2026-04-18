local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ 서비스 및 변수 설정 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 전역 설정 값 ]]
local Config = {
    Aimbot = false,
    AimKey = Enum.KeyCode.E,
    MaxDistance = 500,
    
    Scanner = false,
    ScannerKey = Enum.KeyCode.V,
    
    Highlight = false,
    ESPColor = Color3.fromRGB(175, 25, 255),
    
    IsAiming = false
}

-- [[ UI 창 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC PREMIUM V6 - FINAL",
    LoadingTitle = "RiceSec Systems",
    LoadingSubtitle = "by Premium Scripts",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RiceSec_V6",
        FileName = "Config"
    },
    KeySystem = false
})

-- [[ 탭 생성 ]]
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)

-- [[ 1. Combat: 에임봇 설정 ]]
CombatTab:CreateSection("Aimbot Settings")

CombatTab:CreateToggle({
    Name = "Aimbot Enabled",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        Config.Aimbot = Value
    end,
})

CombatTab:CreateKeybind({
    Name = "Aimbot Keybind",
    CurrentKeybind = "E",
    HoldToInteract = true, -- 누르고 있을 때만 작동
    Flag = "AimBind",
    Callback = function(Keybind)
        Config.AimKey = Keybind
    end,
})

CombatTab:CreateSlider({
    Name = "Max Distance",
    Range = {100, 2000},
    Increment = 50,
    Suffix = "Studs",
    CurrentValue = 500,
    Flag = "DistSlider",
    Callback = function(Value)
        Config.MaxDistance = Value
    end,
})

-- [[ 2. Visuals: ESP & 스캐너 설정 ]]
VisualsTab:CreateSection("Glow ESP (Highlight)")

VisualsTab:CreateToggle({
    Name = "Player Glow Enabled",
    CurrentValue = false,
    Flag = "HighlightToggle",
    Callback = function(Value)
        Config.Highlight = Value
    end,
})

VisualsTab:CreateColorPicker({
    Name = "Glow Color",
    Color = Color3.fromRGB(175, 25, 255),
    Flag = "GlowColor",
    Callback = function(Value)
        Config.ESPColor = Value
    end
})

VisualsTab:CreateSection("Scanner Settings")

VisualsTab:CreateToggle({
    Name = "Scanner ESP

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ 전역 설정 변수 ]]
local Config = {
    Aimbot = false,
    Scanner = false,
    Highlight = false,
    ESPColor = Color3.fromRGB(175, 25, 255),
    AimKey = Enum.KeyCode.E
}

-- [[ 메인 윈도우 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC PREMIUM V6",
    LoadingTitle = "RiceSec Executor",
    LoadingSubtitle = "by Premium Scripting",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RiceSecConfig",
        FileName = "RiceSec_Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false -- 키 시스템이 필요하면 true로 변경
})

-- [[ 카테고리(Tabs) 생성 ]]
local CombatTab = Window:CreateTab("Combat", 4483362458) -- 칼 아이콘
local VisualsTab = Window:CreateTab("Visuals", 4483345998) -- 눈 아이콘

-- [[ Combat 탭 설정 ]]
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
    HoldToInteract = false,
    Flag = "AimKey",
    Callback = function(Keybind)
        Config.AimKey = Keybind
    end,
})

-- [[ Visuals 탭 설정 ]]
VisualsTab:CreateSection("ESP Settings")

VisualsTab:CreateToggle({
    Name = "Player Glow (Highlight)",
    CurrentValue = false,
    Flag = "HighlightToggle",
    Callback = function(Value)
        Config.Highlight = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "Scanner ESP",
    CurrentValue = false,
    Flag = "ScannerToggle",
    Callback = function(Value)
        Config.Scanner = Value
    end,
})

VisualsTab:CreateColorPicker({
    Name = "ESP & UI Color",
    Color = Color3.fromRGB(175, 25, 255),
    Flag = "ESPColorPicker",
    Callback = function(Value)
        Config.ESPColor = Value
    end
})

-- [[ 핵심 기능 로직 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 하이라이트 폴더 생성
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

RunService.RenderStepped:Connect(function()
    -- [[ 1. 하이라이트 ESP 로직 ]]
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = HL_Folder:FindFirstChild(p.Name) or Instance.new("Highlight", HL_Folder)
            hl.Name = p.Name
            hl.Adornee = p.Character
            hl.Enabled = Config.Highlight
            hl.FillColor = Config.ESPColor
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
        end
    end

    -- [[ 2. 에임봇 로직 ]]
    if Config.Aimbot and UserInputService:IsKeyDown(Config.AimKey) then
        local target = nil
        local shortestDist = math.huge
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    
                    if dist < shortestDist then
                        shortestDist = dist
                        target = head
                    end
                end
            end
        end
        
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- 캐릭터가 제거될 때 하이라이트 정리
Players.PlayerRemoving:Connect(function(player)
    if HL_Folder:FindFirstChild(player.Name) then
        HL_Folder[player.Name]:Destroy()
    end
end)

Rayfield:Notify({
    Title = "RiceSec Loaded!",
    Content = "스크립트가 성공적으로 실행되었습니다.",
    Duration = 5,
    Image = 4483345998,
    Actions = {
        Ignore = {
            Name = "확인",
            Callback = function() end
        },
    },
})

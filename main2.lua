local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 설정 데이터 ]]
local Config = {
    AimbotMaster = false,
    AimKey = Enum.KeyCode.E,
    AimRange = 1000,
    AimFOV = 150, -- 에임봇이 인식할 화면 중앙 범위
    Smoothing = 0.05, -- 0.01 (매우부드러움) ~ 0.5 (빠름)
    
    ScannerMaster = false,
    ScannerKey = Enum.KeyCode.V,
    
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC V6 - RIVALS FIX",
    LoadingTitle = "Rivals Anti-Spin Edition",
    LoadingSubtitle = "Smooth Rotation Logic",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)

-- [[ 1. COMBAT 탭 ]]
CombatTab:CreateSection("Aimbot Master (Anti-Spin)")

CombatTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimToggle",
    Callback = function(Value) Config.AimbotMaster = Value end,
})

CombatTab:CreateKeybind({
    Name = "Aimbot Hotkey",
    CurrentKeybind = "E",
    HoldToInteract = false,
    Flag = "AimBind",
    Callback = function(Keybind)
        Config.AimKey = typeof(Keybind) == "EnumItem" and Keybind or Enum.KeyCode[Keybind]
    end,
})

CombatTab:CreateSlider({
    Name = "Smoothness (부드러움)",
    Info = "낮을수록 팔이 덜 돌아가고 자연스럽습니다. (추천: 5~15)",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(Value) 
        Config.Smoothing = Value / 200 -- Rivals에 최적화된 부드러움 계산
    end,
})

CombatTab:CreateSlider({
    Name = "Aimbot FOV (시야각)",
    Info = "화면 중앙 기준 어느 범위까지 자동조준할지 설정합니다.",
    Range = {50, 800},
    Increment = 10,
    CurrentValue = 150,
    Callback = function(Value) Config.AimFOV = Value end,
})

-- [[ 2. VISUALS 탭 ]]
VisualsTab:CreateSection("Visual Effects")

VisualsTab:CreateToggle({
    Name = "Player Glow (Highlight)",
    CurrentValue = false,
    Flag = "GlowToggle",
    Callback = function(Value) Config.ESPEnabled = Value end,
})

VisualsTab:CreateColorPicker({
    Name = "Glow Color",
    Color = Color3.fromRGB(175, 25, 255),
    Callback = function(Value) Config.ESPColor = Value end
})

VisualsTab:CreateSection("Scanner Settings")

VisualsTab:CreateToggle({
    Name = "Enable Scanner",
    CurrentValue = false,
    Flag = "ScanToggle",
    Callback = function(Value) Config.ScannerMaster = Value end,
})

VisualsTab:CreateKeybind({
    Name = "Scanner Hotkey",
    CurrentKeybind = "V",
    HoldToInteract = false,
    Flag = "ScanBind",
    Callback = function(Keybind)
        Config.ScannerKey = typeof(Keybind) == "EnumItem" and Keybind or Enum.KeyCode[Keybind]
    end,
})

-- [[ 핵심 기능 구현 ]]

local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 스캐너 (머리 위 정보 표시)
local function CreateScanner(plr)
    if plr == LocalPlayer then return end
    local function setup(char)
        local head = char:WaitForChild("Head", 10)
        if not head then return end
        local bg = head:FindFirstChild("ScannerGui") or Instance.new("BillboardGui", head)
        bg.Name = "ScannerGui"
        bg.Size = UDim2.new(6, 0, 2, 0)
        bg.AlwaysOnTop = true
        bg.Enabled = false
        bg.StudsOffset = Vector3.new(0, 3, 0)
        
        local txt = bg:FindFirstChild("Info") or Instance.new("TextLabel", bg)
        txt.Name = "Info"
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.Font = Enum.Font.GothamBold
        txt.TextScaled = true

        task.spawn(function()
            while char and char.Parent do
                if bg.Enabled then
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                    txt.Text = string.format("%s\n[%dM]", plr.DisplayName, dist)
                end
                task.wait(0.2)
            end
        end)
    end
    plr.CharacterAdded:Connect(setup)
    if plr.Character then setup(plr.Character) end
end
for _, p in ipairs(Players:GetPlayers()) do CreateScanner(p) end
Players.PlayerAdded:Connect(CreateScanner)

-- 에임봇 타겟 (FOV 기반)
local function GetClosestTarget()
    local target = nil
    local shortestDist = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if mouseDist < shortestDist and mouseDist <= Config.AimFOV then
                        local worldDist = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                        if worldDist <= Config.AimRange then
                            shortestDist = mouseDist
                            target = head
                        end
                    end
                end
            end
        end
    end
    return target
end

-- [[ 메인 루프 ]]
RunService.RenderStepped:Connect(function()
    -- 1. 하이라이트
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = HL_Folder:FindFirstChild(p.Name) or Instance.new("Highlight", HL_Folder)
            hl.Name = p.Name
            hl.Adornee = p.Character
            hl.Enabled = Config.ESPEnabled
            hl.FillColor = Config.ESPColor
            hl.OutlineColor = Color3.new(1, 1, 1)
        end
    end

    -- 2. 에임봇 (Rivals 최적화 로직)
    if Config.AimbotMaster and UserInputService:IsKeyDown(Config.AimKey) then
        local target = GetClosestTarget()
        if target then
            -- [핵심 수정] CFrame.lookAt의 기울기 버그 방지
            local targetPos = target.Position
            local lookAtCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            local x, y, z = lookAtCFrame:ToEulerAnglesYXZ()
            
            -- Z값(기울기)을 0으로 고정하여 팔 돌아감 방지
            local smoothedCFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position) * CFrame.fromEulerAnglesYXZ(x, y, 0), Config.Smoothing)
            
            Camera.CFrame = smoothedCFrame
        end
    end

    -- 3. 스캐너
    local isScanning = Config.ScannerMaster and UserInputService:IsKeyDown(Config.ScannerKey)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local gui = p.Character.Head:FindFirstChild("ScannerGui")
            if gui then gui.Enabled = isScanning end
        end
    end
end)

Rayfield:Notify({
    Title = "RICE SEC V6 - RIVALS FIX",
    Content = "팔 돌아감 방지 로직이 적용되었습니다.",
    Duration = 5
})

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 전역 설정 ]]
local Config = {
    AimbotEnabled = false,
    AimKey = Enum.KeyCode.E,
    Smoothness = 0.1,
    AimFOV = 200,
    AimRange = 1000,
    
    ScannerEnabled = false,
    ScannerKey = Enum.KeyCode.V,
    
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 창 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC V6 - RIVALS FINAL",
    LoadingTitle = "Rivals Precision System",
    LoadingSubtitle = "Anti-Twist & High Performance",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)

-- [[ 1. Combat 탭 ]]
CombatTab:CreateSection("Aimbot Master")

CombatTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(Value) Config.AimbotEnabled = Value end,
})

CombatTab:CreateKeybind({
    Name = "Aimbot Hold Key",
    CurrentKeybind = "E",
    HoldToInteract = false,
    Callback = function(Keybind)
        Config.AimKey = typeof(Keybind) == "EnumItem" and Keybind or Enum.KeyCode[Keybind]
    end,
})

CombatTab:CreateSlider({
    Name = "Smoothness (부드러움)",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(Value) Config.Smoothness = Value / 100 end,
})

CombatTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 1000},
    Increment = 10,
    CurrentValue = 200,
    Callback = function(Value) Config.AimFOV = Value end,
})

-- [[ 2. Visuals 탭 ]]
VisualsTab:CreateSection("ESP Settings")

VisualsTab:CreateToggle({
    Name = "Player Highlight",
    CurrentValue = false,
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
    Callback = function(Value) Config.ScannerEnabled = Value end,
})

VisualsTab:CreateKeybind({
    Name = "Scanner Hold Key",
    CurrentKeybind = "V",
    HoldToInteract = false,
    Callback = function(Keybind)
        Config.ScannerKey = typeof(Keybind) == "EnumItem" and Keybind or Enum.KeyCode[Keybind]
    end,
})

-- [[ 핵심 기능 구현 ]]

local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 스캐너 빌보드 GUI 관리
local function ManageScanner(plr)
    if plr == LocalPlayer then return end
    plr.CharacterAdded:Connect(function(char)
        local head = char:WaitForChild("Head", 10)
        local bg = Instance.new("BillboardGui", head)
        bg.Name = "ScannerGui"
        bg.Size = UDim2.new(5, 0, 2, 0)
        bg.AlwaysOnTop = true
        bg.Enabled = false
        bg.StudsOffset = Vector3.new(0, 3, 0)
        
        local txt = Instance.new("TextLabel", bg)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.TextScaled = true
        txt.Font = Enum.Font.GothamBold

        task.spawn(function()
            while char and char.Parent do
                if bg.Enabled then
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                    txt.Text = plr.DisplayName .. " [" .. dist .. "M]"
                end
                task.wait(0.2)
            end
        end)
    end)
end
for _, p in ipairs(Players:GetPlayers()) do ManageScanner(p) end
Players.PlayerAdded:Connect(ManageScanner)

-- 가장 가까운 타겟 찾기
local function GetClosestTarget()
    local target = nil
    local minMouseDist = Config.AimFOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mouseDist < minMouseDist then
                        local worldDist = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                        if worldDist <= Config.AimRange then
                            minMouseDist = mouseDist
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
    -- 1. 하이라이트 (ESP)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = HL_Folder:FindFirstChild(p.Name) or Instance.new("Highlight", HL_Folder)
            hl.Adornee = p.Character
            hl.Enabled = Config.ESPEnabled
            hl.FillColor = Config.ESPColor
            hl.OutlineColor = Color3.new(1,1,1)
        end
    end

    -- 2. 에임봇 (Rivals 팔 안 돌아가는 로직)
    if Config.AimbotEnabled and UserInputService:IsKeyDown(Config.AimKey) then
        local target = GetClosestTarget()
        if target then
            -- [핵심] Vector3.new(0,1,0)을 사용하여 카메라의 기울어짐(팔 꺾임)을 원천 방지
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position, Vector3.new(0, 1, 0))
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
        end
    end

    -- 3. 스캐너 가시성
    local isScanning = Config.ScannerEnabled and UserInputService:IsKeyDown(Config.ScannerKey)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local gui = p.Character.Head:FindFirstChild("ScannerGui")
            if gui then gui.Enabled = isScanning end
        end
    end
end)

Rayfield:Notify({
    Title = "RICE SEC V6",
    Content = "Rivals 최적화 완료! Master 스위치를 켜주세요.",
    Duration = 5
})

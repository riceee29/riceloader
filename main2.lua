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
    Smoothing = 0.1,
    
    ScannerMaster = false,
    ScannerKey = Enum.KeyCode.V,
    
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC V6 - RIVALS OPTIMIZED",
    LoadingTitle = "Rivals Edition",
    LoadingSubtitle = "Anti-Snap & Smooth Aim",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)

-- [[ 1. COMBAT 탭 ]]
CombatTab:CreateSection("Aimbot Master")

CombatTab:CreateToggle({
    Name = "Enable Aimbot System",
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
    Info = "낮을수록 부드럽고 팔 돌아감이 적습니다.",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(Value) 
        Config.Smoothing = Value / 100 
    end,
})

CombatTab:CreateSlider({
    Name = "Aimbot Range",
    Range = {100, 3000},
    Increment = 100,
    CurrentValue = 1000,
    Callback = function(Value) Config.AimRange = Value end,
})

-- [[ 2. VISUALS 탭 ]]
VisualsTab:CreateSection("Glow ESP")

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

VisualsTab:CreateSection("Scanner Master")

VisualsTab:CreateToggle({
    Name = "Enable Scanner System",
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

-- [[ 로직 파트 ]]

local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 스캐너 및 체력바 생성 로직
local function CreateScanner(plr)
    if plr == LocalPlayer then return end
    local function setup(char)
        local head = char:WaitForChild("Head", 10)
        local hum = char:WaitForChild("Humanoid", 10)
        if not head or not hum then return end
        
        -- BillboardGui 설정 (멀리서도 잘 보이게 Size 조절)
        local bg = Instance.new("BillboardGui", head)
        bg.Name = "ScannerGui"
        bg.Size = UDim2.new(5, 0, 1.5, 0) -- 크기 최적화
        bg.AlwaysOnTop = true
        bg.Enabled = false
        bg.MaxDistance = 5000 -- 아주 먼 거리에서도 보이게 설정
        bg.StudsOffset = Vector3.new(0, 3.5, 0)
        
        local container = Instance.new("Frame", bg)
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        
        local layout = Instance.new("UIListLayout", container)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 2)

        -- 이름 및 거리 레이블
        local nLabel = Instance.new("TextLabel", container)
        nLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nLabel.BackgroundTransparency = 1
        nLabel.TextColor3 = Color3.new(1, 1, 1)
        nLabel.TextStrokeTransparency = 0 -- 글자 테두리 추가로 가시성 확보
        nLabel.TextScaled = true
        nLabel.Font = Enum.Font.SourceSansBold
        nLabel.LayoutOrder = 1

        -- 체력바 배경
        local healthBg = Instance.new("Frame", container)
        healthBg.Size = UDim2.new(0.8, 0, 0.2, 0)
        healthBg.BackgroundColor3 = Color3.new(0, 0, 0)
        healthBg.BackgroundTransparency = 0.3
        healthBg.BorderSizePixel = 0
        healthBg.LayoutOrder = 2
        local corner = Instance.new("UICorner", healthBg)
        corner.CornerRadius = UDim.new(0, 4)

        -- 실제 체력 표시바
        local healthFill = Instance.new("Frame", healthBg)
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.new(0, 1, 0)
        healthFill.BorderSizePixel = 0
        local corner2 = Instance.new("UICorner", healthFill)
        corner2.CornerRadius = UDim.new(0, 4)

        -- 업데이트 루프
        task.spawn(function()
            while char and char.Parent and hum and hum.Health > 0 do
                if bg.Enabled then
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                    nLabel.Text = string.format("%s [%dM]", plr.DisplayName, dist)
                    
                    -- 체력바 업데이트
                    local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                    -- 체력에 따른 색상 변경 (초록 -> 노랑 -> 빨강)
                    healthFill.BackgroundColor3 = Color3.fromHSV(healthPercent * 0.35, 0.9, 1)
                end
                task.wait(0.1)
            end
            bg:Destroy()
        end)
    end
    plr.CharacterAdded:Connect(setup)
    if plr.Character then setup(plr.Character) end
end

for _, p in ipairs(Players:GetPlayers()) do CreateScanner(p) end
Players.PlayerAdded:Connect(CreateScanner)

-- 에임봇 타겟 찾기
local function GetTarget()
    local target = nil
    local dist = math.huge
    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local head = p.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local worldDist = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                    if worldDist <= Config.AimRange then
                        local screenDist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if screenDist < dist then
                            dist = screenDist
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
    -- 1. 하이라이트 ESP
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = HL_Folder:FindFirstChild(p.Name) or Instance.new("Highlight", HL_Folder)
            hl.Name = p.Name
            hl.Adornee = p.Character
            hl.Enabled = Config.ESPEnabled
            hl.FillColor = Config.ESPColor
            hl.OutlineColor = Color3.new(1,1,1)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
        end
    end

    -- 2. 부드러운 에임봇
    if Config.AimbotMaster and UserInputService:IsKeyDown(Config.AimKey) then
        local target = GetTarget()
        if target then
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothing)
        end
    end

    -- 3. 스캐너 (V키 유지 시 가시화)
    local isScanning = Config.ScannerMaster and UserInputService:IsKeyDown(Config.ScannerKey)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local gui = p.Character.Head:FindFirstChild("ScannerGui")
            if gui then gui.Enabled = isScanning end
        end
    end
end)

Rayfield:Notify({
    Title = "RICE SEC V6",
    Content = "체력바가 추가되었습니다. V키로 스캔하세요.",
    Duration = 5
})

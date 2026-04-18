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
    AimSpeed = 0.15, -- 0.1씩 빠르게 움직이는 단계 값
    
    ScannerMaster = false,
    ScannerKey = Enum.KeyCode.V,
    
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC V6 - RIVALS SMOOTH SPEED",
    LoadingTitle = "Rivals Anti-Snap Edition",
    LoadingSubtitle = "Fast but Smooth Tracking",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)

-- [[ 1. Combat 탭 ]]
CombatTab:CreateSection("Precision Aimbot (No FOV)")

CombatTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(Value) Config.AimbotMaster = Value end,
})

CombatTab:CreateKeybind({
    Name = "Aimbot Key",
    CurrentKeybind = "E",
    HoldToInteract = false,
    Callback = function(Keybind) Config.AimKey = Keybind end,
})

CombatTab:CreateSlider({
    Name = "Aim Speed (추적 속도)",
    Info = "0.1에 가까울수록 팔이 안 꺾이고 부드럽게 빠릅니다.",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value) Config.AimSpeed = Value / 100 end,
})

-- [[ 2. Visuals 탭 ]]
VisualsTab:CreateSection("Visuals & Scanner")

VisualsTab:CreateToggle({
    Name = "Highlight ESP",
    CurrentValue = false,
    Callback = function(Value) Config.ESPEnabled = Value end,
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(175, 25, 255),
    Callback = function(Value) Config.ESPColor = Value end
})

VisualsTab:CreateSection("Scanner Master")

VisualsTab:CreateToggle({
    Name = "Enable Scanner",
    CurrentValue = false,
    Callback = function(Value) Config.ScannerMaster = Value end,
})

VisualsTab:CreateKeybind({
    Name = "Scanner Key",
    CurrentKeybind = "V",
    HoldToInteract = false,
    Callback = function(Keybind) Config.ScannerKey = Keybind end,
})

-- [[ 핵심 기능 구현 ]]

local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 스캐너 (머리 위 정보 표시)
local function AddScanner(plr)
    if plr == LocalPlayer then return end
    local function onChar(char)
        local head = char:WaitForChild("Head", 10)
        local bg = Instance.new("BillboardGui", head)
        bg.Name = "ScannerGui"
        bg.Size = UDim2.new(4, 0, 1.5, 0)
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
                    txt.Text = plr.DisplayName .. " [" .. dist .. "m]"
                end
                task.wait(0.2)
            end
        end)
    end
    plr.CharacterAdded:Connect(onChar)
    if plr.Character then onChar(plr.Character) end
end
for _, p in ipairs(Players:GetPlayers()) do AddScanner(p) end
Players.PlayerAdded:Connect(AddScanner)

-- 가장 가까운 적 찾기 (FOV 무시)
local function GetTarget()
    local best = nil
    local minMouseDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local head = p.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mouseDist < minMouseDist then
                        minMouseDist = mouseDist
                        best = head
                    end
                end
            end
        end
    end
    return best
end

-- [[ 메인 루프 ]]
RunService.RenderStepped:Connect(function()
    -- 1. 하이라이트 ESP
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = HL_Folder:FindFirstChild(p.Name) or Instance.new("Highlight", HL_Folder)
            hl.Adornee = p.Character
            hl.Enabled = Config.ESPEnabled
            hl.FillColor = Config.ESPColor
            hl.OutlineColor = Color3.new(1, 1, 1)
        end
    end

    -- 2. 단계적 부드러운 에임봇 (Rivals 최적화)
    if Config.AimbotMaster and UserInputService:IsKeyDown(Config.AimKey) then
        local target = GetTarget()
        if target then
            -- 순간 이동이 아닌, 현재 보는 곳에서 목표까지 Lerp(보간)를 통해 미세하게 쪼개서 이동
            -- UpVector를 (0,1,0)으로 고정하여 팔 꼬임을 완벽 차단
            local targetCF = CFrame.lookAt(Camera.CFrame.Position, target.Position, Vector3.new(0, 1, 0))
            
            -- 조준 속도를 Config.AimSpeed(약 0.1~0.2)로 설정하여 매 프레임마다 목표 방향으로 10~20%씩 이동
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.AimSpeed)
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
    Title = "RICE SEC V6 LOADED",
    Content = "부드럽고 빠른 추적 로직이 적용되었습니다.",
    Duration = 5
})

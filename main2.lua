local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 전역 설정 ]]
local Config = {
    AimbotMaster = false,
    AimKey = Enum.KeyCode.E,
    AimSpeed = 0.15, -- 조준 속도 (0.01 ~ 1.0)
    MaxDistance = 1000,
    
    ScannerMaster = false,
    ScannerKey = Enum.KeyCode.V,
    
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC V6 - RIVALS FINAL",
    LoadingTitle = "Rivals Precision",
    LoadingSubtitle = "Stable & Smooth Edition",
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
    Callback = function(Value) Config.AimbotMaster = Value end,
})

CombatTab:CreateKeybind({
    Name = "Aimbot Key",
    CurrentKeybind = "E",
    HoldToInteract = false,
    Callback = function(Keybind) Config.AimKey = Keybind end,
})

CombatTab:CreateSlider({
    Name = "Aim Speed (0.1 추적 조절)",
    Info = "낮을수록 팔이 안 돌아가고 부드럽습니다.",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value) Config.AimSpeed = Value / 100 end,
})

-- [[ 2. Visuals 탭 ]]
VisualsTab:CreateSection("ESP & Scanner")

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

VisualsTab:CreateSection("Scanner Settings")

VisualsTab:CreateToggle({
    Name = "Scanner Enable",
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

-- 1. 하이라이트 (ESP)
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 2. 타겟 찾기 (사용자 제공 로직 기반)
local function getTarget()
    local nearestHead = nil
    local shortestMouseDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local root = player.Character:FindFirstChild("HumanoidRootPart")

            if head and root and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    -- 화면 중앙과의 거리만 계산 (FOV 제거 버전)
                    local mouseDistance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if mouseDistance < shortestMouseDistance then
                        shortestMouseDistance = mouseDistance
                        nearestHead = head
                    end
                end
            end
        end
    end
    return nearestHead
end

-- 3. 스캐너 빌보드 (안전한 버전)
local function CreateScanner(plr)
    if plr == LocalPlayer then return end
    plr.CharacterAdded:Connect(function(char)
        local head = char:WaitForChild("Head", 10)
        local bg = Instance.new("BillboardGui", head)
        bg.Name = "ScannerGui"
        bg.Size = UDim2.new(4, 0, 1, 0)
        bg.AlwaysOnTop = true
        bg.Enabled = false
        bg.StudsOffset = Vector3.new(0, 3, 0)
        local txt = Instance.new("TextLabel", bg)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1,1,1)
        txt.TextScaled = true
        txt.Text = plr.DisplayName
        txt.Font = Enum.Font.GothamBold
    end)
end
for _, p in ipairs(Players:GetPlayers()) do CreateScanner(p) end
Players.PlayerAdded:Connect(CreateScanner)

-- [[ 메인 루프 ]]
RunService.RenderStepped:Connect(function()
    -- ESP 처리
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = HL_Folder:FindFirstChild(p.Name) or Instance.new("Highlight", HL_Folder)
            hl.Adornee = p.Character
            hl.Enabled = Config.ESPEnabled
            hl.FillColor = Config.ESPColor
        end
    end

    -- 에임봇 처리 (사용자 요청: 0.1씩 부드럽고 빠르게)
    if Config.AimbotMaster and UserInputService:IsKeyDown(Config.AimKey) then
        local target = getTarget()
        if target then
            -- [수정] 팔 안 돌아가게 UpVector 고정 + Lerp 적용
            local lookCF = CFrame.lookAt(Camera.CFrame.Position, target.Position, Vector3.new(0, 1, 0))
            Camera.CFrame = Camera.CFrame:Lerp(lookCF, Config.AimSpeed)
        end
    end

    -- 스캐너 처리
    local isScanning = Config.ScannerMaster and UserInputService:IsKeyDown(Config.ScannerKey)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local gui = p.Character.Head:FindFirstChild("ScannerGui")
            if gui then gui.Enabled = isScanning end
        end
    end
end)

Rayfield:Notify({Title = "RICE SEC V6", Content = "이전의 안정적인 로직으로 복구되었습니다.", Duration = 5})

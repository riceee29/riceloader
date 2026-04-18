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
    MaxDistance = 500,
    AimSpeed = 0.15, -- 0.1~0.2 사이가 "부드럽고 빠른" 수치입니다.
    
    ScannerMaster = false,
    ScannerKey = Enum.KeyCode.V,
    
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC V6 - FINAL RIVALS",
    LoadingTitle = "Rivals Optimized System",
    LoadingSubtitle = "Smooth & Fast Tracking",
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
    Name = "Aim Speed (0.1 ~ 0.5)",
    Info = "0.1에 가까울수록 부드럽고 팔 돌아감이 없습니다.",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value) Config.AimSpeed = Value / 100 end,
})

CombatTab:CreateSlider({
    Name = "Max Distance",
    Range = {100, 2000},
    Increment = 50,
    CurrentValue = 500,
    Callback = function(Value) Config.MaxDistance = Value end,
})

-- [[ 2. Visuals 탭 ]]
VisualsTab:CreateSection("ESP & Scanner")

VisualsTab:CreateToggle({
    Name = "Highlight (Glow)",
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

-- 하이라이트 ESP 폴더
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 스캐너 빌보드 생성
local function AddScanner(plr)
    if plr == LocalPlayer then return end
    local function onChar(char)
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
                    txt.Text = string.format("%s\n%dM", plr.DisplayName, dist)
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

-- [사용자 제공 기반] 가장 가까운 플레이어 탐색 함수
local function getClosestPlayerToCursor()
    local nearestHead = nil
    local shortestMouseDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")

            if head and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local worldDistance = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                    if worldDistance < Config.MaxDistance then
                        local mouseDistance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if mouseDistance < shortestMouseDistance then
                            shortestMouseDistance = mouseDistance
                            nearestHead = head
                        end
                    end
                end
            end
        end
    end
    return nearestHead
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

    -- 2. 에임봇 (사용자 요청: 0.1씩 빠르게 부드럽게)
    if Config.AimbotMaster and UserInputService:IsKeyDown(Config.AimKey) then
        local targetHead = getClosestPlayerToCursor()
        if targetHead then
            -- [수정] CFrame.lookAt에 UpVector(0,1,0)을 추가하여 팔 돌아감 방지
            -- [수정] Lerp를 사용하여 목표 지점까지 Config.AimSpeed(0.15) 비율로 부드럽게 이동
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position, Vector3.new(0, 1, 0))
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.AimSpeed)
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
    Title = "RICE SEC V6",
    Content = "작동 준비 완료! E와 V키를 사용하세요.",
    Duration = 5
})

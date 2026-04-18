local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ 서비스 설정 ]]
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
    Smoothness = 0.15, -- 영상 29초 스타일의 부드러움 수치
    
    ScannerMaster = false,
    ScannerKey = Enum.KeyCode.V,
    
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC PREMIUM V6 - SMOOTH",
    LoadingTitle = "RiceSec Hub",
    LoadingSubtitle = "Smooth & Stable Edition",
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
        Config.AimKey = Keybind
    end,
})

CombatTab:CreateSlider({
    Name = "Smoothness (조준 속도)",
    Info = "낮을수록 영상처럼 부드럽고 팔 돌아감이 없습니다.",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value) 
        Config.Smoothness = Value / 100 
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
VisualsTab:CreateSection("ESP & Scanner")

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
        Config.ScannerKey = Keybind
    end,
})

-- [[ 핵심 기능 구현 ]]

local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 스캐너 빌보드 (에러 방지 강화)
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
        txt.TextColor3 = Color3.new(1,1,1)
        txt.TextScaled = true
        txt.Font = Enum.Font.GothamBold

        task.spawn(function()
            while char and char.Parent do
                if bg.Enabled then
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot and head then
                        local dist = math.floor((myRoot.Position - head.Position).Magnitude)
                        txt.Text = string.format("%s [%dM]", plr.DisplayName, dist)
                    end
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

-- 안전한 타겟 찾기
local function GetTarget()
    local target = nil
    local minMouseDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local head = p.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local worldDist = (myRoot.Position - head.Position).Magnitude
                    if worldDist <= Config.AimRange then
                        local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if mouseDist < minMouseDist then
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
    -- ESP 처리
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = HL_Folder:FindFirstChild(p.Name) or Instance.new("Highlight", HL_Folder)
            hl.Adornee = p.Character
            hl.Enabled = Config.ESPEnabled
            hl.FillColor = Config.ESPColor
        end
    end

    -- 에임봇 처리 (영상 스타일 부드러운 Lerp 적용)
    if Config.AimbotMaster and UserInputService:IsKeyDown(Config.AimKey) then
        local target = GetTarget()
        if target and Camera.CFrame then
            -- [수정] 0.1 단위로 부드럽게 따라가는 로직
            -- UpVector(0,1,0) 고정으로 팔 꺾임 원천 차단
            local targetCF = CFrame.lookAt(Camera.CFrame.Position, target.Position, Vector3.new(0, 1, 0))
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Smoothness)
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

Rayfield:Notify({
    Title = "RICE SEC V6 LOADED",
    Content = "부드러운 에임봇 로직이 적용되었습니다.",
    Duration

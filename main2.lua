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
    AimSpeed = 0.15, -- 조준 부드러움 (0.01 ~ 1.0)
    
    ScannerMaster = false,
    ScannerKey = Enum.KeyCode.V,
    
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC V6 - STABLE FINAL",
    LoadingTitle = "RiceSec Hub",
    LoadingSubtitle = "Anti-Error & Smooth Edition",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)

-- [[ 1. Combat 탭 ]]
CombatTab:CreateSection("Aimbot Master")

CombatTab:CreateToggle({
    Name = "Enable Aimbot System",
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
    Name = "Smoothness (0.1 추적 조절)",
    Info = "0.1에 가까울수록 부드럽고 팔이 안 꺾입니다.",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value) Config.AimSpeed = Value / 100 end,
})

-- [[ 2. Visuals 탭 ]]
VisualsTab:CreateSection("Visuals & Scanner")

VisualsTab:CreateToggle({
    Name = "Player Highlight (ESP)",
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
    Name = "Enable Scanner System",
    CurrentValue = false,
    Callback = function(Value) Config.ScannerMaster = Value end,
})

VisualsTab:CreateKeybind({
    Name = "Scanner Key",
    CurrentKeybind = "V",
    HoldToInteract = false,
    Callback = function(Keybind) Config.ScannerKey = Keybind end,
})

-- [[ 기능 구현 ]]

-- 하이라이트 폴더
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 타겟 찾기 (가장 가까운 적)
local function GetTarget()
    local target = nil
    local minMouseDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local head = p.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mouseDist < minMouseDist then
                        minMouseDist = mouseDist
                        target = head
                    end
                end
            end
        end
    end
    return target
end

-- 스캐너 (빌보드)
local function SetupScanner(plr)
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
for _, p in ipairs(Players:GetPlayers()) do SetupScanner(p) end
Players.PlayerAdded:Connect(SetupScanner)

-- [[ 메인 루프 ]]
RunService.RenderStepped:Connect(function()
    -- 1. ESP
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = HL_Folder:FindFirstChild(p.Name) or Instance.new("Highlight", HL_Folder)
            hl.Adornee = p.Character
            hl.Enabled = Config.ESPEnabled
            hl.FillColor = Config.ESPColor
        end
    end

    -- 2. 에임봇 (에러 방지 강화 버전)
    if Config.AimbotMaster and UserInputService:IsKeyDown(Config.AimKey) then
        local target = GetTarget()
        -- 타겟과 타겟의 위치 정보가 확실히 존재할 때만 실행 (Line 161 에러 방지)
        if target and target:IsA("BasePart") then
            local targetPos = target.Position
            if targetPos and Camera.CFrame then
                -- UpVector 고정으로 팔 돌아감 방지
                local lookCF = CFrame.lookAt(Camera.CFrame.Position, targetPos, Vector3.new(0, 1, 0))
                Camera.CFrame = Camera.CFrame:Lerp(lookCF, Config.AimSpeed)
            end
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
    Title = "RICE SEC LOADED",
    Content = "모든 에러가 수정되었습니다.",
    Duration = 5
})

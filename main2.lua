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
    -- 에임봇
    AimbotMaster = false,
    AimKey = Enum.KeyCode.E,
    AimRange = 1000,
    
    -- 스캐너
    ScannerMaster = false,
    ScannerKey = Enum.KeyCode.V,
    
    -- ESP
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC PREMIUM V6 - FINAL",
    LoadingTitle = "RiceSec Systems",
    LoadingSubtitle = "by Premium Scripts",
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

-- 하이라이트 ESP 폴더
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 스캐너 빌보드 생성 함수
local function CreateScanner(plr)
    if plr == LocalPlayer then return end
    
    local function setup(char)
        local head = char:WaitForChild("Head", 10)
        if not head then return end
        
        local bg = Instance.new("BillboardGui", head)
        bg.Name = "ScannerGui"
        bg.Size = UDim2.new(6, 0, 4, 0)
        bg.AlwaysOnTop = true
        bg.Enabled = false
        bg.StudsOffset = Vector3.new(0, 3, 0)

        local frame = Instance.new("Frame", bg)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        Instance.new("UIListLayout", frame).HorizontalAlignment = Enum.HorizontalAlignment.Center

        local function mkLabel(name, color)
            local l = Instance.new("TextLabel", frame)
            l.Size = UDim2.new(1, 0, 0.3, 0)
            l.BackgroundTransparency = 0.5
            l.BackgroundColor3 = Color3.new(0,0,0)
            l.TextColor3 = color
            l.TextScaled = true
            l.Font = Enum.Font.GothamBold
            Instance.new("UICorner", l)
            return l
        end

        local nLabel = mkLabel("N", Color3.new(1,1,1))
        local hLabel = mkLabel("H", Color3.new(0,1,0))

        task.spawn(function()
            while char and char.Parent do
                if bg.Enabled then
                    local hum = char:FindFirstChild("Humanoid")
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                    nLabel.Text = string.format("%s [%dM]", plr.DisplayName, dist)
                    if hum then
                        hLabel.Text = string.format("HP: %d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))
                        hLabel.TextColor3 = Color3.fromHSV(math.clamp(hum.Health/hum.MaxHealth, 0, 1) * 0.35, 0.9, 1)
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

-- 에임봇 타겟 찾기 (가장 가까운 적)
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
        end
    end

    -- 2. 에임봇 (마스터 켜짐 + 키 누르고 있음)
    if Config.AimbotMaster and UserInputService:IsKeyDown(Config.AimKey) then
        local target = GetTarget()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end

    -- 3. 스캐너 (마스터 켜짐 + 키 누르고 있음)
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
    Content = "에임봇과 스캐너는 지정된 키를 꾹 누를 때만 활성화됩니다.",
    Duration = 5
})

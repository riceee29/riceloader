local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ 기본 서비스 설정 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 전역 설정 값 ]]
local Config = {
    -- 에임봇 설정
    AimbotMaster = false,
    AimKey = Enum.KeyCode.E,
    AimRange = 1000,
    
    -- 스캐너 설정
    ScannerMaster = false,
    ScannerKey = Enum.KeyCode.V,
    
    -- 비주얼(ESP) 설정
    HighlightEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 창 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC PREMIUM V6",
    LoadingTitle = "RiceSec Hub",
    LoadingSubtitle = "High Performance Scripts",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- [[ 탭 생성 ]]
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)

-- [[ 1. COMBAT 탭 구성 ]]
CombatTab:CreateSection("Aimbot Master Settings")

CombatTab:CreateToggle({
    Name = "Enable Aimbot System",
    CurrentValue = false,
    Flag = "AimToggle",
    Callback = function(Value) Config.AimbotMaster = Value end,
})

CombatTab:CreateKeybind({
    Name = "Aimbot Hold Key",
    CurrentKeybind = "E",
    HoldToInteract = false,
    Flag = "AimBind",
    Callback = function(Keybind) 
        Config.AimKey = typeof(Keybind) == "EnumItem" and Keybind or Enum.KeyCode[Keybind]
    end,
})

CombatTab:CreateSlider({
    Name = "Aimbot FOV Range",
    Range = {100, 3000},
    Increment = 100,
    CurrentValue = 1000,
    Callback = function(Value) Config.AimRange = Value end,
})

-- [[ 2. VISUALS 탭 구성 ]]
VisualsTab:CreateSection("Highlight ESP")

VisualsTab:CreateToggle({
    Name = "Glow (Highlight)",
    CurrentValue = false,
    Flag = "GlowToggle",
    Callback = function(Value) Config.HighlightEnabled = Value end,
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(175, 25, 255),
    Callback = function(Value) Config.ESPColor = Value end
})

VisualsTab:CreateSection("Scanner Master Settings")

VisualsTab:CreateToggle({
    Name = "Enable Scanner System",
    CurrentValue = false,
    Flag = "ScanToggle",
    Callback = function(Value) Config.ScannerMaster = Value end,
})

VisualsTab:CreateKeybind({
    Name = "Scanner Hold Key",
    CurrentKeybind = "V",
    HoldToInteract = false,
    Flag = "ScanBind",
    Callback = function(Keybind) 
        Config.ScannerKey = typeof(Keybind) == "EnumItem" and Keybind or Enum.KeyCode[Keybind]
    end,
})

-- [[ 핵심 기능 로직 구현 ]]

-- 1. 하이라이트 ESP 관리
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 2. 스캐너 GUI 생성 (머리 위에 정보 표시)
local function createScanner(player)
    if player == LocalPlayer then return end
    
    local function setupChar(char)
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
        
        local layout = Instance.new("UIListLayout", frame)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Padding = UDim.new(0, 2)

        local function createLabel(name, color)
            local lbl = Instance.new("TextLabel", frame)
            lbl.Name = name
            lbl.Size = UDim2.new(1, 0, 0.25, 0)
            lbl.BackgroundTransparency = 0.5
            lbl.BackgroundColor3 = Color3.new(0,0,0)
            lbl.TextColor3 = color
            lbl.TextScaled = true
            lbl.Font = Enum.Font.GothamBold
            Instance.new("UICorner", lbl)
            return lbl
        end

        local nameLabel = createLabel("NameLabel", Color3.new(1,1,1))
        local hpLabel = createLabel("HPLabel", Color3.new(0,1,0))
        local itemLabel = createLabel("ItemLabel", Color3.new(1,1,0))

        task.spawn(function()
            while char and char.Parent do
                if bg.Enabled then
                    local hum = char:FindFirstChild("Humanoid")
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                    
                    nameLabel.Text = string.format("%s [%dM]", player.DisplayName, dist)
                    if hum then
                        hpLabel.Text = "HP: " .. math.floor(hum.Health)
                        hpLabel.TextColor3 = Color3.fromHSV(math.clamp(hum.Health/hum.MaxHealth, 0, 1) * 0.35, 0.9, 1)
                    end

                    -- 아이템 스캐너 로직 (특정 게임 UI 기반)
                    local inv = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("MainGui")
                    if inv then
                        -- 게임의 UI 구조에 맞춰 이 부분을 수정할 수 있습니다.
                        itemLabel.Text = "Scanning Inventory..."
                        itemLabel.Visible = true
                    else
                        itemLabel.Visible = false
                    end
                end
                task.wait(0.2)
            end
        end)
    end
    player.CharacterAdded:Connect(setupChar)
    if player.Character then setupChar(player.Character) end
end

for _, p in ipairs(Players:GetPlayers()) do createScanner(p) end
Players.PlayerAdded:Connect(createScanner)

-- 3. 에임봇 타겟 찾기
local function getClosestEnemy()
    local target = nil
    local shortestMouseDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local wDist = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                    if wDist <= Config.AimRange then
                        local mDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if mDist < shortestMouseDist then
                            shortestMouseDist = mDist
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
            hl.Enabled = Config.HighlightEnabled
            hl.FillColor = Config.ESPColor
            hl.OutlineColor = Color3.new(1,1,1)
        end
    end

    -- 2. 에임봇 (마스터 온 + 키 누름 중)
    if Config.AimbotMaster and UserInputService:IsKeyDown(Config.AimKey) then
        local target = getClosestEnemy()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end

    -- 3. 스캐너 (마스터 온 + 키 누름 중)
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
    Content = "에임봇(E)와 스캐너(V)는 키를 꾹 누르고 있을 때만 작동합니다.",
    Duration = 5
})

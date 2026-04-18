local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 전역 설정 ]]
local Config = {
    Aimbot = false,
    AimKey = Enum.KeyCode.E,
    MaxDistance = 1000,
    
    Scanner = false,
    ScannerKey = Enum.KeyCode.V,
    
    Highlight = false,
    ESPColor = Color3.fromRGB(175, 25, 255),
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

-- [[ 1. Combat 설정 ]]
CombatTab:CreateSection("Aimbot Settings")

CombatTab:CreateToggle({
    Name = "Aimbot Master",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value) Config.Aimbot = Value end,
})

CombatTab:CreateKeybind({
    Name = "Aimbot Key",
    CurrentKeybind = "E",
    HoldToInteract = true,
    Flag = "AimBind",
    Callback = function(Keybind) Config.AimKey = Keybind end,
})

CombatTab:CreateSlider({
    Name = "Aimbot Range",
    Range = {100, 3000},
    Increment = 100,
    CurrentValue = 1000,
    Callback = function(Value) Config.MaxDistance = Value end,
})

-- [[ 2. Visuals 설정 ]]
VisualsTab:CreateSection("ESP & Scanner")

VisualsTab:CreateToggle({
    Name = "Player Glow (Highlight)",
    CurrentValue = false,
    Flag = "HighlightToggle",
    Callback = function(Value) Config.Highlight = Value end,
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(175, 25, 255),
    Callback = function(Value) Config.ESPColor = Value end
})

VisualsTab:CreateSection("Scanner Settings")

VisualsTab:CreateToggle({
    Name = "Scanner Master",
    CurrentValue = false,
    Callback = function(Value) Config.Scanner = Value end,
})

VisualsTab:CreateKeybind({
    Name = "Scanner Key",
    CurrentKeybind = "V",
    HoldToInteract = true,
    Callback = function(Keybind) Config.ScannerKey = Keybind end,
})

-- [[ 기능 구현 ]]

-- 1. 하이라이트 ESP 폴더
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 2. 스캐너 GUI 생성 및 관리
local function updateScanner(player)
    if player == LocalPlayer then return end
    
    local function setup(character)
        local head = character:WaitForChild("Head", 10)
        if not head then return end
        
        local bb = head:FindFirstChild("ScannerGui") or Instance.new("BillboardGui", head)
        bb.Name = "ScannerGui"
        bb.Size = UDim2.new(8, 0, 5, 0)
        bb.StudsOffset = Vector3.new(0, 4, 0)
        bb.AlwaysOnTop = true
        bb.Enabled = false

        local container = bb:FindFirstChild("Container") or Instance.new("Frame", bb)
        container.Name = "Container"
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        
        local layout = container:FindFirstChild("Layout") or Instance.new("UIListLayout", container)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Padding = UDim.new(0, 2)

        task.spawn(function()
            while character and character.Parent do
                if bb.Enabled then
                    for _, v in ipairs(container:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
                    
                    -- 기본 정보 (이름/체력) - 스캐너가 작동하는지 확인용
                    local hum = character:FindFirstChild("Humanoid")
                    local hp = hum and math.floor(hum.Health) or 0
                    
                    local info = Instance.new("TextLabel", container)
                    info.Size = UDim2.new(1, 0, 0.25, 0)
                    info.Text = string.format("[%s] HP: %d", player.DisplayName, hp)
                    info.TextColor3 = Color3.new(1, 1, 1)
                    info.BackgroundTransparency = 0.5
                    info.BackgroundColor3 = Color3.new(0,0,0)
                    info.TextScaled = true
                    Instance.new("UICorner", info)

                    -- 아이템 인터페이스 스캔 (특정 게임용)
                    local pg = player:FindFirstChild("PlayerGui")
                    local targetRoot = pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("MainFrame") and pg.MainGui.MainFrame:FindFirstChild("ItemInterfaces")
                    
                    if targetRoot then
                        for _, item in ipairs(targetRoot:GetChildren()) do
                            local lbl = Instance.new("TextLabel", container)
                            lbl.Size = UDim2.new(1, 0, 0.2, 0)
                            lbl.Text = "Item: " .. item.Name
                            lbl.TextColor3 = Color3.fromRGB(255, 255, 100)
                            lbl.BackgroundTransparency = 0.5
                            lbl.BackgroundColor3 = Color3.new(0,0,0)
                            lbl.TextScaled = true
                            Instance.new("UICorner", lbl)
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
    player.CharacterAdded:Connect(setup)
    if player.Character then setup(player.Character) end
end

for _, p in ipairs(Players:GetPlayers()) do updateScanner(p) end
Players.PlayerAdded:Connect(updateScanner)

-- 3. 에임봇 타겟 로직
local function getTarget()
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
                    if worldDist <= Config.MaxDistance then
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
    -- ESP 처리
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = HL_Folder:FindFirstChild(p.Name) or Instance.new("Highlight", HL_Folder)
            hl.Name = p.Name
            hl.Adornee = p.Character
            hl.Enabled = Config.Highlight
            hl.FillColor = Config.ESPColor
            hl.OutlineColor = Color3.new(1, 1, 1)
        end
    end

    -- 에임봇 처리 (키 눌림 직접 감지)
    if Config.Aimbot and UserInputService:IsKeyDown(Config.AimKey) then
        local target = getTarget()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end

    -- 스캐너 가시성 처리
    local showScanner = Config.Scanner and UserInputService:IsKeyDown(Config.ScannerKey)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local gui = p.Character.Head:FindFirstChild("ScannerGui")
            if gui then gui.Enabled = showScanner end
        end
    end
end)

Rayfield:Notify({
    Title = "RICE SEC LOADED",
    Content = "에임봇(E), 스캐너(V) 키를 확인하세요.",
    Duration = 5
})

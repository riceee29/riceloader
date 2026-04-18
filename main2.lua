-- [[ Rayfield UI 라이브러리 로드 ]]
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
    MaxDistance = 500,
    
    Scanner = false, -- 토글 상태
    ScannerKey = Enum.KeyCode.V,
    
    Highlight = false,
    ESPColor = Color3.fromRGB(175, 25, 255),
    
    IsAiming = false,
    ScannerActive = false -- V키 눌림 상태
}

-- [[ UI 창 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC PREMIUM V6 - FINAL",
    LoadingTitle = "RiceSec Systems",
    LoadingSubtitle = "by Premium Scripts",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RiceSec_V6",
        FileName = "Config"
    },
    KeySystem = false
})

-- [[ 탭 생성 ]]
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)

-- [[ 1. Combat 탭 ]]
CombatTab:CreateSection("Aimbot Settings")

CombatTab:CreateToggle({
    Name = "Aimbot Master",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        Config.Aimbot = Value
    end,
})

CombatTab:CreateKeybind({
    Name = "Aimbot Keybind",
    CurrentKeybind = "E",
    HoldToInteract = true,
    Flag = "AimBind",
    Callback = function(Keybind)
        Config.AimKey = Keybind
    end,
})

CombatTab:CreateSlider({
    Name = "Aimbot Range",
    Range = {100, 2000},
    Increment = 50,
    Suffix = "Studs",
    CurrentValue = 500,
    Flag = "DistSlider",
    Callback = function(Value)
        Config.MaxDistance = Value
    end,
})

-- [[ 2. Visuals 탭 ]]
VisualsTab:CreateSection("Highlight ESP")

VisualsTab:CreateToggle({
    Name = "Glow ESP Enabled",
    CurrentValue = false,
    Flag = "HighlightToggle",
    Callback = function(Value)
        Config.Highlight = Value
    end,
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(175, 25, 255),
    Flag = "GlowColor",
    Callback = function(Value)
        Config.ESPColor = Value
    end
})

VisualsTab:CreateSection("Scanner ESP")

VisualsTab:CreateToggle({
    Name = "Scanner Master (V Key)",
    CurrentValue = false,
    Flag = "ScannerToggle",
    Callback = function(Value)
        Config.Scanner = Value
    end,
})

-- [[ 기능 로직 구현 ]]

-- 1. 하이라이트 ESP 폴더
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 2. 스캐너 GUI 생성 함수
local function createScannerGui(player)
    if player == LocalPlayer then return end
    
    local function setup(character)
        local head = character:WaitForChild("Head", 10)
        if not head then return end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ScannerGui"
        billboard.Size = UDim2.new(10, 0, 8, 0)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = false
        billboard.Parent = head

        local infoList = Instance.new("Frame", billboard)
        infoList.Size = UDim2.new(1, 0, 1, 0)
        infoList.BackgroundTransparency = 1
        
        local layout = Instance.new("UIListLayout", infoList)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Padding = UDim.new(0, 5)

        -- 실시간 스캔 정보 업데이트 루프
        task.spawn(function()
            while character and character.Parent do
                if billboard.Enabled then
                    for _, v in ipairs(infoList:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
                    
                    local pg = player:FindFirstChild("PlayerGui")
                    if pg then
                        local targetRoot = pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("MainFrame") and pg.MainGui.MainFrame:FindFirstChild("ItemInterfaces")
                        if targetRoot then
                            for _, item in ipairs(targetRoot:GetChildren()) do
                                local lbl = Instance.new("TextLabel", infoList)
                                lbl.Size = UDim2.new(0.8, 0, 0.15, 0)
                                lbl.BackgroundColor3 = Color3.new(0,0,0)
                                lbl.BackgroundTransparency = 0.4
                                lbl.TextColor3 = Color3.new(1,1,1)
                                lbl.Text = item.Name
                                lbl.TextScaled = true
                                Instance.new("UICorner", lbl)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
    player.CharacterAdded:Connect(setup)
    if player.Character then setup(player.Character) end
end

for _, p in ipairs(Players:GetPlayers()) do createScannerGui(p) end
Players.PlayerAdded:Connect(createScannerGui)

-- 3. 에임봇 타겟 찾기 함수
local function getClosestTarget()
    local target = nil
    local dist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local worldDist = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                if worldDist <= Config.MaxDistance then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mouseDist < dist then
                        dist = mouseDist
                        target = head
                    end
                end
            end
        end
    end
    return target
end

-- [[ 메인 루프 (RenderStepped) ]]
RunService.RenderStepped:Connect(function()
    -- 하이라이트 처리
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = HL_Folder:FindFirstChild(p.Name) or Instance.new("Highlight", HL_Folder)
            hl.Name = p.Name
            hl.Adornee = p.Character
            hl.Enabled = Config.Highlight
            hl.FillColor = Config.ESPColor
            hl.OutlineColor = Color3.new(1,1,1)
        end
    end

    -- 에임봇 처리
    if Config.Aimbot and Config.IsAiming then
        local target = getClosestTarget()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- [[ 입력 감지 ]]
UserInputService.InputBegan:Connect(function(io, gp)
    if gp then return end
    if io.KeyCode == Config.AimKey then Config.IsAiming = true end
    
    if io.KeyCode == Config.ScannerKey and Config.Scanner then
        Config.ScannerActive = true
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                local gui = p.Character.Head:FindFirstChild("ScannerGui")
                if gui then gui.Enabled = true end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(io)
    if io.KeyCode == Config.AimKey then Config.IsAiming = false end
    
    if io.KeyCode == Config.ScannerKey then
        Config.ScannerActive = false
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                local gui = p.Character.Head:FindFirstChild("ScannerGui")
                if gui then gui.Enabled = false end
            end
        end
    end
end)

Rayfield:Notify({
    Title = "RICE SEC LOADED",
    Content = "모든 기능이 활성화되었습니다.",
    Duration = 5,
    Image = 4483345998,
})

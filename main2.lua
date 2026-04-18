-- [[ Rayfield 라이브러리 안전 로드 ]]
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
    AimRange = 2000, -- FOV를 뺐으므로 거리를 넉넉하게 설정
    Smoothness = 0.15, -- 영상 29초 스타일의 부드러움 (0.1 ~ 0.2 추천)
    
    ScannerMaster = false,
    ScannerKey = Enum.KeyCode.V,
    
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC V6 - RIVALS STABLE",
    LoadingTitle = "RiceSec Premium",
    LoadingSubtitle = "Anti-Error & Smooth Tracking",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)

-- [[ 1. COMBAT 탭 ]]
CombatTab:CreateSection("Aimbot Settings")

CombatTab:CreateToggle({
    Name = "Enable Aimbot System",
    CurrentValue = false,
    Callback = function(Value) Config.AimbotMaster = Value end,
})

CombatTab:CreateKeybind({
    Name = "Aimbot Hotkey",
    CurrentKeybind = "E",
    HoldToInteract = false,
    Callback = function(Keybind) Config.AimKey = Keybind end,
})

CombatTab:CreateSlider({
    Name = "Smoothness (조준 부드러움)",
    Info = "낮을수록 영상처럼 부드럽고 팔이 안 꺾입니다.",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value) Config.Smoothness = Value / 100 end,
})

-- [[ 2. VISUALS 탭 ]]
VisualsTab:CreateSection("ESP & Scanner")

VisualsTab:CreateToggle({
    Name = "Player Glow (Highlight)",
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
    Name = "Enable Scanner System",
    CurrentValue = false,
    Callback = function(Value) Config.ScannerMaster = Value end,
})

VisualsTab:CreateKeybind({
    Name = "Scanner Hotkey",
    CurrentKeybind = "V",
    HoldToInteract = false,
    Callback = function(Keybind) Config.ScannerKey = Keybind end,
})

-- [[ 안전한 타겟 찾기 로직 ]]
local function GetClosestTarget()
    local target = nil
    local shortestDist = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- 내 캐릭터가 살아있는지 확인
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                -- FOV를 뺐으므로 화면에 보이기만 하면 커서와 가장 가까운 적 선택
                if onScreen then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if mouseDist < shortestDist then
                        shortestDist = mouseDist
                        target = head
                    end
                end
            end
        end
    end
    return target
end

-- [[ 안전한 스캐너 생성 ]]
local function SetupScanner(plr)
    if plr == LocalPlayer then return end
    
    local function onChar(char)
        local head = char:WaitForChild("Head", 15)
        if not head then return end
        
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
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot and head then
                        local dist = math.floor((myRoot.Position - head.Position).Magnitude)
                        txt.Text = plr.DisplayName .. "\n[" .. dist .. "M]"
                    end
                end
                task.wait(0.2)
            end
        end)
    end
    plr.CharacterAdded:Connect(onChar)
    if plr.Character then onChar(plr.Character) end
end

for _, p in ipairs(Players:GetPlayers()) do SetupScanner(p) end
Players.PlayerAdded:Connect(SetupScanner)

-- [[ 메인 루프 ]]
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

RunService.RenderStepped:Connect(function()
    -- 1. 하이라이트 (ESP)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = HL_Folder:FindFirstChild(p.Name) or Instance.new("Highlight", HL_Folder)
            hl.Adornee = p.Character
            hl.Enabled = Config.ESPEnabled
            hl.FillColor = Config.ESPColor
        end
    end

    -- 2. 에임봇 (부드러운 조준 + 팔 돌아감 방지)
    if Config.AimbotMaster and UserInputService:IsKeyDown(Config.AimKey) then
        local target = GetClosestTarget()
        if target and Camera.CFrame then
            -- UpVector(0,1,0) 고정으로 팔 꺾임 방지
            local targetCF = CFrame.lookAt(Camera.CFrame.Position, target.Position, Vector3.new(0, 1, 0))
            -- Lerp를 이용해 0.1 단위로 부드럽게 추격
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Smoothness)
        end
    end

    -- 3. 스캐너 토글 제어
    local isScanning = Config.ScannerMaster and UserInputService:IsKeyDown(Config.ScannerKey)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local gui = p.Character.Head:FindFirstChild("ScannerGui")
            if gui then gui.Enabled = isScanning end
        end
    end
end)

Rayfield:Notify({
    Title = "RICE SEC V6 FIXED",
    Content = "에러 방지 로직이 강화되었습니다.",
    Duration = 5
})

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
    MaxDistance = 1000,
    Smoothness = 0.15, -- 에러 방지를 위한 기본값
    
    ScannerMaster = false,
    ScannerKey = Enum.KeyCode.V,
    
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC V6 - REFIXED",
    LoadingTitle = "Rivals Final Optimization",
    LoadingSubtitle = "Anti-Error & Smooth Aim",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)

-- [[ 1. Combat 탭 ]]
CombatTab:CreateSection("Aimbot Settings")

CombatTab:CreateToggle({
    Name = "Aimbot System Enable",
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
    Name = "Smoothness (조준 부드러움)",
    Info = "낮을수록 부드럽고 팔이 안 꺾입니다 (추천: 10~20)",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value) 
        Config.Smoothness = Value / 100 -- 0.01 ~ 1.0 범위로 변환
    end,
})

CombatTab:CreateSlider({
    Name = "Aim Range (거리)",
    Range = {100, 3000},
    Increment = 100,
    CurrentValue = 1000,
    Callback = function(Value) Config.MaxDistance = Value end,
})

-- [[ 2. Visuals 탭 ]]
VisualsTab:CreateSection("Visuals")

VisualsTab:CreateToggle({
    Name = "Glow ESP (Highlight)",
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

-- [[ 로직 파트 ]]

-- 하이라이트 폴더
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

-- 타겟 찾기 함수 (에러 방지 처리 완료)
local function GetTarget()
    local target = nil
    local minMouseDist = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local head = p.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- 에러 방지를 위해 캐릭터 존재 여부 다시 확인
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local worldDist = (root.Position - head.Position).Magnitude
                        if worldDist <= Config.MaxDistance then
                            local mouseDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                            if mouseDist < minMouseDist then
                                minMouseDist = mouseDist
                                target = head
                            end
                        end
                    end
                end
            end
        end
    end
    return target
end

-- 스캐너 빌보드 관리
local function SetupScanner(plr)
    if plr == LocalPlayer then return end
    local function charAdded(char)
        local head = char:WaitForChild("Head", 10)
        if not head then return end
        
        local bg = head:FindFirstChild("ScannerGui") or Instance.new("BillboardGui", head)
        bg.Name = "ScannerGui"
        bg.Size = UDim2.new(5, 0, 2, 0)
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
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                    txt.Text = plr.DisplayName .. "\n[" .. dist .. "M]"
                end
                task.wait(0.2)
            end
        end)
    end
    plr.CharacterAdded:Connect(charAdded)
    if plr.Character then charAdded(plr.Character) end
end

for _, p in ipairs(Players:GetPlayers()) do SetupScanner(p) end
Players.PlayerAdded:Connect(SetupScanner)

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

    -- 2. 에임봇 (Rivals 팔 돌아감 방지 로직)
    if Config.AimbotMaster and UserInputService:IsKeyDown(Config.AimKey) then
        local target = GetTarget()
        if target then
            -- UpVector (0,1,0) 고정으로 카메라 기울어짐(팔 꺾임) 원천 봉쇄
            local targetCF = CFrame.lookAt(Camera.CFrame.Position, target.Position, Vector3.new(0, 1, 0))
            -- Lerp를 이용해 부드럽게 추격 (Config.Smoothness 값에 따라 속도 결정)
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
    Title = "RICE SEC V6 LOADED",
    Content = "에러 방지 로직 및 스무스 설정이 적용되었습니다.",
    Duration = 5
})

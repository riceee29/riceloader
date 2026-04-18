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
    Smoothness = 0.15,
    
    ScannerMaster = false,
    ScannerKey = Enum.KeyCode.V,
    
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(175, 25, 255)
}

-- [[ UI 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE SEC V6 - ERROR FIXED",
    LoadingTitle = "Rivals Anti-Error Edition",
    LoadingSubtitle = "Stable & Smooth Tracking",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)

-- [[ 1. Combat 탭 ]]
CombatTab:CreateSection("Aimbot Settings")

CombatTab:CreateToggle({
    Name = "Aimbot Enable",
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
    Info = "낮을수록 부드럽고 팔이 안 돌아갑니다.",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value) Config.Smoothness = Value / 100 end,
})

-- [[ 2. Visuals 탭 ]]
VisualsTab:CreateSection("Visuals")

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

-- [[ 안전한 타겟 찾기 함수 ]]
local function GetTarget()
    local target = nil
    local minMouseDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- 내 캐릭터가 살아있는지 먼저 확인 (에러 방지 핵심)
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
                    if worldDist <= Config.MaxDistance then
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

-- [[ 안전한 스캐너 설정 ]]
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
                -- 내 캐릭터와 상대방 캐릭터 부위가 모두 존재할 때만 계산 (에러 방지)
                if bg.Enabled then
                    local myChar = LocalPlayer.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if myRoot and head then
                        local dist = math.floor((myRoot.Position - head.Position).Magnitude)
                        txt.Text = plr.DisplayName .. "\n[" .. dist .. "M]"
                    end
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
            hl.OutlineColor = Color3.new(1, 1, 1)
        end
    end

    -- 2. 에임봇 (Rivals 최적화 & 에러 방지)
    if Config.AimbotMaster and UserInputService:IsKeyDown(Config.AimKey) then
        local target = GetTarget()
        -- target과 Camera.CFrame이 모두 nil이 아닐 때만 계산
        if target and Camera.CFrame then
            local targetPos = target.Position
            if targetPos then
                local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPos, Vector3.new(0, 1, 0))
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Smoothness)
            end
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
    Title = "RICE SEC V6 - FIXED",
    Content = "에러가 수정되었습니다. Smoothness를 조절하세요.",
    Duration = 5
})

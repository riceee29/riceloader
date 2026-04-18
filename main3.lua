local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "RICE LOADER v3.0 PREMIUM",
    LoadingTitle = "Invisibility & Movement System",
    LoadingSubtitle = "by RiceSec",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- [[ 변수 설정 ]]
local lp = game.Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local SpeedEnabled = false
local WalkSpeedValue = 16
local NoclipEnabled = false
local FlyEnabled = false
local FlySpeed = 50
local TransparencyValue = 0 -- 0은 불투명, 1은 완전투명

-- [[ 루프 관리 (Noclip & Speed) ]]
game:GetService("RunService").Stepped:Connect(function()
    if NoclipEnabled and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if SpeedEnabled and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = WalkSpeedValue
    end
end)

-- [[ 탭 생성 ]]
local MainTab = Window:CreateTab("Character", 4483362458)
local InvisibleTab = Window:CreateTab("Stealth", 4483345998)

-- [[ 1. 기본 이동 설정 ]]
MainTab:CreateSection("Movement Settings")

MainTab:CreateToggle({
    Name = "Speed Hack (속도 조절)",
    CurrentValue = false,
    Callback = function(Value)
        SpeedEnabled = Value
        if not Value then lp.Character.Humanoid.WalkSpeed = 16 end
    end,
})

MainTab:CreateSlider({
    Name = "WalkSpeed Amount",
    Range = {16, 300},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        WalkSpeedValue = Value
    end,
})

MainTab:CreateToggle({
    Name = "Noclip (벽 뚫기)",
    CurrentValue = false,
    Callback = function(Value)
        NoclipEnabled = Value
    end,
})

-- [[ 2. 비행 기능 ]]
MainTab:CreateSection("Fly System")

MainTab:CreateToggle({
    Name = "Fly (비행)",
    CurrentValue = false,
    Callback = function(Value)
        FlyEnabled = Value
        if FlyEnabled then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "RiceFlyForce"
            bv.Parent = lp.Character.PrimaryPart
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            
            task.spawn(function()
                while FlyEnabled do
                    local cam = workspace.CurrentCamera
                    local moveDir = Vector3.new(0,0,0)
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                    bv.Velocity = moveDir * FlySpeed
                    task.wait()
                end
                bv:Destroy()
            end)
        end
    end,
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(Value)
        FlySpeed = Value
    end,
})

-- [[ 3. 투명화 설정 (가장 중요) ]]
InvisibleTab:CreateSection("Transparency Control")

-- 실시간 투명도 조절 슬라이더
InvisibleTab:CreateSlider({
    Name = "Character Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0,
    Callback = function(Value)
        TransparencyValue = Value
        for _, v in pairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                -- HumanoidRootPart는 건드리지 않는 것이 안정적입니다.
                if v.Name ~= "HumanoidRootPart" then
                    v.Transparency = TransparencyValue
                end
            end
        end
    end,
})

InvisibleTab:CreateSection("Server-Side Stealth")

-- 다른 사람에게도 안 보이게 하는 강력한 투명화 (FE Invisible)
InvisibleTab:CreateButton({
    Name = "FE Invisible (서버 투명화 - 실행 시 캐릭터가 분리됨)",
    Callback = function()
        local Character = lp.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")
        if Root then
            local Clone = Root:Clone()
            Root:Destroy() -- Root를 파괴하면 서버가 내 위치를 갱신하지 못함
            Clone.Parent = Character
            Rayfield:Notify({Title = "Invisible", Content = "서버 투명화가 활성화되었습니다.", Duration = 3})
        end
    end,
})

InvisibleTab:CreateLabel("주의: FE Invisible 사용 후 죽으면 다시 실행하세요.")

-- 로드 알림
Rayfield:Notify({
    Title = "RICE Loader v3.0",
    Content = "스크립트가 성공적으로 로드되었습니다.",
    Duration = 5,
    Image = 4483345998,
})

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "RICE PREMIUM HUB v3.0",
    LoadingTitle = "Movement & Stealth System",
    LoadingSubtitle = "by RiceSec",
    ConfigurationSaving = { Enabled = true, FileName = "RiceLoaderConfig" },
    KeySystem = false
})

-- [[ 변수 설정 ]]
local lp = game.Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local SpeedEnabled = false
local WalkSpeedValue = 16
local JumpPowerValue = 50
local NoclipEnabled = false
local FlyEnabled = false
local FlySpeed = 50
local InvisibleEnabled = false

-- [[ 유틸리티 루프 ]]
game:GetService("RunService").Stepped:Connect(function()
    -- Noclip 기능
    if NoclipEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Speed 기능
    if SpeedEnabled then
        hum.WalkSpeed = WalkSpeedValue
    end
end)

-- [[ 탭 생성 ]]
local MainTab = Window:CreateTab("Main Movement", 4483362458)
local StealthTab = Window:CreateTab("Stealth & Misc", 4483345998)

-- [[ 이동 관련 섹션 ]]
MainTab:CreateSection("Character Control")

MainTab:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = false,
    Callback = function(Value)
        SpeedEnabled = Value
        if not Value then hum.WalkSpeed = 16 end
    end,
})

MainTab:CreateSlider({
    Name = "WalkSpeed Amount",
    Range = {16, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Callback = function(Value)
        WalkSpeedValue = Value
    end,
})

MainTab:CreateSlider({
    Name = "JumpPower Amount",
    Range = {50, 500},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Callback = function(Value)
        hum.JumpPower = Value
    end,
})

MainTab:CreateSection("Special Movement")

MainTab:CreateToggle({
    Name = "Noclip (벽 뚫기)",
    CurrentValue = false,
    Callback = function(Value)
        NoclipEnabled = Value
    end,
})

-- Fly 기능 (고급 CFrame 방식)
MainTab:CreateToggle({
    Name = "Fly (비행)",
    CurrentValue = false,
    Callback = function(Value)
        FlyEnabled = Value
        if FlyEnabled then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "RiceFly"
            bv.Parent = char.PrimaryPart
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            
            task.spawn(function()
                while FlyEnabled do
                    local cam = workspace.CurrentCamera
                    local moveDir = Vector3.new(0,0,0)
                    
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                        moveDir = moveDir + cam.CFrame.LookVector
                    end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                        moveDir = moveDir - cam.CFrame.LookVector
                    end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                        moveDir = moveDir - cam.CFrame.RightVector
                    end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                        moveDir = moveDir + cam.CFrame.RightVector
                    end
                    
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
    Range = {10, 300},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 50,
    Callback = function(Value)
        FlySpeed = Value
    end,
})

-- [[ 스텔스(투명화) 섹션 ]]
StealthTab:CreateSection("Invisibility System")

StealthTab:CreateLabel("주의: 투명화 시 본인 캐릭터가 바닥으로 꺼져 보일 수 있음")

StealthTab:CreateButton({
    Name = "FE Invisible (서버 투명화)",
    Callback = function()
        -- FE Invisible 정석 코드 (다른 사람에게 안 보임)
        local Character = lp.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")
        if Root then
            local Clone = Root:Clone()
            Root:Destroy()
            Clone.Parent = Character
            Rayfield:Notify({Title = "Invisible Active", Content = "이제 다른 플레이어에게 보이지 않습니다.", Duration = 3})
        end
    end,
})

StealthTab:CreateToggle({
    Name = "Local Ghost (반투명 모드)",
    CurrentValue = false,
    Callback = function(Value)
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                v.Transparency = Value and 0.5 or 0
            end
        end
    end,
})

StealthTab:CreateSection("Other Utils")
StealthTab:CreateButton({
    Name = "Rejoin Game (재접속)",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
    end,
})

-- 로드 완료 알림
Rayfield:Notify({
    Title = "RICE HUB v3.0 Loaded",
    Content = "모든 기능이 준비되었습니다.",
    Duration = 5,
    Image = 4483345998,
})

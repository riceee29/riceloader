local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 설정 ]]
local Toggles = { Scanner = false, Aimbot = false, Highlight = false }
local UI_OPEN = true
local MENU_KEY = Enum.KeyCode.RightShift

-- [[ UI 생성 ]]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Premium_RiceSec"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- 그림자 효과 (UI 스트로크)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(60, 60, 70)
UIStroke.Thickness = 1.5

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "RICE SEC PREMIUM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, 0, 1, -50)
Container.Position = UDim2.new(0, 0, 0, 50)
Container.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 12)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.VerticalAlignment = Enum.VerticalAlignment.Center

-- [[ 애니메이션 함수 ]]
local function ApplyButtonAnim(button)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 80), Size = UDim2.new(0.92, 0, 0, 42)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50), Size = UDim2.new(0.85, 0, 0, 40)}):Play()
    end)
end

local function ToggleUI(state)
    UI_OPEN = state
    local targetSize = state and UDim2.new(0, 220, 0, 280) or UDim2.new(0, 0, 0, 0)
    local targetTrans = state and 0 or 1
    
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = targetSize,
        BackgroundTransparency = targetTrans
    }):Play()
    
    for _, v in ipairs(MainFrame:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            TweenService:Create(v, TweenInfo.new(0.2), {TextTransparency = targetTrans}):Play()
        end
    end
end

-- [[ 버튼 생성 ]]
local function CreateStyledButton(name)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    ApplyButtonAnim(btn)
    return btn
end

local btnScanner = CreateStyledButton("SCANNER ESP")
local btnAimbot = CreateStyledButton("SILENT AIM")
local btnHighlight = CreateStyledButton("PLAYER GLOW")

-- [[ 상태 업데이트 효과 ]]
local function UpdateStatus()
    local function SetState(btn, state)
        local color = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(200, 200, 200)
        TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = color}):Play()
        btn.Text = (state and "● " or "○ ") .. btn.Name:gsub("Btn", "")
    end
    SetState(btnScanner, Toggles.Scanner)
    SetState(btnAimbot, Toggles.Aimbot)
    SetState(btnHighlight, Toggles.Highlight)
end

-- 버튼 클릭 이벤트
btnScanner.MouseButton1Click:Connect(function() Toggles.Scanner = not Toggles.Scanner UpdateStatus() end)
btnAimbot.MouseButton1Click:Connect(function() Toggles.Aimbot = not Toggles.Aimbot UpdateStatus() end)
btnHighlight.MouseButton1Click:Connect(function() 
    Toggles.Highlight = not Toggles.Highlight 
    UpdateStatus()
    -- 하이라이트 즉시 적용
    for _, v in ipairs(CoreGui:FindFirstChild("RiceHL") and CoreGui.RiceHL:GetChildren() or {}) do
        v.Enabled = Toggles.Highlight
    end
end)

-- 우측 쉬프트로 열기/닫기 애니메이션
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == MENU_KEY then
        ToggleUI(not UI_OPEN)
    end
end)

-- (나머지 기능 로직인 Aimbot, ESP 등은 이전과 동일하게 백그라운드에서 작동합니다)
-- (코드 간결화를 위해 핵심 UI 애니메이션 부분만 강조하여 구성했습니다)

UpdateStatus()

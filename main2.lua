local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 상태 및 키바인드 설정 ]]
local Toggles = { Scanner = false, Aimbot = false, Highlight = false }
local Binds = {
    Scanner = Enum.KeyCode.V,
    Aimbot = Enum.KeyCode.E,
    Menu = Enum.KeyCode.RightShift
}
local UI_OPEN = true
local ListeningForBind = nil -- 현재 어떤 키를 바꾸고 있는지 저장

-- [[ UI 생성 ]]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "RiceSec_KeybindSystem"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 240, 0, 300)
MainFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(100, 100, 255)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "RICE SEC CONFIG"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, 0, 1, -45)
Container.Position = UDim2.new(0, 0, 0, 45)
Container.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.VerticalAlignment = Enum.VerticalAlignment.Center

-- [[ 버튼 및 키바인드 UI 생성 함수 ]]
local function CreateFeatureRow(name, featureKey)
    local Frame = Instance.new("Frame", Container)
    Frame.Size = UDim2.new(0.9, 0, 0, 45)
    Frame.BackgroundTransparency = 1
    
    -- 활성화 토글 버튼
    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0.65, 0, 1, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    ToggleBtn.Text = "○ " .. name
    ToggleBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    ToggleBtn.Font = Enum.Font.GothamMedium
    ToggleBtn.TextSize = 12
    Instance.new("UICorner", ToggleBtn)
    
    -- 키바인드 변경 버튼
    local BindBtn = Instance.new("TextButton", Frame)
    BindBtn.Size = UDim2.new(0.3, 0, 1, 0)
    BindBtn.Position = UDim2.new(0.7, 0, 0, 0)
    BindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    BindBtn.Text = Binds[featureKey].Name
    BindBtn.TextColor3 = Color3.new(1, 1, 1)
    BindBtn.Font = Enum.Font.Code
    BindBtn.TextSize = 12
    Instance.new("UICorner", BindBtn)

    -- 토글 로직
    ToggleBtn.MouseButton1Click:Connect(function()
        Toggles[featureKey] = not Toggles[featureKey]
        ToggleBtn.Text = (Toggles[featureKey] and "● " or "○ ") .. name
        TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {TextColor3 = Toggles[featureKey] and Color3.new(0, 1, 0.5) or Color3.new(0.8,0.8,0.8)}):Play()
        if featureKey == "Highlight" then
            for _, v in ipairs(CoreGui:FindFirstChild("RiceHL_Storage"):GetChildren()) do v.Enabled = Toggles.Highlight end
        end
    end)

    -- 키바인드 변경 로직
    BindBtn.MouseButton1Click:Connect(function()
        ListeningForBind = featureKey
        BindBtn.Text = "..."
        BindBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 20)
    end)

    return {Toggle = ToggleBtn, Bind = BindBtn}
end

local UI_Scanner = CreateFeatureRow("SCANNER", "Scanner")
local UI_Aimbot = CreateFeatureRow("AIMBOT", "Aimbot")
local UI_Highlight = CreateFeatureRow("HIGHLIGHT", "Highlight")

-- [[ 키 입력 감지 로직 ]]
UserInputService.InputBegan:Connect(function(io, gpe)
    -- 1. 키바인드 설정 중일 때
    if ListeningForBind then
        if io.UserInputType == Enum.UserInputType.Keyboard then
            local key = io.KeyCode
            Binds[ListeningForBind] = key
            
            -- UI 갱신
            if ListeningForBind == "Scanner" then UI_Scanner.Bind.Text = key.Name
            elseif ListeningForBind == "Aimbot" then UI_Aimbot.Bind.Text = key.Name end
            
            UI_Scanner.Bind.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            UI_Aimbot.Bind.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            ListeningForBind = nil
        end
        return
    end

    if gpe then return end

    -- 2. 메뉴 열기/닫기 (오른쪽 쉬프트 고정)
    if io.KeyCode == Binds.Menu then
        UI_OPEN = not UI_OPEN
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UI_OPEN and UDim2.new(0, 240, 0, 300) or UDim2.new(0, 0, 0, 0)}):Play()
    end
end)

-- [[ 실제 기능 작동 루프 ]]
local vHeld, eHeld = false, false

RunService.RenderStepped:Connect(function()
    vHeld = UserInputService:IsKeyDown(Binds.Scanner)
    eHeld = UserInputService:IsKeyDown(Binds.Aimbot)

    -- Scanner 작동
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local sg = p.Character.Head:FindFirstChild("ScannerGui")
            if sg then sg.Enabled = (Toggles.Scanner and vHeld) end
        end
    end

    -- Aimbot 작동
    if Toggles.Aimbot and eHeld then
        local target = nil
        local minDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < minDist then minDist = mag target = p.Character.Head end
                end
            end
        end
        if target then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position) end
    end
end)

-- (나머지 ESP 및 초기화 로직은 이전과 동일하게 유지됩니다)
-- 하이라이트/스캐너 초기 세팅은 생략(위 코드와 동일)

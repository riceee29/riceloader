local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 전역 설정 값 ]]
local Config = {
    Toggles = { Scanner = false, Aimbot = false, Highlight = false },
    Binds = { Scanner = Enum.KeyCode.V, Aimbot = Enum.KeyCode.E, Menu = Enum.KeyCode.RightShift },
    Colors = { ESP = Color3.fromRGB(175, 25, 255), UI = Color3.fromRGB(100, 100, 255) },
    UI_Open = true,
    Listening = nil -- 현재 키 바인딩 대기 중인 기능
}

-- [[ 하이라이트 저장소 ]]
local HL_Folder = CoreGui:FindFirstChild("RiceHL_Storage") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL_Storage"

-- [[ 고퀄리티 UI 생성 ]]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "RiceSec_Premium_V3"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 260, 0, 340)
MainFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- 테두리 빛 효과
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Config.Colors.UI
Stroke.Thickness = 2
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "RICE SEC PREMIUM"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Instance.new("UICorner", Title)

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, 0, 1, -55)
Container.Position = UDim2.new(0, 0, 0, 55)
Container.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [[ 유틸리티: 버튼 생성 함수 ]]
local function CreateMenuRow(name, key)
    local Row = Instance.new("Frame", Container)
    Row.Size = UDim2.new(0.9, 0, 0, 45)
    Row.BackgroundTransparency = 1

    local Toggle = Instance.new("TextButton", Row)
    Toggle.Size = UDim2.new(0.65, 0, 1, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Toggle.Text = "○ " .. name
    Toggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    Toggle.Font = Enum.Font.GothamMedium
    Toggle.TextSize = 12
    Instance.new("UICorner", Toggle)

    local Bind = Instance.new("TextButton", Row)
    Bind.Size = UDim2.new(0.3, 0, 1, 0)
    Bind.Position = UDim2.new(0.7, 0, 0, 0)
    Bind.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Bind.Text = Config.Binds[key] and Config.Binds[key].Name or "None"
    Bind.TextColor3 = Config.Colors.UI
    Bind.Font = Enum.Font.Code
    Bind.TextSize = 12
    Instance.new("UICorner", Bind)

    -- 토글 이벤트
    Toggle.MouseButton1Click:Connect(function()
        Config.Toggles[key] = not Config.Toggles[key]
        Toggle.Text = (Config.Toggles[key] and "● " or "○ ") .. name
        TweenService:Create(Toggle, TweenInfo.new(0.3), {TextColor3 = Config.Toggles[key] and Color3.new(0, 1, 0.5) or Color3.fromRGB(200, 200, 200)}):Play()
        
        if key == "Highlight" then
            for _, v in ipairs(HL_Folder:GetChildren()) do v.Enabled = Config.Toggles.Highlight end
        end
    end)

    -- 키바인드 설정 이벤트
    Bind.MouseButton1Click:Connect(function()
        Config.Listening = key
        Bind.Text = "..."
        Bind.BackgroundColor3 = Color3.fromRGB(60, 50, 20)
    end)

    return {Toggle = Toggle, Bind = Bind}
end

-- 색상 변경 로직 (ESP 색상 입력)
local function CreateColorInput()
    local Row = Instance.new("Frame", Container)
    Row.Size = UDim2.new(0.9, 0, 0, 45)
    Row.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(0.4, 0, 1, 0)
    Label.Text = "ESP COLOR (RGB)"
    Label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 10

    local Input = Instance.new("TextBox", Row)
    Input.Size = UDim2.new(0.55, 0, 1, 0)
    Input.Position = UDim2.new(0.45, 0, 0, 0)
    Input.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Input.Text = "175, 25, 255"
    Input.TextColor3 = Color3.new(1,1,1)
    Input.Font = Enum.Font.Code
    Input.TextSize = 12
    Instance.new("UICorner", Input)

    Input.FocusLost:Connect(function()
        local r, g, b = Input.Text:match("(%d+),%s*(%d+),%s*(%d+)")
        if r and g and b then
            Config.Colors.ESP = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
            for _, v in ipairs(HL_Folder:GetChildren()) do v.FillColor = Config.Colors.ESP end
        end
    end)
end

local UI_Scanner = CreateMenuRow("SCANNER", "Scanner")
local UI_Aimbot = CreateMenuRow("AIMBOT", "Aimbot")
local UI_Highlight = CreateMenuRow("HIGHLIGHT", "Highlight")
CreateColorInput()

-- [[ 핵심 기능 로직 ]]

-- 하이라이트 ESP
local function ApplyHighlight(plr)
    if plr == LocalPlayer then return end
    local hl = Instance.new("Highlight", HL_Folder)
    hl.Name = plr.Name
    hl.FillColor = Config.Colors.ESP
    hl.Enabled = Config.Toggles.Highlight
    local function update(char) hl.Adornee = char end
    if plr.Character then update(plr.Character) end
    plr.CharacterAdded:Connect(update)
end

-- 키 입력 감지 (토글 & 바인딩)
UserInputService.InputBegan:Connect(function(io, gpe)
    if Config.Listening then
        if io.UserInputType == Enum.UserInputType.Keyboard then
            Config.Binds[Config.Listening] = io.KeyCode
            if Config.Listening == "Scanner" then UI_Scanner.Bind.Text = io.KeyCode.Name
            elseif Config.Listening == "Aimbot" then UI_Aimbot.Bind.Text = io.KeyCode.Name end
            UI_Scanner.Bind.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            UI_Aimbot.Bind.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            Config.Listening = nil
        end
        return
    end

    if gpe then return end
    if io.KeyCode == Config.Binds.Menu then
        Config.UI_Open = not Config.UI_Open
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = Config.UI_Open and UDim2.new(0, 260, 0, 340) or UDim2.new(0,0,0,0)}):Play()
    end
end)

-- 루프 연산 (Aimbot & Scanner)
RunService.RenderStepped:Connect(function()
    local scannerDown = UserInputService:IsKeyDown(Config.Binds.Scanner)
    local aimbotDown = UserInputService:IsKeyDown(Config.Binds.Aimbot)

    -- Scanner ESP 가시성 업데이트
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local sg = p.Character.Head:FindFirstChild("ScannerGui")
            if sg then sg.Enabled = (Config.Toggles.Scanner and scannerDown) end
        end
    end

    -- Aimbot 로직
    if Config.Toggles.Aimbot and aimbotDown then
        local target = nil
        local shortest = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortest then shortest = dist target = p.Character.Head end
                end
            end
        end
        if target then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position) end
    end
end)

-- 초기화
for _, p in ipairs(Players:GetPlayers()) do ApplyHighlight(p) end
Players.PlayerAdded:Connect(ApplyHighlight)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 전역 설정 ]]
local Config = {
    Toggles = { Scanner = false, Aimbot = false, Highlight = false },
    Binds = { Scanner = Enum.KeyCode.V, Aimbot = Enum.KeyCode.E, Menu = Enum.KeyCode.RightShift },
    ESPColor = Color3.fromRGB(175, 25, 255),
    UI_Open = true,
    Listening = nil
}

-- [[ 하이라이트(Highlight)란? ]]
-- 캐릭터의 외곽선(Outline)과 내부(Fill)를 빛나게 만드는 최신 ESP입니다. 
-- 벽 뒤에서도 적의 형태가 3D로 뚜렷하게 보이며, 일반적인 박스 ESP보다 시인성이 압도적입니다.

-- [[ UI 생성 ]]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "RiceSec_V6_Final"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.4, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true -- 드래그를 위해 활성화
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(100, 100, 255)
Stroke.Thickness = 1.5

-- [[ 완벽 드래그 로직 ]]
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- [[ 사이드바 & 카테고리 ]]
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Instance.new("UICorner", Sidebar)

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Text = "RICE SEC\nPREMIUM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- [[ 메인 컨텐츠 영역 ]]
local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Position = UDim2.new(0, 140, 0, 15)
Content.Size = UDim2.new(1, -155, 1, -30)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 1.2, 0)
Content.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 10)

-- 섹션 생성 유틸리티
local function NewSection(name)
    local l = Instance.new("TextLabel", Content)
    l.Size = UDim2.new(1, 0, 0, 20)
    l.Text = " " .. name
    l.TextColor3 = Color3.fromRGB(100, 100, 150)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.BackgroundTransparency = 1
end

local function NewToggle(name, key)
    local Frame = Instance.new("Frame", Content)
    Frame.Size = UDim2.new(0.95, 0, 0, 40)
    Frame.BackgroundTransparency = 0.9
    Frame.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Frame)

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0.6, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = "○ " .. name
    Btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 13

    local Bind = Instance.new("TextButton", Frame)
    Bind.Size = UDim2.new(0.35, -5, 0.8, 0)
    Bind.Position = UDim2.new(0.65, 0, 0.1, 0)
    Bind.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Bind.Text = Config.Binds[key].Name
    Bind.TextColor3 = Color3.fromRGB(150, 150, 255)
    Bind.Font = Enum.Font.Code
    Instance.new("UICorner", Bind)

    Btn.MouseButton1Click:Connect(function()
        Config.Toggles[key] = not Config.Toggles[key]
        Btn.Text = (Config.Toggles[key] and "● " or "○ ") .. name
        TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Config.Toggles[key] and Color3.new(0, 1, 0.5) or Color3.new(0.8,0.8,0.8)}):Play()
    end)

    Bind.MouseButton1Click:Connect(function() Config.Listening = key Bind.Text = "..." end)
end

-- [[ 컬러보드 프리셋 시스템 ]]
local function NewColorBoard()
    NewSection("ESP COLOR BOARD")
    local Grid = Instance.new("Frame", Content)
    Grid.Size = UDim2.new(0.95, 0, 0, 40)
    Grid.BackgroundTransparency = 1
    local GLayout = Instance.new("UIGridLayout", Grid)
    GLayout.CellSize = UDim2.new(0, 35, 0, 35)

    local colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0), Color3.new(1,0,1), Color3.new(1,0.5,0)}
    for _, col in ipairs(colors) do
        local cbtn = Instance.new("TextButton", Grid)
        cbtn.Text = ""
        cbtn.BackgroundColor3 = col
        Instance.new("UICorner", cbtn)
        cbtn.MouseButton1Click:Connect(function() Config.ESPColor = col Stroke.Color = col end)
    end
end

-- 카테고리 배치
NewSection("COMBAT")
NewToggle("AIMBOT", "Aimbot")
NewSection("VISUALS")
NewToggle("SCANNER ESP", "Scanner")
NewToggle("PLAYER GLOW (HL)", "Highlight")
NewColorBoard()

-- [[ 핵심 기능 루프 ]]
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

RunService.RenderStepped:Connect(function()
    -- 하이라이트 작동
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = HL_Folder:FindFirstChild(p.Name) or Instance.new("Highlight", HL_Folder)
            hl.Name = p.Name
            hl.Adornee = p.Character
            hl.Enabled = Config.Toggles.Highlight
            hl.FillColor = Config.ESPColor
            hl.OutlineColor = Color3.new(1, 1, 1)
        end
    end
    -- 에임봇 작동
    if Config.Toggles.Aimbot and UserInputService:IsKeyDown(Config.Binds.Aimbot) then
        local target = nil local dist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then dist = mag target = p.Character.Head end
                end
            end
        end
        if target then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position) end
    end
end)

-- 키 바인딩 대기 및 메뉴 토글
UserInputService.InputBegan:Connect(function(io, g)
    if Config.Listening then
        Config.Binds[Config.Listening] = io.KeyCode
        Config.Listening = nil
        return
    end
    if not g and io.KeyCode == Config.Binds.Menu then
        Config.UI_Open = not Config.UI_Open
        MainFrame.Visible = Config.UI_Open
    end
end)

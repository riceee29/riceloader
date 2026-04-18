local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 설정 값 ]]
local Config = {
    Toggles = { Scanner = false, Aimbot = false, Highlight = false },
    Binds = { Scanner = Enum.KeyCode.V, Aimbot = Enum.KeyCode.E, Menu = Enum.KeyCode.RightShift },
    ESPColor = Color3.fromRGB(175, 25, 255),
    UI_Open = true,
    Listening = nil
}

-- [[ 하이라이트(Highlight) 설명 ]]
-- 하이라이트는 캐릭터 모델 전체에 "광원(Glow)" 효과를 주는 기능입니다. 
-- 벽 뒤에서도 적의 실루엣을 뚜렷하게 볼 수 있어 일반 박스 ESP보다 시인성이 훨씬 좋습니다.

-- [[ UI 생성 및 드래그 로직 ]]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "RiceSec_V5_Ultimate"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.4, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(60, 60, 70)
MainStroke.Thickness = 1.5

-- 드래그 기능 (상단 바 클릭 시 이동)
local DragBar = Instance.new("Frame", MainFrame)
DragBar.Size = UDim2.new(1, 0, 0, 40)
DragBar.BackgroundTransparency = 1
local dragging, dragInput, dragStart, startPos
DragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
DragBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- [[ 사이드바 (카테고리 구분) ]]
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UICorner", Sidebar)

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "RICE SEC"
Title.TextColor3 = Color3.fromRGB(150, 150, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- [[ 섹션 생성 ]]
local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 130, 0, 10)
Content.Size = UDim2.new(1, -140, 1, -20)
Content.BackgroundTransparency = 1

local function CreateCategory(name)
    local l = Instance.new("TextLabel", Content)
    l.Size = UDim2.new(1, 0, 0, 30)
    l.Text = "--- " .. name .. " ---"
    l.TextColor3 = Color3.fromRGB(100, 100, 110)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.BackgroundTransparency = 1
end

local function CreateToggle(name, key)
    local Frame = Instance.new("Frame", Content)
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundTransparency = 1
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0.6, 0, 0.8, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Btn.Text = "○ " .. name
    Btn.TextColor3 = Color3.new(0.8,0.8,0.8)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Instance.new("UICorner", Btn)

    local Bind = Instance.new("TextButton", Frame)
    Bind.Size = UDim2.new(0.35, 0, 0.8, 0)
    Bind.Position = UDim2.new(0.65, 0, 0, 0)
    Bind.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Bind.Text = Config.Binds[key] and Config.Binds[key].Name or "None"
    Bind.TextColor3 = Color3.fromRGB(150, 150, 255)
    Instance.new("UICorner", Bind)

    Btn.MouseButton1Click:Connect(function()
        Config.Toggles[key] = not Config.Toggles[key]
        Btn.Text = (Config.Toggles[key] and "● " or "○ ") .. name
        Btn.TextColor3 = Config.Toggles[key] and Color3.new(0.4, 1, 0.4) or Color3.new(0.8,0.8,0.8)
    end)

    Bind.MouseButton1Click:Connect(function()
        Config.Listening = key
        Bind.Text = "..."
    end)
end

-- 컬러보드 (RGB 슬라이더 대신 간편한 컬러 프리셋/직접입력)
local function CreateColorPicker()
    local Frame = Instance.new("Frame", Content)
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundTransparency = 1
    
    local Lbl = Instance.new("TextLabel", Frame)
    Lbl.Size = UDim2.new(0.4, 0, 1, 0)
    Lbl.Text = "ESP GLOW COLOR"
    Lbl.TextColor3 = Color3.new(1,1,1)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 11
    Lbl.BackgroundTransparency = 1

    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(0.55, 0, 0.8, 0)
    Box.Position = UDim2.new(0.45, 0, 0, 0)
    Box.BackgroundColor3 = Config.ESPColor
    Box.Text = "RGB: 175, 25, 255"
    Box.Font = Enum.Font.Code
    Box.TextSize = 10
    Instance.new("UICorner", Box)

    Box.FocusLost:Connect(function()
        local r, g, b = Box.Text:match("(%d+),%s*(%d+),%s*(%d+)")
        if r and g and b then
            Config.ESPColor = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
            Box.BackgroundColor3 = Config.ESPColor
        end
    end)
end

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 5)

-- 카테고리별 배치
CreateCategory("COMBAT")
CreateToggle("AIMBOT", "Aimbot")
CreateCategory("VISUALS")
CreateToggle("SCANNER ESP", "Scanner")
CreateToggle("PLAYER GLOW", "Highlight")
CreateColorPicker()

-- [[ 기능 로직 ]]
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

UserInputService.InputBegan:Connect(function(io, g)
    if Config.Listening then
        Config.Binds[Config.Listening] = io.KeyCode
        Config.Listening = nil
        MainFrame.Visible = true -- 키 세팅 후 UI 갱신 (직접 UI에서 텍스트 업데이트 로직 추가 권장)
        return
    end
    if g then return end
    if io.KeyCode == Config.Binds.Menu then
        Config.UI_Open = not Config.UI_Open
        MainFrame.Visible = Config.UI_Open
    end
end)

RunService.RenderStepped:Connect(function()
    -- 하이라이트(GLOW) 실시간 처리
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

    -- 에임봇 (E키)
    if Config.Toggles.Aimbot and UserInputService:IsKeyDown(Config.Binds.Aimbot) then
        local target = nil
        local dist = math.huge
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

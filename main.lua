local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- [1] 메인 UI 생성
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "RiceLoader_Premium"

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
MainFrame.Size = UDim2.new(0, 320, 0, 280)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- [2] 드래그 기능 구현 (움직일 수 있게)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- [3] 상단 바 및 장식
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "RICE LOADER v2.5"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

-- [4] 스크롤 리스트 (UIX 개선)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0.9, 0, 0.55, 0)
ScrollFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 0 -- 깔끔하게 숨김
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.Parent = ScrollFrame

-- 자동 캔버스 크기 조절
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
end)

local selectedURL = ""
local selectedBtn = nil

-- [5] 고퀄리티 UIX 버튼 생성 함수
local function addScript(name, url)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.98, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = ScrollFrame

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 8)
    bCorner.Parent = btn

    -- 버튼 애니메이션 효과
    btn.MouseButton1Click:Connect(function()
        if selectedBtn then
            TweenService:Create(selectedBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 30, 35), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
        end
        selectedURL = url
        selectedBtn = btn
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 100, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)

    btn.MouseEnter:Connect(function()
        if selectedBtn ~= btn then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if selectedBtn ~= btn then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
        end
    end)
end

-- 스크립트 목록 추가
addScript("Main ESP Script", "https://raw.githubusercontent.com/riceee29/riceloader/refs/heads/main/main2.lua?token=GHSAT0AAAAAAD2DMG6ME53SBJZOCNQFTLXQ2PDBYGQ")
addScript("Aimbot V3", "https://raw.githubusercontent.com/url2")
addScript("Speed & Jump Hack", "https://raw.githubusercontent.com/url3")
addScript("Auto Farm System", "https://raw.githubusercontent.com/url4")

-- [6] 메인 실행(Apply) 버튼
local ApplyButton = Instance.new("TextButton")
ApplyButton.Size = UDim2.new(0.9, 0, 0, 45)
ApplyButton.Position = UDim2.new(0.05, 0, 0.8, 0)
ApplyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
ApplyButton.Text = "EXECUTE"
ApplyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyButton.Font = Enum.Font.GothamBold
ApplyButton.TextSize = 16
ApplyButton.AutoButtonColor = false
ApplyButton.Parent = MainFrame

local aCorner = Instance.new("UICorner")
aCorner.CornerRadius = UDim.new(0, 8)
aCorner.Parent = ApplyButton

-- 실행 버튼 애니메이션 및 기능
ApplyButton.MouseButton1Click:Connect(function()
    if selectedURL ~= "" then
        ApplyButton.Text = "EXECUTING..."
        pcall(function() loadstring(game:HttpGet(selectedURL))() end)
        wait(1)
        ApplyButton.Text = "DONE!"
        wait(0.5)
        ApplyButton.Text = "EXECUTE"
    else
        ApplyButton.Text = "SELECT A SCRIPT!"
        wait(1)
        ApplyButton.Text = "EXECUTE"
    end
end)

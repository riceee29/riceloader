local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- 메인 설정
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "RiceLoaderV2"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -120)
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.BackgroundTransparency = 1
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

-- 상단 바 (제목)
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "RICE LOADER MULTI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BackgroundTransparency = 1

-- 스크롤 영역 (여러 버튼을 담는 곳)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.Size = UDim2.new(0.9, 0, 0.55, 0)
ScrollFrame.Position = UDim2.new(0.05, 0, 0.18, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0) -- 버튼이 많아지면 자동으로 늘어남
ScrollFrame.ScrollBarThickness = 2

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)

-- 상태 변수
local selectedURL = ""
local selectedButton = nil

-- 버튼 생성 함수
local function addScriptButton(name, scriptURL)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = ScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    -- 클릭 이벤트
    btn.MouseButton1Click:Connect(function()
        -- 이전 선택 해제 애니메이션
        if selectedButton and selectedButton ~= btn then
            TweenService:Create(selectedButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
        
        -- 현재 선택 애니메이션
        selectedURL = scriptURL
        selectedButton = btn
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 100, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)

    -- 마우스 올렸을 때 효과
    btn.MouseEnter:Connect(function()
        if selectedButton ~= btn then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if selectedButton ~= btn then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        end
    end)
end

-- [여기에 스크립트들을 추가하세요]
addScriptButton("1번 ESP 스크립트", "https://raw.githubusercontent.com/주소1")
addScriptButton("2번 에임봇 스크립트", "https://raw.githubusercontent.com/주소2")
addScriptButton("3번 스피드핵 스크립트", "https://raw.githubusercontent.com/주소3")
addScriptButton("4번 무한점프 스크립트", "https://raw.githubusercontent.com/주소4")
addScriptButton("5번 텔레포트 스크립트", "https://raw.githubusercontent.com/주소5")

-- 하단 실행(적용) 버튼
local ApplyButton = Instance.new("TextButton")
ApplyButton.Parent = MainFrame
ApplyButton.Size = UDim2.new(0.9, 0, 0, 45)
ApplyButton.Position = UDim2.new(0.05, 0, 0.82, 0)
ApplyButton.BackgroundColor3 = Color3.fromRGB(60, 180, 110)
ApplyButton.Text = "선택된 스크립트 실행"
ApplyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyButton.Font = Enum.Font.GothamBold
ApplyButton.TextSize = 16
ApplyButton.AutoButtonColor = false

local ApplyCorner = Instance.new("UICorner")
ApplyCorner.CornerRadius = UDim.new(0, 10)
ApplyCorner.Parent = ApplyButton

-- 적용 버튼 클릭 이벤트
ApplyButton.MouseButton1Click:Connect(function()
    if selectedURL ~= "" then
        ApplyButton.Text = "실행 중..."
        -- 실제 실행 부분
        local success, err = pcall(function()
            loadstring(game:HttpGet(selectedURL))()
        end)
        
        if success then
            ApplyButton.Text = "실행 완료!"
        else
            ApplyButton.Text = "오류 발생!"
            warn(err)
        end
        
        wait(1.5)
        ApplyButton.Text = "선택된 스크립트 실행"
    else
        ApplyButton.Text = "스크립트를 먼저 선택하세요!"
        wait(1.5)
        ApplyButton.Text = "선택된 스크립트 실행"
    end
end)

-- 시작 애니메이션
TweenService:Create(MainFrame, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -150, 0.5, -175),
    BackgroundTransparency = 0
}):Play()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 설정 및 상태 ]]
local Toggles = { Scanner = false, Aimbot = false, Highlight = false }
local UI_VISIBLE = true
local BIND_SCANNER = Enum.KeyCode.V
local BIND_AIMBOT = Enum.KeyCode.E
local MENU_KEY = Enum.KeyCode.RightShift

-- [[ UI 생성 ]]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "RiceSec_Fixed"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 260)
MainFrame.Position = UDim2.new(0.5, -100, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "RICE SEC V2"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Instance.new("UICorner", Title)

local Layout = Instance.new("UIListLayout", MainFrame)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- 버튼 생성 함수 (오류 방지 위해 nil 체크 포함)
local function CreateButton(name, order)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.LayoutOrder = order
    Instance.new("UICorner", btn)
    return btn
end

local btnScanner = CreateButton("Scanner (V)", 1)
local btnAimbot = CreateButton("Aimbot (E)", 2)
local btnHighlight = CreateButton("Highlight", 3)

-- [[ 기능 로직 ]]

-- 1. 스캐너 (안전한 경로 탐색)
local function setupScanner(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        local head = char:WaitForChild("Head", 10)
        if not head then return end
        
        local bgui = Instance.new("BillboardGui", head)
        bgui.Name = "ScannerGui"
        bgui.Size = UDim2.new(8, 0, 5, 0)
        bgui.StudsOffset = Vector3.new(0, 4, 0)
        bgui.AlwaysOnTop = true
        bgui.Enabled = false

        local list = Instance.new("Frame", bgui)
        list.Size = UDim2.new(1, 0, 1, 0)
        list.BackgroundTransparency = 1
        local l_layout = Instance.new("UIListLayout", list)
        l_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        task.spawn(function()
            while char and char.Parent do
                if bgui.Enabled then
                    for _, v in ipairs(list:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
                    
                    pcall(function() -- 타겟 GUI 접근 시 에러 방지
                        local pg = player:FindFirstChild("PlayerGui")
                        local target = pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("MainFrame") and pg.MainGui.MainFrame:FindFirstChild("ItemInterfaces")
                        if target then
                            for _, item in ipairs(target:GetChildren()) do
                                local txt = Instance.new("TextLabel", list)
                                txt.Size = UDim2.new(0.8, 0, 0.2, 0)
                                txt.Text = item.Name
                                txt.BackgroundColor3 = Color3.new(0,0,0)
                                txt.BackgroundTransparency = 0.6
                                txt.TextColor3 = Color3.new(1,1,1)
                                txt.TextScaled = true
                                Instance.new("UICorner", txt)
                            end
                        end
                    end)
                end
                task.wait(1.5)
            end
        end)
    end)
end

-- 2. 하이라이트 (저장소 중복 생성 방지)
local HL_Folder = CoreGui:FindFirstChild("RiceHL") or Instance.new("Folder", CoreGui)
HL_Folder.Name = "RiceHL"

local function doHighlight(plr)
    if plr == LocalPlayer then return end
    local hl = Instance.new("Highlight", HL_Folder)
    hl.FillColor = Color3.fromRGB(0, 150, 255)
    hl.Enabled = Toggles.Highlight
    
    local function setChar(c) hl.Adornee = c end
    if plr.Character then setChar(plr.Character) end
    plr.CharacterAdded:Connect(setChar)
end

-- [[ 이벤트 핸들링 ]]
local function updateUI()
    btnScanner.Text = "Scanner (V): " .. (Toggles.Scanner and "ON" or "OFF")
    btnScanner.BackgroundColor3 = Toggles.Scanner and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)
    
    btnAimbot.Text = "Aimbot (E): " .. (Toggles.Aimbot and "ON" or "OFF")
    btnAimbot.BackgroundColor3 = Toggles.Aimbot and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)
    
    btnHighlight.Text = "Highlight: " .. (Toggles.Highlight and "ON" or "OFF")
    btnHighlight.BackgroundColor3 = Toggles.Highlight and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)
    
    for _, h in ipairs(HL_Folder:GetChildren()) do h.Enabled = Toggles.Highlight end
end

btnScanner.MouseButton1Click:Connect(function() Toggles.Scanner = not Toggles.Scanner updateUI() end)
btnAimbot.MouseButton1Click:Connect(function() Toggles.Aimbot = not Toggles.Aimbot updateUI() end)
btnHighlight.MouseButton1Click:Connect(function() Toggles.Highlight = not Toggles.Highlight updateUI() end)

-- 입력 감지
local vHeld, eHeld = false, false
UserInputService.InputBegan:Connect(function(io, g)
    if g then return end
    if io.KeyCode == MENU_KEY then
        UI_VISIBLE = not UI_VISIBLE
        MainFrame.Visible = UI_VISIBLE
    elseif io.KeyCode == BIND_SCANNER then vHeld = true
    elseif io.KeyCode == BIND_AIMBOT then eHeld = true end
end)

UserInputService.InputEnded:Connect(function(io)
    if io.KeyCode == BIND_SCANNER then vHeld = false
    elseif io.KeyCode == BIND_AIMBOT then eHeld = false end
end)

-- 실행 루프
RunService.RenderStepped:Connect(function()
    -- 스캐너 온오프
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local g = p.Character.Head:FindFirstChild("ScannerGui")
            if g then g.Enabled = (Toggles.Scanner and vHeld) end
        end
    end
    
    -- 에임봇
    if Toggles.Aimbot and eHeld then
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
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- 초기 실행
for _, p in ipairs(Players:GetPlayers()) do setupScanner(p) doHighlight(p) end
Players.PlayerAdded:Connect(function(p) setupScanner(p) doHighlight(p) end)

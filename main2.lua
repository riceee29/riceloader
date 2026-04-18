local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 상태 관리 변수 ]]
local Toggles = {
    Scanner = false,
    Aimbot = false,
    Highlight = false
}
local UI_VISIBLE = true
local BIND_KEY_SCANNER = Enum.KeyCode.V
local BIND_KEY_AIMBOT = Enum.KeyCode.E
local MENU_KEY = Enum.KeyCode.RightShift

-- [[ GUI 생성 ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RiceSec_Integrated"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0.5, -100, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "RICE SEC MULTI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame
Instance.new("UICorner", Title)

local Layout = Instance.new("UIListLayout", MainFrame)
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- 버튼 생성 함수
local function CreateButton(name, layoutOrder)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.LayoutOrder = layoutOrder
    btn.Parent = MainFrame
    Instance.new("UICorner", btn)
    return btn
end

local btnScanner = CreateButton("Scanner (V)", 1)
local btnAimbot = CreateButton("Aimbot (E)", 2)
local btnHighlight = CreateButton("Highlight", 3)

-- [[ 1. 스캐너 기능 로직 ]]
local function createScannerGui(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(character)
        local head = character:WaitForChild("Head", 15)
        local billboard = Instance.new("BillboardGui", head)
        billboard.Name = "ScannerGui"
        billboard.Size = UDim2.new(10, 0, 6, 0)
        billboard.StudsOffset = Vector3.new(0, 5, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = false

        local infoList = Instance.new("Frame", billboard)
        infoList.Name = "InfoList"
        infoList.Size = UDim2.new(1, 0, 1, 0)
        infoList.BackgroundTransparency = 1
        Instance.new("UIListLayout", infoList).HorizontalAlignment = Enum.HorizontalAlignment.Center

        task.spawn(function()
            while character and character.Parent do
                if billboard.Enabled then
                    for _, v in ipairs(infoList:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
                    local pg = player:FindFirstChild("PlayerGui")
                    local targetRoot = pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("MainFrame") and pg.MainGui.MainFrame:FindFirstChild("ItemInterfaces")
                    
                    if targetRoot then
                        for _, item in ipairs(targetRoot:GetChildren()) do
                            local val = item:IsA("TextLabel") and item.Text or item.Name
                            local lbl = Instance.new("TextLabel", infoList)
                            lbl.Size = UDim2.new(0.7, 0, 0.12, 0)
                            lbl.Text = "» " .. val .. " «"
                            lbl.TextColor3 = Color3.new(1,1,1)
                            lbl.BackgroundTransparency = 0.5
                            lbl.BackgroundColor3 = Color3.new(0,0,0)
                            lbl.TextScaled = true
                            Instance.new("UICorner", lbl)
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end)
end

-- [[ 2. 에임봇 기능 로직 ]]
local function getClosestPlayerToCursor()
    local nearestHead = nil
    local shortestMouseDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mouseDistance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if mouseDistance < shortestMouseDistance then
                        shortestMouseDistance = mouseDistance
                        nearestHead = head
                    end
                end
            end
        end
    end
    return nearestHead
end

-- [[ 3. 하이라이트 기능 로직 ]]
local HighlightStorage = Instance.new("Folder", CoreGui)
HighlightStorage.Name = "RiceHighlight_Storage"

local function ApplyHighlight(plr)
    if plr == LocalPlayer then return end
    local hl = Instance.new("Highlight")
    hl.Name = plr.Name
    hl.FillColor = Color3.fromRGB(0, 120, 255)
    hl.OutlineColor = Color3.new(1,1,1)
    hl.Enabled = Toggles.Highlight
    hl.Parent = HighlightStorage
    
    local function update(char) hl.Adornee = char end
    if plr.Character then update(plr.Character) end
    plr.CharacterAdded:Connect(update)
end

-- [[ 토글 및 이벤트 연결 ]]
local function updateButtons()
    btnScanner.Text = "Scanner (V): " .. (Toggles.Scanner and "ON" or "OFF")
    btnScanner.BackgroundColor3 = Toggles.Scanner and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    
    btnAimbot.Text = "Aimbot (E): " .. (Toggles.Aimbot and "ON" or "OFF")
    btnAimbot.BackgroundColor3 = Toggles.Aimbot and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    
    btnHighlight.Text = "Highlight: " .. (Toggles.Highlight and "ON" or "OFF")
    btnHighlight.BackgroundColor3 = Toggles.Highlight and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    
    for _, v in ipairs(HighlightStorage:GetChildren()) do v.Enabled = Toggles.Highlight end
end

btnScanner.MouseButton1Click:Connect(function() Toggles.Scanner = not Toggles.Scanner updateButtons() end)
btnAimbot.MouseButton1Click:Connect(function() Toggles.Aimbot = not Toggles.Aimbot updateButtons() end)
btnHighlight.MouseButton1Click:Connect(function() Toggles.Highlight = not Toggles.Highlight updateButtons() end)

-- 입력 처리 (V: 스캔, E: 에임봇, R-Shift: UI)
local isVDown, isEDown = false, false
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == MENU_KEY then
        UI_VISIBLE = not UI_VISIBLE
        MainFrame.Visible = UI_VISIBLE
    elseif input.KeyCode == BIND_KEY_SCANNER then
        isVDown = true
    elseif input.KeyCode == BIND_KEY_AIMBOT then
        isEDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == BIND_KEY_SCANNER then isVDown = false
    elseif input.KeyCode == BIND_KEY_AIMBOT then isEDown = false end
end)

-- 프레임마다 실행 (에임봇 및 스캐너 가시성)
RunService.RenderStepped:Connect(function()
    -- 스캐너 가시성 업데이트
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local gui = p.Character.Head:FindFirstChild("ScannerGui")
            if gui then gui.Enabled = Toggles.Scanner and isVDown end
        end
    end
    
    -- 에임봇
    if Toggles.Aimbot and isEDown then
        local target = getClosestPlayerToCursor()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- 초기화 실행
for _, p in ipairs(Players:GetPlayers()) do 
    createScannerGui(p)
    ApplyHighlight(p)
end
Players.PlayerAdded:Connect(function(p)
    createScannerGui(p)
    ApplyHighlight(p)
end)

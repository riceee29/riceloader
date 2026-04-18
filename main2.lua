local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- 설정
local BIND_KEY = Enum.KeyCode.V
local UPDATE_SPEED = 0.5 -- 0.5초마다 적 정보 동기화

local function createScannerGui(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function(character)
        local head = character:WaitForChild("Head", 15)
        local humanoid = character:WaitForChild("Humanoid", 15)
        if not head or not humanoid then return end

        -- 1. BillboardGui (정보를 담을 큰 틀)
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ScannerGui"
        billboard.Size = UDim2.new(10, 0, 6, 0) -- 세로로 길게 설정
        billboard.StudsOffset = Vector3.new(0, 5, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = false
        billboard.Parent = head

        -- 2. 체력바 (상단)
        local healthBg = Instance.new("Frame")
        healthBg.Size = UDim2.new(0.8, 0, 0.1, 0)
        healthBg.Position = UDim2.new(0.1, 0, 0, 0)
        healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        healthBg.BorderSizePixel = 0
        healthBg.Parent = billboard
        Instance.new("UICorner", healthBg).CornerRadius = UDim.new(0.5, 0)

        local healthFill = Instance.new("Frame")
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        healthFill.BorderSizePixel = 0
        healthFill.Parent = healthBg
        Instance.new("UICorner", healthFill).CornerRadius = UDim.new(0.5, 0)

        -- 3. 우하단 UI 복제 컨테이너 (체력바 아래)
        local infoList = Instance.new("Frame")
        infoList.Name = "InfoList"
        infoList.Size = UDim2.new(1, 0, 0.85, 0)
        infoList.Position = UDim2.new(0, 0, 0.15, 0)
        infoList.BackgroundTransparency = 1
        infoList.Parent = billboard

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0.02, 0)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = infoList

        -- 실시간 스캔 루프
        task.spawn(function()
            while character and character.Parent do
                -- 기존 목록 초기화
                for _, v in ipairs(infoList:GetChildren()) do
                    if v:IsA("TextLabel") then v:Destroy() end
                end

                -- [핵심] 상대방의 PlayerGui 탐색
                local pg = player:FindFirstChild("PlayerGui")
                if pg then
                    -- MainGui > MainFrame > ItemInterfaces 경로 탐색
                    local targetRoot = pg:FindFirstChild("MainGui") 
                        and pg.MainGui:FindFirstChild("MainFrame") 
                        and pg.MainGui.MainFrame:FindFirstChild("ItemInterfaces")

                    if targetRoot then
                        -- 해당 영역 안의 모든 텍스트/이름 스캔
                        for _, item in ipairs(targetRoot:GetChildren()) do
                            local val = ""
                            if item:IsA("TextLabel") then val = item.Text
                            elseif item:IsA("StringValue") or item:IsA("IntValue") then val = tostring(item.Value)
                            else val = item.Name end

                            if val ~= "" and val ~= " " then
                                local lbl = Instance.new("TextLabel")
                                lbl.Size = UDim2.new(0.7, 0, 0.12, 0)
                                lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                                lbl.BackgroundTransparency = 0.5
                                lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                                lbl.Text = "» " .. val .. " «"
                                lbl.Font = Enum.Font.GothamBold
                                lbl.TextScaled = true
                                lbl.Parent = infoList
                                Instance.new("UICorner", lbl)
                            end
                        end
                    end
                end

                -- 체력바 업데이트
                local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                TweenService:Create(healthFill, TweenInfo.new(0.3), {
                    Size = UDim2.new(hpPercent, 0, 1, 0),
                    BackgroundColor3 = Color3.fromHSV(hpPercent * 0.35, 0.8, 1)
                }):Play()

                task.wait(UPDATE_SPEED)
            end
        end)
    end)
end

-- V키 토글 로직
local function toggleScanner(state)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local gui = p.Character.Head:FindFirstChild("ScannerGui")
            if gui then gui.Enabled = state end
        end
    end
end

UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == BIND_KEY then toggleScanner(true) end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode == BIND_KEY then toggleScanner(false) end
end)

-- 모든 유저 초기화
for _, p in ipairs(Players:GetPlayers()) do createScannerGui(p) end
Players.PlayerAdded:Connect(createScannerGui)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 설정
local isEPressed = false
local MAX_DISTANCE = 500 -- 최대 탐색 월드 거리 (스터드)

-- 화면상에서 가장 가까운 플레이어의 Head를 찾는 함수
local function getClosestPlayerToCursor()
    local nearestHead = nil
    local shortestMouseDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")

            -- 살아있는 플레이어만 대상
            if head and humanoid and humanoid.Health > 0 then
                -- 3D 좌표를 2D 화면 좌표로 변환
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

                if onScreen then
                    -- 월드 거리 체크 (너무 멀리 있는 유저는 제외하고 싶을 때)
                    local worldDistance = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                    
                    if worldDistance < MAX_DISTANCE then
                        -- 화면 중앙(커서)과의 2D 거리 계산
                        local mouseDistance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        
                        if mouseDistance < shortestMouseDistance then
                            shortestMouseDistance = mouseDistance
                            nearestHead = head
                        end
                    end
                end
            end
        end
    end
    return nearestHead
end

-- 입력 감지
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
        isEPressed = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        isEPressed = false
    end
end)

-- 에임 보정 실행
RunService.RenderStepped:Connect(function()
    if isEPressed then
        local targetHead = getClosestPlayerToCursor()
        
        if targetHead then
            -- 현재 카메라 위치에서 대상을 바라보도록 CFrame 설정
            -- Lerp를 사용하여 부드럽게 따라가게 할 수도 있습니다.
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)
local FillColor = Color3.fromRGB(0, 120, 255) -- 진한 하늘색/파란색으로 변경
local DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
local FillTransparency = 0.5
local OutlineColor = Color3.fromRGB(255, 255, 255)
local OutlineTransparency = 0

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local connections = {}

-- 기존 저장소 삭제 (중복 방지)
if CoreGui:FindFirstChild("Highlight_Storage") then
    CoreGui.Highlight_Storage:Destroy()
end

local Storage = Instance.new("Folder")
Storage.Parent = CoreGui
Storage.Name = "Highlight_Storage"

local function Highlight(plr)
    -- 자기 자신은 제외 (원치 않을 경우 이 조건문 삭제)
    if plr == lp then return end

    local hl = Instance.new("Highlight")
    hl.Name = plr.Name
    hl.FillColor = FillColor
    hl.DepthMode = DepthMode
    hl.FillTransparency = FillTransparency
    hl.OutlineColor = OutlineColor
    hl.OutlineTransparency = OutlineTransparency
    hl.Parent = Storage
    
    local function applyAdornee(char)
        hl.Adornee = char
    end

    if plr.Character then
        applyAdornee(plr.Character)
    end

    connections[plr] = plr.CharacterAdded:Connect(applyAdornee)
end

-- 초기 실행 및 플레이어 추가 이벤트
Players.PlayerAdded:Connect(Highlight)
for _, v in ipairs(Players:GetPlayers()) do
    Highlight(v)
end

-- 플레이어 나갈 시 정리
Players.PlayerRemoving:Connect(function(plr)
    if Storage:FindFirstChild(plr.Name) then
        Storage[plr.Name]:Destroy()
    end
    if connections[plr] then
        connections[plr]:Disconnect()
        connections[plr] = nil
    end
end)

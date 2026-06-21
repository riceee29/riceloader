-- Rayfield UI 라이브러리 불러오기
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 메인 창 만들기
local Window = Rayfield:CreateWindow({
   Name = "99 Script Hub",
   LoadingTitle = "99 스크립트 로딩 중...",
   LoadingSubtitle = "아이템 가져오기 & 인피니티 일드",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false, -- 키 시스템 끄기
})

-- 탭 생성
local ItemTab = Window:CreateTab("아이템 (Items)", 4483362458)
local AdminTab = Window:CreateTab("관리자 (Admin)", 4483362458)

---------------------------------------------------------
-- [1] 아이템 가져오기 기능 (Items Tab)
---------------------------------------------------------

-- 월드(Workspace)에 떨어져 있는 아이템(Tool) 이름을 가져오는 함수
local function getDroppedItems()
    local items = {}
    local itemCheck = {} -- 중복 방지용
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            if not itemCheck[obj.Name] then
                table.insert(items, obj.Name)
                itemCheck[obj.Name] = true
            end
        end
    end
    
    if #items == 0 then
        table.insert(items, "아이템 없음")
    end
    
    return items
end

local selectedItem = ""

-- 드롭다운 (아이템 리스트)
local ItemDropdown = ItemTab:CreateDropdown({
   Name = "가져올 아이템 선택",
   Options = getDroppedItems(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "ItemDropdown",
   Callback = function(Option)
       selectedItem = Option[1]
   end,
})

-- 목록 새로고침 버튼
ItemTab:CreateButton({
   Name = "🔄 아이템 리스트 새로고침",
   Callback = function()
       ItemDropdown:Refresh(getDroppedItems())
       Rayfield:Notify({
           Title = "새로고침 완료",
           Content = "바닥에 있는 아이템 목록을 다시 불러왔습니다.",
           Duration = 3,
       })
   end,
})

-- 아이템을 플레이어 앞으로 가져오는 버튼
ItemTab:CreateButton({
   Name = "✨ 선택한 아이템 내 앞으로 가져오기",
   Callback = function()
       if selectedItem ~= "" and selectedItem ~= "아이템 없음" then
           local player = game.Players.LocalPlayer
           local character = player.Character or player.CharacterAdded:Wait()
           local hrp = character:FindFirstChild("HumanoidRootPart")

           if hrp then
               local found = false
               for _, obj in pairs(workspace:GetChildren()) do
                   -- 이름이 일치하고 Handle이 있는 툴을 찾음
                   if obj:IsA("Tool") and obj.Name == selectedItem and obj:FindFirstChild("Handle") then
                       -- 플레이어의 3스터드(칸) 앞으로 아이템 이동
                       obj.Handle.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
                       found = true
                   end
               end
               
               if found then
                   Rayfield:Notify({
                       Title = "성공!",
                       Content = selectedItem .. "을(를) 앞으로 가져왔습니다.",
                       Duration = 3,
                   })
               else
                   Rayfield:Notify({
                       Title = "실패",
                       Content = "아이템을 찾을 수 없거나 이미 누군가 주웠습니다.",
                       Duration = 3,
                   })
               end
           end
       else
           Rayfield:Notify({
               Title = "경고",
               Content = "먼저 가져올 아이템을 선택해주세요.",
               Duration = 3,
           })
       end
   end,
})

---------------------------------------------------------
-- [2] 인피니티 일드 기능 (Admin Tab)
---------------------------------------------------------

AdminTab:CreateButton({
   Name = "🚀 인피니티 일드 (Infinity Yield) 실행",
   Callback = function()
       loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infinityyield/master/source'))()
       Rayfield:Notify({
           Title = "실행됨",
           Content = "Infinity Yield가 성공적으로 로드되었습니다.",
           Duration = 3,
       })
   end,
})

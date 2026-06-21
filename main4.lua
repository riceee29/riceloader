-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Main Window
local Window = Rayfield:CreateWindow({
   Name = "99 Script Hub",
   LoadingTitle = "Loading 99 Script...",
   LoadingSubtitle = "Item Auto Farm & Infinity Yield",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
})

local ItemTab = Window:CreateTab("Items", 4483362458)
local AdminTab = Window:CreateTab("Admin", 4483362458)

---------------------------------------------------------
-- [1] Item Fetching Features (Items Folder)
---------------------------------------------------------

local function getDroppedItems()
    local items = {}
    local itemCheck = {}
    local itemsFolder = workspace:FindFirstChild("Items")
    
    if itemsFolder then
        for _, obj in pairs(itemsFolder:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                if not itemCheck[obj.Name] then
                    table.insert(items, obj.Name)
                    itemCheck[obj.Name] = true
                end
            end
        end
    end
    
    if #items == 0 then
        table.insert(items, "No Items Found")
    end
    
    return items
end

local selectedItem = ""

-- Dropdown (Item List) - 에러 방지 처리 완료
local ItemDropdown = ItemTab:CreateDropdown({
   Name = "Select Item to Fetch",
   Options = getDroppedItems(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "ItemDropdown",
   Callback = function(Option)
       -- 콜백 에러 방지 (테이블인지 문자열인지 확인)
       if type(Option) == "table" and Option[1] then
           selectedItem = Option[1]
       elseif type(Option) == "string" then
           selectedItem = Option
       end
   end,
})

ItemTab:CreateButton({
   Name = "🔄 Refresh Item List",
   Callback = function()
       ItemDropdown:Refresh(getDroppedItems())
       Rayfield:Notify({ Title = "Refreshed", Content = "Item list updated.", Duration = 3 })
   end,
})

ItemTab:CreateSection("Teleport Items")

-- 선택한 아이템 가져오기 (원형 배치 + Chest 구분)
ItemTab:CreateButton({
   Name = "✨ Bring Selected Item",
   Callback = function()
       if selectedItem ~= "" and selectedItem ~= "No Items Found" then
           local player = game.Players.LocalPlayer
           local character = player.Character or player.CharacterAdded:Wait()
           local hrp = character:FindFirstChild("HumanoidRootPart")
           local itemsFolder = workspace:FindFirstChild("Items")

           if hrp and itemsFolder then
               local objectsToMove = {}
               
               -- 가져올 아이템들 수집
               for _, obj in pairs(itemsFolder:GetChildren()) do
                   if obj.Name == selectedItem then
                       table.insert(objectsToMove, obj)
                   end
               end
               
               local total = #objectsToMove
               if total > 0 then
                   -- 이름에 "Chest"가 들어가는지 확인
                   local isChest = string.match(selectedItem, "Chest")
                   
                   -- 중심점 설정: Chest는 앞쪽 10칸, 일반 아이템은 왼쪽 5칸
                   local centerCFrame
                   if isChest then
                       centerCFrame = hrp.CFrame * CFrame.new(0, 0, -10) -- 10칸 멀리(정면)
                   else
                       centerCFrame = hrp.CFrame * CFrame.new(-5, 0, 0) -- 왼쪽(Left)
                   end

                   -- 아이템들을 둥글게(Circle) 배치
                   for i, obj in ipairs(objectsToMove) do
                       local angle = (i / total) * math.pi * 2
                       local radius = math.max(3, total * 0.15) -- 개수가 많으면 원이 커짐
                       local offset = CFrame.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                       local finalCFrame = centerCFrame * offset
                       
                       if obj:IsA("Model") then
                           obj:PivotTo(finalCFrame)
                       elseif obj:IsA("BasePart") then
                           obj.CFrame = finalCFrame
                       end
                   end
                   
                   Rayfield:Notify({ Title = "Success!", Content = "Brought " .. total .. "x " .. selectedItem, Duration = 3 })
               else
                   Rayfield:Notify({ Title = "Failed", Content = "Item not found in map.", Duration = 3 })
               end
           end
       else
           Rayfield:Notify({ Title = "Warning", Content = "Select an item first.", Duration = 3 })
       end
   end,
})

-- 모든 아이템 가져오기 (Chest/일반 분리 + 원형 배치)
ItemTab:CreateButton({
   Name = "🔥 Bring [ALL ITEMS]",
   Callback = function()
       local player = game.Players.LocalPlayer
       local character = player.Character or player.CharacterAdded:Wait()
       local hrp = character:FindFirstChild("HumanoidRootPart")
       local itemsFolder = workspace:FindFirstChild("Items")

       if hrp and itemsFolder then
           local chests = {}
           local normals = {}
           
           -- 상자와 일반 아이템 분류
           for _, obj in pairs(itemsFolder:GetChildren()) do
               if obj:IsA("Model") or obj:IsA("BasePart") then
                   if string.match(obj.Name, "Chest") then
                       table.insert(chests, obj)
                   else
                       table.insert(normals, obj)
                   end
               end
           end
           
           local totalCount = 0

           -- Chest(상자)들 10칸 멀리 동그랗게 배치
           if #chests > 0 then
               local chestCenter = hrp.CFrame * CFrame.new(0, 0, -10)
               for i, obj in ipairs(chests) do
                   local angle = (i / #chests) * math.pi * 2
                   local radius = math.max(3, #chests * 0.15)
                   local offset = CFrame.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                   if obj:IsA("Model") then obj:PivotTo(chestCenter * offset)
                   elseif obj:IsA("BasePart") then obj.CFrame = chestCenter * offset end
                   totalCount = totalCount + 1
               end
           end
           
           -- 일반 아이템들 왼쪽 동그랗게 배치
           if #normals > 0 then
               local normalCenter = hrp.CFrame * CFrame.new(-6, 0, 0) -- 왼쪽
               for i, obj in ipairs(normals) do
                   local angle = (i / #normals) * math.pi * 2
                   local radius = math.max(3, #normals * 0.15)
                   local offset = CFrame.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                   if obj:IsA("Model") then obj:PivotTo(normalCenter * offset)
                   elseif obj:IsA("BasePart") then obj.CFrame = normalCenter * offset end
                   totalCount = totalCount + 1
               end
           end
           
           if totalCount > 0 then
               Rayfield:Notify({ Title = "Swept Everything!", Content = "Brought " .. totalCount .. " items.", Duration = 3 })
           else
               Rayfield:Notify({ Title = "No Items", Content = "The Items folder is empty.", Duration = 3 })
           end
       end
   end,
})

---------------------------------------------------------
-- [2] Infinity Yield (Admin Tab)
---------------------------------------------------------

AdminTab:CreateButton({
   Name = "🚀 Execute Infinity Yield",
   Callback = function()
       loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infinityyield/master/source'))()
       Rayfield:Notify({ Title = "Executed", Content = "Infinity Yield loaded.", Duration = 3 })
   end,
})

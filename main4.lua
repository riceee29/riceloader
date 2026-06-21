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

-- Create Tabs
local ItemTab = Window:CreateTab("Items", 4483362458)
local AdminTab = Window:CreateTab("Admin", 4483362458)

---------------------------------------------------------
-- [1] Item Fetching Features (Items Folder)
---------------------------------------------------------

-- Function to get item names from workspace.Items
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

-- Dropdown (Item List)
local ItemDropdown = ItemTab:CreateDropdown({
   Name = "Select Item to Fetch",
   Options = getDroppedItems(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "ItemDropdown",
   Callback = function(Option)
       selectedItem = Option[1]
   end,
})

-- Refresh List Button
ItemTab:CreateButton({
   Name = "🔄 Refresh Item List",
   Callback = function()
       ItemDropdown:Refresh(getDroppedItems())
       Rayfield:Notify({
           Title = "Refreshed",
           Content = "Item list has been successfully updated.",
           Duration = 3,
       })
   end,
})

ItemTab:CreateSection("Teleport Items")

-- Bring Selected Item Button
ItemTab:CreateButton({
   Name = "✨ Bring Selected Item to Me",
   Callback = function()
       if selectedItem ~= "" and selectedItem ~= "No Items Found" then
           local player = game.Players.LocalPlayer
           local character = player.Character or player.CharacterAdded:Wait()
           local hrp = character:FindFirstChild("HumanoidRootPart")
           local itemsFolder = workspace:FindFirstChild("Items")

           if hrp and itemsFolder then
               local count = 0
               for _, obj in pairs(itemsFolder:GetChildren()) do
                   if obj.Name == selectedItem then
                       -- Move Models (like Bandage, Berry) using PivotTo
                       if obj:IsA("Model") then
                           obj:PivotTo(hrp.CFrame * CFrame.new(0, 0, -3))
                           count = count + 1
                       elseif obj:IsA("BasePart") then
                           obj.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
                           count = count + 1
                       end
                   end
               end
               
               if count > 0 then
                   Rayfield:Notify({ Title = "Success!", Content = "Brought " .. count .. "x " .. selectedItem .. " to you.", Duration = 3 })
               else
                   Rayfield:Notify({ Title = "Failed", Content = "Could not find the item in the map.", Duration = 3 })
               end
           end
       else
           Rayfield:Notify({ Title = "Warning", Content = "Please select an item from the dropdown first.", Duration = 3 })
       end
   end,
})

-- Bring ALL Items Button
ItemTab:CreateButton({
   Name = "🔥 Bring [ALL ITEMS] to Me",
   Callback = function()
       local player = game.Players.LocalPlayer
       local character = player.Character or player.CharacterAdded:Wait()
       local hrp = character:FindFirstChild("HumanoidRootPart")
       local itemsFolder = workspace:FindFirstChild("Items")

       if hrp and itemsFolder then
           local count = 0
           for _, obj in pairs(itemsFolder:GetChildren()) do
               if obj:IsA("Model") then
                   -- Randomize position slightly to prevent lag from stacking in one exact spot
                   local offsetX = math.random(-20, 20) / 10
                   local offsetZ = math.random(-50, -30) / 10
                   obj:PivotTo(hrp.CFrame * CFrame.new(offsetX, 0, offsetZ))
                   count = count + 1
               elseif obj:IsA("BasePart") then
                   local offsetX = math.random(-20, 20) / 10
                   local offsetZ = math.random(-50, -30) / 10
                   obj.CFrame = hrp.CFrame * CFrame.new(offsetX, 0, offsetZ)
                   count = count + 1
               end
           end
           
           if count > 0 then
               Rayfield:Notify({
                   Title = "Swept Everything!",
                   Content = "Brought a total of " .. count .. " items to you.",
                   Duration = 3,
               })
           else
               Rayfield:Notify({ Title = "No Items", Content = "The Items folder is currently empty.", Duration = 3 })
           end
       else
           Rayfield:Notify({ Title = "Error", Content = "Could not find Player or Items folder.", Duration = 3 })
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
       Rayfield:Notify({ Title = "Executed", Content = "Infinity Yield has been loaded.", Duration = 3 })
   end,
})

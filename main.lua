local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ 로더 메인 윈도우 생성 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE LOADER v2.5 PREMIUM",
    LoadingTitle = "RiceSec Premium Hub",
    LoadingSubtitle = "Select a script to execute",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

-- [[ 스크립트 실행 함수 (실행 후 UI 삭제) ]]
local function ExecuteAndClose(name, url)
    Rayfield:Notify({
        Title = "Executing Script",
        Content = name .. " 스크립트를 불러오는 중입니다...",
        Duration = 3,
        Image = 4483345998,
    })
    
    -- 스크립트 실행
    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    
    if success then
        -- 실행 성공 시 UI 제거 (구동기 사라짐)
        task.wait(0.5)
        Rayfield:Destroy()
    else
        warn("실행 오류: " .. err)
        Rayfield:Notify({
            Title = "Execution Error",
            Content = "스크립트 로드 중 오류가 발생했습니다.",
            Duration = 5,
        })
    end
end

-- [[ 카테고리 탭 ]]
local MainTab = Window:CreateTab("Script List", 4483362458) -- 리스트 아이콘

MainTab:CreateSection("Available Scripts")

-- [1] Main Rival 스크립트
MainTab:CreateButton({
    Name = "Main Rival (Recommended)",
    Callback = function()
        ExecuteAndClose("Main Rival", "https://raw.githubusercontent.com/riceee29/riceloader/refs/heads/main/main2.lua")
    end,
})

-- [2] Aimbot V3 스크립트
MainTab:CreateButton({
    Name = "Aimbot V3 - Precision",
    Callback = function()
        ExecuteAndClose("Aimbot V3", "https://raw.githubusercontent.com/url2")
    end,
})

-- [3] Speed & Jump Hack 스크립트
MainTab:CreateButton({
    Name = "Speed & Jump System",
    Callback = function()
        ExecuteAndClose("Speed & Jump Hack", "https://raw.githubusercontent.com/url3")
    end,
})

-- [4] Auto Farm System 스크립트
MainTab:CreateButton({
    Name = "Auto Farm System",
    Callback = function()
        ExecuteAndClose("Auto Farm System", "https://raw.githubusercontent.com/url4")
    end,
})

-- [[ 기타 정보 탭 ]]
local InfoTab = Window:CreateTab("Information", 4483345998)
InfoTab:CreateSection("Credits")
InfoTab:CreateParagraph({Title = "Developer", Content = "RiceSec Premium Team"})
InfoTab:CreateParagraph({Title = "Version", Content = "v2.5 (Rayfield Optimized)"})

Rayfield:Notify({
    Title = "Loader Ready",
    Content = "원하는 스크립트를 선택해 주세요.",
    Duration = 5,
})

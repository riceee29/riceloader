-- [[ Rayfield 라이브러리 안전 로드 ]]
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Rayfield UI 라이브러리를 불러오지 못했습니다. 인터넷 연결이나 실행기를 확인하세요.")
    return
end

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

-- [[ 스크립트 실행 함수 (에러 방지 및 종료 처리) ]]
local function ExecuteAndClose(name, url)
    -- 알림 표시
    Rayfield:Notify({
        Title = "Executing: " .. name,
        Content = "스크립트를 로드 중입니다. 잠시만 기다려주세요...",
        Duration = 3,
        Image = 4483345998,
    })
    
    -- 스크립트 주소에서 소스 코드 가져오기 시도
    local scriptSource = ""
    local getSuccess, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if getSuccess and result then
        -- 가져온 소스 코드를 실행
        local execSuccess, execError = pcall(function()
            local func = loadstring(result)
            if func then
                -- UI를 먼저 닫고 스크립트 실행 (충돌 방지)
                Rayfield:Destroy()
                task.wait(0.2)
                func()
            else
                error("Loadstring 실패: 올바른 루아 코드가 아닙니다.")
            end
        end)
        
        if not execSuccess then
            warn(name .. " 실행 중 에러 발생: " .. tostring(execError))
        end
    else
        warn(name .. " 소스를 불러오지 못했습니다: " .. url)
        Rayfield:Notify({
            Title = "Network Error",
            Content = "URL로부터 스크립트를 가져오지 못했습니다.",
            Duration = 5,
        })
    end
end

-- [[ 카테고리 탭 ]]
local MainTab = Window:CreateTab("Script List", 4483362458)

MainTab:CreateSection("Main Feature")

-- [1] Main Rival 스크립트 (사용자님이 요청하신 부드러운 에임봇 포함 주소)
MainTab:CreateButton({
    Name = "Main Rival (Anti-Spin & Smooth Aim)",
    Callback = function()
        ExecuteAndClose("Main Rival", "https://raw.githubusercontent.com/riceee29/riceloader/refs/heads/main/main2.lua")
    end,
})

MainTab:CreateSection("Other Scripts")

-- [2] Aimbot V3 스크립트
MainTab:CreateButton({
    Name = "Admin sc",
    Callback = function()
        ExecuteAndClose("Admin", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
    end,
})

-- [3] Speed & Jump Hack 스크립트
MainTab:CreateButton({
    Name = "Movement Speed & Jump System",
    Callback = function()
        ExecuteAndClose("Speed & Jump Hack", "https://raw.githubusercontent.com/url3")
    end,
})

-- [4] Auto Farm System 스크립트
MainTab:CreateButton({
    Name = "Universal Auto Farm System",
    Callback = function()
        ExecuteAndClose("Auto Farm System", "https://raw.githubusercontent.com/url4")
    end,
})

-- [[ 정보 탭 ]]
local InfoTab = Window:CreateTab("Information", 4483345998)
InfoTab:CreateSection("Credits")
InfoTab:CreateParagraph({Title = "Developer", Content = "RiceSec Premium Team"})
InfoTab:CreateParagraph({Title = "Support", Content = "Rivals Optimized Edition"})

-- 로드 완료 알림
Rayfield:Notify({
    Title = "Rice Loader v2.5",
    Content = "로더가 성공적으로 로드되었습니다.",
    Duration = 5,
})

-- [[ Rayfield 라이브러리 안전 로드 ]]
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Rayfield UI 라이브러리를 불러오지 못했습니다.")
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

-- [[ 전역 변수 설정 ]]
local CloseOnExecute = true -- 실행 후 UI를 닫을지 여부

-- [[ 스크립트 실행 핵심 함수 ]]
local function ExecuteScript(name, url)
    Rayfield:Notify({
        Title = "Script Loading...",
        Content = name .. " 소스를 가져오는 중입니다.",
        Duration = 2,
        Image = 4483345998,
    })
    
    local getSuccess, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if getSuccess and result then
        local func, err = loadstring(result)
        if func then
            Rayfield:Notify({
                Title = "Success!",
                Content = name .. " 실행 성공!",
                Duration = 2,
                Image = 4483345998,
            })
            
            -- UI 종료 설정이 켜져있을 경우에만 파괴
            if CloseOnExecute then
                task.wait(0.5)
                Rayfield:Destroy()
            end
            
            -- 스크립트 실행
            local execSuccess, execError = pcall(func)
            if not execSuccess then
                warn(name .. " 실행 중 런타임 에러: " .. tostring(execError))
            end
        else
            Rayfield:Notify({
                Title = "Syntax Error",
                Content = "스크립트 코드에 문법 오류가 있습니다.",
                Duration = 5,
            })
            warn("Loadstring Error: " .. tostring(err))
        end
    else
        Rayfield:Notify({
            Title = "Network Error",
            Content = "URL이 잘못되었거나 연결이 원활하지 않습니다.",
            Duration = 5,
        })
    end
end

-- [[ 카테고리 탭 ]]
local MainTab = Window:CreateTab("Script List", 4483362458)

MainTab:CreateSection("Settings")
MainTab:CreateToggle({
    Name = "Execute and Close UI",
    CurrentValue = true,
    Flag = "CloseOnExec",
    Callback = function(Value)
        CloseOnExecute = Value
    end,
})

MainTab:CreateSection("Main Feature")

-- [1] Main Rival 스크립트
MainTab:CreateButton({
    Name = "🔥 Main Rival (Anti-Spin & Smooth)",
    Callback = function()
        ExecuteScript("Main Rival", "https://raw.githubusercontent.com/riceee29/riceloader/refs/heads/main/main2.lua")
    end,
})

MainTab:CreateSection("Other Scripts")

-- [2] Aimbot V3 스크립트
MainTab:CreateButton({
    Name = "🎯 Aimbot V3 - Precision Lock",
    Callback = function()
        ExecuteScript("Aimbot V3", "https://raw.githubusercontent.com/url2") -- 실제 주소로 변경 필요
    end,
})

-- [3] Speed & Jump Hack 스크립트
MainTab:CreateButton({
    Name = "⚡ Movement System",
    Callback = function()
        ExecuteScript("Speed & Jump Hack", "https://raw.githubusercontent.com/url3") -- 실제 주소로 변경 필요
    end,
})

-- [4] Auto Farm System 스크립트
MainTab:CreateButton({
    Name = "🚜 Universal Auto Farm",
    Callback = function()
        ExecuteScript("Auto Farm System", "https://raw.githubusercontent.com/url4") -- 실제 주소로 변경 필요
    end,
})

-- [[ 정보 탭 ]]
local InfoTab = Window:CreateTab("Information", 4483345998)
InfoTab:CreateSection("Credits")
InfoTab:CreateParagraph({Title = "Developer", Content = "RiceSec Premium Team"})
InfoTab:CreateParagraph({Title = "Version", Content = "v2.5 Optimized Edition"})

-- 실행 버튼 (UI 수동 종료)
InfoTab:CreateButton({
    Name = "Destroy Loader UI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

-- 로드 완료 알림
Rayfield:Notify({
    Title = "Rice Loader Loaded",
    Content = "환영합니다! 스크립트를 선택해주세요.",
    Duration = 3,
    Image = 4483345998,
})

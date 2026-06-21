-- [[ Rayfield 라이브러리 로드 (대체 주소 포함) ]]
local Rayfield
local success, err = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if success and type(err) == "table" then
    Rayfield = err
else
    -- 첫 번째 로드 실패 시 백업 주소 시도
    success, Rayfield = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
    end)
end

if not success or not Rayfield then
    warn("Rayfield 로드 실패: 실행기가 HttpGet 또는 loadstring을 지원하는지 확인하세요.")
    return
end

-- [[ 로더 메인 윈도우 ]]
local Window = Rayfield:CreateWindow({
    Name = "RICE LOADER v2.5 PREMIUM",
    LoadingTitle = "RiceSec Premium Hub",
    LoadingSubtitle = "Select a script to execute",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- [[ 설정 변수 ]]
local CloseOnExecute = true

-- [[ 스크립트 실행 함수 개선 ]]
local function ExecuteScript(name, url)
    Rayfield:Notify({
        Title = "Loading Script",
        Content = name .. "을(를) 불러오는 중...",
        Duration = 3
    })

    -- 1. 소스 코드 가져오기
    local getSuccess, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not getSuccess or result == "" then
        Rayfield:Notify({ Title = "Error", Content = "스크립트 소스를 불러오지 못했습니다.", Duration = 5 })
        return
    end

    -- 2. 실행 준비
    local func, loadErr = loadstring(result)
    if not func then
        warn("문법 에러: " .. tostring(loadErr))
        Rayfield:Notify({ Title = "Syntax Error", Content = "스크립트 코드 오류가 발견되었습니다.", Duration = 5 })
        return
    end

    -- 3. UI 닫기 및 실행
    if CloseOnExecute then
        Rayfield:Notify({ Title = "Executing", Content = "로더를 닫고 스크립트를 실행합니다.", Duration = 2 })
        task.wait(0.5)
        Rayfield:Destroy()
    end

    -- 4. 별도 쓰레드에서 실행 (중요: 충돌 방지)
    task.spawn(function()
        local execSuccess, execErr = pcall(func)
        if not execSuccess then
            warn(name .. " 실행 중 에러: " .. tostring(execErr))
        end
    end)
end

-- [[ 탭 생성 ]]
local MainTab = Window:CreateTab("Script List", 4483362458)

MainTab:CreateSection("Settings")
MainTab:CreateToggle({
    Name = "Execute and Close UI",
    CurrentValue = true,
    Callback = function(Value)
        CloseOnExecute = Value
    end,
})

MainTab:CreateSection("Main Feature")

-- [1] Main Rival
MainTab:CreateButton({
    Name = "🔥 Main Rival (Anti-Spin & Smooth)",
    Callback = function()
        ExecuteScript("Main Rival", "https://raw.githubusercontent.com/riceee29/riceloader/refs/heads/main/main2.lua")
    end,
})

MainTab:CreateSection("Other Scripts")

-- [2] Infinite Yield (Admin) - 주소 수정 완료
MainTab:CreateButton({
    Name = "🎮 Infinite Yield (Admin)",
    Callback = function()
        ExecuteScript("Infinite Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
    end,
})

-- [3] 대체용 빈 스크립트 예시 (작동 확인용)
MainTab:CreateButton({
    Name = "⚡ Fly tool (Test)",
    Callback = function()
        ExecuteScript("Fly tool", "https://raw.githubusercontent.com/riceee29/riceloader/refs/heads/main/main3.lua")
    end,
})

-- [3] 대체용 빈 스크립트 예시 (작동 확인용)
MainTab:CreateButton({
    Name = "99 tool",
    Callback = function()
        ExecuteScript("99 tool", "https://raw.githubusercontent.com/riceee29/riceloader/refs/heads/main/main4.lua")
    end,
})


-- [[ 정보 탭 ]]
local InfoTab = Window:CreateTab("Information", 4483345998)
InfoTab:CreateSection("Credits")
InfoTab:CreateParagraph({Title = "Developer", Content = "RiceSec Premium Team"})
InfoTab:CreateButton({
    Name = "Destroy Loader UI",
    Callback = function() Rayfield:Destroy() end,
})

Rayfield:Notify({
    Title = "Rice Loader v2.5",
    Content = "로드가 완료되었습니다.",
    Duration = 3,
})

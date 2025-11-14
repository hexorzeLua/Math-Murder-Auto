local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local supportedGameIds = {
    127707120843339,  -- Замените на реальный ID игры
}
local currentGameId = game.PlaceId
local isSupportedGame = false

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

for _, id in pairs(supportedGameIds) do
    if currentGameId == id then
        isSupportedGame = true
        break
    end
end
if not isSupportedGame then
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    
    -- Небольшая задержка чтобы GUI успело загрузиться
    wait(1)
    
    localPlayer:Kick("Not supported game. Here is actual support games: https://discord.gg/YJxaKBcZbA")
    return -- Останавливаем выполнение скрипта
end

-- Конфигурация
local CHECK_INTERVAL = 0.1
local TOMATO_INTERVAL = 0.5
local COIN_FARM_SPEED = 15

-- RemoteEvents
local GameEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("GameEvent")

-- Список троллинг-фраз
local TROLL_PHRASES = {
    "lol u mad ? why so ez",
    "math is too easy for me", 
    "are you even trying?",
    "my calculator is faster than you",
    "ez pz lemon squeezy",
    "you should practice more",
    "i'm basically a math genius",
    "this is boring, make it harder",
    "did you skip math classes?",
    "i could do this in my sleep"
}

-- Улучшенный математический решатель
local function solveMathExpression(expression)
    -- Нормализация выражения
    local normalized = expression
        :gsub("×", "*")
        :gsub("÷", "/") 
        :gsub(":", "/")
        :gsub("−", "-")
        :gsub("=", "")
        :gsub("%?", "")
        :gsub("^%s*(.-)%s*$", "%1")
        :gsub("%s+", " ")
    
    print("[DEBUG] Normalized: " .. normalized)
    
    -- Извлекаем числа и операторы
    local numbers = {}
    local operators = {}
    
    -- Разбиваем на токены
    for token in normalized:gmatch("[%d%.]+|[%+%-%*/]") do
        if token:match("[%d%.]+") then
            table.insert(numbers, tonumber(token))
        else
            table.insert(operators, token)
        end
    end
    
    -- Если не удалось разобрать стандартным способом, пробуем ручной парсинг
    if #numbers == 0 then
        for num in normalized:gmatch("%d+") do
            table.insert(numbers, tonumber(num))
        end
        
        if normalized:find("+") then table.insert(operators, "+") end
        if normalized:find("-") then table.insert(operators, "-") end
        if normalized:find("*") or normalized:find("x") then table.insert(operators, "*") end
        if normalized:find("/") or normalized:find("÷") or normalized:find(":") then table.insert(operators, "/") end
    end
    
    print("[DEBUG] Numbers: " .. table.concat(numbers, ", "))
    print("[DEBUG] Operators: " .. table.concat(operators, ", "))
    
    -- Вычисление выражения
    if #numbers >= 2 and #operators >= 1 then
        local result
        
        -- Сначала умножение и деление
        local i = 1
        while i <= #operators do
            if operators[i] == "*" or operators[i] == "/" then
                if operators[i] == "*" then
                    numbers[i] = numbers[i] * numbers[i + 1]
                else
                    if numbers[i + 1] ~= 0 then
                        numbers[i] = numbers[i] / numbers[i + 1]
                    else
                        print("[ERROR] Division by zero!")
                        return nil
                    end
                end
                table.remove(numbers, i + 1)
                table.remove(operators, i)
            else
                i = i + 1
            end
        end
        
        -- Затем сложение и вычитание
        result = numbers[1]
        for i = 1, #operators do
            if operators[i] == "+" then
                result = result + numbers[i + 1]
            elseif operators[i] == "-" then
                result = result - numbers[i + 1]
            end
        end
        
        -- Форматируем результат
        if result % 1 == 0 then
            result = tostring(math.floor(result))
        else
            result = string.format("%.2f", result):gsub("%.?0+$", "")
        end
        
        return result
    else
        -- Альтернативный метод
        local success, calcResult = pcall(function()
            local safeExpr = normalized
                :gsub("([%d%)])%s*([%d%(])", "%1*%2")
                :gsub("(%d)%s*(%a)", "%1*%2")
            
            local func, err = loadstring("return " .. safeExpr)
            if func then
                return func()
            end
            return nil
        end)
        
        if success and calcResult and type(calcResult) == "number" then
            if calcResult % 1 == 0 then
                return tostring(math.floor(calcResult))
            else
                return string.format("%.2f", calcResult):gsub("%.?0+$", "")
            end
        end
    end
    
    print("[ERROR] Could not parse expression: " .. expression)
    return nil
end

-- Улучшенный решатель
local function advancedMathSolver(expression)
    local result = solveMathExpression(expression)
    if result then return result end
    
    -- Специфичные паттерны
    if expression:find("x") then
        local a, b = expression:match("(%d+)%s*x%s*(%d+)")
        if a and b then
            return tostring(tonumber(a) * tonumber(b))
        end
    end
    
    if expression:find("/") or expression:find("÷") then
        local a, b = expression:match("(%d+)%s*[%/÷]%s*(%d+)")
        if a and b and tonumber(b) ~= 0 then
            local res = tonumber(a) / tonumber(b)
            if res % 1 == 0 then
                return tostring(math.floor(res))
            else
                return string.format("%.2f", res):gsub("%.?0+$", "")
            end
        end
    end
    
    -- Простое извлечение чисел
    local numbers = {}
    for num in expression:gmatch("%d+") do
        table.insert(numbers, tonumber(num))
    end
    
    if #numbers >= 2 then
        if expression:find("+") then
            return tostring(numbers[1] + numbers[2])
        elseif expression:find("-") or expression:find("−") then
            return tostring(numbers[1] - numbers[2])
        elseif expression:find("*") or expression:find("x") then
            return tostring(numbers[1] * numbers[2])
        elseif (expression:find("/") or expression:find("÷") or expression:find(":")) and numbers[2] ~= 0 then
            local res = numbers[1] / numbers[2]
            if res % 1 == 0 then
                return tostring(math.floor(res))
            else
                return string.format("%.2f", res):gsub("%.?0+$", "")
            end
        end
    end
    
    return nil
end

-- Функция для поиска GUI элементов
local function getCurrentQuestion()
    local success, question = pcall(function()
        return workspace.Map.Functional.Screen.SurfaceGui.MainFrame.MainGameContainer.MainTxtContainer.QuestionText.Text
    end)
    
    if success and question and question ~= "" then
        return question
    end
    return nil
end

-- Функция для отправки ответа через RemoteEvent
local function submitAnswer(answer)
    local args = {
        "submitAnswer",
        tostring(answer)
    }
    GameEvent:FireServer(unpack(args))
    print("[SUBMITTED] Answer: " .. tostring(answer))
end

-- Улучшенная функция для экипировки томата
local function equipTomato()
    -- Пробуем разные возможные ивенты для экипировки
    local possibleEvents = {
        {"EquipTomato", 1},
        {"EquipItem", 1},
        {"SelectItem", 1},
        {"TakeTomato", 1},
        {"EquipWeapon", 1},
        {"EquipTool", 1},
        {"Equip", 1}
    }
    
    for _, eventArgs in ipairs(possibleEvents) do
        local success = pcall(function()
            GameEvent:FireServer(unpack(eventArgs))
        end)
        if success then
            print("[TOMATO] Successfully equipped with: " .. table.concat(eventArgs, ", "))
            return true
        end
    end
    
    print("[TOMATO] Failed to equip tomato")
    return false
end

-- Функция для кидания помидора в случайного игрока
local function throwTomatoAtRandomPlayer()
    -- Сначала пытаемся экипировать томат
    if not equipTomato() then
        print("[TOMATO] Cannot throw without equipping first")
        return
    end
    
    task.wait(0.2) -- Даем время на экипировку
    
    local allPlayers = Players:GetPlayers()
    local targetPlayers = {}
    
    for _, p in ipairs(allPlayers) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targetPlayers, p)
        end
    end
    
    if #targetPlayers > 0 then
        local randomPlayer = targetPlayers[math.random(1, #targetPlayers)]
        local targetPos = randomPlayer.Character.HumanoidRootPart.Position
        
        local args = {
            "ThrowTomato",
            targetPos
        }
        
        local success = pcall(function()
            GameEvent:FireServer(unpack(args))
        end)
        
        if success then
            print("[TOMATO] Thrown at: " .. randomPlayer.Name)
        else
            print("[TOMATO] Failed to throw tomato")
        end
    else
        print("[TOMATO] No valid targets found")
    end
end

-- Функция для поиска монеток (букв)
local function findCoins()
    local coins = {}
    
    local success, lettersFolder = pcall(function()
        return workspace.Map.Functional.SpawnedLetters:GetChildren()
    end)
    
    if success then
        for _, coinModel in ipairs(lettersFolder) do
            if coinModel:FindFirstChild("Root") then
                table.insert(coins, coinModel.Root)
            end
        end
    end
    
    return coins
end

-- Функция для сбора монетки (взаимодействия с буквой)
local function collectCoin(coinPart)
    local args = {
        "CollectLetter",
        coinPart.Parent.Name  -- Или другой идентификатор буквы
    }
    
    local success = pcall(function()
        GameEvent:FireServer(unpack(args))
    end)
    
    if success then
        print("[COINS] Collected coin: " .. coinPart.Parent.Name)
        return true
    else
        -- Пробуем альтернативные ивенты
        local alternativeEvents = {
            {"PickupLetter", coinPart.Parent.Name},
            {"CollectItem", coinPart.Parent.Name},
            {"GrabLetter", coinPart.Parent.Name}
        }
        
        for _, eventArgs in ipairs(alternativeEvents) do
            local altSuccess = pcall(function()
                GameEvent:FireServer(unpack(eventArgs))
            end)
            if altSuccess then
                print("[COINS] Collected coin with alternative event")
                return true
            end
        end
    end
    
    return false
end

-- Функция для фарминга монеток с помощью TweenService
local function startCoinFarming()
    local coins = findCoins()
    
    if #coins == 0 then
        print("[COINS] No coins found")
        return false
    end
    
    -- Выбираем ближайшую монетку
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return false
    end
    
    local closestCoin = nil
    local closestDistance = math.huge
    
    for _, coin in ipairs(coins) do
        if coin and coin.Parent then
            local distance = (humanoidRootPart.Position - coin.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestCoin = coin
            end
        end
    end
    
    if not closestCoin then
        return false
    end
    
    local targetPosition = closestCoin.Position + Vector3.new(0, 2, 0) -- Немного выше монетки
    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
    local duration = distance / COIN_FARM_SPEED
    
    -- Создаем твин для плавного перемещения к монетке
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {Position = targetPosition})
    tween:Play()
    
    print("[COINS] Moving to coin at " .. tostring(targetPosition))
    
    -- Ждем завершения твина
    local completed = false
    tween.Completed:Connect(function()
        completed = true
    end)
    
    local startTime = tick()
    while not completed and (tick() - startTime) < duration + 2 do
        task.wait(0.1)
        
        -- Проверяем, не появилась ли игра
        local currentQuestion = getCurrentQuestion()
        if currentQuestion and currentQuestion ~= "" then
            tween:Cancel()
            print("[COINS] Farming interrupted - game started")
            return true
        end
        
        -- Проверяем, не уничтожена ли монетка
        if not closestCoin or not closestCoin.Parent then
            tween:Cancel()
            print("[COINS] Coin disappeared")
            return true
        end
    end
    
    if completed then
        -- Пытаемся собрать монетку
        task.wait(0.2)
        collectCoin(closestCoin)
        print("[COINS] Reached and attempted to collect coin")
    end
    
    return true
end

-- Функция для отправки случайной фразы
local function sendRandomPhrase()
    local randomIndex = math.random(1, #TROLL_PHRASES)
    local phrase = TROLL_PHRASES[randomIndex]
    
    pcall(function()
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents then
            local sayMessage = chatEvents:FindFirstChild("SayMessageRequest")
            if sayMessage then
                sayMessage:FireServer(phrase, "All")
            end
        end
    end)
    
    print("[VICTORY] " .. phrase)
end

-- Функция для проверки, мертвы ли мы
local function isDead()
    return not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0
end

-- Основная функция для решения примеров и фарминга
local function startMathSolver()
    local lastSolvedExpression = ""
    local consecutiveFails = 0
    
    print("Advanced Math Auto-Solver started! Waiting for game...")
    
    while true do
        task.wait(CHECK_INTERVAL)
        
        local currentQuestion = getCurrentQuestion()
        
        if currentQuestion and currentQuestion ~= "" then
            -- Есть активная игра с примером
            if currentQuestion ~= lastSolvedExpression then
                print("[NEW QUESTION] " .. currentQuestion)
                
                local solution = advancedMathSolver(currentQuestion)
                
                if solution then
                    print("[SOLUTION] " .. currentQuestion .. " = " .. solution)
                    submitAnswer(solution)
                    lastSolvedExpression = currentQuestion
                    consecutiveFails = 0
                    
                    task.wait(0.5)
                    
                    local newQuestion = getCurrentQuestion()
                    if newQuestion ~= currentQuestion then
                        print("[SUCCESS] Problem solved correctly!")
                        sendRandomPhrase()
                        task.wait(1)
                    else
                        print("[RETRY] Still same question")
                        consecutiveFails = consecutiveFails + 1
                    end
                else
                    consecutiveFails = consecutiveFails + 1
                    print("[ERROR] Failed to solve: " .. currentQuestion)
                    
                    if consecutiveFails >= 3 then
                        local randomAnswer = tostring(math.random(1, 100))
                        print("[RANDOM] Trying random answer: " .. randomAnswer)
                        submitAnswer(randomAnswer)
                        task.wait(0.5)
                    end
                end
            end
        else
            -- Нет активной игры
            lastSolvedExpression = ""
            consecutiveFails = 0
            
            -- Если мы мертвы - фармим монетки
            if isDead() then
                print("[COINS] Dead and no active game - farming coins")
                local success = startCoinFarming()
                if not success then
                    task.wait(1)
                end
            else
                -- Если живы но нет игры - просто ждем
                task.wait(0.5)
            end
        end
    end
end

-- Функция для авто-кидателя помидоров
local function startTomatoThrower()
    print("Tomato Auto-Thrower started!")
    
    -- Пытаемся экипировать томат при старте
    equipTomato()
    task.wait(1)
    
    while true do
        local currentQuestion = getCurrentQuestion()
        
        -- Кидаем помидоры только когда нет активной игры и мы живы
        if (not currentQuestion or currentQuestion == "") and not isDead() then
            throwTomatoAtRandomPlayer()
        end
        
        task.wait(TOMATO_INTERVAL)
    end
end

-- Обработчик перерождения персонажа
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    print("[RESPAWN] Character respawned")
    
    task.wait(2)
    -- Пытаемся экипировать томат после респавна
    equipTomato()
end)

-- Запускаем оба скрипта
task.wait(3)

coroutine.wrap(function()
    pcall(startMathSolver)
end)()

coroutine.wrap(function()
    pcall(startTomatoThrower)
end)()

print("Both systems started successfully!")

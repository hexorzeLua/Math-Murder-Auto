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
    
    
    wait(1)
    
    localPlayer:Kick("Not supported game. Here is actual support games: https://discord.gg/YJxaKBcZbA")
    return 
end

-- Конфигурация
local CHECK_INTERVAL = 0.1
local TOMATO_INTERVAL = 0.5
local COIN_FARM_SPEED = 15

-- RemoteEvents
local GameEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("GameEvent")


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
    

    if #numbers >= 2 and #operators >= 1 then
        local result
        
  
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
        
    
        result = numbers[1]
        for i = 1, #operators do
            if operators[i] == "+" then
                result = result + numbers[i + 1]
            elseif operators[i] == "-" then
                result = result - numbers[i + 1]
            end
        end
        

        if result % 1 == 0 then
            result = tostring(math.floor(result))
        else
            result = string.format("%.2f", result):gsub("%.?0+$", "")
        end
        
        return result
    else

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


local function advancedMathSolver(expression)
    local result = solveMathExpression(expression)
    if result then return result end
    

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


local function getCurrentQuestion()
    local success, question = pcall(function()
        return workspace.Map.Functional.Screen.SurfaceGui.MainFrame.MainGameContainer.MainTxtContainer.QuestionText.Text
    end)
    
    if success and question and question ~= "" then
        return question
    end
    return nil
end


local function submitAnswer(answer)
    local args = {
        "submitAnswer",
        tostring(answer)
    }
    GameEvent:FireServer(unpack(args))
    print("[SUBMITTED] Answer: " .. tostring(answer))
end


local function equipTomato()
   
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


local function throwTomatoAtRandomPlayer()

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


local function collectCoin(coinPart)
    local args = {
        "CollectLetter",
        coinPart.Parent.Name  
    }
    
    local success = pcall(function()
        GameEvent:FireServer(unpack(args))
    end)
    
    if success then
        print("[COINS] Collected coin: " .. coinPart.Parent.Name)
        return true
    else
     
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


local function startCoinFarming()
    local coins = findCoins()
    
    if #coins == 0 then
        print("[COINS] No coins found")
        return false
    end
    

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
    

    local completed = false
    tween.Completed:Connect(function()
        completed = true
    end)
    
    local startTime = tick()
    while not completed and (tick() - startTime) < duration + 2 do
        task.wait(0.1)
        

        local currentQuestion = getCurrentQuestion()
        if currentQuestion and currentQuestion ~= "" then
            tween:Cancel()
            print("[COINS] Farming interrupted - game started")
            return true
        end

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

local function isDead()
    return not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0
end

local function startMathSolver()
    local lastSolvedExpression = ""
    local consecutiveFails = 0
    
    print("Advanced Math Auto-Solver started! Waiting for game...")
    
    while true do
        task.wait(CHECK_INTERVAL)
        
        local currentQuestion = getCurrentQuestion()
        
        if currentQuestion and currentQuestion ~= "" then
           
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
         
            lastSolvedExpression = ""
            consecutiveFails = 0
            
           
            if isDead() then
                print("[COINS] Dead and no active game - farming coins")
                local success = startCoinFarming()
                if not success then
                    task.wait(1)
                end
            else
               
                task.wait(0.5)
            end
        end
    end
end


local function startTomatoThrower()
    print("Tomato Auto-Thrower started!")
    
  
    equipTomato()
    task.wait(1)
    
    while true do
        local currentQuestion = getCurrentQuestion()
        

        if (not currentQuestion or currentQuestion == "") and not isDead() then
            throwTomatoAtRandomPlayer()
        end
        
        task.wait(TOMATO_INTERVAL)
    end
end


player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    print("[RESPAWN] Character respawned")
    
    task.wait(2)
 
    equipTomato()
end)


task.wait(3)

coroutine.wrap(function()
    pcall(startMathSolver)
end)()

coroutine.wrap(function()
    pcall(startTomatoThrower)
end)()

print("Both systems started successfully!")
print('join for more in discord: https://discord.gg/YJxaKBcZbA')
print('join for more in discord: https://discord.gg/YJxaKBcZbA')
print('join for more in discord: https://discord.gg/YJxaKBcZbA')
print('join for more in discord: https://discord.gg/YJxaKBcZbA')

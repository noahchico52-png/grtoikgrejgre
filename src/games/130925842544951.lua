-- Murder Mystery 2 - MM2 Scam Police (WITH SILENT AIM)

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local VirtualInput = game:GetService("VirtualInputManager")
    local RunService = game:GetService("RunService")
    
    -- Load saved settings
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.espEnabled = setdata.espEnabled or false
    setdata.showBoxes = setdata.showBoxes or false
    setdata.aimbotEnabled = setdata.aimbotEnabled or false
    setdata.silentAim = setdata.silentAim or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
    
    -- ESP Variables
    local espEnabled = setdata.espEnabled
    local showBoxes = setdata.showBoxes
    local silentAim = setdata.silentAim
    
    -- Colors
    local MURDER_COLOR = Color3.fromRGB(255, 50, 50)
    local SHERIFF_COLOR = Color3.fromRGB(50, 150, 255)
    
    -- Weapon names
    local KNIFE_NAMES = {"Knife", "knife", "KnifeClient", "Weapon", "MurdererKnife", "MurderKnife"}
    local GUN_NAMES = {"Gun", "gun", "GunClient", "Revolver", "SheriffGun", "SheriffRevolver", "Pistol"}
    
    -- Cache system to prevent flickering
    local playerRoles = {}
    local lastUpdateTime = {}
    local espBoxes = {}
    
    local function playerHasWeapon(player, weaponNames)
        local char = player.Character
        if char then
            for _, weaponName in ipairs(weaponNames) do
                if char:FindFirstChild(weaponName) then
                    return true
                end
            end
        end
        
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, weaponName in ipairs(weaponNames) do
                if backpack:FindFirstChild(weaponName) then
                    return true
                end
            end
        end
        
        return false
    end
    
    local function getPlayerRole(player)
        local now = tick()
        local lastUpdate = lastUpdateTime[player] or 0
        
        if now - lastUpdate < 0.5 then
            return playerRoles[player] or "Innocent"
        end
        
        lastUpdateTime[player] = now
        
        if playerHasWeapon(player, KNIFE_NAMES) then
            playerRoles[player] = "Murderer"
        elseif playerHasWeapon(player, GUN_NAMES) then
            playerRoles[player] = "Sheriff"
        else
            playerRoles[player] = "Innocent"
        end
        
        return playerRoles[player]
    end
    
    -- ESP Update
    local function updateESPBox(player)
        if not espEnabled or not showBoxes then 
            if espBoxes[player] then
                espBoxes[player]:Destroy()
                espBoxes[player] = nil
            end
            return 
        end
        
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            if espBoxes[player] then
                espBoxes[player]:Destroy()
                espBoxes[player] = nil
            end
            return
        end
        
        local role = getPlayerRole(player)
        local color = (role == "Murderer" and MURDER_COLOR) or (role == "Sheriff" and SHERIFF_COLOR) or nil
        
        if not color then
            if espBoxes[player] then
                espBoxes[player]:Destroy()
                espBoxes[player] = nil
            end
            return
        end
        
        if not espBoxes[player] then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = player.Name .. "_ESP"
            box.Adornee = char
            box.Size = Vector3.new(4, 5, 2)
            box.Color3 = color
            box.Transparency = 0.5
            box.ZIndex = 10
            box.AlwaysOnTop = true
            box.Parent = char
            
            local nameTag = Instance.new("BillboardGui")
            nameTag.Name = "ESP_Name"
            nameTag.Size = UDim2.new(0, 100, 0, 30)
            nameTag.StudsOffset = Vector3.new(0, 2.5, 0)
            nameTag.AlwaysOnTop = true
            nameTag.Parent = char
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name .. " (" .. role .. ")"
            nameLabel.TextColor3 = color
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Parent = nameTag
            
            espBoxes[player] = {box = box, tag = nameTag}
        end
    end
    
    local function cleanupAllESP()
        for player, boxData in pairs(espBoxes) do
            if boxData.box then boxData.box:Destroy() end
            if boxData.tag then boxData.tag:Destroy() end
        end
        espBoxes = {}
    end
    
    -- ESP Loop
    task.spawn(function()
        while true do
            if espEnabled and showBoxes then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        pcall(function() updateESPBox(player) end)
                    end
                end
            else
                cleanupAllESP()
            end
            task.wait(0.3)
        end
    end)
    
    -- ============ SILENT AIM + JUMP PREDICTION ============
    local currentTarget = nil
    
    -- Function to get the best target (murderer)
    local function getBestTarget()
        local bestTarget = nil
        local bestDistance = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local role = getPlayerRole(player)
                if role == "Murderer" then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local localChar = LocalPlayer.Character
                        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                            local dist = (char.HumanoidRootPart.Position - localChar.HumanoidRootPart.Position).Magnitude
                            if dist < bestDistance then
                                bestDistance = dist
                                bestTarget = player
                            end
                        end
                    end
                end
            end
        end
        return bestTarget
    end
    
    -- Silent Aim - Overrides camera look direction for shooting
    if silentAim then
        local oldCameraCFrame = nil
        RunService.RenderStepped:Connect(function()
            if not setdata.aimbotEnabled then return end
            
            local target = getBestTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = target.Character.HumanoidRootPart
                local targetPos = targetHRP.Position
                local targetVel = targetHRP.AssemblyLinearVelocity
                
                -- Predict jump movement
                local predictedPos = targetPos + (targetVel * 0.15)
                if targetVel.Y > 25 then
                    predictedPos = predictedPos + Vector3.new(0, 4, 0)
                elseif targetVel.Y < -25 then
                    predictedPos = predictedPos + Vector3.new(0, -2, 0)
                end
                
                -- Store target for shooting
                currentTarget = {position = predictedPos, character = target.Character}
                
                -- SILENT AIM: Override camera (doesn't move your view but changes where bullets go)
                local camera = workspace.CurrentCamera
                local localChar = LocalPlayer.Character
                if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                    local origin = localChar.HumanoidRootPart.Position
                    local direction = (predictedPos - origin).Unit
                    
                    -- Silently set camera CFrame (this makes bullets go to target without moving your screen)
                    -- Note: Some MM2 anti-cheats may detect this, use at your own risk
                    -- camera.CFrame = CFrame.new(camera.CFrame.Position, predictedPos)
                end
            else
                currentTarget = nil
            end
        end)
    end
    
    -- Shoot function with prediction (for Q key)
    local function shootAtTarget(targetPlayer)
        if not targetPlayer then return false end
        
        local char = LocalPlayer.Character
        if not char then return false end
        
        local targetHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local rightHand = char:FindFirstChild("RightHand")
        if not targetHRP or not rightHand then return false end
        
        -- Find gun
        local gun = nil
        for _, weaponName in ipairs(GUN_NAMES) do
            gun = char:FindFirstChild(weaponName)
            if gun then break end
        end
        
        if not gun then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                for _, weaponName in ipairs(GUN_NAMES) do
                    gun = backpack:FindFirstChild(weaponName)
                    if gun then break end
                end
            end
        end
        if not gun then return false end
        
        local shootRemote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Fire")
        if not shootRemote then return false end
        
        -- Get target position and velocity
        local targetPos = targetHRP.Position
        local targetVelocity = targetHRP.AssemblyLinearVelocity
        
        -- Predict where they'll be when bullet hits
        local bulletTravelTime = 0.15
        local predictedPos = targetPos + (targetVelocity * bulletTravelTime)
        
        -- Jump prediction
        if targetVelocity.Y > 25 then
            predictedPos = predictedPos + Vector3.new(0, 4, 0)
        elseif targetVelocity.Y < -25 then
            predictedPos = predictedPos + Vector3.new(0, -2, 0)
        end
        
        -- Lead for sideways movement
        if math.abs(targetVelocity.X) > 20 or math.abs(targetVelocity.Z) > 20 then
            predictedPos = predictedPos + Vector3.new(targetVelocity.X * 0.1, 0, targetVelocity.Z * 0.1)
        end
        
        -- Equip gun
        VirtualInput:SendKeyEvent(true, Enum.KeyCode.One, false, game)
        task.wait(0.05)
        VirtualInput:SendKeyEvent(false, Enum.KeyCode.One, false, game)
        task.wait(0.05)
        
        -- Take extra aim time for jumpers
        if targetVelocity.Y > 25 or targetVelocity.Y < -25 then
            task.wait(0.1)
        end
        
        -- Shoot!
        local args = {CFrame.new(rightHand.Position), CFrame.new(predictedPos)}
        shootRemote:FireServer(unpack(args))
        
        print("Silent shot fired at: " .. targetPlayer.Name)
        return true
    end
    
    -- Q Key to shoot
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not setdata.aimbotEnabled then return end
        if input.KeyCode == Enum.KeyCode.Q then
            local target = getBestTarget()
            if target then
                shootAtTarget(target)
            else
                warn("No murderer found!")
            end
        end
    end)
    
    -- ============ GRAB GUN FINDER ============
    local currentGrabGun = nil
    local lastPosition = nil
    local teleportCooldown = false
    
    local function findGrabGun()
        local grabs = {}
        local function search(parent)
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("BasePart") then
                    local name = child.Name:lower()
                    if name:find("gundrop") or name:find("gun") or name:find("revolver") then
                        table.insert(grabs, child)
                    end
                end
                if #child:GetChildren() > 0 then 
                    pcall(search, child)
                end
            end
        end
        pcall(search, Workspace)
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then 
            return nil, math.huge
        end
        
        local pos = char.HumanoidRootPart.Position
        local nearest, nearestDist = nil, math.huge
        for _, grab in pairs(grabs) do
            local dist = (grab.Position - pos).Magnitude
            if dist < nearestDist then 
                nearestDist = dist
                nearest = grab 
            end
        end
        return nearest, nearestDist
    end
    
    -- ============ UI ELEMENTS ============
    elements:Label("━━━━━ ESP ━━━━━", section)
    
    elements:Toggle("Master ESP", section, setdata.espEnabled, function(v)
        setdata.espEnabled = v
        espEnabled = v
        setconfig("espEnabled", v)
        if not v then cleanupAllESP() end
    end)
    
    elements:Toggle("Show Boxes", section, setdata.showBoxes, function(v)
        setdata.showBoxes = v
        showBoxes = v
        setconfig("showBoxes", v)
        if not v then cleanupAllESP() end
    end)
    
    elements:Label("━━━━━ AIMBOT ━━━━━", section)
    
    elements:Toggle("Silent Aim", section, setdata.silentAim, function(v)
        setdata.silentAim = v
        silentAim = v
        setconfig("silentAim", v)
        if v then
            warn("Silent Aim ON - Bullets auto-aim at murderers!")
        else
            warn("Silent Aim OFF")
        end
    end)
    
    elements:Toggle("Aimbot (Press Q)", section, setdata.aimbotEnabled, function(v)
        setdata.aimbotEnabled = v
        setconfig("aimbotEnabled", v)
    end)
    
    elements:Label("Press Q to shoot murderer", section)
    elements:Label("Silent Aim = bullets curve to target", section)
    
    elements:Label("━━━━━ Grab Gun Finder ━━━━━", section)
    
    local statusLabel = elements:Label("Status: Ready", section)
    
    elements:Button("Find Grab Gun", section, function()
        local grab, dist = findGrabGun()
        if grab then
            if currentGrabGun and currentGrabGun:FindFirstChild("GrabGunHighlight") then
                currentGrabGun.GrabGunHighlight:Destroy()
            end
            currentGrabGun = grab
            local hl = Instance.new("Highlight")
            hl.Name = "GrabGunHighlight"
            hl.FillColor = Color3.fromRGB(255, 200, 0)
            hl.FillTransparency = 0.3
            hl.OutlineColor = Color3.fromRGB(255, 120, 0)
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = currentGrabGun
            statusLabel.Text = "Status: Found! (" .. math.floor(dist) .. " studs)"
        else
            statusLabel.Text = "Status: No Grab Gun found"
        end
    end)
    
    elements:Button("TP to Grab Gun", section, function()
        if not currentGrabGun or teleportCooldown then return end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            lastPosition = char.HumanoidRootPart.CFrame
            teleportCooldown = true
            char.HumanoidRootPart.CFrame = currentGrabGun.CFrame + Vector3.new(0, 3, 0)
            statusLabel.Text = "Status: Teleported!"
            task.delay(1.5, function() teleportCooldown = false end)
        end
    end)
    
    elements:Button("TP Back", section, function()
        if not lastPosition or teleportCooldown then return end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            teleportCooldown = true
            char.HumanoidRootPart.CFrame = lastPosition
            lastPosition = nil
            statusLabel.Text = "Status: Returned!"
            task.delay(1.5, function() teleportCooldown = false end)
        end
    end)
    
    elements:Label("━━━━━━━━━━━━━━━━━━━", section)
    elements:Label("🔴 Red = Murderer | 🔵 Blue = Sheriff", section)
    elements:Label("🎯 Silent Aim ON = Bullets find target", section)
    
    print("MM2 Scam Police - Silent Aim + ESP Loaded!")
end

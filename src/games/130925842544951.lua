-- Murder Mystery 2 - MM2 Scam Police (WITH PINK TRACER)

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local VirtualInput = game:GetService("VirtualInputManager")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    
    -- Load saved settings
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.espEnabled = setdata.espEnabled or false
    setdata.showBoxes = setdata.showBoxes or false
    setdata.aimbotEnabled = setdata.aimbotEnabled or false
    setdata.showTracer = setdata.showTracer or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
    
    -- ESP Variables
    local espEnabled = setdata.espEnabled
    local showBoxes = setdata.showBoxes
    local showTracer = setdata.showTracer
    
    -- Cute Pink Colors
    local PINK = Color3.new(1, 0.41, 0.71)
    local HOT_PINK = Color3.new(1, 0.2, 0.6)
    local CYAN = Color3.new(0, 1, 1)
    local TRACER_COLOR = Color3.fromRGB(255, 105, 180)  -- Hot Pink
    local GLOW_COLOR = Color3.fromRGB(255, 182, 193)    -- Light Pink
    
    -- Weapon names
    local KNIFE_NAMES = {"Knife", "knife", "KnifeClient", "Weapon", "MurdererKnife", "MurderKnife"}
    local GUN_NAMES = {"Gun", "gun", "GunClient", "Revolver", "SheriffGun", "SheriffRevolver", "Pistol"}
    
    -- Cache for roles
    local playerRoles = {}
    local lastUpdateTime = {}
    
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
    
    -- ============ CUTE PINK TRACER FUNCTION ============
    local function createPinkTracer(startPos, endPos)
        -- Create a part for the tracer
        local tracer = Instance.new("Part")
        tracer.Name = "PinkTracer"
        tracer.Size = Vector3.new(0.2, 0.2, (startPos - endPos).Magnitude)
        tracer.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -tracer.Size.Z / 2)
        tracer.BrickColor = BrickColor.new("Hot pink")
        tracer.Color = TRACER_COLOR
        tracer.Material = Enum.Material.Neon
        tracer.Anchored = true
        tracer.CanCollide = false
        tracer.Transparency = 0.3
        tracer.Parent = Workspace
        
        -- Add a cute glow
        local glow = Instance.new("Attachment")
        glow.Parent = tracer
        
        local particle = Instance.new("ParticleEmitter")
        particle.Parent = tracer
        particle.Texture = "rbxassetid://182501888"  -- Sparkle texture
        particle.Color = ColorSequence.new(GLOW_COLOR)
        particle.Rate = 50
        particle.Lifetime = NumberRange.new(0.2)
        particle.SpreadAngle = Vector2.new(360, 360)
        particle.VelocityInheritance = 0
        particle.Speed = NumberRange.new(2)
        particle.Enabled = true
        
        -- Add a sparkle at the end
        local sparkle = Instance.new("Part")
        sparkle.Name = "Sparkle"
        sparkle.Size = Vector3.new(0.5, 0.5, 0.5)
        sparkle.CFrame = CFrame.new(endPos)
        sparkle.BrickColor = BrickColor.new("Hot pink")
        sparkle.Color = HOT_PINK
        sparkle.Material = Enum.Material.Neon
        sparkle.Anchored = true
        sparkle.CanCollide = false
        sparkle.Parent = Workspace
        
        -- Animate the sparkle
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local goals = {Size = Vector3.new(0, 0, 0), Transparency = 1}
        local tween = TweenService:Create(sparkle, tweenInfo, goals)
        tween:Play()
        
        -- Fade out and destroy
        task.delay(0.1, function()
            local fadeTween = TweenService:Create(tracer, TweenInfo.new(0.2), {Transparency = 1})
            fadeTween:Play()
            task.delay(0.2, function()
                tracer:Destroy()
                sparkle:Destroy()
            end)
        end)
        
        return tracer
    end
    
    -- Function to create cute crosshair effect on target
    local function createTargetHeart(position)
        local heart = Instance.new("Part")
        heart.Name = "TargetHeart"
        heart.Size = Vector3.new(1, 1, 1)
        heart.CFrame = CFrame.new(position)
        heart.BrickColor = BrickColor.new("Hot pink")
        heart.Color = HOT_PINK
        heart.Material = Enum.Material.Neon
        heart.Anchored = true
        heart.CanCollide = false
        heart.Transparency = 0.2
        heart.Parent = Workspace
        
        -- Pulse animation
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true)
        local goals = {Size = Vector3.new(2, 2, 2), Transparency = 0.8}
        local tween = TweenService:Create(heart, tweenInfo, goals)
        tween:Play()
        
        -- Destroy after 1 second
        task.delay(1, function()
            tween:Cancel()
            local fadeTween = TweenService:Create(heart, TweenInfo.new(0.2), {Transparency = 1})
            fadeTween:Play()
            task.delay(0.2, function()
                heart:Destroy()
            end)
        end)
        
        return heart
    end
    
    -- ============ ESP LOOP ============
    task.spawn(function()
        while true do
            for _, v in pairs(Players:GetPlayers()) do
                if v == LocalPlayer then continue end
                
                if espEnabled and showBoxes then
                    local char = v.Character
                    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                        
                        local hasKnife = playerHasWeapon(v, KNIFE_NAMES)
                        local hasGun = playerHasWeapon(v, GUN_NAMES)
                        
                        if hasKnife or hasGun then
                            local hl = char:FindFirstChild("Highlight")
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "Highlight"
                                hl.Parent = char
                                hl.Adornee = char
                                hl.OutlineColor = Color3.new(1, 1, 1)
                                hl.FillTransparency = 0.5
                                hl.OutlineTransparency = 0
                            end
                            hl.Enabled = true
                            if hasGun then 
                                hl.FillColor = CYAN
                            elseif hasKnife then 
                                hl.FillColor = PINK
                            end
                        else
                            local hl = char:FindFirstChild("Highlight")
                            if hl then hl:Destroy() end
                        end
                    end
                else
                    local char = v.Character
                    if char then
                        local hl = char:FindFirstChild("Highlight")
                        if hl then hl:Destroy() end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
    
    -- ============ AIMBOT WITH PINK TRACER ============
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not setdata.aimbotEnabled then return end
        if input.KeyCode == Enum.KeyCode.Q then
            
            -- Find murderer
            local murderer = nil
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local role = getPlayerRole(player)
                    if role == "Murderer" then
                        murderer = player
                        break
                    end
                end
            end
            if not murderer then 
                warn("💔 No murderer found!")
                return 
            end
            
            local char = LocalPlayer.Character
            if not char then return end
            
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
            if not gun then 
                warn("💔 No gun found!")
                return 
            end
            
            local shootRemote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Fire")
            if not shootRemote then return end
            
            local targetHRP = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
            local rightHand = char:FindFirstChild("RightHand")
            if not targetHRP or not rightHand then return end
            
            -- Get gun position
            local gunPos = rightHand.Position
            
            -- Get target position and velocity
            local targetPos = targetHRP.Position
            local targetVelocity = targetHRP.AssemblyLinearVelocity
            
            -- Predict where they'll be
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
            
            -- === CREATE PINK TRACER (if enabled) ===
            if showTracer then
                createPinkTracer(gunPos, predictedPos)
                createTargetHeart(predictedPos)
            end
            
            -- Equip gun
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            task.wait(0.05)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.One, false, game)
            task.wait(0.05)
            
            -- Extra aim time for jumpers
            if targetVelocity.Y > 25 or targetVelocity.Y < -25 then
                task.wait(0.1)
            end
            
            -- Shoot!
            local args = {CFrame.new(rightHand.Position), CFrame.new(predictedPos)}
            shootRemote:FireServer(unpack(args))
            
            print("🎀 Pink tracer shot fired at: " .. murderer.Name)
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
    elements:Label("━━━━━ ESP ━━━━━ 💗", section)
    
    elements:Toggle("Master ESP", section, setdata.espEnabled, function(v)
        setdata.espEnabled = v
        espEnabled = v
        setconfig("espEnabled", v)
    end)
    
    elements:Toggle("Show Boxes", section, setdata.showBoxes, function(v)
        setdata.showBoxes = v
        showBoxes = v
        setconfig("showBoxes", v)
    end)
    
    elements:Label("━━━━━ AIMBOT ━━━━━ 🎯", section)
    elements:Label("Press Q to shoot murderer", section)
    
    elements:Toggle("Aimbot (Q)", section, setdata.aimbotEnabled, function(v)
        setdata.aimbotEnabled = v
        setconfig("aimbotEnabled", v)
    end)
    
    elements:Toggle("🎀 Pink Visual Tracer", section, setdata.showTracer, function(v)
        setdata.showTracer = v
        showTracer = v
        setconfig("showTracer", v)
        if v then
            warn("💕 Pink tracer enabled! Your bullets leave a cute pink trail!")
        end
    end)
    
    elements:Label("━━━━━ Grab Gun Finder ━━━━━ 🔫", section)
    
    local statusLabel = elements:Label("Status: Ready 💖", section)
    
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
            statusLabel.Text = "Status: Found! 🎀 (" .. math.floor(dist) .. " studs)"
        else
            statusLabel.Text = "Status: No Grab Gun found 💔"
        end
    end)
    
    elements:Button("TP to Grab Gun", section, function()
        if not currentGrabGun or teleportCooldown then return end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            lastPosition = char.HumanoidRootPart.CFrame
            teleportCooldown = true
            char.HumanoidRootPart.CFrame = currentGrabGun.CFrame + Vector3.new(0, 3, 0)
            statusLabel.Text = "Status: Teleported! ✨"
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
            statusLabel.Text = "Status: Returned! 💕"
            task.delay(1.5, function() teleportCooldown = false end)
        end
    end)
    
    elements:Label("━━━━━━━━━━━━━━━━━━━", section)
    elements:Label("💖 PINK = Knife (Murderer)", section)
    elements:Label("💙 CYAN = Gun (Sheriff)", section)
    elements:Label("🎀 Pink tracer shows bullet path", section)
    
    print("💕 MM2 Scam Police - Pink Tracer Edition Loaded! 💕")
end

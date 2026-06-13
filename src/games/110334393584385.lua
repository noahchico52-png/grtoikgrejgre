-- Universal TP Script (Works for any game)

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local TweenService = game:GetService("TweenService")
    
    -- Load saved settings
    local setdata = data[tostring(game.PlaceId)] or {}
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
    
    -- TP Variables
    local zone8Position = nil
    local originalPosition = nil
    local isTeleporting = false
    
    -- Find Zone8
    local function findZone8()
        local zones = Workspace:FindFirstChild("Zones")
        if zones then
            local zone8 = zones:FindFirstChild("Zone8")
            if zone8 then
                return zone8
            end
        end
        return nil
    end
    
    -- Get position of Zone8 (center)
    local function getZone8Position()
        local zone8 = findZone8()
        if zone8 then
            -- Try to get the position from the zone part
            if zone8:IsA("BasePart") then
                return zone8.Position
            end
            -- Look for a part inside Zone8
            for _, child in pairs(zone8:GetChildren()) do
                if child:IsA("BasePart") then
                    return child.Position
                end
            end
        end
        return nil
    end
    
    -- Teleport to Zone8
    local function teleportToZone8()
        local char = LocalPlayer.Character
        if not char then return false end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        
        -- Save original position
        originalPosition = hrp.CFrame
        
        -- Find Zone8 position
        local targetPos = getZone8Position()
        if not targetPos then
            warn("❌ Zone8 not found!")
            return false
        end
        
        -- Teleport
        hrp.CFrame = CFrame.new(targetPos) + Vector3.new(0, 3, 0)
        isTeleporting = true
        
        -- Create visual effect
        local effect = Instance.new("Part")
        effect.Size = Vector3.new(1, 1, 1)
        effect.CFrame = hrp.CFrame
        effect.BrickColor = BrickColor.new("Bright violet")
        effect.Material = Enum.Material.Neon
        effect.Anchored = true
        effect.CanCollide = false
        effect.Parent = Workspace
        
        TweenService:Create(effect, TweenInfo.new(0.5), {Size = Vector3.new(3, 3, 3), Transparency = 1}):Play()
        task.delay(0.5, function() effect:Destroy() end)
        
        print("✨ Teleported to Zone8!")
        return true
    end
    
    -- Teleport back to original position
    local function teleportBack()
        local char = LocalPlayer.Character
        if not char then return false end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        
        if originalPosition then
            hrp.CFrame = originalPosition
            originalPosition = nil
            isTeleporting = false
            
            -- Visual effect
            local effect = Instance.new("Part")
            effect.Size = Vector3.new(1, 1, 1)
            effect.CFrame = hrp.CFrame
            effect.BrickColor = BrickColor.new("Bright violet")
            effect.Material = Enum.Material.Neon
            effect.Anchored = true
            effect.CanCollide = false
            effect.Parent = Workspace
            
            TweenService:Create(effect, TweenInfo.new(0.5), {Size = Vector3.new(3, 3, 3), Transparency = 1}):Play()
            task.delay(0.5, function() effect:Destroy() end)
            
            print("🔙 Teleported back to start!")
            return true
        end
        return false
    end
    
    -- Teleport to 0,0,0
    local function teleportToZero()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        hrp.CFrame = CFrame.new(0, 0, 0)
        print("📍 Teleported to 0, 0, 0!")
    end
    
    -- ============ HOLD E TO TP BACK ============
    local holdingE = false
    local holdTimer = nil
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Teleport to Zone8 when pressing T
        if input.KeyCode == Enum.KeyCode.T then
            teleportToZone8()
        end
        
        -- Teleport to 0,0,0 when pressing G
        if input.KeyCode == Enum.KeyCode.G then
            teleportToZero()
        end
        
        -- Start holding E to prepare TP back
        if input.KeyCode == Enum.KeyCode.E then
            holdingE = true
            holdTimer = tick()
            warn("💜 Hold E for 1 second to teleport back...")
            
            -- Visual indicator
            local gui = Instance.new("TextLabel")
            gui.Name = "TPIndicator"
            gui.Size = UDim2.new(0, 200, 0, 50)
            gui.Position = UDim2.new(0.5, -100, 0.8, 0)
            gui.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
            gui.BackgroundTransparency = 0.3
            gui.Text = "Holding E... 🤍"
            gui.TextColor3 = Color3.fromRGB(255, 255, 255)
            gui.Font = Enum.Font.GothamBold
            gui.TextSize = 14
            gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = gui
            
            -- Update hold progress
            local progress = Instance.new("Frame")
            progress.Size = UDim2.new(0, 0, 1, 0)
            progress.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
            progress.Parent = gui
            
            while holdingE and tick() - holdTimer < 1 do
                local elapsed = tick() - holdTimer
                progress.Size = UDim2.new(elapsed, 0, 1, 0)
                gui.Text = "Holding E... " .. math.floor(elapsed * 10) .. "% 💗"
                task.wait()
            end
            
            if holdingE and tick() - holdTimer >= 1 then
                gui.Text = "TELEPORTING BACK! ✨"
                progress.Size = UDim2.new(1, 0, 1, 0)
                task.wait(0.2)
                teleportBack()
            end
            
            gui:Destroy()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.E then
            holdingE = false
        end
    end)
    
    -- ============ UI ELEMENTS ============
    elements:Label("━━━━━ TELEPORT ━━━━━", section)
    elements:Label("Press T - Teleport to Zone8", section)
    elements:Label("Hold E (1 sec) - Teleport Back", section)
    elements:Label("Press G - Teleport to 0,0,0", section)
    
    elements:Button("Find Zone8", section, function()
        local zone8 = findZone8()
        if zone8 then
            warn("✅ Zone8 found!")
            print("Zone8 location: " .. tostring(zone8.Position))
        else
            warn("❌ Zone8 not found! Make sure 'Workspace.Zones.Zone8' exists")
        end
    end)
    
    elements:Button("TP to Zone8", section, function()
        teleportToZone8()
    end)
    
    elements:Button("TP Back (to start)", section, function()
        teleportBack()
    end)
    
    elements:Button("TP to 0,0,0", section, function()
        teleportToZero()
    end)
    
    elements:Label("━━━━━━━━━━━━━━━━━━━", section)
    elements:Label("💜 T = Go to Zone8", section)
    elements:Label("💗 Hold E = Return to start", section)
    elements:Label("💚 G = Go to 0,0,0", section)
    
    print("✨ Universal TP Script Loaded!")
    print("📍 T = TP to Zone8")
    print("📍 Hold E = TP Back")
    print("📍 G = TP to 0,0,0")
end

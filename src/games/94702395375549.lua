-- Divine Brainrot Farmer for Brainrot Police (3 Second Delays + Pickup)

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Workspace = game:GetService("Workspace")
    
    -- Load saved settings
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farming = setdata.farming or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
    
    local farming = false
    
    -- Function to pick up brainrot
    local function pickupBrainrot()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Find ItemSpawners.Divine
        local itemSpawners = Workspace:FindFirstChild("ItemSpawners")
        if itemSpawners then
            local divine = itemSpawners:FindFirstChild("Divine")
            if divine then
                -- Look for brainrot with RootPart and ProximityPrompt
                for _, child in pairs(divine:GetChildren()) do
                    local rootPart = child:FindFirstChild("RootPart")
                    if rootPart then
                        local prompt = rootPart:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt then
                            -- TP to brainrot
                            hrp.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
                            task.wait(3)
                            
                            -- Pick up (simulate hold E)
                            prompt:InputHoldBegin()
                            task.wait(3)
                            prompt:InputHoldEnd()
                            
                            print("✅ Picked up: " .. child.Name)
                            return true
                        end
                    end
                end
            end
        end
        return false
    end
    
    -- Function to teleport back to base (Plots)
    local function tpToBase()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Try to find base/plot location
        local baseFound = false
        
        -- Look for Plot_voltneoxe21
        local plot = Workspace:FindFirstChild("Plot_voltneoxe21")
        if plot then
            hrp.CFrame = plot:GetPivot() + Vector3.new(0, 5, 0)
            baseFound = true
            print("✅ Teleported to Plot_voltneoxe21")
        -- Look for any Plot
        elseif Workspace:FindFirstChild("Plots") then
            local plots = Workspace:FindFirstChild("Plots")
            for _, child in pairs(plots:GetChildren()) do
                if child:IsA("BasePart") then
                    hrp.CFrame = child.CFrame + Vector3.new(0, 3, 0)
                    baseFound = true
                    print("✅ Teleported to: " .. child.Name)
                    break
                end
            end
        -- Look for any Spawn location
        elseif Workspace:FindFirstChild("SpawnLocation") then
            local spawn = Workspace:FindFirstChild("SpawnLocation")
            hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
            baseFound = true
            print("✅ Teleported to SpawnLocation")
        end
        
        if not baseFound then
            -- Default teleport to 0,0,0 if no base found
            hrp.CFrame = CFrame.new(0, 10, 0)
            print("⚠️ No base found, teleported to 0,0,0")
        end
        
        task.wait(0.5)
        return baseFound
    end
    
    -- Farm function
    local function farm()
        if not farming then return end
        
        print("━━━━━━━━━━━━━━━━━━━━")
        print("🔄 Farming cycle starting...")
        
        -- TP to Zones.Divine
        local zones = Workspace:FindFirstChild("Zones")
        if zones then
            local divineZone = zones:FindFirstChild("Divine")
            if divineZone then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = divineZone:GetPivot() + Vector3.new(0, 3, 0)
                    task.wait(3)
                    print("✅ Teleported to Zones.Divine")
                end
            end
        end
        
        -- Pick up brainrot
        pickupBrainrot()
        
        -- TP back to base
        tpToBase()
        
        print("✅ Cycle complete!")
        print("━━━━━━━━━━━━━━━━━━━━")
        
        -- Loop
        if farming then
            task.wait(3)
            farm()
        end
    end
    
    -- UI Elements
    elements:Label("━━━━━ Divine Farmer ━━━━━", section)
    
    elements:Toggle("Auto Farm Divine Brainrot", section, setdata.farming, function(v)
        setdata.farming = v
        farming = v
        setconfig("farming", v)
        
        if v then
            print("🟢 Auto farming started!")
            farm()
        else
            print("🔴 Auto farming stopped!")
        end
    end)
    
    elements:Button("Pick Up Brainrot Now", section, function()
        pickupBrainrot()
    end)
    
    elements:Button("TP to Base", section, function()
        tpToBase()
    end)
    
    elements:Label("━━━━━━━━━━━━━━━━━━━", section)
    elements:Label("1. TP to Zones.Divine", section)
    elements:Label("2. Find brainrot in ItemSpawners.Divine", section)
    elements:Label("3. Hold E for 3 seconds to pick up", section)
    elements:Label("4. TP back to base (Plot)", section)
    elements:Label("5. Repeat after 3 seconds", section)
    
    print("✅ Divine Brainrot Farmer loaded!")
end

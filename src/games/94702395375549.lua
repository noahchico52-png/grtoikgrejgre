-- Divine Brainrot Farmer for Brainrot Police

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
                            task.wait(0.3)
                            
                            -- Pick up
                            prompt:InputHoldBegin()
                            task.wait(0.1)
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
    
    -- Function to teleport back to base
    local function tpToBase()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local base = Workspace:FindFirstChild("Plot_voltneoxe21")
        if base then
            local floor1 = base:FindFirstChild("Floor1")
            if floor1 then
                local plotStand = floor1:FindFirstChild("PlotStand")
                if plotStand then
                    hrp.CFrame = plotStand:GetPivot() + Vector3.new(0, 3, 0)
                    print("✅ Teleported back to base!")
                    return true
                end
            end
        end
        return false
    end
    
    -- Farm function
    local function farm()
        if not farming then return end
        
        print("🔄 Farming brainrot...")
        
        -- TP to Zones.Divine
        local zones = Workspace:FindFirstChild("Zones")
        if zones then
            local divineZone = zones:FindFirstChild("Divine")
            if divineZone then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = divineZone:GetPivot() + Vector3.new(0, 3, 0)
                    task.wait(0.5)
                end
            end
        end
        
        -- Pick up brainrot
        pickupBrainrot()
        
        -- TP back to base
        tpToBase()
        
        -- Loop
        if farming then
            task.wait(2)
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
    elements:Label("Finds brainrot in ItemSpawners.Divine", section)
    elements:Label("Tps to Zones.Divine first", section)
    elements:Label("Then picks up and returns to base", section)
    
    print("✅ Divine Brainrot Farmer loaded!")
end

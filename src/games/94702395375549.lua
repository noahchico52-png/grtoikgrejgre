-- Divine Brainrot Farmer for Brainrot Police (Max 5 then TP to Base)

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
    local MAX_BRAINROTS = 5
    
    -- Function to check how many brainrots you have
    local function getBrainrotCount()
        local count = 0
        local char = LocalPlayer.Character
        if char then
            for _, child in pairs(char:GetChildren()) do
                if child:IsA("Tool") and (child.Name:find("Brainrot") or child.Name:find("brainrot")) then
                    count = count + 1
                end
            end
        end
        
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, child in pairs(backpack:GetChildren()) do
                if child:IsA("Tool") and (child.Name:find("Brainrot") or child.Name:find("brainrot")) then
                    count = count + 1
                end
            end
        end
        
        return count
    end
    
    -- Function to teleport to base
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
        
        -- Fallback
        hrp.CFrame = CFrame.new(0, 10, 0)
        print("⚠️ Teleported to 0,0,0")
        return false
    end
    
    -- Function to pick up brainrot
    local function pickupBrainrot()
        local char = LocalPlayer.Character
        if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        
        -- Find ItemSpawners.Divine
        local itemSpawners = Workspace:FindFirstChild("ItemSpawners")
        if itemSpawners then
            local divine = itemSpawners:FindFirstChild("Divine")
            if divine then
                for _, child in pairs(divine:GetChildren()) do
                    local rootPart = child:FindFirstChild("RootPart")
                    if rootPart then
                        local prompt = rootPart:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt then
                            hrp.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
                            task.wait(3)
                            
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
    
    -- Farm function
    local function farm()
        if not farming then return end
        
        -- Check if max reached
        local currentCount = getBrainrotCount()
        if currentCount >= MAX_BRAINROTS then
            print("━━━━━━━━━━━━━━━━━━━━")
            print("🎉 Max brainrots reached! (" .. currentCount .. "/" .. MAX_BRAINROTS .. ")")
            print("🔜 Teleporting back to base...")
            tpToBase()
            print("🔴 Auto farming stopped!")
            farming = false
            setdata.farming = false
            setconfig("farming", false)
            return
        end
        
        print("━━━━━━━━━━━━━━━━━━━━")
        print("🔄 Farming cycle... (Brainrots: " .. currentCount .. "/" .. MAX_BRAINROTS .. ")")
        
        -- TP to Zones.Divine
        local zones = Workspace:FindFirstChild("Zones")
        if zones then
            local divineZone = zones:FindFirstChild("Divine")
            if divineZone then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = divineZone:GetPivot() + Vector3.new(0, 3, 0)
                    task.wait(3)
                end
            end
        end
        
        -- Pick up brainrot
        pickupBrainrot()
        
        -- Check again after pickup
        local newCount = getBrainrotCount()
        if newCount >= MAX_BRAINROTS then
            print("🎉 Reached max brainrots! TP to base...")
            tpToBase()
            print("🔴 Auto farming stopped!")
            farming = false
            setdata.farming = false
            setconfig("farming", false)
            return
        end
        
        -- Loop
        if farming then
            task.wait(3)
            farm()
        end
    end
    
    -- UI Elements
    elements:Label("━━━━━ Divine Farmer ━━━━━", section)
    elements:Label("Max Carry: 5 Brainrots", section)
    
    elements:Toggle("Auto Farm Divine Brainrot", section, setdata.farming, function(v)
        setdata.farming = v
        farming = v
        setconfig("farming", v)
        
        if v then
            local currentCount = getBrainrotCount()
            if currentCount >= MAX_BRAINROTS then
                print("⚠️ You already have " .. currentCount .. " brainrots! TP to base...")
                tpToBase()
                setdata.farming = false
                farming = false
                setconfig("farming", false)
                return
            end
            print("🟢 Auto farming started! (Max: " .. MAX_BRAINROTS .. ")")
            farm()
        else
            print("🔴 Auto farming stopped!")
        end
    end)
    
    elements:Button("Check Brainrot Count", section, function()
        local count = getBrainrotCount()
        print("📦 You have " .. count .. "/" .. MAX_BRAINROTS .. " brainrots")
        warn("Brainrots: " .. count .. "/" .. MAX_BRAINROTS)
    end)
    
    elements:Button("TP to Base Now", section, function()
        tpToBase()
    end)
    
    elements:Label("━━━━━━━━━━━━━━━━━━━", section)
    elements:Label("Auto stops and TPs to base at 5 brainrots!", section)
    
    print("✅ Divine Brainrot Farmer loaded! (Max 5, then TP to base)")
end

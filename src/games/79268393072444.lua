-- Tycoon Auto Buyer for BrainrotPolice (Combined Loop)

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    
    -- Load saved data
    getgenv().AutoBuyTycoon = false
    
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.autobuystycoon = setdata.autobuystycoon or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local workspace = game.Workspace
    local myName = LocalPlayer.Name-- Tycoon Auto Buyer for BrainrotPolice (Fast Loop 0.01s)

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    
    -- Load saved data
    getgenv().AutoBuyTycoon = false
    
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.autobuystycoon = setdata.autobuystycoon or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local workspace = game.Workspace
    local myName = LocalPlayer.Name
    
    -- Find your tycoon
    local function findMyTycoon()
        for _, t in pairs(workspace:GetChildren()) do
            if t.Name and t.Name:match("Tycoon") and t:FindFirstChild("Owner") then
                local ownerValue = tostring(t.Owner.Value)
                if ownerValue == myName then
                    return t
                end
            end
        end
        return nil
    end
    
    -- Find Decor folder
    local function findDecor(tycoon)
        local purchases = tycoon:FindFirstChild("Purchases")
        if purchases then
            local lemonDash = purchases:FindFirstChild("LemonDash")
            if lemonDash then
                local buttons = lemonDash:FindFirstChild("Buttons")
                if buttons then
                    local decor = buttons:FindFirstChild("Decor")
                    if decor then return decor end
                end
                local decor = lemonDash:FindFirstChild("Decor")
                if decor then return decor end
            end
        end
        return nil
    end
    
    -- Find Upgrade path (LemonDash chain)
    local function findUpgrade(tycoon)
        local purchases = tycoon:FindFirstChild("Purchases")
        if purchases then
            local lemonDash = purchases:FindFirstChild("LemonDash")
            if lemonDash then
                local upgrade = lemonDash:FindFirstChild("LemonDash")
                if upgrade then
                    upgrade = upgrade:FindFirstChild("LemonDash")
                    if upgrade then
                        upgrade = upgrade:FindFirstChild("Upgrade")
                        if upgrade then return upgrade end
                    end
                end
            end
        end
        return nil
    end
    
    -- Find Lemon Stand Upgrade
    local function findLemonStandUpgrade(tycoon)
        local purchases = tycoon:FindFirstChild("Purchases")
        if purchases then
            local lemonStand = purchases:FindFirstChild("Lemon Stand")
            if lemonStand then
                local upgrade = lemonStand:FindFirstChild("Lemon Stand")
                if upgrade then
                    upgrade = upgrade:FindFirstChild("Lemon Stand")
                    if upgrade then
                        upgrade = upgrade:FindFirstChild("Upgrade")
                        if upgrade then return upgrade end
                    end
                end
            end
        end
        return nil
    end
    
    -- Purchase Decor items
    local function purchaseItems()
        local myTycoon = findMyTycoon()
        if not myTycoon then return end
        
        local decor = findDecor(myTycoon)
        if decor then
            for _, item in pairs(decor:GetChildren()) do
                local enabled = item:GetAttribute("Enabled") == true
                local shown = item:GetAttribute("Shown") == true
                
                if enabled and shown then
                    local purchaseEvent = item:FindFirstChild("Purchase")
                    if purchaseEvent then
                        pcall(function()
                            purchaseEvent:InvokeServer(false)
                        end)
                    end
                end
                task.wait(0.01)
            end
        end
    end
    
    -- Do both upgrades
    local function doUpgrades()
        local myTycoon = findMyTycoon()
        if not myTycoon then return end
        
        -- Upgrade 1: LemonDash chain
        local upgradeEvent = findUpgrade(myTycoon)
        if upgradeEvent then
            pcall(function()
                upgradeEvent:InvokeServer(1)
            end)
        end
        
        task.wait(0.01)
        
        -- Upgrade 2: Lemon Stand chain
        local lemonStandUpgrade = findLemonStandUpgrade(myTycoon)
        if lemonStandUpgrade then
            pcall(function()
                lemonStandUpgrade:InvokeServer(1)
            end)
        end
    end
    
    -- Main loop (0.01 seconds)
    local function startAutoBuy()
        getgenv().AutoBuyTycoon = true
        print("[AutoBuy] Started - Loop speed: 0.01s")
        
        while getgenv().AutoBuyTycoon do
            purchaseItems()
            task.wait(0.01)
            doUpgrades()
            task.wait(0.01)
        end
    end
    
    local function stopAutoBuy()
        getgenv().AutoBuyTycoon = false
        print("[AutoBuy] Stopped")
    end
    
    -- UI Element
    elements:Toggle("Auto Buy & Upgrade (Fast)", section, setdata.autobuystycoon, function(v)
        getgenv().setconfig("autobuystycoon", v)
        if v then
            startAutoBuy()
        else
            stopAutoBuy()
        end
    end)
end
    
    -- Find your tycoon
    local function findMyTycoon()
        for _, t in pairs(workspace:GetChildren()) do
            if t.Name and t.Name:match("Tycoon") and t:FindFirstChild("Owner") then
                local ownerValue = tostring(t.Owner.Value)
                if ownerValue == myName then
                    return t
                end
            end
        end
        return nil
    end
    
    -- Find Decor folder
    local function findDecor(tycoon)
        local purchases = tycoon:FindFirstChild("Purchases")
        if purchases then
            local lemonDash = purchases:FindFirstChild("LemonDash")
            if lemonDash then
                local buttons = lemonDash:FindFirstChild("Buttons")
                if buttons then
                    local decor = buttons:FindFirstChild("Decor")
                    if decor then return decor end
                end
                local decor = lemonDash:FindFirstChild("Decor")
                if decor then return decor end
            end
        end
        return nil
    end
    
    -- Find Upgrade path (LemonDash chain)
    local function findUpgrade(tycoon)
        local purchases = tycoon:FindFirstChild("Purchases")
        if purchases then
            local lemonDash = purchases:FindFirstChild("LemonDash")
            if lemonDash then
                -- Path: LemonDash.LemonDash.LemonDash.Upgrade
                local upgrade = lemonDash:FindFirstChild("LemonDash")
                if upgrade then
                    upgrade = upgrade:FindFirstChild("LemonDash")
                    if upgrade then
                        upgrade = upgrade:FindFirstChild("Upgrade")
                        if upgrade then return upgrade end
                    end
                end
            end
        end
        return nil
    end
    
    -- Find Lemon Stand Upgrade
    local function findLemonStandUpgrade(tycoon)
        local purchases = tycoon:FindFirstChild("Purchases")
        if purchases then
            local lemonStand = purchases:FindFirstChild("Lemon Stand")
            if lemonStand then
                -- Path: "Lemon Stand"."Lemon Stand"."Lemon Stand".Upgrade
                local upgrade = lemonStand:FindFirstChild("Lemon Stand")
                if upgrade then
                    upgrade = upgrade:FindFirstChild("Lemon Stand")
                    if upgrade then
                        upgrade = upgrade:FindFirstChild("Upgrade")
                        if upgrade then return upgrade end
                    end
                end
            end
        end
        return nil
    end
    
    -- Purchase Decor items
    local function purchaseItems()
        local myTycoon = findMyTycoon()
        if not myTycoon then
            print("[AutoBuy] ❌ No tycoon found for: " .. myName)
            return
        end
        
        local decor = findDecor(myTycoon)
        if decor then
            for _, item in pairs(decor:GetChildren()) do
                if not getgenv().AutoBuyTycoon then break end
                
                local enabled = item:GetAttribute("Enabled") == true
                local shown = item:GetAttribute("Shown") == true
                
                if enabled and shown then
                    local purchaseEvent = item:FindFirstChild("Purchase")
                    if purchaseEvent then
                        local success = pcall(function()
                            purchaseEvent:InvokeServer(false)
                        end)
                        
                        if success then
                            print("[AutoBuy] ✅ Purchased: " .. item.Name)
                        else
                            print("[AutoBuy] ❌ Cannot afford: " .. item.Name)
                        end
                        task.wait(0.3)
                    end
                end
            end
        end
    end
    
    -- Do both upgrades
    local function doUpgrades()
        local myTycoon = findMyTycoon()
        if not myTycoon then
            print("[AutoUpgrade] ❌ No tycoon found")
            return
        end
        
        -- Upgrade 1: LemonDash chain
        local upgradeEvent = findUpgrade(myTycoon)
        if upgradeEvent then
            local success = pcall(function()
                upgradeEvent:InvokeServer(1)
            end)
            
            if success then
                print("[AutoUpgrade] ✅ LemonDash Upgrade successful!")
            else
                print("[AutoUpgrade] ❌ Cannot afford LemonDash upgrade")
            end
        else
            print("[AutoUpgrade] ❌ LemonDash Upgrade event not found")
        end
        
        task.wait(0.5)
        
        -- Upgrade 2: Lemon Stand chain
        local lemonStandUpgrade = findLemonStandUpgrade(myTycoon)
        if lemonStandUpgrade then
            local success = pcall(function()
                lemonStandUpgrade:InvokeServer(1)
            end)
            
            if success then
                print("[AutoUpgrade] ✅ Lemon Stand Upgrade successful!")
            else
                print("[AutoUpgrade] ❌ Cannot afford Lemon Stand upgrade")
            end
        else
            print("[AutoUpgrade] ❌ Lemon Stand Upgrade event not found")
        end
    end
    
    -- Main loop (combines everything)
    local function startAutoBuy()
        getgenv().AutoBuyTycoon = true
        print("[AutoBuy] Started - Buying items and upgrading...")
        
        while getgenv().AutoBuyTycoon do
            -- Buy decor items
            purchaseItems()
            
            task.wait(1)
            
            -- Do both upgrades
            doUpgrades()
            
            -- Wait before next cycle
            task.wait(5)
        end
    end
    
    local function stopAutoBuy()
        getgenv().AutoBuyTycoon = false
        print("[AutoBuy] Stopped")
    end
    
    -- UI Element
    elements:Toggle("Auto Buy & Upgrade", section, setdata.autobuystycoon, function(v)
        getgenv().setconfig("autobuystycoon", v)
        if v then
            startAutoBuy()
        else
            stopAutoBuy()
        end
    end)
end

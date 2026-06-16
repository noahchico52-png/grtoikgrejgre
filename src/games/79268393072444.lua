-- Tycoon Auto Buyer (Multiple Upgrade paths + Lemon Depot)

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    
    -- Load saved data
    getgenv().AutoBuyTycoon = false
    getgenv().AutoUpgrade = false
    getgenv().AutoLemonStandUpgrade = false
    getgenv().AutoLemonDepotUpgrade = false
    
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.autobuystycoon = setdata.autobuystycoon or false
    setdata.autoupgrade = setdata.autoupgrade or false
    setdata.autolemonstandupgrade = setdata.autolemonstandupgrade or false
    setdata.autolemondepotupgrade = setdata.autolemondepotupgrade or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local workspace = game.Workspace
    local myName = LocalPlayer.Name
    
    -- Find your tycoon number
    local function getMyTycoonNumber()
        for _, t in pairs(workspace:GetChildren()) do
            if t.Name and t.Name:match("Tycoon") and t:FindFirstChild("Owner") then
                if tostring(t.Owner.Value) == myName then
                    return t.Name:match("(%d+)")
                end
            end
        end
        return nil
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
                local upgrade = lemonDash:FindFirstChild("LemonDash")
                if upgrade then
                    upgrade = upgrade:FindFirstChild("LemonDash")
                    if upgrade then
                        upgrade = upgrade:FindFirstChild("Upgrade")
                        if upgrade then return upgrade end
                    end
                end
                local upgrade = lemonDash:FindFirstChild("Upgrade")
                if upgrade then return upgrade end
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
                local upgrade = lemonStand:FindFirstChild("Upgrade")
                if upgrade then return upgrade end
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
    
    -- Auto Upgrade (LemonDash)
    local function doUpgrade()
        local myTycoon = findMyTycoon()
        if not myTycoon then
            print("[AutoUpgrade] ❌ No tycoon found")
            return
        end
        
        local upgradeEvent = findUpgrade(myTycoon)
        if upgradeEvent then
            local success = pcall(function()
                upgradeEvent:InvokeServer(1)
            end)
            
            if success then
                print("[AutoUpgrade] ✅ Upgrade successful!")
            else
                print("[AutoUpgrade] ❌ Cannot afford upgrade")
            end
        else
            print("[AutoUpgrade] ❌ Upgrade event not found")
        end
    end
    
    -- Auto Lemon Stand Upgrade
    local function doLemonStandUpgrade()
        local myTycoon = findMyTycoon()
        if not myTycoon then
            print("[AutoLemonStand] ❌ No tycoon found")
            return
        end
        
        local upgradeEvent = findLemonStandUpgrade(myTycoon)
        if upgradeEvent then
            local success = pcall(function()
                upgradeEvent:InvokeServer(1)
            end)
            
            if success then
                print("[AutoLemonStand] ✅ Lemon Stand Upgrade successful!")
            else
                print("[AutoLemonStand] ❌ Cannot afford upgrade")
            end
        else
            print("[AutoLemonStand] ❌ Lemon Stand Upgrade event not found")
        end
    end
    
    -- Auto Lemon Depot Upgrade
    local function doLemonDepotUpgrade()
        local tycoonNum = getMyTycoonNumber()
        if not tycoonNum then
            print("[AutoLemonDepot] ❌ No tycoon found")
            return
        end
        
        local success = pcall(function()
            workspace["Tycoon" .. tycoonNum].Purchases["Lemon Depot"]["Lemon Depot"]["Lemon Depot"].Upgrade:InvokeServer(1)
        end)
        
        if success then
            print("[AutoLemonDepot] ✅ Lemon Depot Upgrade successful!")
        else
            print("[AutoLemonDepot] ❌ Cannot afford upgrade")
        end
    end
    
    -- Main loops
    local function startAutoBuy()
        getgenv().AutoBuyTycoon = true
        print("[AutoBuy] Started auto-buying")
        
        while getgenv().AutoBuyTycoon do
            purchaseItems()
            task.wait(0.1)
        end
    end
    
    local function stopAutoBuy()
        getgenv().AutoBuyTycoon = false
        print("[AutoBuy] Stopped auto-buying")
    end
    
    local function startAutoUpgrade()
        getgenv().AutoUpgrade = true
        print("[AutoUpgrade] Started auto-upgrading")
        
        while getgenv().AutoUpgrade do
            doUpgrade()
            task.wait(0.1)
        end
    end
    
    local function stopAutoUpgrade()
        getgenv().AutoUpgrade = false
        print("[AutoUpgrade] Stopped auto-upgrading")
    end
    
    local function startAutoLemonStandUpgrade()
        getgenv().AutoLemonStandUpgrade = true
        print("[AutoLemonStand] Started auto-upgrading Lemon Stand")
        
        while getgenv().AutoLemonStandUpgrade do
            doLemonStandUpgrade()
            task.wait(0.1)
        end
    end
    
    local function stopAutoLemonStandUpgrade()
        getgenv().AutoLemonStandUpgrade = false
        print("[AutoLemonStand] Stopped auto-upgrading Lemon Stand")
    end
    
    local function startAutoLemonDepotUpgrade()
        getgenv().AutoLemonDepotUpgrade = true
        print("[AutoLemonDepot] Started auto-upgrading Lemon Depot")
        
        while getgenv().AutoLemonDepotUpgrade do
            doLemonDepotUpgrade()
            task.wait(0.1)
        end
    end
    
    local function stopAutoLemonDepotUpgrade()
        getgenv().AutoLemonDepotUpgrade = false
        print("[AutoLemonDepot] Stopped auto-upgrading Lemon Depot")
    end
    
    -- UI Elements
    elements:Toggle("Auto Buy Decor Items", section, setdata.autobuystycoon, function(v)
        getgenv().setconfig("autobuystycoon", v)
        if v then
            startAutoBuy()
        else
            stopAutoBuy()
        end
    end)
    
    elements:Toggle("Auto Upgrade (LemonDash)", section, setdata.autoupgrade, function(v)
        getgenv().setconfig("autoupgrade", v)
        if v then
            startAutoUpgrade()
        else
            stopAutoUpgrade()
        end
    end)
    
    elements:Toggle("Auto Upgrade (Lemon Stand)", section, setdata.autolemonstandupgrade, function(v)
        getgenv().setconfig("autolemonstandupgrade", v)
        if v then
            startAutoLemonStandUpgrade()
        else
            stopAutoLemonStandUpgrade()
        end
    end)
    
    elements:Toggle("Auto Upgrade (Lemon Depot)", section, setdata.autolemondepotupgrade, function(v)
        getgenv().setconfig("autolemondepotupgrade", v)
        if v then
            startAutoLemonDepotUpgrade()
        else
            stopAutoLemonDepotUpgrade()
        end
    end)
end

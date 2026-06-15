-- tycoon_autobuy.lua
return function(section, elements)
    getgenv().AutoBuyTycoon = false
    getgenv().AutoUpgrade = false
    getgenv().AutoLemonStandUpgrade = false
    
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.autobuystycoon = setdata.autobuystycoon or false
    setdata.autoupgrade = setdata.autoupgrade or false
    setdata.autolemonstandupgrade = setdata.autolemonstandupgrade or false
   
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
        if not myTycoon then return end
        
        local decor = findDecor(myTycoon)
        if decor then
            for _, item in pairs(decor:GetChildren()) do
                if not getgenv().AutoBuyTycoon then break end
                
                local enabled = item:GetAttribute("Enabled") == true
                local shown = item:GetAttribute("Shown") == true
                
                if enabled and shown then
                    local purchaseEvent = item:FindFirstChild("Purchase")
                    if purchaseEvent then
                        pcall(function() purchaseEvent:InvokeServer(false) end)
                        task.wait(0.3)
                    end
                end
            end
        end
    end
    
    -- Auto Upgrade (LemonDash)
    local function doUpgrade()
        local myTycoon = findMyTycoon()
        if not myTycoon then return end
        
        local upgradeEvent = findUpgrade(myTycoon)
        if upgradeEvent then
            pcall(function() upgradeEvent:InvokeServer(1) end)
        end
    end
    
    -- Auto Lemon Stand Upgrade
    local function doLemonStandUpgrade()
        local myTycoon = findMyTycoon()
        if not myTycoon then return end
        
        local upgradeEvent = findLemonStandUpgrade(myTycoon)
        if upgradeEvent then
            pcall(function() upgradeEvent:InvokeServer(1) end)
        end
    end
    
    -- Main loops
    local function startAutoBuy()
        getgenv().AutoBuyTycoon = true
        task.spawn(function()
            while getgenv().AutoBuyTycoon do
                purchaseItems()
                task.wait(0.1)
            end
        end)
    end
    
    local function stopAutoBuy()
        getgenv().AutoBuyTycoon = false
    end
    
    local function startAutoUpgrade()
        getgenv().AutoUpgrade = true
        task.spawn(function()
            while getgenv().AutoUpgrade do
                doUpgrade()
                task.wait(0.1)
            end
        end)
    end
    
    local function stopAutoUpgrade()
        getgenv().AutoUpgrade = false
    end
    
    local function startAutoLemonStandUpgrade()
        getgenv().AutoLemonStandUpgrade = true
        task.spawn(function()
            while getgenv().AutoLemonStandUpgrade do
                doLemonStandUpgrade()
                task.wait(0.1)
            end
        end)
    end
    
    local function stopAutoLemonStandUpgrade()
        getgenv().AutoLemonStandUpgrade = false
    end
    
    -- UI Elements
    elements:Toggle("Auto Buy Decor Items", section, setdata.autobuystycoon, function(v)
        if v then
            startAutoBuy()
        else
            stopAutoBuy()
        end
    end)
    
    elements:Toggle("Auto Upgrade (LemonDash)", section, setdata.autoupgrade, function(v)
        if v then
            startAutoUpgrade()
        else
            stopAutoUpgrade()
        end
    end)
    
    elements:Toggle("Auto Upgrade (Lemon Stand)", section, setdata.autolemonstandupgrade, function(v)
        if v then
            startAutoLemonStandUpgrade()
        else
            stopAutoLemonStandUpgrade()
        end
    end)
end

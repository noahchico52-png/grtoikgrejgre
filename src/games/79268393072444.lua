-- Tycoon Auto Buyer for BrainrotPolice

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    
    -- Load saved data
    getgenv().AutoBuyTycoon = false
    getgenv().BuyDelay = 0.3
    
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.autobuystycoon = setdata.autobuystycoon or false
    setdata.buydelay = setdata.buydelay or "0.3"
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
    
    -- Purchase items
    local function purchaseItems()
        local myTycoon = findMyTycoon()
        if not myTycoon then
            print("[AutoBuy] ❌ No tycoon found for: " .. myName)
            return
        end
        
        local decor = findDecor(myTycoon)
        if not decor then
            print("[AutoBuy] ❌ Decor folder not found")
            return
        end
        
        print("[AutoBuy] 🔍 Checking items in " .. myTycoon.Name)
        
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
                    task.wait(getgenv().BuyDelay)
                end
            end
        end
    end
    
    -- Auto buy loop
    local function startAutoBuy()
        getgenv().AutoBuyTycoon = true
        print("[AutoBuy] Started auto-buying")
        
        while getgenv().AutoBuyTycoon do
            purchaseItems()
            task.wait(5) -- Wait 5 seconds before checking again
        end
    end
    
    local function stopAutoBuy()
        getgenv().AutoBuyTycoon = false
        print("[AutoBuy] Stopped auto-buying")
    end
    
    -- UI Elements
    elements:Toggle("Auto Buy Tycoon Items", section, setdata.autobuystycoon, function(v)
        getgenv().setconfig("autobuystycoon", v)
        if v then
            startAutoBuy()
        else
            stopAutoBuy()
        end
    end)
    
    elements:Textbox("Buy Delay (seconds)", section, setdata.buydelay, function(v)
        getgenv().setconfig("buydelay", v)
        getgenv().BuyDelay = tonumber(v) or 0.3
    end)
    
    elements:Button("Buy Now (One Time)", section, function()
        purchaseItems()
    end)
    
    elements:Button("Find My Tycoon", section, function()
        local tycoon = findMyTycoon()
        if tycoon then
            print("[AutoBuy] ✅ You own: " .. tycoon.Name)
            local decor = findDecor(tycoon)
            if decor then
                print("[AutoBuy] 📁 Decor found with " .. #decor:GetChildren() .. " items")
            end
        else
            print("[AutoBuy] ❌ No tycoon found for: " .. myName)
        end
    end)
end

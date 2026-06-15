-- Tycoon Auto Buyer for BrainrotPolice (UI Always Shows)

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
    
    -- Find your tycoon number
    local function findMyTycoonNumber()
        for _, t in pairs(workspace:GetChildren()) do
            if t.Name and t.Name:match("Tycoon") and t:FindFirstChild("Owner") then
                local ownerValue = tostring(t.Owner.Value)
                if ownerValue == myName then
                    local num = t.Name:match("(%d+)")
                    return num
                end
            end
        end
        return nil
    end
    
    -- Get tycoon number (will be nil if not found)
    local tycoonNum = findMyTycoonNumber()
    
    -- Auto Buy Decor Items
    local function startAutoBuyDecor()
        while getgenv().AutoBuyTycoon and wait(0.01) do
            if tycoonNum then
                pcall(function()
                    local decor = workspace:WaitForChild("Tycoon" .. tycoonNum):WaitForChild("Purchases"):WaitForChild("LemonDash"):WaitForChild("Buttons"):WaitForChild("Decor")
                    for _, item in pairs(decor:GetChildren()) do
                        local enabled = item:GetAttribute("Enabled") == true
                        local shown = item:GetAttribute("Shown") == true
                        if enabled and shown then
                            local purchase = item:FindFirstChild("Purchase")
                            if purchase then
                                purchase:InvokeServer(false)
                            end
                        end
                        wait(0.01)
                    end
                end)
            end
        end
    end
    
    -- Auto Upgrade LemonDash
    local function startAutoUpgradeLemonDash()
        while getgenv().AutoBuyTycoon and wait(0.01) do
            if tycoonNum then
                pcall(function()
                    workspace:WaitForChild("Tycoon" .. tycoonNum):WaitForChild("Purchases"):WaitForChild("LemonDash"):WaitForChild("LemonDash"):WaitForChild("LemonDash"):WaitForChild("Upgrade"):InvokeServer(1)
                end)
            end
        end
    end
    
    -- Auto Upgrade Lemon Stand
    local function startAutoUpgradeLemonStand()
        while getgenv().AutoBuyTycoon and wait(0.01) do
            if tycoonNum then
                pcall(function()
                    workspace:WaitForChild("Tycoon" .. tycoonNum):WaitForChild("Purchases"):WaitForChild("Lemon Stand"):WaitForChild("Lemon Stand"):WaitForChild("Lemon Stand"):WaitForChild("Upgrade"):InvokeServer(1)
                end)
            end
        end
    end
    
    -- Start all loops
    local function startAutoBuy()
        if not tycoonNum then
            print("[AutoBuy] ❌ No tycoon found for: " .. myName)
            return
        end
        getgenv().AutoBuyTycoon = true
        print("[AutoBuy] Started all loops for Tycoon" .. tycoonNum)
        spawn(startAutoBuyDecor)
        spawn(startAutoUpgradeLemonDash)
        spawn(startAutoUpgradeLemonStand)
    end
    
    local function stopAutoBuy()
        getgenv().AutoBuyTycoon = false
        print("[AutoBuy] Stopped all loops")
    end
    
    -- Create status text
    local statusText = ""
    if tycoonNum then
        statusText = "✅ Tycoon" .. tycoonNum .. " found!"
    else
        statusText = "❌ No tycoon found for: " .. myName
    end
    
    local statusLabel = elements:Label(statusText, section)
    
    -- UI Element
    elements:Toggle("Auto Buy & Upgrade (0.01s)", section, setdata.autobuystycoon, function(v)
        getgenv().setconfig("autobuystycoon", v)
        if v then
            if tycoonNum then
                startAutoBuy()
            else
                print("[AutoBuy] ❌ Cannot start - No tycoon found")
                -- Refresh tycoon number
                tycoonNum = findMyTycoonNumber()
                if tycoonNum then
                    statusLabel:SetText("✅ Tycoon" .. tycoonNum .. " found!")
                    startAutoBuy()
                else
                    statusLabel:SetText("❌ Still no tycoon found!")
                end
            end
        else
            stopAutoBuy()
        end
    end)
    
    -- Button to manually refresh tycoon
    elements:Button("Refresh Tycoon", section, function()
        tycoonNum = findMyTycoonNumber()
        if tycoonNum then
            statusLabel:SetText("✅ Tycoon" .. tycoonNum .. " found!")
            print("[AutoBuy] ✅ Found Tycoon" .. tycoonNum)
        else
            statusLabel:SetText("❌ No tycoon found for: " .. myName)
            print("[AutoBuy] ❌ No tycoon found")
        end
    end)
end

-- Tycoon Auto Buyer for BrainrotPolice (Original)

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
    
    local tycoonNum = findMyTycoonNumber()
    
    -- Auto Buy Decor Items
    local function startAutoBuyDecor()
        while getgenv().AutoBuyTycoon and wait(0.01) do
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
    
    -- Auto Upgrade LemonDash
    local function startAutoUpgradeLemonDash()
        while getgenv().AutoBuyTycoon and wait(0.01) do
            pcall(function()
                workspace:WaitForChild("Tycoon" .. tycoonNum):WaitForChild("Purchases"):WaitForChild("LemonDash"):WaitForChild("LemonDash"):WaitForChild("LemonDash"):WaitForChild("Upgrade"):InvokeServer(1)
            end)
        end
    end
    
    -- Auto Upgrade Lemon Stand
    local function startAutoUpgradeLemonStand()
        while getgenv().AutoBuyTycoon and wait(0.01) do
            pcall(function()
                workspace:WaitForChild("Tycoon" .. tycoonNum):WaitForChild("Purchases"):WaitForChild("Lemon Stand"):WaitForChild("Lemon Stand"):WaitForChild("Lemon Stand"):WaitForChild("Upgrade"):InvokeServer(1)
            end)
        end
    end
    
    -- Start all loops
    local function startAutoBuy()
        getgenv().AutoBuyTycoon = true
        print("[AutoBuy] Started all loops (0.01s delay)")
        spawn(startAutoBuyDecor)
        spawn(startAutoUpgradeLemonDash)
        spawn(startAutoUpgradeLemonStand)
    end
    
    local function stopAutoBuy()
        getgenv().AutoBuyTycoon = false
        print("[AutoBuy] Stopped all loops")
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

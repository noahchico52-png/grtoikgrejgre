-- Tycoon Auto Buyer - Just Toggle

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    
    getgenv().AutoBuyTycoon = false
    
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.autobuystycoon = setdata.autobuystycoon or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local workspace = game.Workspace
    local myName = LocalPlayer.Name
    
    local function findMyTycoonNumber()
        for _, t in pairs(workspace:GetChildren()) do
            if t.Name and t.Name:match("Tycoon") and t:FindFirstChild("Owner") then
                if tostring(t.Owner.Value) == myName then
                    return t.Name:match("(%d+)")
                end
            end
        end
        return nil
    end
    
    local tycoonNum = findMyTycoonNumber()
    
    local function startAutoBuyDecor()
        while getgenv().AutoBuyTycoon and wait(0.01) do
            pcall(function()
                local decor = workspace:WaitForChild("Tycoon" .. tycoonNum):WaitForChild("Purchases"):WaitForChild("LemonDash"):WaitForChild("Buttons"):WaitForChild("Decor")
                for _, item in pairs(decor:GetChildren()) do
                    if item:GetAttribute("Enabled") == true and item:GetAttribute("Shown") == true then
                        local purchase = item:FindFirstChild("Purchase")
                        if purchase then purchase:InvokeServer(false) end
                    end
                    wait(0.01)
                end
            end)
        end
    end
    
    local function startAutoUpgradeLemonDash()
        while getgenv().AutoBuyTycoon and wait(0.01) do
            pcall(function()
                workspace:WaitForChild("Tycoon" .. tycoonNum):WaitForChild("Purchases"):WaitForChild("LemonDash"):WaitForChild("LemonDash"):WaitForChild("LemonDash"):WaitForChild("Upgrade"):InvokeServer(1)
            end)
        end
    end
    
    local function startAutoUpgradeLemonStand()
        while getgenv().AutoBuyTycoon and wait(0.01) do
            pcall(function()
                workspace:WaitForChild("Tycoon" .. tycoonNum):WaitForChild("Purchases"):WaitForChild("Lemon Stand"):WaitForChild("Lemon Stand"):WaitForChild("Lemon Stand"):WaitForChild("Upgrade"):InvokeServer(1)
            end)
        end
    end
    
    local function startAutoBuy()
        getgenv().AutoBuyTycoon = true
        spawn(startAutoBuyDecor)
        spawn(startAutoUpgradeLemonDash)
        spawn(startAutoUpgradeLemonStand)
    end
    
    local function stopAutoBuy()
        getgenv().AutoBuyTycoon = false
    end
    
    elements:Toggle("Auto Buy & Upgrade", section, setdata.autobuystycoon, function(v)
        getgenv().setconfig("autobuystycoon", v)
        if v then startAutoBuy() else stopAutoBuy() end
    end)
end

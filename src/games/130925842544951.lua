-- Murder Mystery 2 - MM2 Scam Police

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local VirtualInput = game:GetService("VirtualInputManager")
    
    -- Load saved settings
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.espEnabled = setdata.espEnabled or false
    setdata.showBoxes = setdata.showBoxes or false
    setdata.aimbotEnabled = setdata.aimbotEnabled or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
    
    -- ESP Variables
    local PINK = Color3.new(1, 0.41, 0.71)
    local CYAN = Color3.new(0, 1, 1)
    local espEnabled = setdata.espEnabled
    local showBoxes = setdata.showBoxes
    
    -- Grab Gun Variables
    local currentGrabGun = nil
    local lastPosition = nil
    local teleportCooldown = false
    
    -- ============ ESP LOOP ============
    task.spawn(function()
        while true do
            if espEnabled and showBoxes then
                for _, v in pairs(Players:GetPlayers()) do
                    if v == LocalPlayer then continue end
                    
                    local char = v.Character
                    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                        
                        local hasKnife = false
                        local hasGun = false
                        
                        for _, child in ipairs(char:GetChildren()) do
                            if child:IsA("Tool") then
                                if child.Name == "Knife" then hasKnife = true end
                                if child.Name == "Gun" then hasGun = true end
                            end
                        end
                        
                        local bp = v:FindFirstChild("Backpack")
                        if bp then
                            for _, child in ipairs(bp:GetChildren()) do
                                if child:IsA("Tool") then
                                    if child.Name == "Knife" then hasKnife = true end
                                    if child.Name == "Gun" then hasGun = true end
                                end
                            end
                        end
                        
                        if hasKnife or hasGun then
                            local hl = char:FindFirstChild("Highlight")
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "Highlight"
                                hl.Parent = char
                                hl.Adornee = char
                                hl.OutlineColor = Color3.new(1, 1, 1)
                                hl.FillTransparency = 0.5
                                hl.OutlineTransparency = 0
                            end
                            hl.Enabled = true
                            if hasGun then 
                                hl.FillColor = CYAN
                            elseif hasKnife then 
                                hl.FillColor = PINK
                            end
                        else
                            local hl = char:FindFirstChild("Highlight")
                            if hl then hl:Destroy() end
                        end
                    end
                end
            else
                -- Remove all highlights when ESP is off
                for _, v in pairs(Players:GetPlayers()) do
                    if v.Character then
                        local hl = v.Character:FindFirstChild("Highlight")
                        if hl then hl:Destroy() end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
    
    -- ============ AIMBOT (Q key to snap and shoot) ============
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not setdata.aimbotEnabled then return end
        if input.KeyCode == Enum.KeyCode.Q then
            
            local murderer = nil
            for _, p in pairs(Players:GetPlayers()) do
                if p == LocalPlayer then continue end
                local char = p.Character
                if char then
                    for _, c in ipairs(char:GetChildren()) do
                        if c:IsA("Tool") and c.Name == "Knife" then murderer = p break end
                    end
                end
                if not murderer then
                    local bp = p:FindFirstChild("Backpack")
                    if bp then
                        for _, c in ipairs(bp:GetChildren()) do
                            if c:IsA("Tool") and c.Name == "Knife" then murderer = p break end
                        end
                    end
                end
                if murderer then break end
            end
            if not murderer then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local gun = nil
            for _, c in ipairs(char:GetChildren()) do
                if c:IsA("Tool") and c.Name == "Gun" then gun = c break end
            end
            if not gun then
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    for _, c in ipairs(bp:GetChildren()) do
                        if c:IsA("Tool") and c.Name == "Gun" then gun = c break end
                    end
                end
            end
            if not gun then return end
            
            local shootRemote = gun:FindFirstChild("Shoot")
            if not shootRemote then return end
            
            local targetHRP = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
            local rightHand = char:FindFirstChild("RightHand")
            if not targetHRP or not rightHand then return end
            
            -- Press 1 to equip gun
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            task.wait(0.05)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.One, false, game)
            task.wait(0.05)
            
            -- Shoot
            shootRemote:FireServer(CFrame.new(rightHand.Position), CFrame.new(targetHRP.Position))
        end
    end)
    
    -- ============ GRAB GUN FINDER FUNCTIONS ============
    local function findGrabGun()
        local grabs = {}
        local function search(parent)
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("BasePart") then
                    local name = child.Name:lower()
                    if name:find("gundrop") or name:find("gun") then
                        table.insert(grabs, child)
                    end
                end
                if #child:GetChildren() > 0 then search(child) end
            end
        end
        search(Workspace)
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local pos = char.HumanoidRootPart.Position
        local nearest, nearestDist = nil, math.huge
        for _, grab in pairs(grabs) do
            local dist = (grab.Position - pos).Magnitude
            if dist < nearestDist then nearestDist = dist; nearest = grab end
        end
        return nearest, nearestDist
    end
    
    -- ============ UI BUTTONS ============
    elements:Label("━━━━━ ESP ━━━━━", section)
    
    elements:Toggle("Master ESP", section, setdata.espEnabled, function(v)
        setdata.espEnabled = v
        espEnabled = v
        setconfig("espEnabled", v)
    end)
    
    elements:Toggle("Show Boxes", section, setdata.showBoxes, function(v)
        setdata.showBoxes = v
        showBoxes = v
        setconfig("showBoxes", v)
    end)
    
    elements:Label("━━━━━ AIMBOT ━━━━━", section)
    
    elements:Toggle("Aimbot (Press Q)", section, setdata.aimbotEnabled, function(v)
        setdata.aimbotEnabled = v
        setconfig("aimbotEnabled", v)
        if v then
            warn("Aimbot enabled! Press Q to snap and shoot murderer")
        else
            warn("Aimbot disabled")
        end
    end)
    
    elements:Label("━━━━━ Grab Gun Finder ━━━━━", section)
    
    local statusLabel = elements:Label("Status: Ready", section)
    
    elements:Button("Find Grab Gun", section, function()
        local grab, dist = findGrabGun()
        if grab then
            if currentGrabGun and currentGrabGun:FindFirstChild("GrabGunHighlight") then
                currentGrabGun.GrabGunHighlight:Destroy()
            end
            currentGrabGun = grab
            local hl = Instance.new("Highlight")
            hl.Name = "GrabGunHighlight"
            hl.FillColor = Color3.fromRGB(255, 200, 0)
            hl.FillTransparency = 0.3
            hl.OutlineColor = Color3.fromRGB(255, 120, 0)
            hl.OutlineTransparency = 0.1
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = currentGrabGun
            statusLabel.Text = "Status: Found! (" .. math.floor(dist) .. " studs)"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            statusLabel.Text = "Status: No Grab Gun found"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    elements:Button("TP to Grab Gun", section, function()
        if not currentGrabGun or teleportCooldown then return end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            lastPosition = char.HumanoidRootPart.CFrame
            teleportCooldown = true
            char.HumanoidRootPart.CFrame = currentGrabGun.CFrame + Vector3.new(0, 3, 0)
            statusLabel.Text = "Status: Teleported!"
            task.delay(1.5, function() teleportCooldown = false end)
        end
    end)
    
    elements:Button("TP Back", section, function()
        if not lastPosition or teleportCooldown then return end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            teleportCooldown = true
            char.HumanoidRootPart.CFrame = lastPosition
            lastPosition = nil
            statusLabel.Text = "Status: Returned!"
            task.delay(1.5, function() teleportCooldown = false end)
        end
    end)
    
    elements:Label("━━━━━━━━━━━━━━━━━━━", section)
    elements:Label("PINK = Knife | CYAN = Gun", section)
    elements:Label("Press Q to aimbot murderer", section)
    
    print("MM2 Scam Police - ESP + Aimbot + Grab Gun Loaded!")
end

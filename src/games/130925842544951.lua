-- Murder Mystery 2 - MM2 Scam Police (FIXED ESP)

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local VirtualInput = game:GetService("VirtualInputManager")
    local RunService = game:GetService("RunService")
    
    -- Load saved settings
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.espEnabled = setdata.espEnabled or false
    setdata.showBoxes = setdata.showBoxes or false
    setdata.aimbotEnabled = setdata.aimbotEnabled or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
    
    -- ESP Variables
    local espEnabled = setdata.espEnabled
    local showBoxes = setdata.showBoxes
    
    -- Colors
    local MURDER_COLOR = Color3.fromRGB(255, 50, 50)  -- Red for Murderer
    local SHERIFF_COLOR = Color3.fromRGB(50, 150, 255) -- Blue for Sheriff
    local INNOCENT_COLOR = Color3.fromRGB(100, 100, 100) -- Gray for Innocent
    
    -- Weapon name lists (covers all possible names)
    local KNIFE_NAMES = {
        "Knife", "knife", "KnifeClient", "Weapon",
        "MurdererKnife", "MurderKnife", "Dagger"
    }
    
    local GUN_NAMES = {
        "Gun", "gun", "GunClient", "Revolver",
        "SheriffGun", "SheriffRevolver", "Pistol",
        "GunDrop", "RevolverDrop"
    }
    
    -- Helper function to check if player has a weapon
    local function playerHasWeapon(player, weaponNames)
        -- Check character
        local char = player.Character
        if char then
            for _, weaponName in ipairs(weaponNames) do
                if char:FindFirstChild(weaponName) then
                    return true
                end
            end
        end
        
        -- Check backpack
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, weaponName in ipairs(weaponNames) do
                if backpack:FindFirstChild(weaponName) then
                    return true
                end
            end
        end
        
        return false
    end
    
    -- Function to get player role
    local function getPlayerRole(player)
        if playerHasWeapon(player, KNIFE_NAMES) then
            return "Murderer"
        elseif playerHasWeapon(player, GUN_NAMES) then
            return "Sheriff"
        else
            return "Innocent"
        end
    end
    
    -- Get color for role
    local function getRoleColor(role)
        if role == "Murderer" then
            return MURDER_COLOR
        elseif role == "Sheriff" then
            return SHERIFF_COLOR
        else
            return INNOCENT_COLOR
        end
    end
    
    -- Store highlights in a folder
    local espFolder = Instance.new("Folder")
    espFolder.Name = "MM2_ESP_Highlights"
    espFolder.Parent = game:GetService("CoreGui")
    
    -- Clean up old highlights
    local function cleanupHighlights()
        for _, child in pairs(espFolder:GetChildren()) do
            if child:IsA("Highlight") then
                child:Destroy()
            end
        end
    end
    
    -- Update ESP for a player
    local function updateESP(player)
        local char = player.Character
        if not char then return end
        
        local highlight = espFolder:FindFirstChild(player.Name .. "_ESP")
        
        if espEnabled and showBoxes then
            local role = getPlayerRole(player)
            local color = getRoleColor(role)
            
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = player.Name .. "_ESP"
                highlight.FillTransparency = 0.6
                highlight.OutlineTransparency = 0.2
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = espFolder
            end
            
            highlight.Adornee = char
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.Enabled = true
        else
            if highlight then
                highlight:Destroy()
            end
        end
    end
    
    -- ESP Loop with better detection
    task.spawn(function()
        while true do
            if espEnabled and showBoxes then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        updateESP(player)
                    end
                end
            else
                cleanupHighlights()
            end
            task.wait(0.15)
        end
    end)
    
    -- Monitor new characters and tool changes
    local function onCharacterAdded(player, character)
        if player == LocalPlayer then return end
        
        -- Wait a bit for tools to load
        task.wait(0.5)
        updateESP(player)
        
        -- Also monitor tool changes
        local function onToolAdded(tool)
            updateESP(player)
        end
        
        character.ChildAdded:Connect(onToolAdded)
    end
    
    -- Connect to player added events
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(char)
                onCharacterAdded(player, char)
            end)
            if player.Character then
                onCharacterAdded(player, player.Character)
            end
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(char)
                onCharacterAdded(player, char)
            end)
        end
    end)
    
    -- ============ AIMBOT ============
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not setdata.aimbotEnabled then return end
        if input.KeyCode == Enum.KeyCode.Q then
            
            -- Find murderer
            local murderer = nil
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and playerHasWeapon(player, KNIFE_NAMES) then
                    murderer = player
                    break
                end
            end
            if not murderer then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            -- Find gun
            local gun = nil
            for _, weaponName in ipairs(GUN_NAMES) do
                gun = char:FindFirstChild(weaponName)
                if gun then break end
            end
            
            if not gun then
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, weaponName in ipairs(GUN_NAMES) do
                        gun = backpack:FindFirstChild(weaponName)
                        if gun then break end
                    end
                end
            end
            if not gun then return end
            
            local shootRemote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Fire")
            if not shootRemote then return end
            
            local targetHRP = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
            local rightHand = char:FindFirstChild("RightHand")
            if not targetHRP or not rightHand then return end
            
            -- Equip gun (press 1)
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            task.wait(0.05)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.One, false, game)
            task.wait(0.05)
            
            -- Shoot
            local args = {CFrame.new(rightHand.Position), CFrame.new(targetHRP.Position)}
            shootRemote:FireServer(unpack(args))
        end
    end)
    
    -- ============ GRAB GUN FINDER ============
    local currentGrabGun = nil
    local lastPosition = nil
    local teleportCooldown = false
    
    local function findGrabGun()
        local grabs = {}
        local function search(parent)
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("BasePart") then
                    local name = child.Name:lower()
                    if name:find("gundrop") or name:find("gun") or name:find("revolver") then
                        table.insert(grabs, child)
                    end
                end
                if #child:GetChildren() > 0 then 
                    pcall(search, child)
                end
            end
        end
        pcall(search, Workspace)
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then 
            return nil, math.huge
        end
        
        local pos = char.HumanoidRootPart.Position
        local nearest, nearestDist = nil, math.huge
        for _, grab in pairs(grabs) do
            local dist = (grab.Position - pos).Magnitude
            if dist < nearestDist then 
                nearestDist = dist
                nearest = grab 
            end
        end
        return nearest, nearestDist
    end
    
    -- ============ UI ELEMENTS ============
    elements:Label("━━━━━ ESP (FIXED) ━━━━━", section)
    
    elements:Toggle("Master ESP", section, setdata.espEnabled, function(v)
        setdata.espEnabled = v
        espEnabled = v
        setconfig("espEnabled", v)
        if not v then
            cleanupHighlights()
        end
    end)
    
    elements:Toggle("Show Boxes", section, setdata.showBoxes, function(v)
        setdata.showBoxes = v
        showBoxes = v
        setconfig("showBoxes", v)
    end)
    
    elements:Label("━━━━━ AIMBOT ━━━━━", section)
    elements:Label("Press Q to auto-shoot murderer", section)
    
    elements:Toggle("Aimbot (Q)", section, setdata.aimbotEnabled, function(v)
        setdata.aimbotEnabled = v
        setconfig("aimbotEnabled", v)
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
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = currentGrabGun
            statusLabel.Text = "Status: Found! (" .. math.floor(dist) .. " studs)"
        else
            statusLabel.Text = "Status: No Grab Gun found"
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
    elements:Label("🔴 Red = Murderer | 🔵 Blue = Sheriff", section)
    
    print("MM2 Scam Police - FIXED ESP Loaded!")
end

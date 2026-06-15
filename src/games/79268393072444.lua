-- Simple standalone version (just paste and run)
local tycoonNum = "8" -- Change this to your tycoon number

-- Auto buy decor items
spawn(function()
    while wait(0.01) do
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
end)

-- Auto upgrade LemonDash
spawn(function()
    while wait(0.01) do
        pcall(function()
            workspace:WaitForChild("Tycoon" .. tycoonNum):WaitForChild("Purchases"):WaitForChild("LemonDash"):WaitForChild("LemonDash"):WaitForChild("LemonDash"):WaitForChild("Upgrade"):InvokeServer(1)
        end)
    end
end)

-- Auto upgrade Lemon Stand
spawn(function()
    while wait(0.01) do
        pcall(function()
            workspace:WaitForChild("Tycoon" .. tycoonNum):WaitForChild("Purchases"):WaitForChild("Lemon Stand"):WaitForChild("Lemon Stand"):WaitForChild("Lemon Stand"):WaitForChild("Upgrade"):InvokeServer(1)
        end)
    end
end)

print("✅ All loops started with 0.01s delay!")

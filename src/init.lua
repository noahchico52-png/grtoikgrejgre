if not game:IsLoaded() then
    game.Loaded:Wait()
end
local env = getgenv()

-- Change folder name here if you want
if not isfolder("MM2ScamPolice") then makefolder("MM2ScamPolice") end
if not isfile("MM2ScamPolice/Config.json") then
    writefile("MM2ScamPolice/Config.json", game:GetService("HttpService"):JSONEncode({
        settings = {
            auto_rejoin_on_kick = false,
            disable_3d_rendering = false
        }
    }))
end

function env.import(id)
    return game:GetObjects(id)[1]
end

-- CHANGE THIS TO YOUR GITHUB
function env.getgitpath(where)
    local mainBuild = "https://raw.githubusercontent.com/noahchico52-png/grtoikgrejgre/refs/heads/main/"
    if where == "src" then
        return mainBuild .. "src/"
    elseif where == "games" then
        return mainBuild .. "src/games/"
    end
end

function env.setconfig(key, value)
    local httpservice = game:GetService("HttpService")
    local dec = httpservice:JSONDecode(readfile("MM2ScamPolice/Config.json"))
    dec[tostring(game.PlaceId)] = dec[tostring(game.PlaceId)] or {}
    dec[tostring(game.PlaceId)][key] = value
    writefile("MM2ScamPolice/Config.json", httpservice:JSONEncode(dec))
end

game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    if env.autorjjjj then
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
end)

-- This loads YOUR ui.lua from YOUR GitHub
loadstring(game:HttpGet(getgitpath("src").."ui.lua"))()

-- CHANGE THIS TO YOUR GITHUB TOO
if queue_on_teleport then
    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/noahchico52-png/grtoikgrejgre/refs/heads/main/src/init.lua"))()')
end

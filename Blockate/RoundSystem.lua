--[[ Configuration ]]--
getgenv().BRS_Settings = {
TIME_UNTIL_NEXT_EVENT = 4.5,
PAUSED = true
}

--[[ Services ]]--
local Players = game:GetService("Players")

--[[ Modules ]]--
local Events = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/main/Blockate/Events.lua",true))()

--[[ Setup ]]--
local count = 0
local playerCount = 0
for _,v in pairs(Events) do
 count += 1
end
Players.PlayerAdded:Connect(function()
    count += 1
end)
Players.PlayerRemoving:Connect(function()
    count -= 1
end)
for _,v in pairs(Players:GetPlayers()) do
    count += 1
end

--[[ Main ]]--
task.spawn(function()
  while true do
   task.wait()
   if count > 0 then
    getgenv().BRS_Settings.PAUSED = false
   else
    getgenv().BRS_Settings.PAUSED = true
   end
  end
end)

while true do
    if getgenv().BRS_Settings.PAUSED then repeat task.wait(1); shout("Waiting for players...") until not getgenv().BRS_Settings.PAUSED end
    task.wait(getgenv().BRS_Settings.TIME_UNTIL_NEXT_EVENT)
    Events[math.random(1, count)]()
end

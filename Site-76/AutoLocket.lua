
getgenv().AutoLovecraftianLocket = true
getgenv().HealthThreshold = 385 -- should not be higher than 385
getgenv().LocketCooldown = 0.1

-- dont touch everything below unless you know what you're doing

-- // Services \\ --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalHealth = LocalPlayer.Character.Humanoid.Health
local LocalMaxHealth = LocalPlayer.Character.Humanoid.MaxHealth

local EquipLocket = function() game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseLocket"):FireServer() end
local UnequipLocket = function() game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DropItem"):InvokeServer("Lovecraftian Locket") end
local Notification

function findFunctionInGC(funcName)
    for i,v in pairs(getgc()) do
        if type(v) == "function" and not is_synapse_function(v) and getinfo(v).name then
            if getinfo(v).name == funcName then
                return v
            end
        end
    end
    return false
end
Notification = findFunctionInGC("DisplayLocalNotif") -- cant believe i had to getgc for this

function checkForLocket()
	-- Equipment Check
	for i,v in pairs(LocalPlayer.PlayerGui.MainUi.Main.TopBar.EquipmentBar:GetDescendants()) do
		if v.Name ~= "EquipmentIcon" then continue end

		if v.Image == "rbxassetid://5601642525" then
			return true, "equipment"
		end
	end

	-- Toolbar Check
	for i,v in pairs(LocalPlayer.PlayerGui.MainUi.Main.ToolBar.Background:GetDescendants()) do
		if v.Name ~= "Icon" then continue end

		if v.Image == "rbxassetid://5601642525" then
			return true, "toolbar"
		end
	end

	-- Inventory Check
	for i,v in pairs(LocalPlayer.PlayerGui.MainUi.Main.Backpack.Background.Holder:GetDescendants()) do
		if v.Name ~= "Icon" then continue end

		if v.Image == "rbxassetid://5601642525" then
			return true, "inventory"
		end
	end	

	Notification(LocalPlayer.PlayerGui.MainUi.Main, [[⚠️ Script Error ⚠️
	
	Lovecraftian Locket not found! Please equip the locket and run the script again.]])
	return false
end

checkForLocket()

--Main Loop
repeat
	task.wait()
	local locketExist, locketLocation = checkForLocket()
	if not locketExist then getgenv().AutoLovecraftianLocket = false; return end

	if locketLocation == "toolbar" or "inventory" then
		EquipLocket()
	end

	LocalHealth = LocalPlayer.Character.Humanoid.Health

	if LocalHealth >= getgenv().HealthThreshold then
		UnequipLocket()
		task.wait(getgenv().LocketCooldown)
		EquipLocket()
	end

until not getgenv().AutoLovecraftianLocket

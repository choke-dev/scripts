local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()
local GUI = Mercury:Create{
    Name = "PBCC Panel",
    Size = UDim2.fromOffset(550, 400),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/choke-dev/scripts/Pinewood"
}

local LP = game:GetService("Players").LocalPlayer

function findPartWithVector3Value(Position, Size)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Size == Size and v.Position == Position then
            return v
        end
    end
end

function tpClickReturn(Position, CD)
    reInitializeVariables()
    -- this function will modify the Position Y value by -4 to make sure the player is on the ground
    Position = Vector3.new(Position.X, Position.Y, Position.Z)
    local SavedPosition = LP.Character.HumanoidRootPart.CFrame
    LP.Character.HumanoidRootPart.CFrame = CFrame.new(Position)
    task.wait(0.1)
    fireclickdetector(CD)
    task.wait(0.2)
    LP.Character.HumanoidRootPart.CFrame = SavedPosition
end

local CoolantPump_ButtonPosition = Vector3.new(116.51488494873047, 448.0394592285156, -722.4148559570312)
local CoolantPump_ButtonSize = Vector3.new(1, 0.4000000059604645, 1)
local CoolantSupply_ButtonPosition = Vector3.new(148.72488403320312, 410.529541015625, -999.4135131835938)
local CoolantSupply_ButtonSize = Vector3.new(1, 0.4000000059604645, 1)
local CoolantFlow_ButtonPosition = Vector3.new(-165.59991455078125, 734.3217163085938, -243.1623077392578)
local CoolantFlow_ButtonSize = Vector3.new(1, 0.800000011920929, 1)

local CoolantPump_Button = findPartWithVector3Value(CoolantPump_ButtonPosition, CoolantPump_ButtonSize)
local CoolantSupply_Button = findPartWithVector3Value(CoolantSupply_ButtonPosition, CoolantSupply_ButtonSize)
local CoolantFlow_Button = findPartWithVector3Value(CoolantFlow_ButtonPosition, CoolantFlow_ButtonSize)

local CoolantPump_CD = CoolantPump_Button:FindFirstChildOfClass("ClickDetector")
local CoolantSupplyCD = CoolantSupply_Button:FindFirstChildOfClass("ClickDetector")
local CoolantFlowCD = CoolantFlow_Button:FindFirstChildOfClass("ClickDetector")


local Fan1_ButtonPosition = Vector3.new(-455.12969970703125, 707.1543579101562, -311.1838684082031)
local Fan1_ButtonSize = Vector3.new(1, 0.4000000059604645, 1)
local Fan2_ButtonPosition = Vector3.new(-455.12969970703125, 707.1543579101562, -309.78387451171875)
local Fan2_ButtonSize = Vector3.new(1, 0.4000000059604645, 1)
local Fan3_ButtonPosition = Vector3.new(-455.12969970703125, 707.1543579101562, -308.3839416503906)
local Fan3_ButtonSize = Vector3.new(1, 0.4000000059604645, 1)
local Fan4_ButtonPosition = Vector3.new(-455.12969970703125, 707.1543579101562, -306.9838562011719)
local Fan4_ButtonSize = Vector3.new(1, 0.4000000059604645, 1)
local Fan5_ButtonPosition = Vector3.new(-455.12969970703125, 707.1543579101562, -305.58392333984375)
local Fan5_ButtonSize = Vector3.new(1, 0.4000000059604645, 1)   

local Fan1_Button = findPartWithVector3Value(Fan1_ButtonPosition, Fan1_ButtonSize)
local Fan2_Button = findPartWithVector3Value(Fan2_ButtonPosition, Fan2_ButtonSize)
local Fan3_Button = findPartWithVector3Value(Fan3_ButtonPosition, Fan3_ButtonSize)
local Fan4_Button = findPartWithVector3Value(Fan4_ButtonPosition, Fan4_ButtonSize)
local Fan5_Button = findPartWithVector3Value(Fan5_ButtonPosition, Fan5_ButtonSize)

local Fan1_CD = Fan1_Buttondw
local Fan2_CD = Fan2_Button:FindFirstChildOfClass("ClickDetector")
local Fan3_CD = Fan3_Button:FindFirstChildOfClass("ClickDetector")
local Fan4_CD = Fan4_Button:FindFirstChildOfClass("ClickDetector")
local Fan5_CD = Fan5_Button:FindFirstChildOfClass("ClickDetector")

function reInitializeVariables()
    CoolantPump_Button = findPartWithVector3Value(CoolantPump_ButtonPosition, CoolantPump_ButtonSize)
    CoolantSupply_Button = findPartWithVector3Value(CoolantSupply_ButtonPosition, CoolantSupply_ButtonSize)
    CoolantFlow_Button = findPartWithVector3Value(CoolantFlow_ButtonPosition, CoolantFlow_ButtonSize)
    CoolantPump_CD = CoolantPump_Button:FindFirstChildOfClass("ClickDetector")
    CoolantSupplyCD = CoolantSupply_Button:FindFirstChildOfClass("ClickDetector")
    CoolantFlowCD = CoolantFlow_Button:FindFirstChildOfClass("ClickDetector")

    Fan1_Button = findPartWithVector3Value(Fan1_ButtonPosition, Fan1_ButtonSize)
    Fan2_Button = findPartWithVector3Value(Fan2_ButtonPosition, Fan2_ButtonSize)
    Fan3_Button = findPartWithVector3Value(Fan3_ButtonPosition, Fan3_ButtonSize)
    Fan4_Button = findPartWithVector3Value(Fan4_ButtonPosition, Fan4_ButtonSize)
    Fan5_Button = findPartWithVector3Value(Fan5_ButtonPosition, Fan5_ButtonSize)
    Fan1_CD = Fan1_Button:FindFirstChildOfClass("ClickDetector")
    Fan2_CD = Fan2_Button:FindFirstChildOfClass("ClickDetector")
    Fan3_CD = Fan3_Button:FindFirstChildOfClass("ClickDetector")
    Fan4_CD = Fan4_Button:FindFirstChildOfClass("ClickDetector")
    Fan5_CD = Fan5_Button:FindFirstChildOfClass("ClickDetector")
    return true
end

local Tab_CoreTempControl = GUI:Tab{
	Name = "Core Temperature Control",
	Icon = "rbxassetid://8569322835"
}
local CTC_Coolant = Tab_CoreTempControl:Section{
    Name = "Coolant"
}
local CTC_Fans = Tab_CoreTempControl:Section{
    Name = "Fans"
}

CTC_Coolant:Button{
	Name = "Toggle Coolant Supply",
	Description = "Handles the production of coolant.",
	Callback = function()
        tpClickReturn(CoolantSupply_ButtonPosition, CoolantSupplyCD)
    end
}
CTC_Coolant:Button{
	Name = "Toggle Coolant Pump",
	Description = "Handles coolant transportation to the core.",
	Callback = function()
        tpClickReturn(CoolantPump_ButtonPosition, CoolantPump_CD)
    end
}
CTC_Coolant:Button{
    Name = "Toggle Coolant Flow",
    Description = "Handles coolant flow to the core.",
    Callback = function()
        tpClickReturn(CoolantFlow_ButtonPosition, CoolantFlowCD)
    end
}

CTC_Fans:Button{
    Name = "Toggle Fan 1",
    Description = "Enables fan 1",
    Callback = function()
        tpClickReturn(Fan1_ButtonPosition, Fan1_CD)
    end
}
CTC_Fans:Button{
    Name = "Toggle Fan 2",
    Description = "Enables fan 2",
    Callback = function()
        tpClickReturn(Fan2_ButtonPosition, Fan2_CD)
    end
}
CTC_Fans:Button{
    Name = "Toggle Fan 3",
    Description = "Enables fan 3",
    Callback = function()
        tpClickReturn(Fan3_ButtonPosition, Fan3_CD)
    end
}
CTC_Fans:Button{
    Name = "Toggle Fan 4",
    Description = "Enables fan 4",
    Callback = function()
        tpClickReturn(Fan4_ButtonPosition, Fan4_CD)
    end
}
CTC_Fans:Button{
    Name = "Toggle Fan 5",
    Description = "Enables fan 5",
    Callback = function()
        tpClickReturn(Fan5_ButtonPosition, Fan5_CD)
    end
}

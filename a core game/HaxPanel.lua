-- Initialize GUI Library
local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

local DecreasePowerCD = workspace.CoreFolder.CoreFunctions.RCTRPower.Decrease.shinybutotn.ClickDetector
local IncreasePowerCD = workspace.CoreFolder.CoreFunctions.RCTRPower.Increase.shinybutotn.ClickDetector
local ContainmentFieldIgnitionCD = workspace.CoreFolder.CoreFunctions.Startup.ShieldButton.shinybutotn.CD
local MainReactorIgnitionCD = workspace.CoreFolder.CoreFunctions.Startup.Button.shinybutotn.CD
local ECoolantCD = workspace.CoreFolder.ECoolant.CoolingDischarge.Button.CD
local CoolantFlowCD = workspace.CoreFolder.CoreFunctions.Coolant.shinybutotn.ClickDetector
local ExhaustFanCD = workspace.CoreFolder.CoreFunctions.FanSystem.FanButtons.F2.shinybutotn.CD
local IntakeFanCD = workspace.CoreFolder.CoreFunctions.FanSystem.FanButtons.F1.shinybutotn.CD

local ECoolantValvePP = workspace.CoreFolder.ECoolant.Valves.Valve2.Valve["Meshes/valve2"].PrAtt["2"]
local PrimaryLever = {}
local SecondaryLever = {}
local StabilizationLever = {}   
PrimaryLever[1] = workspace.CoreFolder.CoreFunctions.LaserPanel.PL.Indicator.Model.One.CD
PrimaryLever[2] = workspace.CoreFolder.CoreFunctions.LaserPanel.PL.Indicator.Model.Two.CD
PrimaryLever[3] = workspace.CoreFolder.CoreFunctions.LaserPanel.PL.Indicator.Model.Three.CD
PrimaryLever[4] = workspace.CoreFolder.CoreFunctions.LaserPanel.PL.Indicator.Model.Four.CD
SecondaryLever[1] = workspace.CoreFolder.CoreFunctions.LaserPanel.Stab.Indicator.Model.One.CD
SecondaryLever[2] = workspace.CoreFolder.CoreFunctions.LaserPanel.Stab.Indicator.Model.Two.CD
SecondaryLever[3] = workspace.CoreFolder.CoreFunctions.LaserPanel.Stab.Indicator.Model.Three.CD
SecondaryLever[4] = workspace.CoreFolder.CoreFunctions.LaserPanel.Stab.Indicator.Model.Four.CD
StabilizationLever[1] = workspace.CoreFolder.CoreFunctions.LaserPanel.Sec.Indicator.Model.One.CD
StabilizationLever[2] = workspace.CoreFolder.CoreFunctions.LaserPanel.Sec.Indicator.Model.Two.CD
StabilizationLever[3] = workspace.CoreFolder.CoreFunctions.LaserPanel.Sec.Indicator.Model.Three.CD
StabilizationLever[4] = workspace.CoreFolder.CoreFunctions.LaserPanel.Sec.Indicator.Model.Four.CD -- for some reason idk why the names are swapped lol

local LocalPlayer = game:GetService("Players").LocalPlayer
local PLChoice = 1
local SLChoice = 1
local StabChoice = 1
-- Create Functions
local function checkMagnitude(vector)
    return LocalPlayer:DistanceFromCharacter(vector)
end


-- Create GUI

local GUI = Mercury:Create{
    Name = "ACG Admin",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/choke-dev/scripts/ACoreGame"
}

-- Create Tabs
local Tab_MainSystems = GUI:Tab{
	Name = "Main Systems",
	Icon = "rbxassetid://8569322835"
}
local Tab_Thermals = GUI:Tab{
	Name = "Thermals",
	Icon = "rbxassetid://8569322835"
}
local Tab_Misc = GUI:Tab{
	Name = "Miscellaneous",
	Icon = "rbxassetid://8569322835"
}

-- Buttons
    -- Main Systems
    Tab_MainSystems:Button{
    	Name = "Containment Field Ignition",
    	Description = "ignites the containment field ig",
    	Callback = function()
            fireclickdetector(ContainmentFieldIgnitionCD, math.random(1, 5))
        end
    }
    Tab_MainSystems:Button{
    	Name = "Main Reactor Core Ignition",
    	Description = "ignites the main reactor core lol",
    	Callback = function()
            fireclickdetector(MainReactorIgnitionCD, math.random(1, 5))
        end
    }

    -- Thermals
    local ThermalsTab_SectionCF = Tab_Thermals:Section{
        Name = "Coolant & Fans"
    }
    local ThermalsTab_SectionCLC = Tab_Thermals:Section{
        Name = "Core Lasers Control"
    }
    ThermalsTab_SectionCF:Button{
    	Name = "Toggle Intake Fan",
    	Description = "Ventilates air in the chamber",
    	Callback = function()
            fireclickdetector(IntakeFanCD, math.random(1, 5))   
        end
    }
    ThermalsTab_SectionCF:Button{
    	Name = "Toggle Exhaust Fan",
    	Description = "Ventilates air out of the chamber",
    	Callback = function()
            fireclickdetector(IntakeFanCD, math.random(1, 5))   
        end
    }
    ThermalsTab_SectionCF:Button{
    	Name = "Toggle Coolant Flow",
    	Description = "Used to reduce temperature, requires coolant pool to be at least 3% full.",
    	Callback = function()
            fireclickdetector(CoolantFlowCD, math.random(1, 5))   
        end
    }
    ThermalsTab_SectionCF:Button{
    	Name = "Activate E-Coolant",
    	Description = "Rapidly cools the core, disengages once temperature is below 2500C.",
    	Callback = function()
            fireclickdetector(CoolantFlowCD, math.random(1, 5))   
        end
    }

    ThermalsTab_SectionCLC:Button{
    	Name = "Increase Power",
    	Description = "Allocates more core output, resulting in higher temperature.",
    	Callback = function()
            fireclickdetector(IncreasePowerCD, math.random(1, 5))   
        end
    }
    ThermalsTab_SectionCLC:Button{
    	Name = "Reduce Power",
    	Description = "Allocates less core output, resulting in lower temperature.",
    	Callback = function()
            fireclickdetector(DecreasePowerCD, math.random(1, 5))
        end
    }
    ThermalsTab_SectionCLC:Slider{
        Name = "Primary Lever Position",
        Default = 1,
        Min = 1,
        Max = 4,
        Callback = function(value)
            PLChoice = value
            GUI:set_status("[INFO] Set Primary Lever Position to " .. value)
        end
    }
    ThermalsTab_SectionCLC:Slider{
        Name = "Secondary Lever Position",
        Default = 1,
        Min = 1,
        Max = 4,
        Callback = function(value)
            SLChoice = value
            GUI:set_status("[INFO] Set Secondary Lever Position to " .. value)
        end
    }
    ThermalsTab_SectionCLC:Slider{
        Name = "Stabilization Lever Position",
        Default = 1,
        Min = 1,
        Max = 4,
        Callback = function(value)
            StabChoice = value
            GUI:set_status("[INFO] Set Stabilization Lever Position to " .. value)
        end
    }
    ThermalsTab_SectionCLC:Button{
    	Name = "Apply settings to levers",
    	Description = "Applies the settings to the levers simultaneously",
    	Callback = function()
            -- check if the player's head is less than or equal to 32 studs away from the levers using checkMagnitude, if not then error
            if checkMagnitude(workspace.CoreFolder.CoreFunctions.LaserPanel.PL.Frame.Part.CFrame.Position) > 6 then
                GUI:Notification{
                    Title = "Error",
                    Text = "Too far away from levers, please move closer.",
                    Duration = 3,
                    Callback = function() end
                }
                return
            end
            
            fireclickdetector(PrimaryLever[PLChoice], math.random(1, 5))
            fireclickdetector(SecondaryLever[SLChoice], math.random(1, 5))
            fireclickdetector(StabilizationLever[StabChoice], math.random(1, 5))
            GUI:set_status("[SUCCESS] Applied settings to levers")
        end
    }

    -- Miscellaneous
    Tab_Misc:Button{
    	Name = "Toggle E-Coolant",
        Description = "Toggles the E-Coolant system",
        Callback = function()
            fireproximityprompt(ECoolantValvePP, math.random(1, 5))
        end
    }

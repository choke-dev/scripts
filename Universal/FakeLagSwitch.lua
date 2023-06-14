local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))();

local ContextActionService = game:GetService("ContextActionService")
local RunService           = game:GetService("RunService")
local Players              = game:GetService("Players")

local Status = false

local Objects     = {}
local Connections = {}

function FormatTextWithColor(text, color)
    local formattedText = string.format('<font color="rgb(%d,%d,%d)">%s</font>', color.R * 255, color.G * 255, color.B * 255, text)
    return formattedText
end

function Notify(Title, Description, Duration)
    AkaliNotif.Notify({
        Description = Description;
        Title = Title;
        Duration = Duration or 5;
    });
end

function Setup()
    local VehicleSeat = Instance.new("VehicleSeat")
    local Weld        = Instance.new("Weld")

    return VehicleSeat, Weld
end

function CreateShadow()
    local LocalCharacterArchivable = Players.LocalPlayer.Character.Archivable
    Players.LocalPlayer.Character.Archivable = true
    local Clone = Players.LocalPlayer.Character:Clone()
    Players.LocalPlayer.Character.Archivable = LocalCharacterArchivable

    for _, Part in pairs(Clone:GetDescendants()) do
        if Part:IsA("Part") then
            Part.Anchored = true
            Part.CanCollide = false
            Part.Material = Enum.Material.ForceField
        end
    end

    Clone.Parent = workspace

    table.insert(Objects, Clone)
end

function ToggleLagSwitch(_actionName, inputState, _inputObject)
    if inputState ~= Enum.UserInputState.Begin then return end

    if Status then
        Status = false

        for _, Connection in pairs(Connections) do
            Connection:Disconnect()
        end

        for _, Object in pairs(Objects) do
            Object:Destroy()
        end
        Notify("Lag Switch", FormatTextWithColor("Disabled", Color3.fromRGB(255, 0, 0)))   
    else
        Status = true
        local VehicleSeat, Weld  = Setup()
        local Clone              = CreateShadow()
        local HumanoidRoot       = Players.LocalPlayer.Character.HumanoidRootPart
        local HumanoidRootCFrame = HumanoidRoot.CFrame

        VehicleSeat.Parent = workspace
        Weld.Parent        = VehicleSeat

        VehicleSeat.Transparency = 1

        VehicleSeat.CFrame   = HumanoidRoot.CFrame
        VehicleSeat.CanCollide = false

        Weld.Part0 = VehicleSeat
        Weld.Part1 = HumanoidRoot

        HumanoidRoot.CFrame = HumanoidRootCFrame

        local function Update()
            VehicleSeat.CFrame = HumanoidRoot.CFrame
        end

        local MoveVSeatCFrame = RunService.RenderStepped:Connect(Update)
        table.insert(Connections, MoveVSeatCFrame)
        table.insert(Objects, VehicleSeat)
        table.insert(Objects, Weld)
        table.insert(Objects, Clone)
        Notify("Lag Switch", FormatTextWithColor("Enabled", Color3.fromRGB(0, 255, 0)))
    end
end


ContextActionService:BindAction("ToggleLagSwitch", ToggleLagSwitch, false, Enum.KeyCode.F)

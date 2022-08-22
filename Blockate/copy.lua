
--[[
    
   > Note:
    // Trusses are removed because I am lazy.
    // You will now not experience any kicks.

    // Blockate World Copier;
    // This script is for COPYING the world.
    // Use the other script to LOAD the world.

    // PUBLIC!
    // Release to anyone, I literally don't care
    
--]]

local lol = {}
-- vars;
local modules = game:GetService("ReplicatedStorage").Modules

-- how does blockate calculate the orientations!??!
local orientations = {
    ["0"] = Vector3.new(0, 0, 0),
    ["1"] = Vector3.new(0, 0, 90),
    ["2"] = Vector3.new(0, 0, 180),
    ["3"] = Vector3.new(0, 0, -90),
    ["4"] = Vector3.new(0, 180, 0),
    ["5"] = Vector3.new(0, 180, 90),
    ["6"] = Vector3.new(0, 180, 180),
    ["7"] = Vector3.new(0, -180, -90),
    ["8"] = Vector3.new(90, 90, 0),
    ["9"] = Vector3.new(90, 0, 0),
    ["10"] = Vector3.new(90, -90, 0),
    ["11"] = Vector3.new(90, 180, 0),
    ["12"] = Vector3.new(-90, -90, 0),
    ["13"] = Vector3.new(-90, 0, 0),
    ["14"] = Vector3.new(-90, 90, 0),
    ["15"] = Vector3.new(-90, -180, 0),
    ["16"] = Vector3.new(0, -90, 0),
    ["17"] = Vector3.new(0, -90, 90),
    ["18"] = Vector3.new(0, -90, 180),
    ["19"] = Vector3.new(0, -90, -90),
    ["20"] = Vector3.new(0, 90, 0),
    ["21"] = Vector3.new(0, 90, 90),
    ["22"] = Vector3.new(0, 90, 180),
    ["23"] = Vector3.new(0, 90, -90),
}

--[[

    // INTERNAL FUNCTIONS!
    // DO NOT EDIT!

--]]

-- getAxisString<num> -> number [Internal!]
local getAxisString;


local function toBlockateCoordinatesFromVector(vector)
    local x = vector.X
    local y = vector.Y
    local z = vector.Z
    local xString = getAxisString(x)
    local yString = getAxisString(y)
    local zString = getAxisString(z)
    return ("%s %s %s/0"):format(xString, yString, zString)
end

-- toBlockateCoordinates<instance: Instance> -> string [Internal!]
-- TODO: Orientation
function toBlockateCoordinates(instance, fixer)
    if instance.Name == "Cube" or instance.Name == "Ball" then return toBlockateCoordinatesFromVector(instance.Functionality.Movable.SpawnPoint.Value) end
    assert(typeof(instance) == "Instance")
    local instance_pos = instance.Position
    local instance_orientation = instance.Orientation
    
-- have to make the code this ugly because it won't work
    for i,v in pairs(orientations) do
        if v == instance_orientation then
            instance_orientation = i
            break
        end
    end
    
    if instance_orientation == instance.Orientation then 
        return
    end

    return ("%s %s %s/%s"):format(getAxisString(instance_pos.X), getAxisString(instance_pos.Y), getAxisString(instance_pos.Z), instance_orientation)
end 

-- toBlockateSize<instance: Instance> -> number [Internal!]
function toBlockateMaterial(instance)
    assert(typeof(instance) == "Instance")
    local BlockMaterials = require(modules.Data.PropertiesIndex.BlockMaterials)
    for i, material in ipairs(BlockMaterials) do
        if instance.Material == material then
            return i
        end
    end
end

-- toBlockateSize<instance: Instance> -> number [Internal!]
function toBlockateSize(instance)
    assert(typeof(instance) == "Instance")
    local BlockSizes = require(modules.Data.PropertiesIndex.BlockSizes)
    for i, size in ipairs(BlockSizes) do
        if instance.Size == size.Value then
            return i
        end

        if Vector3.new(instance.Size.X+0.1, instance.Size.Y+0.1, instance.Size.Z+0.1) == size.Value then
            return i
        end
    end
end

-- toBlockateShape<instance: Instance> -> number [Internal!]
function toBlockateShape(instance)
    assert(typeof(instance) == "Instance")
    local BlockShapes = require(modules.Data.PropertiesIndex.BlockShapes)
    for i, shape in ipairs(BlockShapes) do
        if instance.Name == shape.Name then
            return i
        end
    end
end

--[[

    // FUNCTIONS

--]]

-- getBlockProperties<instance: Instance> -> table
function getBlockProperties(instance)
    -- Light properties; because it errors >:(
    local Light, LightColor = 0, "ffff00"
    if instance:FindFirstChild("PointLight") then
        LightColor = instance.PointLight.Color:ToHex()
        Light = instance.PointLight.Range
    end
    
    local properties

    if string.find(instance.Name, "Cube") or string.find(instance.Name, "Ball") then
        properties = {
            [1] = toBlockateCoordinatesFromVector(instance.Functionality.Movable.SpawnPoint.Value),
            [2] = {
                ["Reflectance"] = instance.Reflectance,
                ["CanCollide"] = instance.CanCollide,
                ["Color"] = instance.Color:ToHex(),
                ["LightColor"] = LightColor,
                ["Transparency"] = instance.Transparency,
                ["Light"] = Light,
                ["Material"] = toBlockateMaterial(instance),
                ["Shape"] = toBlockateShape(instance),
                ["Size"] = toBlockateSize(instance)
            }
        }
    else
        properties = {
            [1] = toBlockateCoordinates(instance),
            [2] = {
                ["Reflectance"] = instance.Reflectance,
                ["CanCollide"] = instance.CanCollide,
                ["Color"] = instance.Color:ToHex(),
                ["LightColor"] = LightColor,
                ["Transparency"] = instance.Transparency,
                ["Light"] = Light,
                ["Material"] = toBlockateMaterial(instance),
                ["Shape"] = toBlockateShape(instance),
                ["Size"] = toBlockateSize(instance)
            }
        }
    end

    -- Fix PillarX position kick
    if properties[2]["Size"] == 7 then
        properties[1] = toBlockateCoordinates(instance, true)
    end

    return properties
end

-- get functions
for i,v in pairs(getgc()) do
    if type(v) == "function" and getfenv(v).script == game.ReplicatedStorage.Modules.BlockPosition then
        if getinfo(v).name == "getAxisString" then
            getAxisString = v
        end
    end
end

--[[

    // CODE

--]]
-- Save everything in a file.
local HttpService = game:GetService("HttpService")
local saved = {}
local savedVectors = {}

function lol.copy(parts)
    for _, block in ipairs(parts) do

        -- Ignore movables;
        --[[if block.Name == "Cube" or block.Name == "Ball" then
            continue
        end]]
        -- Errors if block has no Creator for some reason..
        if not block:FindFirstChild("Creator") then
            continue
        end
        
        if getBlockProperties(block)[2]["Shape"] == 6 then
            continue
        end
        table.insert(saved, getBlockProperties(block))
    end
    writefile("BlockateCopydata.txt", HttpService:JSONEncode(saved))
    saved = {}
end
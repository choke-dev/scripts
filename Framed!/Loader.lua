getgenv().FramedTESP_Notifications = true
game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
    fireproximityprompt(prompt)
end)
loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/main/Framed!/Target%20ESP.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/RE-Script/main/Dependencies/skeleton%20esp.lua"))()

--[[

Copy the code below to quickly run this loader.

loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/main/Framed!/Loader.lua"))()

]]

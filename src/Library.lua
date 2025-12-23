-- Ensure cloneref is defined properly
local cloneref = function(...)
    print("cloneref called with arguments:", ...)
    return ...
end

-- Fix GetService function to use the correct method call syntax
local GetService = function(Service)
    print("GetService called with Service:", Service)
    local result = game:GetService(Service)
    if result then
        print("GetService success for:", Service)
    else
        print("GetService failed for:", Service)
    end
    return cloneref(result)
end

--// Services
local Services = {
    RunService = GetService("RunService"),
    UserInputService = GetService("UserInputService"),
    HttpService = GetService("HttpService"),
    TweenService = GetService("TweenService"),
    StarterGui = GetService("StarterGui"),
    Players = GetService("Players"),
    StarterPlayer = GetService("StarterPlayer"),
    Lighting = GetService("Lighting"),
    ReplicatedStorage = GetService("ReplicatedStorage"),
    ReplicatedFirst = GetService("ReplicatedFirst"),
    TeleportService = GetService("TeleportService"),
    CoreGui = GetService("CoreGui"),
    --VirtualUser = GetService("VirtualUser"), -- Gets detected by some anti-cheats.
    Camera = workspace.CurrentCamera
}

--// Variables
local Variables = {
    LocalPlayer = Services.Players.LocalPlayer,
    Typing = false,
    Mouse = Services.Players.LocalPlayer:GetMouse()
}

--// Functions

-- Resolve GetService safely for Lua 5.1
local SafeGetService
if clonefunction then
    SafeGetService = clonefunction(GetService)
else
    SafeGetService = GetService
end

local Functions = {
    GetService = SafeGetService,
    
    Encode = function(Table)
        if Table and type(Table) == "table" then
            print("Encoding table:", Table)
            return Services.HttpService:JSONEncode(Table)
        end
    end,

    Decode = function(String)
        if String and type(String) == "string" then
            print("Decoding string:", String)
            return Services.HttpService:JSONDecode(String)
        end
    end,

    SendNotification = function(TitleArg, DescriptionArg, DurationArg, IconArg)
        print("Sending Notification - Title:", TitleArg, "Description:", DescriptionArg, "Duration:", DurationArg, "Icon:", IconArg)
        Services.StarterGui:SetCore("SendNotification", {
            Title = TitleArg,
            Text = DescriptionArg,
            Duration = DurationArg,
            Icon = IconArg
        })
    end,

    StringToRGB = function(String)
        if not String then return end
        print("Converting String to RGB:", String)
        
        local R = tonumber(string.match(String, "([%d]+)[%s]*,[%s]*[%d]+[%s]*,[%s]*[%d]+"))
        local G = tonumber(string.match(String, "[%d]+[%s]*,[%s]*([%d]+)[%s]*,[%s]*[%d]+"))
        local B = tonumber(string.match(String, "[%d]+[%s]*,[%s]*[%d]+[%s]*,[%s]*([%d]+)"))

        print("Converted RGB values:", R, G, B)
        return Color3.fromRGB(R, G, B)
    end,

    RGBToString = function(RGB)
        print("Converting RGB to string:", RGB)
        return tostring(math.floor(RGB.R * 255))..", "..tostring(math.floor(RGB.G * 255))..", "..tostring(math.floor(RGB.B * 255))
    end,

    GetClosestPlayer = function(RequiredDistance, Part, Settings)
        print("Finding closest player with RequiredDistance:", RequiredDistance, "Part:", Part, "Settings:", Settings)
        RequiredDistance = RequiredDistance or 1 / 0
        Part = Part or "HumanoidRootPart"
        Settings = Settings or {false, false, false}

        local Target = nil

        for _, Value in next, Services.Players:GetPlayers() do
            if Value ~= Variables.LocalPlayer and Value.Character[Part] then
                if type(Settings) == "table" then
                    if Settings[1] and Value.TeamColor == Variables.LocalPlayer.TeamColor then continue end
                    if Settings[2] and Value.Character.Humanoid.Health <= 0 then continue end
                    if Settings[3] and #(Services.Camera:GetPartsObscuringTarget({Value.Character[Part].Position}, Value.Character:GetDescendants())) > 0 then continue end
                end

                local Vector, OnScreen = Services.Camera:WorldToViewportPoint(Value.Character[Part].Position)
                local Distance = (Services.UserInputService:GetMouseLocation() - Vector2.new(Vector.X, Vector.Y)).Magnitude

                if Distance < RequiredDistance and OnScreen then
                    RequiredDistance, Target = Distance, Value
                end
            end
        end

        print("Closest player:", Target)
        return Target
    end,

    -- More functions here...

    TestSpeed = function(Function, Checks)
        print("Testing speed for function with", Checks, "checks.")
        Checks = Checks or 1000

        local Start = tick()

        for _ = 1, Checks do
            Function()
        end

        local elapsed = tick() - Start
        print("TestSpeed elapsed time:", elapsed)
        return elapsed
    end
}

--// Main
for Index, Value in next, Services do
    print("Setting service:", Index)
    getfenv(1)[Index] = Value
end

for Index, Value in next, Variables do
    print("Setting variable:", Index)
    getfenv(1)[Index] = Value
end

for Index, Value in next, Functions do
    print("Setting function:", Index)
    getfenv(1)[Index] = Value
end

--// Managing
Services.UserInputService.TextBoxFocused:Connect(function()
    print("TextBox focused.")
    getfenv(1).Typing = true
end)

Services.UserInputService.TextBoxFocusReleased:Connect(function()
    print("TextBox focus released.")
    getfenv(1).Typing = false
end)

--// Unload Function
getfenv(1).ED_UnloadFunctions = function()
    print("Unloading functions.")
    for Index, _ in next, Services do
        getfenv(1)[Index] = nil
    end

    for Index, _ in next, Variables do
        getfenv(1)[Index] = nil
    end

    for Index, _ in next, Functions do
        getfenv(1)[Index] = nil
    end
end

--[[
local args = {
	"UpdateMousePos",
	vector.create(-76.97369384765625, 92.56269836425781, -410.6457824707031)
}
game:GetService("ReplicatedStorage"):WaitForChild("MainEvent"):FireServer(unpack(args))
--]]

local Player_Service = game:GetService "Players"
local Local_Player = Player_Service.LocalPlayer

loadstring(game:HttpGet("https://raw.githubusercontent.com/Babapro31-dev/Hood-Z/refs/heads/main/Adonis_bypass.luau"))();

local Run12 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Babapro31-dev/Hood-Z/refs/heads/main/Run12.luau"))();
Run12.Team_Check = false

local Prediction = {
    X = 0.13;
    Y = 0.09;
}

local namecall;
namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
	local method = getnamecallmethod():lower()

	if not checkcaller() and self.Name == "MainEvent" and method == "fireserver" and args[1] == "UpdateMousePos" and typeof(args[2]) == "Vector3" then
		if not Run12.Target then
			return namecall(self, ...)
		end

		if not Run12.Target.Character then
			return namecall(self, ...)
		end

		if not Run12.Target.Character.HumanoidRootPart then
			return namecall(self, ...)
		end

		local args = {...}
        local root = Run12.Target.Character.HumanoidRootPart
        args[2] = root.Position + (root.Velocity * Vector3.new(Prediction.X, Prediction.Y, Prediction.X))

		return namecall(self, unpack(args))
	end
	return namecall(self, ...)

end)


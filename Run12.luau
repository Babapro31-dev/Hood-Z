assert(Drawing, 'Exploit not supported')
assert(getgenv, 'Exploit not supported')

if getgenv()["Unnamedscripter's Aimtool"] then return getgenv()["Unnamedscripter's Aimtool"] end

local Run12 = {
	Bot_Enabled = true;
	Bot_Interrupted = false;
	Effect_Enabled = true;
	Effect_Speed = 5;
	Target = nil;
	Team_Check = true;
	Ignore_List = {};
	Circle_Distance = 200;
	Circle_Enabled = true;
	Circle_Visible = true;
	Target_Part = "Head";
	Wall_Check = true;
}; Run12["Default_Settings"] = table.clone(Run12); getgenv()["Unnamedscripter's Aimtool"] = Run12; (function()
	local Player_Service = game:GetService "Players"
	local Run_Service = game:GetService "RunService"
	local HTTP_Service = game:GetService "HttpService"
	local Tween_Service = game:GetService "TweenService"
	local User_Input_Service = game:GetService("UserInputService")

	local Local_Player = Player_Service.LocalPlayer
    local Local_Camera;
    repeat Run_Service.RenderStepped:Wait()
        Local_Camera = workspace.CurrentCamera
    until Local_Camera

	local Cursor;
	local G1, G2 = Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)
	local G3 = G1
	local Default_Target;
	local Default_Highlight;
	local JSwitch;
	local Circle = Drawing.new("Circle")
	Circle.Radius = 0
	Circle.Color = G1
	Circle.Filled = false
	Circle.NumSides = 100
	Circle.Thickness = 1
	Circle.Visible = true

	local RayParams = RaycastParams.new()
	RayParams.FilterType = Enum.RaycastFilterType.Exclude
	RayParams.FilterDescendantsInstances = {}
	RayParams.IgnoreWater = true

	local Highlight_Info = TweenInfo.new(
		1, 
		Enum.EasingStyle.Cubic, 
		Enum.EasingDirection.InOut, 
		0, 
		false, 
		0
	)

	local function Generate_Highlight()
		local Selection = Instance.new "Highlight"
		Selection.FillTransparency = 1
		Selection.OutlineColor = G3
		Selection.Name = HTTP_Service:GenerateGUID(false)
		Selection.Parent = game.CoreGui

		task.spawn(function()
			while Selection.Parent do
				Selection.OutlineColor = G3
				Run_Service.RenderStepped:Wait()
			end
		end)

		return Selection
	end

	local Handler = Run_Service.RenderStepped:Connect(function()
		Cursor = User_Input_Service:GetMouseLocation()
		Circle.Color = G3
		Circle.Visible = Run12.Circle_Enabled and Run12.Circle_Visible
		Circle.Position = Cursor
		Circle.Radius = Run12.Circle_Distance

		RayParams.FilterDescendantsInstances = {Local_Player.Character}
		G3 = G1:Lerp(G2, math.abs(math.sin(tick() * Run12.Effect_Speed)))
		if Run12.Bot_Interrupted then return end

		local Targets = Player_Service:GetPlayers()
		table.remove(Targets, table.find(Targets, Local_Player))

		local Current_Target, Current_Distance = nil, math.huge
		for _, Target in ipairs(Targets) do
			local Character = Target.Character
			local TG: Part = Character and Character:FindFirstChild(Run12.Target_Part)
			local Humanoid: Humanoid = Character and Character:FindFirstChildOfClass "Humanoid"
			local Team_Check = (not Run12.Team_Check) or (Target.Team ~= Local_Player.Team)
			local Ignore_Check = not table.find(Run12.Ignore_List, Target)

			if Team_Check and Ignore_Check and Character and TG and TG:IsA "BasePart" and Humanoid and Humanoid.Health > 0 then
                local Root_Screen_Point, Visible = Local_Camera:WorldToViewportPoint(TG.Position)

				if not Visible then
					continue
				end

				if Run12.Wall_Check then
					local Cast = workspace:Raycast(Local_Camera.CFrame.Position, (TG.CFrame.Position - Local_Camera.CFrame.Position), RayParams)
					if not Cast or not Cast.Instance or not Cast.Instance:IsDescendantOf(Character) then
						continue
					end
				end

				local Distance = (
					Vector2.new(Cursor.X, Cursor.Y) - 
					Vector2.new(Root_Screen_Point.X, Root_Screen_Point.Y)
				).Magnitude

				if Distance < Current_Distance then
					if Run12.Circle_Enabled and (Distance >= Run12.Circle_Distance) then
						continue
					end
					Current_Target, Current_Distance = Target, Distance
				end
			end
		end

		if JSwitch ~= Run12.Effect_Enabled then
			JSwitch = Run12.Effect_Enabled
			if not Run12.Effect_Enabled and Default_Highlight and Default_Highlight.Parent then
				local Old_Highlight = Default_Highlight
				local Old_Highlight_Tween = Tween_Service:Create(Old_Highlight, Highlight_Info, {
					OutlineTransparency = 1
				})
				Old_Highlight_Tween:Play()
				Old_Highlight_Tween.Completed:Connect(function()
					Old_Highlight:Destroy()
				end)
			end
		end

		if Current_Target then
			if not Default_Highlight or not Default_Highlight.Parent then
				Default_Target = nil
			end

			if Current_Target ~= Default_Target then
				if Run12.Effect_Enabled then
					if Default_Target and Default_Highlight and Default_Highlight.Parent then
						local Old_Highlight = Default_Highlight
						local Old_Highlight_Tween = Tween_Service:Create(Old_Highlight, Highlight_Info, {
							OutlineTransparency = 1
						})
						Old_Highlight_Tween:Play()
						Old_Highlight_Tween.Completed:Connect(function()
							Old_Highlight:Destroy()
						end)
					end

					Default_Target = Current_Target
					Default_Highlight = Generate_Highlight()
					Default_Highlight.Adornee = Current_Target.Character
					Default_Highlight.OutlineTransparency = 1
					local Highlight_Tween = Tween_Service:Create(Default_Highlight, Highlight_Info, {
						OutlineTransparency = 0
					})
					Highlight_Tween:Play()
				end
			end
		elseif Current_Target ~= Default_Target then
			local Old_Highlight = Default_Highlight
			local Old_Highlight_Tween = Tween_Service:Create(Old_Highlight, Highlight_Info, {
				OutlineTransparency = 1
			})
			Old_Highlight_Tween:Play()
			Old_Highlight_Tween.Completed:Connect(function()
				Old_Highlight:Destroy()
			end)

			Default_Target = Current_Target
		end

		Run12.Target = Run12.Bot_Enabled and Current_Target or nil
	end)
end)();

return Run12
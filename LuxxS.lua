--[[ luxxs :: LocalScript (StarterPlayerScripts) | ключ: best | RightShift - открыть/закрыть ]]
local Players, RS, UIS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService")
local TS, Lighting, WS = game:GetService("TweenService"), game:GetService("Lighting"), game:GetService("Workspace")
local LP = Players.LocalPlayer
local KEY = "best"

local function guiParent()
	local ok, h = pcall(function() return gethui() end)
	if ok and typeof(h) == "Instance" then return h end
	return LP:WaitForChild("PlayerGui")
end
local host = guiParent()
if host:FindFirstChild("luxxs_ui") then host.luxxs_ui:Destroy() end
if WS:FindFirstChild("luxxs_w") then WS.luxxs_w:Destroy() end

------------------------------------------------------------ helpers
local function new(c, p, par)
	local o = Instance.new(c)
	for k, v in pairs(p or {}) do o[k] = v end
	if par then o.Parent = par end
	return o
end
local function corner(o, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, o) end
local function stroke(o, th, col, tr) return new("UIStroke", {Thickness = th, Color = col, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o) end
local EQ, ED = Enum.EasingStyle, Enum.EasingDirection
local function tw(o, t, props, st, dir)
	local x = TS:Create(o, TweenInfo.new(t, st or EQ.Quint, dir or ED.Out), props)
	x:Play()
	return x
end
local conns = {}
local function bind(sig, fn) local c = sig:Connect(fn) conns[#conns + 1] = c return c end

local C = {
	bg = Color3.fromRGB(13, 15, 14), side = Color3.fromRGB(9, 11, 10), row = Color3.fromRGB(24, 27, 26),
	off = Color3.fromRGB(48, 53, 51), txt = Color3.fromRGB(236, 241, 238), sub = Color3.fromRGB(135, 146, 140),
}
local COLORS = {
	Green = {Color3.fromRGB(60, 220, 120)}, Red = {Color3.fromRGB(255, 70, 80)}, Blue = {Color3.fromRGB(70, 140, 255)},
	Purple = {Color3.fromRGB(170, 90, 255)}, Pink = {Color3.fromRGB(255, 100, 190)}, Orange = {Color3.fromRGB(255, 150, 50)},
	Yellow = {Color3.fromRGB(255, 225, 70)}, Cyan = {Color3.fromRGB(60, 230, 235)}, White = {Color3.fromRGB(240, 240, 240)},
	Gold = {Color3.fromRGB(255, 200, 70), Color3.fromRGB(255, 240, 160)},
	Sunset = {Color3.fromRGB(255, 150, 50), Color3.fromRGB(255, 100, 190), Color3.fromRGB(170, 90, 255)},
	Ocean = {Color3.fromRGB(60, 230, 235), Color3.fromRGB(70, 140, 255), Color3.fromRGB(170, 90, 255)},
	Rainbow = {},
}
local LIST_BASIC = {"Green", "Red", "Blue", "Purple", "Pink", "Orange", "Yellow", "Cyan", "White", "Rainbow"}
local LIST_ACCENT = {"Green", "Red", "Blue", "Purple", "Pink", "Orange", "Yellow", "Cyan"}
local LIST_TRAIL = {"Green", "Pink", "Blue", "Gold", "Sunset", "Ocean", "Rainbow"}
local hue = 0
local function colorOf(n) if n == "Rainbow" then return Color3.fromHSV(hue, .7, 1) end return COLORS[n][1] end
local function seqOf(n)
	local list = COLORS[n]
	if n == "Rainbow" then list = {} for i = 0, 6 do list[#list + 1] = Color3.fromHSV((hue + i / 7) % 1, .75, 1) end end
	if #list == 1 then return ColorSequence.new(list[1]) end
	local k = {}
	for i, c in ipairs(list) do k[i] = ColorSequenceKeypoint.new((i - 1) / (#list - 1), c) end
	return ColorSequence.new(k)
end

local cfg = {
	box = false, boxMode = "2D", boxColor = "Green", name = false, nameColor = "White", health = false, dist = false,
	tracer = false, tracerColor = "Cyan", skeleton = false, skelColor = "White", chams = false, chamsColor = "Purple",
	glow = false, glowColor = "Pink", teamCheck = false, crosshair = false, fovChange = false, fovValue = 90,
	aim = false, aimMode = "Smooth", smooth = 30, wall = true, fovShow = false, fov = 150, hold = true, aimPart = "Head",
	fly = false, flySpeed = 60, noclip = false, customFps = false, fpsCap = 240, fpsShow = false,
	trail = false, trailColor = "Rainbow", wings = "Off", transpPct = 0, sizePct = 100, accentName = "Green",
}

local accent = COLORS.Green[1]
local accFns = {}
local function onAccent(f) accFns[#accFns + 1] = f f(accent) end
local function setAccent(c) accent = c for _, f in ipairs(accFns) do f(c) end end
local bgReg = {}
local function bgT(o, base) o.BackgroundTransparency = base bgReg[#bgReg + 1] = {o, base} end
local function applyTransp() for _, r in ipairs(bgReg) do r[1].BackgroundTransparency = math.clamp(r[2] + cfg.transpPct / 100, 0, 1) end end

local sg = new("ScreenGui", {Name = "luxxs_ui", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, host)
local espLayer = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 1}, sg)
local hud = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2}, sg)

local function mkLine(parent, col)
	return new("Frame", {AnchorPoint = Vector2.new(.5, .5), BorderSizePixel = 0, BackgroundColor3 = col or Color3.new(1, 1, 1), Visible = false}, parent)
end
local function line(f, a, b, th)
	local d = b - a
	f.Size = UDim2.fromOffset(d.Magnitude, th or 1.5)
	f.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
	f.Rotation = math.deg(math.atan2(d.Y, d.X))
	f.Visible = true
end

------------------------------------------------------------ ESP
local esp = {}
local R15 = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local R6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
local signs = {}
for x = -1, 1, 2 do for y = -1, 1, 2 do for z = -1, 1, 2 do signs[#signs + 1] = Vector3.new(x, y, z) end end end
local EDGES = {{1,2},{3,4},{5,6},{7,8},{1,3},{2,4},{5,7},{6,8},{1,5},{2,6},{3,7},{4,8}}
local HALF = Vector3.new(2, 2.75, 1)

local function newEsp(p)
	local d = {vis = false}
	d.box = new("Frame", {BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false}, espLayer)
	d.boxS = new("UIStroke", {Thickness = 1.5}, d.box)
	d.edges, d.skel = {}, {}
	for i = 1, 12 do d.edges[i] = mkLine(espLayer) end
	for i = 1, 14 do d.skel[i] = mkLine(espLayer) end
	d.tracer = mkLine(espLayer)
	d.name = new("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextStrokeTransparency = .4, Size = UDim2.fromOffset(220, 16), AnchorPoint = Vector2.new(.5, 1), Visible = false}, espLayer)
	d.hbg = new("Frame", {BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = .35, BorderSizePixel = 0, Visible = false}, espLayer)
	d.hfill = new("Frame", {BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1)}, d.hbg)
	esp[p] = d
end
local function hideEsp(d)
	if not d.vis then return end
	d.vis = false
	d.box.Visible, d.name.Visible, d.hbg.Visible, d.tracer.Visible = false, false, false, false
	for _, e in ipairs(d.edges) do e.Visible = false end
	for _, e in ipairs(d.skel) do e.Visible = false end
end
local function dropHL(d) if d.hl then d.hl:Destroy() d.hl = nil end end
local function sameTeam(p) return p.Team ~= nil and LP.Team ~= nil and p.Team == LP.Team end

local function updateEsp(cam, t)
	local anyOn = cfg.box or cfg.name or cfg.health or cfg.dist or cfg.tracer or cfg.skeleton
	local vp, camPos = cam.ViewportSize, cam.CFrame.Position
	for p, d in pairs(esp) do
		local ch = p.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		if not (hum and root) or hum.Health <= 0 or (cfg.teamCheck and sameTeam(p)) then
			hideEsp(d) dropHL(d)
		else
			-- chams + glow
			if cfg.chams or cfg.glow then
				if not d.hl or d.hl.Parent ~= ch then
					dropHL(d)
					d.hl = new("Highlight", {DepthMode = Enum.HighlightDepthMode.AlwaysOnTop}, ch)
				end
				d.hl.FillColor = colorOf(cfg.chamsColor)
				d.hl.FillTransparency = cfg.chams and .4 or 1
				d.hl.OutlineColor = colorOf(cfg.glowColor)
				d.hl.OutlineTransparency = cfg.glow and (.05 + .3 * (math.sin(t * 3) * .5 + .5)) or 1
			else dropHL(d) end
			if not anyOn then hideEsp(d) else
				local look = root.CFrame.LookVector
				local pos = root.Position
				local cf = CFrame.lookAt(pos, pos + Vector3.new(look.X, 0, look.Z) + Vector3.new(0, 0, 1e-4)) * CFrame.new(0, -.25, 0)
				local pts, minx, miny, maxx, maxy, behind = {}, 1e9, 1e9, -1e9, -1e9, false
				for i, s in ipairs(signs) do
					local v = cam:WorldToViewportPoint(cf * (s * HALF))
					if v.Z <= 0 then behind = true break end
					pts[i] = Vector2.new(v.X, v.Y)
					minx, miny, maxx, maxy = math.min(minx, v.X), math.min(miny, v.Y), math.max(maxx, v.X), math.max(maxy, v.Y)
				end
				if behind then hideEsp(d) else
					d.vis = true
					local cx = (minx + maxx) / 2
					-- box
					local b2 = cfg.box and cfg.boxMode == "2D"
					d.box.Visible = b2
					if b2 then
						d.box.Position = UDim2.fromOffset(minx, miny)
						d.box.Size = UDim2.fromOffset(maxx - minx, maxy - miny)
						d.boxS.Color = colorOf(cfg.boxColor)
					end
					local b3 = cfg.box and cfg.boxMode == "3D"
					for i, e in ipairs(EDGES) do
						local f = d.edges[i]
						if b3 then f.BackgroundColor3 = colorOf(cfg.boxColor) line(f, pts[e[1]], pts[e[2]], 1.5) else f.Visible = false end
					end
					-- name / dist
					if cfg.name or cfg.dist then
						local s = (cfg.name and p.DisplayName or "") .. (cfg.dist and (" [" .. math.floor((pos - camPos).Magnitude) .. "m]") or "")
						d.name.Text = s
						d.name.TextColor3 = colorOf(cfg.nameColor)
						d.name.Position = UDim2.fromOffset(cx, miny - 3)
						d.name.Visible = true
					else d.name.Visible = false end
					-- health
					if cfg.health then
						local pc = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
						d.hbg.Position = UDim2.fromOffset(minx - 7, miny)
						d.hbg.Size = UDim2.fromOffset(4, maxy - miny)
						d.hfill.Size = UDim2.new(1, 0, pc, 0)
						d.hfill.BackgroundColor3 = Color3.fromHSV(pc * .33, .8, 1)
						d.hbg.Visible = true
					else d.hbg.Visible = false end
					-- tracer
					if cfg.tracer then
						d.tracer.BackgroundColor3 = colorOf(cfg.tracerColor)
						line(d.tracer, Vector2.new(vp.X / 2, vp.Y), Vector2.new(cx, maxy), 1.2)
					else d.tracer.Visible = false end
					-- skeleton
					local set = ch:FindFirstChild("UpperTorso") and R15 or R6
					for i = 1, #d.skel do
						local f, pr = d.skel[i], set[i]
						local a, b = pr and ch:FindFirstChild(pr[1]), pr and ch:FindFirstChild(pr[2])
						if cfg.skeleton and a and b then
							local va, vb = cam:WorldToViewportPoint(a.Position), cam:WorldToViewportPoint(b.Position)
							if va.Z > 0 and vb.Z > 0 then
								f.BackgroundColor3 = colorOf(cfg.skelColor)
								line(f, Vector2.new(va.X, va.Y), Vector2.new(vb.X, vb.Y), 1.5)
							else f.Visible = false end
						else f.Visible = false end
					end
				end
			end
		end
	end
end
local function addP(p) if p ~= LP and not esp[p] then newEsp(p) end end
for _, p in ipairs(Players:GetPlayers()) do addP(p) end
bind(Players.PlayerAdded, addP)
bind(Players.PlayerRemoving, function(p)
	local d = esp[p]
	if d then dropHL(d) for _, v in pairs(d) do if typeof(v) == "Instance" then v:Destroy() elseif type(v) == "table" then for _, x in ipairs(v) do x:Destroy() end end end esp[p] = nil end
end)

------------------------------------------------------------ AIM
local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude
rp.RespectCanCollide = true
local function aimPos(ch, n)
	local p
	if n == "Head" then p = ch:FindFirstChild("Head")
	elseif n == "Chest" then p = ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
	elseif n == "Waist" then p = ch:FindFirstChild("LowerTorso") or ch:FindFirstChild("HumanoidRootPart")
	else p = ch:FindFirstChild("LeftLowerLeg") or ch:FindFirstChild("Left Leg") end
	return p and p.Position
end
local function canSee(cam, ch, pos)
	local f = {ch}
	if LP.Character then f[2] = LP.Character end
	rp.FilterDescendantsInstances = f
	local o = cam.CFrame.Position
	return WS:Raycast(o, pos - o, rp) == nil
end
RS:BindToRenderStep("luxxs_aim", Enum.RenderPriority.Camera.Value + 1, function(dt)
	if not cfg.aim then return end
	if cfg.hold and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
	local cam = WS.CurrentCamera
	local c = cam.ViewportSize / 2
	local best, bestPos, bd = nil, nil, cfg.fov
	for _, p in ipairs(Players:GetPlayers()) do
		local ch = p.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if p ~= LP and hum and hum.Health > 0 and not (cfg.teamCheck and sameTeam(p)) then
			local pos = aimPos(ch, cfg.aimPart)
			if pos then
				local v = cam:WorldToViewportPoint(pos)
				if v.Z > 0 then
					local d = (Vector2.new(v.X, v.Y) - c).Magnitude
					if d < bd and (not cfg.wall or canSee(cam, ch, pos)) then best, bestPos, bd = ch, pos, d end
				end
			end
		end
	end
	if bestPos then
		local goal = CFrame.lookAt(cam.CFrame.Position, bestPos)
		local a = 1
		if cfg.aimMode == "Smooth" then a = 1 - (1 - math.clamp(cfg.smooth / 100, .02, 1)) ^ (dt * 60) end
		cam.CFrame = cam.CFrame:Lerp(goal, a)
	end
end)

local fovCircle = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), BackgroundTransparency = 1, Visible = false}, hud)
corner(fovCircle, 999); new("UICorner", {CornerRadius = UDim.new(.5, 0)}, fovCircle)
local fovS = stroke(fovCircle, 1.5, accent, .15)
local xh = new("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(20, 20), Visible = false}, hud)
local xhParts = {}
for _, g in ipairs({{0, 0, 2, 6}, {0, 14, 2, 6}, {0, 0, 6, 2}, {14, 0, 6, 2}}) do
	local f = new("Frame", {BorderSizePixel = 0, Position = UDim2.fromOffset(g[1] == 0 and (g[3] == 2 and 9 or 0) or 14, g[2] == 0 and (g[4] == 2 and 9 or 0) or 14), Size = UDim2.fromOffset(g[3] == 2 and 2 or 6, g[4] == 2 and 2 or 6)}, xh)
	xhParts[#xhParts + 1] = f
end
local xdot = new("Frame", {BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(3, 3)}, xh)
xhParts[#xhParts + 1] = xdot
onAccent(function(c) fovS.Color = c for _, f in ipairs(xhParts) do f.BackgroundColor3 = c end end)

------------------------------------------------------------ PLAYER (fly / noclip)
local fbv, fbg, flying
local function stopFly()
	if fbv then fbv:Destroy() fbv = nil end
	if fbg then fbg:Destroy() fbg = nil end
	if flying then
		local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if h then h.PlatformStand = false end
		flying = false
	end
end
bind(RS.Heartbeat, function()
	local ch = LP.Character
	local root = ch and ch:FindFirstChild("HumanoidRootPart")
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if cfg.fly and root and hum then
		local cam = WS.CurrentCamera
		if not fbv or fbv.Parent ~= root then
			stopFly()
			fbv = new("BodyVelocity", {MaxForce = Vector3.one * 1e9, Velocity = Vector3.zero}, root)
			fbg = new("BodyGyro", {MaxTorque = Vector3.one * 1e9, P = 2e4, D = 800, CFrame = root.CFrame}, root)
		end
		flying = true
		hum.PlatformStand = true
		local c = cam.CFrame
		local fl = Vector3.new(c.LookVector.X, 0, c.LookVector.Z)
		fl = fl.Magnitude > 0 and fl.Unit or Vector3.zero
		local fr = Vector3.new(c.RightVector.X, 0, c.RightVector.Z)
		fr = fr.Magnitude > 0 and fr.Unit or Vector3.zero
		local md = hum.MoveDirection
		local v = c.LookVector * md:Dot(fl) + c.RightVector * md:Dot(fr)
		if UIS:IsKeyDown(Enum.KeyCode.Space) then v += Vector3.yAxis end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then v -= Vector3.yAxis end
		fbv.Velocity = v * cfg.flySpeed
		fbg.CFrame = CFrame.lookAt(root.Position, root.Position + (fl.Magnitude > 0 and fl or root.CFrame.LookVector))
	elseif flying or fbv then stopFly() end
end)
bind(RS.Stepped, function()
	if cfg.noclip and LP.Character then
		for _, v in ipairs(LP.Character:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end
	end
end)

------------------------------------------------------------ TRAIL
local trail, ta0, ta1
local function buildTrail(ch)
	if trail then trail:Destroy() ta0:Destroy() ta1:Destroy() trail = nil end
	local root = ch:WaitForChild("HumanoidRootPart", 5)
	if not root then return end
	ta0 = new("Attachment", {Position = Vector3.new(0, 1.3, 0)}, root)
	ta1 = new("Attachment", {Position = Vector3.new(0, -1.7, 0)}, root)
	trail = new("Trail", {Attachment0 = ta0, Attachment1 = ta1, Lifetime = .75, LightEmission = 1, MinLength = .05, FaceCamera = true, Enabled = cfg.trail,
		Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, .05), NumberSequenceKeypoint.new(1, 1)}), Color = seqOf(cfg.trailColor)}, root)
end
if LP.Character then task.spawn(buildTrail, LP.Character) end
bind(LP.CharacterAdded, function(ch) task.spawn(buildTrail, ch) end)

------------------------------------------------------------ WINGS (3D)
local wFolder = new("Folder", {Name = "luxxs_w"}, WS)
local feathers, wKind = {}, "Off"
local ANG = {Angel = {80, 62, 44, 28, 12, -4}, Demon = {72, 54, 36, 18, 2, -14}}
local LEN = {Angel = {2.6, 3.4, 4.0, 3.8, 3.2, 2.4}, Demon = {3.0, 4.2, 5.0, 4.6, 3.6, 2.6}}
local function buildWings(kind)
	for _, f in ipairs(feathers) do f.p:Destroy() end
	table.clear(feathers)
	wKind = kind
	if kind == "Off" then return end
	for side = -1, 1, 2 do
		for i = 1, 6 do
			local col = kind == "Angel" and (i % 2 == 0 and Color3.fromRGB(255, 238, 175) or Color3.fromRGB(250, 250, 255))
				or (i % 2 == 0 and Color3.fromRGB(95, 8, 24) or Color3.fromRGB(175, 14, 36))
			local len = LEN[kind][i]
			local p = new("Part", {Size = Vector3.new(len, .1, kind == "Angel" and .75 or .45), Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, Massless = true,
				Material = Enum.Material.Neon, Color = col, CastShadow = false}, wFolder)
			feathers[#feathers + 1] = {p = p, side = side, i = i, len = len, base = math.rad(ANG[kind][i])}
		end
	end
end
local function updWings(t)
	if #feathers == 0 then return end
	local ch = LP.Character
	local tor = ch and (ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso"))
	if not tor then return end
	local sweep = wKind == "Angel" and .35 or .6
	local flap = math.sin(t * 3.2) * math.rad(11)
	for _, f in ipairs(feathers) do
		local ang = f.base + flap * (.5 + f.i * .1)
		f.p.CFrame = tor.CFrame * CFrame.new(f.side * .5, .7, .55) * CFrame.Angles(0, -f.side * sweep, 0)
			* CFrame.Angles(0, 0, f.side == 1 and ang or math.pi - ang) * CFrame.new(f.len / 2, 0, 0)
	end
end

------------------------------------------------------------ MAIN UI
local Root = new("CanvasGroup", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(710, 350), BackgroundTransparency = 1, Visible = false, GroupTransparency = 1}, nil)
local wrap = new("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(710, 350), ZIndex = 10}, sg)
Root.Parent = wrap
local rs = new("UIScale", {}, Root)
corner(Root, 14)
local rootStroke = stroke(Root, 1.5, accent, .4)
onAccent(function(c) rootStroke.Color = c end)
local function autoScale()
	local vp = WS.CurrentCamera.ViewportSize
	return math.clamp(math.min((vp.X - 20) / 710, (vp.Y - 20) / 350, 1), .4, 1) * cfg.sizePct / 100
end

local menu = new("Frame", {Size = UDim2.fromOffset(480, 350), BorderSizePixel = 0, BackgroundColor3 = C.bg}, Root) bgT(menu, .03)
local pvPanel = new("Frame", {Position = UDim2.fromOffset(480, 0), Size = UDim2.fromOffset(230, 350), BackgroundColor3 = Color3.fromRGB(15, 18, 17), BorderSizePixel = 0, ClipsDescendants = true}, Root) bgT(pvPanel, .06)
local divider = new("Frame", {Position = UDim2.fromOffset(480, 14), Size = UDim2.fromOffset(1, 322), BorderSizePixel = 0, BackgroundTransparency = .6}, Root)
onAccent(function(c) divider.BackgroundColor3 = c end)
local side = new("Frame", {Size = UDim2.fromOffset(120, 350), BackgroundColor3 = C.side, BorderSizePixel = 0}, menu) bgT(side, .05)
local content = new("Frame", {Position = UDim2.fromOffset(120, 0), Size = UDim2.fromOffset(360, 350), BackgroundTransparency = 1}, menu)

-- header
local hdr = new("Frame", {Size = UDim2.fromOffset(360, 44), BackgroundTransparency = 1}, content)
local title = new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0), Size = UDim2.fromOffset(200, 44), Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = C.txt, TextXAlignment = Enum.TextXAlignment.Left, Text = ""}, hdr)
local closeB = new("TextButton", {Text = "×", Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = C.sub, BackgroundTransparency = 1, Position = UDim2.fromOffset(318, 6), Size = UDim2.fromOffset(32, 32), AutoButtonColor = false}, hdr)
local hline = new("Frame", {Position = UDim2.fromOffset(14, 44), Size = UDim2.fromOffset(332, 2), BorderSizePixel = 0, BackgroundColor3 = accent}, content)
corner(hline, 1)
local hg = new("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})}, hline)
onAccent(function(c) hline.BackgroundColor3 = c end)

-- sidebar
local logo = new("TextLabel", {Text = "Lx", Font = Enum.Font.GothamBlack, TextSize = 16, TextColor3 = C.side, BackgroundColor3 = accent, Position = UDim2.fromOffset(14, 12), Size = UDim2.fromOffset(34, 34)}, side)
corner(logo, 10)
new("TextLabel", {Text = "menu", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.sub, BackgroundTransparency = 1, Position = UDim2.fromOffset(54, 12), Size = UDim2.fromOffset(60, 34), TextXAlignment = Enum.TextXAlignment.Left}, side)
onAccent(function(c) logo.BackgroundColor3 = c end)
local ind = new("Frame", {Size = UDim2.fromOffset(3, 20), BorderSizePixel = 0, BackgroundColor3 = accent, Position = UDim2.fromOffset(0, 70)}, side)
corner(ind, 2)
onAccent(function(c) ind.BackgroundColor3 = c end)
local brand = new("TextLabel", {Text = "luxxs", Font = Enum.Font.GothamBlack, TextSize = 22, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 14, 1, -12), Size = UDim2.fromOffset(100, 26), TextXAlignment = Enum.TextXAlignment.Left}, side)
local brandG = new("UIGradient", {}, brand)
onAccent(function(c) brandG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c), ColorSequenceKeypoint.new(.5, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, c)}) end)

local pages, tabBtns, tabY, cur = {}, {}, {}, nil
local ord = {}
local function nextOrd(pg) ord[pg] = (ord[pg] or 0) + 1 return ord[pg] end
local function selectTab(name)
	if cur == name then return end
	cur = name
	title.Text = name
	for n, b in pairs(tabBtns) do tw(b, .2, {TextColor3 = n == name and C.txt or C.sub}) end
	tw(ind, .4, {Position = UDim2.fromOffset(0, tabY[name] + 7)}, EQ.Back)
	for n, pg in pairs(pages) do
		if n == name then
			pg.Visible = true pg.GroupTransparency = 1 pg.Position = UDim2.fromOffset(0, 62)
			tw(pg, .35, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 52)})
		else pg.Visible = false end
	end
end
local function newPage(name, y)
	local g = new("CanvasGroup", {Position = UDim2.fromOffset(0, 52), Size = UDim2.fromOffset(360, 298), BackgroundTransparency = 1, Visible = false}, content)
	local sf = new("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarImageColor3 = accent}, g)
	onAccent(function(c) sf.ScrollBarImageColor3 = c end)
	new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, sf)
	new("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 12)}, sf)
	pages[name] = g
	tabY[name] = y
	local b = new("TextButton", {Text = "   " .. name, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.sub, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, y), Size = UDim2.fromOffset(120, 34), TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false}, side)
	new("UIPadding", {PaddingLeft = UDim.new(0, 8)}, b)
	tabBtns[name] = b
	b.MouseButton1Click:Connect(function() selectTab(name) end)
	return sf
end

-- components
local function row(pg, h)
	local r = new("Frame", {Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = C.row, BorderSizePixel = 0, LayoutOrder = nextOrd(pg)}, pg)
	corner(r, 8)
	return r
end
local function rlabel(r, t, y)
	return new("TextLabel", {Text = t, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = C.txt, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, y or 0), Size = UDim2.new(.6, 0, 0, y and 20 or 34), TextXAlignment = Enum.TextXAlignment.Left}, r)
end
local function section(pg, t)
	local l = new("TextLabel", {Text = string.upper(t), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = accent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrd(pg)}, pg)
	onAccent(function(c) l.TextColor3 = c end)
end
local function toggle(pg, text, key, cb)
	local r = row(pg, 34)
	rlabel(r, text)
	local sw = new("TextButton", {Text = "", AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -12, .5, 0), Size = UDim2.fromOffset(38, 20), BackgroundColor3 = C.off, AutoButtonColor = false}, r)
	corner(sw, 10)
	local kn = new("Frame", {Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0}, sw)
	corner(kn, 7)
	local function refresh()
		local on = cfg[key]
		tw(sw, .2, {BackgroundColor3 = on and accent or C.off})
		tw(kn, .25, {Position = on and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)}, EQ.Back)
	end
	sw.MouseButton1Click:Connect(function() cfg[key] = not cfg[key] refresh() if cb then cb(cfg[key]) end end)
	onAccent(refresh)
end
local function slider(pg, text, key, mn, mx, step, fmt, cb)
	local r = row(pg, 46)
	rlabel(r, text, 4)
	local val = new("TextLabel", {Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.sub, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 4), Size = UDim2.fromOffset(80, 20), TextXAlignment = Enum.TextXAlignment.Right, Text = ""}, r)
	local bar = new("Frame", {Position = UDim2.new(0, 12, 1, -14), Size = UDim2.new(1, -24, 0, 5), BackgroundColor3 = C.off, BorderSizePixel = 0}, r)
	corner(bar, 3)
	local fill = new("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = accent, BorderSizePixel = 0}, bar)
	corner(fill, 3)
	local kn = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(1, .5), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0}, fill)
	corner(kn, 6)
	onAccent(function(c) fill.BackgroundColor3 = c end)
	local hit = new("TextButton", {Text = "", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, .5), Position = UDim2.fromScale(0, .5), Size = UDim2.new(1, 0, 0, 24)}, bar)
	local function set(v, fire)
		v = math.clamp(math.floor(v / step + .5) * step, mn, mx)
		cfg[key] = v
		fill.Size = UDim2.fromScale((v - mn) / (mx - mn), 1)
		val.Text = fmt and fmt(v) or tostring(v)
		if fire and cb then cb(v) end
	end
	local dragging = false
	local function fromX(x) set(mn + (mx - mn) * math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1), true) end
	hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true fromX(i.Position.X) end
	end)
	bind(UIS.InputChanged, function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then fromX(i.Position.X) end
	end)
	bind(UIS.InputEnded, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
	set(cfg[key], false)
end
local function segment(pg, text, key, opts, cb)
	local r = row(pg, 34)
	rlabel(r, text)
	local box = new("Frame", {AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -10, .5, 0), Size = UDim2.fromOffset(#opts * 58, 22), BackgroundTransparency = 1}, r)
	new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, box)
	local btns = {}
	local function refresh()
		for o, b in pairs(btns) do
			local on = cfg[key] == o
			tw(b, .2, {BackgroundColor3 = on and accent or C.off, TextColor3 = on and C.side or C.sub})
		end
	end
	for i, o in ipairs(opts) do
		local b = new("TextButton", {Text = o, Font = Enum.Font.GothamBold, TextSize = 11, Size = UDim2.fromOffset(54, 22), BackgroundColor3 = C.off, TextColor3 = C.sub, AutoButtonColor = false, LayoutOrder = i}, box)
		corner(b, 6)
		btns[o] = b
		b.MouseButton1Click:Connect(function() cfg[key] = o refresh() if cb then cb(o) end end)
	end
	onAccent(refresh)
end
local function colorRow(pg, text, key, list, cb)
	local r = row(pg, 54)
	rlabel(r, text, 4)
	local box = new("Frame", {Position = UDim2.fromOffset(12, 28), Size = UDim2.new(1, -24, 0, 20), BackgroundTransparency = 1}, r)
	new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, box)
	local sts = {}
	local function refresh() for n, s in pairs(sts) do tw(s, .2, {Thickness = cfg[key] == n and 2 or 0}) end end
	for i, n in ipairs(list) do
		local b = new("TextButton", {Text = "", Size = UDim2.fromOffset(20, 20), BackgroundColor3 = COLORS[n][1] or Color3.new(1, 1, 1), AutoButtonColor = false, LayoutOrder = i}, box)
		corner(b, 10)
		if #COLORS[n] ~= 1 then new("UIGradient", {Color = seqOf(n), Rotation = 45}, b) end
		sts[n] = stroke(b, 0, Color3.new(1, 1, 1))
		b.MouseButton1Click:Connect(function() cfg[key] = n refresh() if cb then cb(n) end end)
	end
	refresh()
end
local function button(pg, text, cb)
	local r = row(pg, 34)
	local b = new("TextButton", {Text = text, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.side, BackgroundColor3 = accent, Size = UDim2.new(1, -20, 0, 24), Position = UDim2.fromOffset(10, 5), AutoButtonColor = false}, r)
	corner(b, 7)
	onAccent(function(c) b.BackgroundColor3 = c end)
	b.MouseButton1Click:Connect(cb)
end

------------------------------------------------------------ PAGES
local pv_set -- заполняется ниже
do
	local pg = newPage("Visuals", 70)
	section(pg, "ESP")
	toggle(pg, "Box", "box")
	segment(pg, "Box type", "boxMode", {"2D", "3D"})
	colorRow(pg, "Box color", "boxColor", LIST_BASIC)
	toggle(pg, "Name", "name")
	colorRow(pg, "Name color", "nameColor", LIST_BASIC)
	toggle(pg, "Health bar", "health")
	toggle(pg, "Distance", "dist")
	toggle(pg, "Tracers", "tracer")
	colorRow(pg, "Tracer color", "tracerColor", LIST_BASIC)
	toggle(pg, "Skeleton", "skeleton")
	colorRow(pg, "Skeleton color", "skelColor", LIST_BASIC)
	toggle(pg, "Chams", "chams")
	colorRow(pg, "Chams color", "chamsColor", LIST_BASIC)
	toggle(pg, "Glow", "glow")
	colorRow(pg, "Glow color", "glowColor", LIST_BASIC)
	toggle(pg, "Team check", "teamCheck")
	section(pg, "HUD")
	toggle(pg, "Custom crosshair", "crosshair")
	toggle(pg, "FOV changer", "fovChange")
	slider(pg, "Camera FOV", "fovValue", 50, 120, 1)
end
local aimInfo
do
	local pg = newPage("Aim", 108)
	section(pg, "Aimbot")
	toggle(pg, "Aimbot", "aim")
	segment(pg, "Mode", "aimMode", {"Smooth", "Snap"})
	slider(pg, "Smoothness", "smooth", 1, 100, 1)
	toggle(pg, "Wall check", "wall")
	toggle(pg, "Hold right mouse", "hold")
	section(pg, "FOV")
	toggle(pg, "Show FOV circle", "fovShow")
	slider(pg, "FOV radius", "fov", 30, 400, 5)
	local r = row(pg, 34)
	aimInfo = rlabel(r, "Target: Head  (pick on preview →)")
	aimInfo.Size = UDim2.new(1, -20, 0, 34)
	aimInfo.TextColor3 = C.sub
end
do
	local pg = newPage("Player", 146)
	section(pg, "Movement")
	toggle(pg, "Fly", "fly")
	slider(pg, "Fly speed", "flySpeed", 10, 250, 5)
	toggle(pg, "Noclip", "noclip")
	section(pg, "Performance")
	local function applyCap() pcall(function() setfpscap(cfg.customFps and cfg.fpsCap or 60) end) end
	toggle(pg, "FPS counter", "fpsShow")
	toggle(pg, "Custom FPS", "customFps", applyCap)
	slider(pg, "FPS cap", "fpsCap", 30, 999, 1, nil, function() if cfg.customFps then applyCap() end end)
end
do
	local pg = newPage("Extra", 184)
	section(pg, "Trail")
	toggle(pg, "Trail", "trail")
	colorRow(pg, "Trail color", "trailColor", LIST_TRAIL)
	section(pg, "Wings")
	segment(pg, "Wings", "wings", {"Off", "Angel", "Demon"}, buildWings)
end
local unload
do
	local pg = newPage("Settings", 222)
	section(pg, "Menu")
	slider(pg, "Transparency", "transpPct", 0, 70, 1, function(v) return v .. "%" end, applyTransp)
	slider(pg, "Size", "sizePct", 60, 130, 5, function(v) return v .. "%" end, function() rs.Scale = autoScale() end)
	colorRow(pg, "Menu color", "accentName", LIST_ACCENT, function(n) setAccent(COLORS[n][1]) end)
	section(pg, "Other")
	button(pg, "Unload luxxs", function() unload() end)
end

------------------------------------------------------------ PREVIEW (2D, справа от меню)
local pvT = new("TextLabel", {Text = "PREVIEW", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = accent, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 10), Size = UDim2.fromOffset(100, 16), TextXAlignment = Enum.TextXAlignment.Left}, pvPanel)
onAccent(function(c) pvT.TextColor3 = c end)
local stage = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset(115, 178), Size = UDim2.fromOffset(160, 250), BackgroundTransparency = 1}, pvPanel)
local floor = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset(80, 230), Size = UDim2.fromOffset(120, 12), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = .55, BorderSizePixel = 0, ZIndex = 1}, stage)
corner(floor, 6)

-- trail + wings (позади манекена)
local pvTrail = new("Frame", {Position = UDim2.fromOffset(-52, 184), Size = UDim2.fromOffset(100, 14), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 1, Visible = false}, stage)
corner(pvTrail, 7)
local pvTrailG = new("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, .1)})}, pvTrail)
local pvFeath = {}
for side = 1, 2 do for i = 1, 6 do
	local f = mkLine(stage) f.ZIndex = 2 corner(f, 6)
	pvFeath[#pvFeath + 1] = {f = f, side = side == 1 and 1 or -1, i = i}
end end

-- манекен
local GRAY = Color3.fromRGB(138, 141, 146)
local pvParts = {}
local function part(x, y, w, h, r)
	local f = new("Frame", {Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundColor3 = GRAY, BorderSizePixel = 0, ZIndex = 3}, stage)
	corner(f, r)
	local s = new("UIStroke", {Thickness = 0, Transparency = .1}, f)
	pvParts[#pvParts + 1] = {f = f, s = s}
end
part(60, 18, 40, 40, 20) part(52, 62, 56, 72, 12) part(32, 64, 16, 68, 8) part(112, 64, 16, 68, 8) part(54, 138, 24, 90, 8) part(82, 138, 24, 90, 8)

-- ESP-превью
local pvBox = new("Frame", {Position = UDim2.fromOffset(24, 10), Size = UDim2.fromOffset(112, 222), BackgroundTransparency = 1, ZIndex = 4, Visible = false}, stage)
local pvBoxS = new("UIStroke", {Thickness = 1.5}, pvBox)
local FR, BK = {Vector2.new(22, 22), Vector2.new(118, 22), Vector2.new(118, 234), Vector2.new(22, 234)}, {Vector2.new(38, 8), Vector2.new(134, 8), Vector2.new(134, 220), Vector2.new(38, 220)}
local pv3 = {}
for i = 1, 12 do pv3[i] = mkLine(stage) pv3[i].ZIndex = 4 end
local pvName = new("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12, TextStrokeTransparency = .4, AnchorPoint = Vector2.new(.5, 1), Position = UDim2.fromOffset(80, 4), Size = UDim2.fromOffset(160, 14), ZIndex = 5, Visible = false}, stage)
local pvHbg = new("Frame", {Position = UDim2.fromOffset(12, 22), Size = UDim2.fromOffset(4, 212), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = .35, BorderSizePixel = 0, ZIndex = 4, Visible = false}, stage)
local pvHf = new("Frame", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.fromScale(1, .7), BackgroundColor3 = Color3.fromHSV(.23, .8, 1), BorderSizePixel = 0}, pvHbg)
local pvTracer = mkLine(stage) pvTracer.ZIndex = 4
local J = {head = Vector2.new(80, 38), neck = Vector2.new(80, 62), pel = Vector2.new(80, 134), shL = Vector2.new(56, 70), shR = Vector2.new(104, 70), elL = Vector2.new(40, 100), elR = Vector2.new(120, 100), hdL = Vector2.new(40, 128), hdR = Vector2.new(120, 128), hpL = Vector2.new(66, 138), hpR = Vector2.new(94, 138), knL = Vector2.new(66, 184), knR = Vector2.new(94, 184), ftL = Vector2.new(66, 226), ftR = Vector2.new(94, 226)}
local SK = {{"head","neck"},{"neck","pel"},{"neck","shL"},{"neck","shR"},{"shL","elL"},{"elL","hdL"},{"shR","elR"},{"elR","hdR"},{"pel","hpL"},{"pel","hpR"},{"hpL","knL"},{"knL","ftL"},{"hpR","knR"},{"knR","ftR"}}
local pvSk = {}
for i = 1, #SK do pvSk[i] = mkLine(stage) pvSk[i].ZIndex = 4 end

-- зоны прицеливания + зелёная точка
local ZONES = {
	Head = {x = 56, y = 14, w = 48, h = 48, pt = Vector2.new(80, 38)}, Chest = {x = 52, y = 64, w = 56, h = 38, pt = Vector2.new(80, 82)},
	Waist = {x = 52, y = 102, w = 56, h = 32, pt = Vector2.new(80, 118)}, Legs = {x = 54, y = 136, w = 52, h = 92, pt = Vector2.new(80, 182)},
}
local zoneF = {}
local dot = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset(80, 38), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = accent, BorderSizePixel = 0, ZIndex = 8}, stage)
corner(dot, 5)
local ring = new("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 1, ZIndex = 8}, dot)
corner(ring, 20)
local ringS = stroke(ring, 1.5, accent, 0)
TS:Create(ring, TweenInfo.new(1.2, EQ.Sine, ED.Out, -1), {Size = UDim2.fromOffset(32, 32)}):Play()
TS:Create(ringS, TweenInfo.new(1.2, EQ.Sine, ED.Out, -1), {Transparency = 1}):Play()
onAccent(function(c) dot.BackgroundColor3 = c ringS.Color = c end)
local function pickZone(n)
	cfg.aimPart = n
	tw(dot, .55, {Position = UDim2.fromOffset(ZONES[n].pt.X, ZONES[n].pt.Y)}, EQ.Quint)
	for k, f in pairs(zoneF) do tw(f, .25, {BackgroundTransparency = k == n and .8 or 1}) end
	if aimInfo then aimInfo.Text = "Target: " .. n .. "  (pick on preview →)" end
	pvAim.Text = "AIM TARGET: " .. string.upper(n)
end
local pvAim = new("TextLabel", {Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.sub, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 322), Size = UDim2.fromOffset(230, 16), Text = "", ZIndex = 5}, pvPanel)
for n, z in pairs(ZONES) do
	local b = new("TextButton", {Text = "", Position = UDim2.fromOffset(z.x, z.y), Size = UDim2.fromOffset(z.w, z.h), BackgroundColor3 = accent, BackgroundTransparency = 1, AutoButtonColor = false, ZIndex = 7}, stage)
	corner(b, n == "Head" and 24 or 8)
	zoneF[n] = b
	onAccent(function(c) b.BackgroundColor3 = c end)
	b.MouseEnter:Connect(function() if cfg.aimPart ~= n then tw(b, .15, {BackgroundTransparency = .9}) end end)
	b.MouseLeave:Connect(function() if cfg.aimPart ~= n then tw(b, .15, {BackgroundTransparency = 1}) end end)
	b.MouseButton1Click:Connect(function() pickZone(n) end)
end
pickZone("Head")

local function updPreview(t)
	local chc, glc = colorOf(cfg.chamsColor), colorOf(cfg.glowColor)
	local col = cfg.chams and GRAY:Lerp(chc, .7) or GRAY
	local th = cfg.glow and (1.5 + 1.3 * (math.sin(t * 3) * .5 + .5)) or 0
	for _, p in ipairs(pvParts) do p.f.BackgroundColor3 = col p.s.Color = glc p.s.Thickness = th end
	local bc = colorOf(cfg.boxColor)
	pvBox.Visible = cfg.box and cfg.boxMode == "2D"
	pvBoxS.Color = bc
	local b3 = cfg.box and cfg.boxMode == "3D"
	for i = 1, 4 do
		local j = i % 4 + 1
		for k, pair in ipairs({{FR[i], FR[j]}, {BK[i], BK[j]}, {FR[i], BK[i]}}) do
			local f = pv3[(k - 1) * 4 + i]
			if b3 then f.BackgroundColor3 = bc line(f, pair[1], pair[2], 1.5) else f.Visible = false end
		end
	end
	pvName.Visible = cfg.name or cfg.dist
	pvName.Text = (cfg.name and "Player" or "") .. (cfg.dist and " [42m]" or "")
	pvName.TextColor3 = colorOf(cfg.nameColor)
	pvHbg.Visible = cfg.health
	if cfg.tracer then pvTracer.BackgroundColor3 = colorOf(cfg.tracerColor) line(pvTracer, Vector2.new(120, 300), Vector2.new(80, 236), 1.5) else pvTracer.Visible = false end
	local sc = colorOf(cfg.skelColor)
	for i, s in ipairs(SK) do
		local f = pvSk[i]
		if cfg.skeleton then f.BackgroundColor3 = sc line(f, J[s[1]], J[s[2]], 1.5) else f.Visible = false end
	end
	pvTrail.Visible = cfg.trail
	if cfg.trail then pvTrailG.Color = seqOf(cfg.trailColor) end
	local ang, len = ANG[cfg.wings], LEN[cfg.wings]
	local pivot = Vector2.new(80, 78)
	for _, fd in ipairs(pvFeath) do
		if ang then
			local a = math.rad(ang[fd.i] + math.sin(t * 3.2) * (4 + fd.i * 1.6))
			local l = len[fd.i] * 17
			local dir = Vector2.new(fd.side * math.cos(a), -math.sin(a))
			fd.f.BackgroundColor3 = cfg.wings == "Angel" and (fd.i % 2 == 0 and Color3.fromRGB(255, 238, 175) or Color3.fromRGB(250, 250, 255)) or (fd.i % 2 == 0 and Color3.fromRGB(95, 8, 24) or Color3.fromRGB(175, 14, 36))
			line(fd.f, pivot + dir * 6, pivot + dir * l, cfg.wings == "Angel" and 10 or 7)
		else fd.f.Visible = false end
	end
end

------------------------------------------------------------ OPEN / CLOSE + ICON
local open, unlocked = false, false
local function setOpen(v)
	if v == open or not unlocked then return end
	open = v
	local S = autoScale()
	if v then
		Root.Visible = true rs.Scale = S * .85 Root.GroupTransparency = 1
		tw(rs, .5, {Scale = S}, EQ.Back)
		tw(Root, .3, {GroupTransparency = 0})
	else
		tw(rs, .3, {Scale = S * .88}, EQ.Quint, ED.In)
		tw(Root, .25, {GroupTransparency = 1}).Completed:Connect(function() if not open then Root.Visible = false end end)
	end
end
closeB.MouseButton1Click:Connect(function() setOpen(false) end)
closeB.MouseEnter:Connect(function() tw(closeB, .15, {TextColor3 = Color3.fromRGB(255, 90, 90)}) end)
closeB.MouseLeave:Connect(function() tw(closeB, .15, {TextColor3 = C.sub}) end)
bind(UIS.InputBegan, function(i, gp)
	if not gp and i.KeyCode == Enum.KeyCode.RightShift then setOpen(not open) end
end)

local function makeDrag(handle, target, onClick)
	local dragging, moved, start, orig = false, false, nil, nil
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, moved, start, orig = true, false, i.Position, target.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					dragging = false
					if not moved and onClick then onClick() end
				end
			end)
		end
	end)
	bind(UIS.InputChanged, function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - start
			if d.Magnitude > 5 then moved = true end
			if moved then target.Position = UDim2.new(orig.X.Scale, orig.X.Offset + d.X, orig.Y.Scale, orig.Y.Offset + d.Y) end
		end
	end)
end
makeDrag(hdr, wrap)

local icon = new("TextButton", {Text = "Lx", Font = Enum.Font.GothamBlack, TextSize = 19, TextColor3 = accent, BackgroundColor3 = Color3.fromRGB(13, 16, 15), Position = UDim2.fromOffset(24, 140), Size = UDim2.fromOffset(50, 50), AutoButtonColor = false, Visible = false, ZIndex = 20}, sg)
corner(icon, 25)
local icS = stroke(icon, 2.5, Color3.new(1, 1, 1))
local icG = new("UIGradient", {}, icS)
local icScale = new("UIScale", {Scale = 0}, icon)
onAccent(function(c)
	icon.TextColor3 = c
	icG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c), ColorSequenceKeypoint.new(.5, Color3.fromRGB(20, 24, 22)), ColorSequenceKeypoint.new(1, c)})
end)
makeDrag(icon, icon, function()
	tw(icScale, .12, {Scale = .88}).Completed:Connect(function() tw(icScale, .35, {Scale = 1}, EQ.Back) end)
	setOpen(not open)
end)
icon.MouseEnter:Connect(function() tw(icScale, .2, {Scale = 1.1}, EQ.Back) end)
icon.MouseLeave:Connect(function() tw(icScale, .2, {Scale = 1}) end)

-- FPS counter
local fpsBox = new("Frame", {Position = UDim2.new(1, -150, 0, 12), Size = UDim2.fromOffset(138, 28), BackgroundColor3 = Color3.fromRGB(13, 16, 15), BackgroundTransparency = .15, Visible = false, ZIndex = 15}, sg)
corner(fpsBox, 8)
local fpsS = stroke(fpsBox, 1.2, accent, .4)
local fpsL = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.txt, Text = "FPS 60"}, fpsBox)
onAccent(function(c) fpsS.Color = c end)
makeDrag(fpsBox, fpsBox)

------------------------------------------------------------ RENDER LOOP
local fAcc, fCnt, fpsNow, tickAcc, spin = 0, 0, 60, 0, 0
local fovTouched = false
bind(RS.RenderStepped, function(dt)
	local t = os.clock()
	hue = (t * .25) % 1
	local cam = WS.CurrentCamera
	-- fps
	fAcc += dt fCnt += 1
	if fAcc >= .4 then fpsNow = math.floor(fCnt / fAcc + .5) fAcc, fCnt = 0, 0 end
	fpsBox.Visible = cfg.fpsShow
	if cfg.fpsShow then fpsL.Text = "FPS " .. fpsNow .. (cfg.customFps and (" / " .. cfg.fpsCap) or "") end
	-- вращение градиентов
	spin = (spin + dt * 120) % 360
	icG.Rotation = spin
	brandG.Offset = Vector2.new(math.sin(t * 1.5) * .5, 0)
	-- esp
	updateEsp(cam, t)
	-- hud
	fovCircle.Visible = cfg.fovShow
	if cfg.fovShow then fovCircle.Size = UDim2.fromOffset(cfg.fov * 2, cfg.fov * 2) end
	xh.Visible = cfg.crosshair
	if cfg.fovChange then cam.FieldOfView = cfg.fovValue fovTouched = true elseif fovTouched then cam.FieldOfView = 70 fovTouched = false end
	-- trail
	tickAcc += dt
	if trail then
		trail.Enabled = cfg.trail
		if tickAcc > .08 then trail.Color = seqOf(cfg.trailColor) end
	end
	if tickAcc > .08 then tickAcc = 0 end
	updWings(t)
	if open then updPreview(t) end
end)

------------------------------------------------------------ UNLOAD
function unload()
	for _, c in ipairs(conns) do c:Disconnect() end
	pcall(function() RS:UnbindFromRenderStep("luxxs_aim") end)
	cfg.fly = false stopFly()
	for _, d in pairs(esp) do dropHL(d) end
	if trail then trail:Destroy() ta0:Destroy() ta1:Destroy() end
	wFolder:Destroy()
	if fovTouched then WS.CurrentCamera.FieldOfView = 70 end
	sg:Destroy()
end

------------------------------------------------------------ KEY SCREEN
local function startMenu()
	unlocked = true
	icon.Visible = true
	tw(icScale, .6, {Scale = 1}, EQ.Back)
	selectTab("Visuals")
	task.wait(.25)
	setOpen(true)
end

local blur = new("BlurEffect", {Size = 0}, Lighting)
tw(blur, .7, {Size = 18})
local scrim = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 40, Active = true, BorderSizePixel = 0}, sg)
tw(scrim, .6, {BackgroundTransparency = .45})
local card = new("CanvasGroup", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(300, 190), BackgroundColor3 = C.bg, GroupTransparency = 1, ZIndex = 41}, sg)
corner(card, 16)
local cardS = stroke(card, 1.5, accent, .35)
onAccent(function(c) cardS.Color = c end)
local cs = new("UIScale", {Scale = .9}, card)
tw(card, .5, {GroupTransparency = 0}) tw(cs, .6, {Scale = 1}, EQ.Back)
local kt = new("TextLabel", {Text = "luxxs", Font = Enum.Font.GothamBlack, TextSize = 34, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 40)}, card)
local ktG = new("UIGradient", {}, kt)
onAccent(function(c) ktG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c), ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))}) end)
new("TextLabel", {Text = "enter your key to continue", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.sub, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 0, 16)}, card)
local kb = new("TextBox", {Text = "", PlaceholderText = "key", PlaceholderColor3 = C.sub, TextColor3 = C.txt, Font = Enum.Font.GothamMedium, TextSize = 14, BackgroundColor3 = C.row, Position = UDim2.fromOffset(25, 88), Size = UDim2.fromOffset(250, 38), ClearTextOnFocus = false}, card)
corner(kb, 9)
local kbS = stroke(kb, 1.2, C.off)
local ub = new("TextButton", {Text = "Unlock", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.side, BackgroundColor3 = accent, Position = UDim2.fromOffset(25, 136), Size = UDim2.fromOffset(250, 38), AutoButtonColor = false}, card)
corner(ub, 9)
onAccent(function(c) ub.BackgroundColor3 = c end)

local busy = false
local function success()
	busy = true
	tw(kbS, .2, {Color = accent}) ub.Text = "Unlocked"
	task.wait(.35)
	tw(card, .35, {GroupTransparency = 1}, EQ.Quint, ED.In) tw(cs, .35, {Scale = .85}, EQ.Quint, ED.In)
	task.wait(.4)
	card:Destroy()
	-- анимация luxxs
	local word, wd = {"l", "u", "x", "x", "s"}, {20, 48, 46, 46, 42}
	local total = 0 for _, w in ipairs(wd) do total += w + 4 end
	local holder = new("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .48), Size = UDim2.fromOffset(total, 90), ZIndex = 45}, sg)
	local lets, px = {}, 0
	for i, ch in ipairs(word) do
		local l = new("TextLabel", {Text = ch, Font = Enum.Font.GothamBlack, TextSize = 78, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, TextTransparency = 1,
			Size = UDim2.fromOffset(wd[i] + 6, 90), Position = UDim2.fromOffset(px, 46), Rotation = math.random(-16, 16), TextStrokeTransparency = 1}, holder)
		new("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))}), Rotation = 90}, l)
		lets[i] = {l = l, x = px}
		task.delay((i - 1) * .09, function() tw(l, .55, {TextTransparency = 0, Position = UDim2.fromOffset(px, 0), Rotation = 0}, EQ.Back) end)
		px += wd[i] + 4
	end
	task.wait(.9)
	local bar = new("Frame", {AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, .48, 56), Size = UDim2.fromOffset(0, 3), BackgroundColor3 = accent, BorderSizePixel = 0, ZIndex = 45}, sg)
	corner(bar, 2)
	tw(bar, .7, {Size = UDim2.fromOffset(total + 50, 3)})
	local wl = new("TextLabel", {Text = "welcome", Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.txt, TextTransparency = 1, BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, .48, 70), Size = UDim2.fromOffset(200, 20), ZIndex = 45}, sg)
	task.wait(.25)
	tw(wl, .5, {TextTransparency = 0})
	task.wait(.9)
	for i, d in ipairs(lets) do
		tw(d.l, .5, {TextTransparency = 1, Position = UDim2.fromOffset(d.x + (i - 3) * 26, -40), Rotation = (i - 3) * 14}, EQ.Quint, ED.In)
	end
	tw(bar, .5, {Size = UDim2.fromOffset(0, 3)}, EQ.Quint, ED.In) tw(wl, .4, {TextTransparency = 1})
	task.wait(.35)
	tw(scrim, .5, {BackgroundTransparency = 1}) tw(blur, .5, {Size = 0})
	task.wait(.5)
	holder:Destroy() bar:Destroy() wl:Destroy() scrim:Destroy() blur:Destroy()
	startMenu()
end
local function submit()
	if busy then return end
	if kb.Text:lower():gsub("%s", "") == KEY then
		success()
	else
		tw(kbS, .15, {Color = Color3.fromRGB(255, 70, 80)})
		for i = 1, 6 do tw(card, .04, {Position = UDim2.new(.5, (i % 2 == 0 and 9 or -9) * (1 - i / 7), .5, 0)}) task.wait(.045) end
		tw(card, .08, {Position = UDim2.fromScale(.5, .5)})
		task.wait(.5)
		tw(kbS, .3, {Color = C.off})
	end
end
ub.MouseButton1Click:Connect(submit)
kb.FocusLost:Connect(function(enter) if enter then submit() end end)

applyTransp()

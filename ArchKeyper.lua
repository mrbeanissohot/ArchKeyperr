local CONFIG = [==[
{
  "replacement_rules": [
    {
      "name": "Profile 1",
      "replace_ids": [13188892761],
      "mode": "local",
      "enabled": true,
      "url": "https://github.com/mrbeanissohot/ArchKeyperr/blob/main/arch_keyper_v4.mesh"
    },
    {
      "name": "Profile 2",
      "replace_ids": [
        14778413014,
        13188893115,
        13188893017,
        14774727092,
        13188892855,
        13188893310,
        14002915797,
        13188892651,
        13188892532
      ],
      "mode": "id",
      "enabled": true
    },
    { "name": "Icon 1", "replace_ids": [17160799574], "mode": "local", "enabled": true, "url": "https://github.com/mrbeanissohot/ArchKeyperr/blob/main/ChatGPT%20Image%20Oct%2013%2C%202026%2C%2007_58_42%20AM.png" },
    { "name": "Icon 2", "replace_ids": [13197583098], "mode": "local", "enabled": true, "url": "https://github.com/mrbeanissohot/ArchKeyperr/blob/main/ChatGPT%20Image%20Oct%2013%2C%202026%2C%2007_58_42%20AM.png" },
    { "name": "Equip", "replace_ids": [13269929260], "mode": "cdn", "enabled": true, "cdn_url": "https://cdn.jsdelivr.net/gh/Plusnoctonia/Void-Sniper-Event-Horizon@main/EventHorizonEquip.rbxm" },
    { "name": "Idle", "replace_ids": [13269931582], "mode": "cdn", "enabled": true, "cdn_url": "https://cdn.jsdelivr.net/gh/Plusnoctonia/Void-Sniper-Event-Horizon@main/EventHorizonIdle.rbxm" },
    { "name": "Sprint", "replace_ids": [13321899382], "mode": "cdn", "enabled": true, "cdn_url": "https://cdn.jsdelivr.net/gh/Plusnoctonia/Void-Sniper-Event-Horizon@main/EventHorizonSprint.rbxm" },
    { "name": "Inspect", "replace_ids": [13269934368], "mode": "cdn", "enabled": true, "cdn_url": "https://cdn.jsdelivr.net/gh/Plusnoctonia/Void-Sniper-Event-Horizon@main/EventHorizonInspect.rbxm" },
    { "name": "Shoot", "replace_ids": [13269963346], "mode": "cdn", "enabled": true, "cdn_url": "https://cdn.jsdelivr.net/gh/Plusnoctonia/Void-Sniper-Event-Horizon@main/EventHorizonShoot.rbxm" },
    { "name": "Reload", "replace_ids": [13642104835], "mode": "cdn", "enabled": true, "cdn_url": "https://cdn.jsdelivr.net/gh/Plusnoctonia/Void-Sniper-Event-Horizon@main/EventHorizonReload.rbxm" },
    { "name": "ReloadEmpty", "replace_ids": [13269951125], "mode": "cdn", "enabled": true, "cdn_url": "https://cdn.jsdelivr.net/gh/Plusnoctonia/Void-Sniper-Event-Horizon@main/EventHorizonEmptyReload.rbxm" }
  ]
}
]==]

local SCALE = 2.6 -- size multiplier for replaced gun mesh
local ICON_SCALE = 0.6 -- icon image size multiplier (1 = original, lower = smaller)

-- slight green glow on the gun (in-game): a soft green light + faint outline
local GLOW = {
	Enabled = true,
	Color = Color3.fromRGB(60, 255, 120),
	Brightness = 1.2,
	Range = 12,
	Outline = true,
	OutlineTransparency = 0.55,
}

-- scope blur: screen blur while holding right mouse with the gun equipped
local SCOPE_BLUR = {
	Enabled = true,
	Size = 18,      -- blur strength
	FadeIn = 0.12,
	FadeOut = 0.2,
}

-- shoot sfx: new shoot sound + rubber band twang (lower pitched)
local SHOOT_SFX = {
	SoundId = 96253147006478, -- replaces the gun's shoot sounds
	PlaybackSpeed = 0.4,  -- overall pitch/speed (lower = deeper)
	PitchStart = 2,     -- twang starts HIGH...  (final pitch = PlaybackSpeed x this)
	PitchLow = 0.5,     -- ...snaps down (elastic boing) to this (0.5 = min)
	PitchEnd = 0.5,     -- then settles at the lowest pitch
	SnapTime = 0.6,     -- length of the boing (longer = easier to hear)
	Recover = 0.35,
	TremoloFreq = 18,   -- rubber vibration speed (lower = more audible wobble)
	TremoloDepth = 0.95, -- vibration strength (fades out)
	FlangerMix = 0.5,   -- extra "thwip" wobble
}

-- angelic layer: quieter + deeper than before
local ANGELIC = {
	Pitch = 0.7,        -- non-shoot sounds (below 1 = deeper)
	EQ = { LowGain = -2, MidGain = 0, HighGain = 2 },
	ChorusMix = 0.25, ChorusDepth = 0.5,
	ReverbDecay = 3.5, ReverbDry = -1, ReverbWet = -5,
	-- much lighter version used on shoot sounds
	Shot = {
		EQ = { LowGain = 3, MidGain = 0, HighGain = -1 },
		ChorusMix = 0.1, ChorusDepth = 0.3,
		ReverbDecay = 1.5, ReverbDry = 0, ReverbWet = -9,
	},
}

-- per-mesh size overrides, keyed by the original asset ID
local SCALE_BY_ID = {
	-- [13188892761] = 1,
}

local TEXTURE_URLS = {
	body  = "https://github.com/mrbeanissohot/ArchKeyperr/blob/main/v3_body.png",
	black = "https://github.com/mrbeanissohot/ArchKeyperr/blob/main/v3_black.png",
	lens  = "https://github.com/mrbeanissohot/ArchKeyperr/blob/main/v3_lens.png",
	halo  = "https://github.com/mrbeanissohot/ArchKeyperr/blob/main/v3_halo.png",
	wing  = "https://github.com/mrbeanissohot/ArchKeyperr/blob/main/v4_wing.png",
}
local MAIN_TEXTURE = "body"

---------------------------------------------------------------------
-- DOWNLOAD HELPERS
---------------------------------------------------------------------
local CACHE_DIR = "ArchKeyper"

local function toRaw(url)
	return (url:gsub("github%.com/([^/]+)/([^/]+)/blob/", "raw.githubusercontent.com/%1/%2/"))
end

local function cachePathFor(url)
	local name = url:match("([^/]+)$")
	name = name:gsub("%%%x%x", "_")
	return CACHE_DIR .. "/" .. name
end

local function download(url, path)
	if isfile(path) then return true end
	local ok, body = pcall(function() return game:HttpGet(toRaw(url)) end)
	if not ok or type(body) ~= "string" or #body == 0 then
		warn("[ArchKeyper] download failed: " .. url)
		return false
	end
	if makefolder and isfolder and not isfolder(CACHE_DIR) then
		pcall(makefolder, CACHE_DIR)
	end
	return (pcall(writefile, path, body))
end

local TEXTURE_PATHS = {}
for name, url in pairs(TEXTURE_URLS) do
	TEXTURE_PATHS[name] = cachePathFor(url)
	download(url, TEXTURE_PATHS[name])
end

---------------------------------------------------------------------

local HttpService = game:GetService("HttpService")
local AssetService = game:GetService("AssetService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local rules = HttpService:JSONDecode(CONFIG).replacement_rules
local lookup, cache, meshCache = {}, {}, {}
local meshIds = {} -- ids swapped for the local mesh (get scale + texture)
local iconIds = {} -- ids swapped for a local image (get shrunk)
local registered, skipped, swapped = 0, 0, 0

local function parseId(v)
	return tonumber(tostring(v):match("(%d+)"))
end

local function loadAsset(path)
	if cache[path] then return cache[path] end
	for _ = 1, 5 do
		if isfile(path) then
			local ok, asset = pcall(getcustomasset, path)
			if ok and asset then
				cache[path] = asset
				return asset
			end
		end
		task.wait(0.3)
	end
	return nil
end

local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local animCache = {}

-- .rbxm (KeyframeSequence) -> registered animation id usable as an AnimationId
local function loadAnimation(path)
	if animCache[path] then return animCache[path] end
	local asset = loadAsset(path)
	if not asset then return nil end
	local ok, objs = pcall(function() return game:GetObjects(asset) end)
	if not ok or type(objs) ~= "table" then
		warn("[ArchKeyper] GetObjects failed: " .. path)
		return nil
	end
	local ks
	for _, o in ipairs(objs) do
		if o:IsA("KeyframeSequence") then ks = o break end
		ks = o:FindFirstChildWhichIsA("KeyframeSequence", true)
		if ks then break end
	end
	if not ks then
		warn("[ArchKeyper] no KeyframeSequence in: " .. path)
		return nil
	end
	local ok2, id = pcall(function() return KeyframeSequenceProvider:RegisterKeyframeSequence(ks) end)
	if ok2 and id then
		animCache[path] = id
		return id
	end
	warn("[ArchKeyper] RegisterKeyframeSequence failed: " .. path)
	return nil
end

local function resolve(rule)
	if rule.mode == "cdn" then
		local path = cachePathFor(rule.cdn_url)
		download(rule.cdn_url, path)
		local id = loadAnimation(path)
		if not id then warn("[ArchKeyper] failed to load: " .. rule.cdn_url) end
		return id
	end
	if rule.mode == "local" then
		local path = cachePathFor(rule.url)
		download(rule.url, path)
		local asset = loadAsset(path)
		if not asset then
			warn("[ArchKeyper] failed to load: " .. rule.url)
		end
		return asset
	end
	if rule.with_id then return "rbxassetid://" .. rule.with_id end
	return ""
end

local function register(rule)
	if rule.type == "group" then
		for _, c in ipairs(rule.children or {}) do register(c) end
	elseif rule.enabled then
		local target = resolve(rule)
		if target == nil then
			skipped += 1
			return
		end
		registered += 1
		local u = rule.url and rule.url:lower()
		local isMesh = rule.mode == "local" and u and (u:match("%.obj$") or u:match("%.mesh$"))
		local isIcon = rule.mode == "local" and u and (u:match("%.png$") or u:match("%.jpe?g$"))
		for _, id in ipairs(rule.replace_ids) do
			local n = parseId(id)
			if n then
				lookup[n] = target
				if isMesh then meshIds[n] = true end
				if isIcon then iconIds[n] = true end
			end
		end
	end
end

for _, r in ipairs(rules) do register(r) end
print(("[ArchKeyper] rules registered: %d, skipped: %d"):format(registered, skipped))

local TEXTURE = loadAsset(TEXTURE_PATHS[MAIN_TEXTURE])
if not TEXTURE then warn("[ArchKeyper] texture not loaded: " .. tostring(TEXTURE_PATHS[MAIN_TEXTURE])) end

local PROPS = {
	MeshPart = { "MeshId", "TextureID" },
	SpecialMesh = { "MeshId", "TextureId" },
	Sound = { "SoundId" },
	Animation = { "AnimationId" },
	Decal = { "Texture" },
	Texture = { "Texture" },
	ImageLabel = { "Image" },
	ImageButton = { "Image" },
	SurfaceAppearance = { "ColorMap", "NormalMap", "MetalnessMap", "RoughnessMap" },
}

local watched = setmetatable({}, { __mode = "k" })
local seen = setmetatable({}, { __mode = "k" })
local lastScaled = setmetatable({}, { __mode = "k" })
local shrunk = setmetatable({}, { __mode = "k" })

local function scaleMesh(inst, mult)
	local m = mult or SCALE
	if m == 1 then return end
	pcall(function()
		if inst:IsA("MeshPart") then
			local last = lastScaled[inst]
			if last and (inst.Size - last).Magnitude < 0.001 then return end
			local target = inst.Size * m
			inst.Size = target
			lastScaled[inst] = target
		elseif inst:IsA("SpecialMesh") then
			local last = lastScaled[inst]
			if last and (inst.Scale - last).Magnitude < 0.001 then return end
			local target = inst.Scale * m
			inst.Scale = target
			lastScaled[inst] = target
		end
	end)
end

-- shrink an icon image around its center (UIScale, applied once)
local function shrinkIcon(inst)
	if ICON_SCALE == 1 or shrunk[inst] then return end
	if not (inst:IsA("ImageLabel") or inst:IsA("ImageButton")) then return end
	shrunk[inst] = true
	pcall(function()
		local s, a, p = inst.Size, inst.AnchorPoint, inst.Position
		local dx, dy = 0.5 - a.X, 0.5 - a.Y
		inst.Position = UDim2.new(
			p.X.Scale + dx * s.X.Scale, p.X.Offset + dx * s.X.Offset,
			p.Y.Scale + dy * s.Y.Scale, p.Y.Offset + dy * s.Y.Offset
		)
		inst.AnchorPoint = Vector2.new(0.5, 0.5)
		local ui = Instance.new("UIScale")
		ui.Name = "ArchIconScale"
		ui.Scale = ICON_SCALE
		ui.Parent = inst
	end)
end

local function setTexture(inst)
	if not TEXTURE then return end
	pcall(function()
		if inst:IsA("MeshPart") then inst.TextureID = TEXTURE end
		if inst:IsA("SpecialMesh") then inst.TextureId = TEXTURE end
	end)
end

local function applyTexture(inst)
	setTexture(inst)
	for _, c in ipairs(inst:GetChildren()) do
		if c:IsA("SurfaceAppearance") then c:Destroy() end
	end
	if not watched[inst] then
		watched[inst] = true
		inst.ChildAdded:Connect(function(c)
			if c:IsA("SurfaceAppearance") then
				task.defer(function() pcall(function() c:Destroy() end) end)
			end
		end)
		local prop = inst:IsA("MeshPart") and "TextureID" or "TextureId"
		pcall(function()
			inst:GetPropertyChangedSignal(prop):Connect(function()
				if TEXTURE and inst[prop] ~= TEXTURE then
					pcall(function() inst[prop] = TEXTURE end)
				end
			end)
		end)
	end
end

local function hideMesh(inst)
	pcall(function()
		if inst:IsA("MeshPart") then
			inst.Transparency = 1
		elseif inst:IsA("SpecialMesh") then
			inst.Scale = Vector3.new(0, 0, 0)
		end
	end)
end

local function applyMesh(inst, asset)
	if inst:IsA("MeshPart") then
		local ok, err = pcall(function()
			local mp = meshCache[asset]
			if not mp then
				mp = AssetService:CreateMeshPartAsync(asset)
				meshCache[asset] = mp
			end
			inst:ApplyMesh(mp)
		end)
		if not ok then
			warn("[ArchKeyper] ApplyMesh failed: " .. tostring(err))
			pcall(function() inst.MeshId = asset end)
		end
	else
		pcall(function() inst.MeshId = asset end)
	end
end

---------------------------------------------------------------------
-- SOUNDS: every gun sound gets an angelic chain (airy EQ + pitch lift +
-- chorus + cathedral reverb). Shoot sounds also get a rubber-band twang:
-- pitch starts high, snaps down with an elastic "boing" while a fast
-- tremolo vibrates and fades out, then settles back.
---------------------------------------------------------------------
local AFFECT_ALL_SOUNDS = false
local SOUND_IDS = {
	[96253147006478] = true, -- new shoot sound
	[13270206087] = true,    -- original shoot sound 1 (gets replaced)
	[13270206222] = true,    -- original shoot sound 2 (gets replaced)
	[13455229044] = true,    -- original shoot sound 3 (gets replaced)
	[13455229188] = true,    -- original shoot sound 4 (gets replaced)
}
local SHOT_IDS = {
	[96253147006478] = true, -- new shoot sound
	[13270206087] = true,    -- original shoot sound 1 (gets replaced)
	[13270206222] = true,    -- original shoot sound 2 (gets replaced)
	[13455229044] = true,    -- original shoot sound 3 (gets replaced)
	[13455229188] = true,    -- original shoot sound 4 (gets replaced)
}

-- these get the new sound + rubber band + low pitch, but NO angelic effects
local NO_ANGELIC_IDS = {
	[13455229044] = true,
	[13455229188] = true,
}

local function isShot(snd)
	local sid = parseId(snd.SoundId)
	if sid and SHOT_IDS[sid] then return true end
	local n = snd.Name:lower()
	return (n:find("shoot") or n:find("shot") or n:find("fire") or n:find("bang") or n:find("blast") or n:find("snipe")) ~= nil
end

local function newFx(class, parent, props)
	local e = Instance.new(class)
	for k, v in pairs(props) do e[k] = v end
	e.Name = "ArchFX"
	e.Parent = parent
	return e
end

local styled = setmetatable({}, { __mode = "k" })

local function styleSound(snd)
	if styled[snd] then return end
	styled[snd] = true
	local shot = isShot(snd)
	local origId = parseId(snd.SoundId)
	local plain = origId and NO_ANGELIC_IDS[origId] or false
	pcall(function()
		if shot then
			if SHOOT_SFX.SoundId and parseId(snd.SoundId) ~= SHOOT_SFX.SoundId then
				snd.SoundId = "rbxassetid://" .. SHOOT_SFX.SoundId
			end
			snd.PlaybackSpeed = SHOOT_SFX.PlaybackSpeed
			snd:GetPropertyChangedSignal("PlaybackSpeed"):Connect(function()
				if snd.PlaybackSpeed ~= SHOOT_SFX.PlaybackSpeed then
					snd.PlaybackSpeed = SHOOT_SFX.PlaybackSpeed
				end
			end)
		end
		if not snd:FindFirstChild("ArchFX") then -- cloned sounds may already carry the effects
			local A = shot and ANGELIC.Shot or ANGELIC
			if not plain then
				newFx("EqualizerSoundEffect", snd, { Priority = 1, LowGain = A.EQ.LowGain, MidGain = A.EQ.MidGain, HighGain = A.EQ.HighGain })
			end
			newFx("PitchShiftSoundEffect", snd, { Priority = 2, Octave = shot and SHOOT_SFX.PitchEnd or ANGELIC.Pitch })
			if not plain then
				newFx("ChorusSoundEffect", snd, { Priority = 3, Depth = A.ChorusDepth, Mix = A.ChorusMix, Rate = 0.9 })
				newFx("ReverbSoundEffect", snd, {
					Priority = 4, DecayTime = A.ReverbDecay, Density = 1, Diffusion = 1,
					DryLevel = A.ReverbDry, WetLevel = A.ReverbWet,
				})
			end
			if shot then
				newFx("FlangerSoundEffect", snd, { Priority = 5, Depth = 0.8, Mix = SHOOT_SFX.FlangerMix, Rate = 10 })
				newFx("TremoloSoundEffect", snd, { Priority = 6, Frequency = SHOOT_SFX.TremoloFreq, Depth = 0, Duty = 0.5 })
			end
		end
		if shot then
			local pitch = snd:FindFirstChildOfClass("PitchShiftSoundEffect")
			local trem = snd:FindFirstChildOfClass("TremoloSoundEffect")
			if not pitch then return end
			local function twang()
				snd.PlaybackSpeed = SHOOT_SFX.PlaybackSpeed
				pitch.Octave = SHOOT_SFX.PitchStart
				if trem then trem.Depth = SHOOT_SFX.TremoloDepth end
				-- elastic snap-down = the rubber band "boing"
				local down = TweenService:Create(pitch,
					TweenInfo.new(SHOOT_SFX.SnapTime, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
					{ Octave = SHOOT_SFX.PitchLow })
				down.Completed:Once(function()
					TweenService:Create(pitch, TweenInfo.new(SHOOT_SFX.Recover, Enum.EasingStyle.Sine),
						{ Octave = SHOOT_SFX.PitchEnd }):Play()
				end)
				down:Play()
				-- vibration dies out like a band settling
				if trem then
					TweenService:Create(trem, TweenInfo.new(SHOOT_SFX.SnapTime + SHOOT_SFX.Recover, Enum.EasingStyle.Quad),
						{ Depth = 0 }):Play()
				end
			end
			snd.Played:Connect(twang)
			if snd.IsPlaying then twang() end
		end
	end)
end

---------------------------------------------------------------------
-- SCOPE BLUR: blur the screen while scoping (right mouse) with the gun out
---------------------------------------------------------------------
local gunRoots = setmetatable({}, { __mode = "k" })
local scopeBlur

local function setBlur(size, t)
	if not scopeBlur then return end
	TweenService:Create(scopeBlur, TweenInfo.new(t, Enum.EasingStyle.Sine), { Size = size }):Play()
end

local function gunEquipped()
	local char = LocalPlayer and LocalPlayer.Character
	for root in pairs(gunRoots) do
		if root.Parent then
			if char and root:IsDescendantOf(char) then return true end
			if workspace.CurrentCamera and root:IsDescendantOf(workspace.CurrentCamera) then return true end
		end
	end
	return false
end

if SCOPE_BLUR.Enabled then
	scopeBlur = Instance.new("BlurEffect")
	scopeBlur.Name = "ArchScopeBlur"
	scopeBlur.Size = 0
	scopeBlur.Parent = Lighting

	UserInputService.InputBegan:Connect(function(input, processed)
		if input.UserInputType == Enum.UserInputType.MouseButton2 and gunEquipped() then
			setBlur(SCOPE_BLUR.Size, SCOPE_BLUR.FadeIn)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			setBlur(0, SCOPE_BLUR.FadeOut)
		end
	end)
end

local function findRoot(inst)
	local tool = inst:FindFirstAncestorOfClass("Tool")
	if tool then return tool end
	local cur, best = inst.Parent, nil
	while cur and cur ~= game and cur ~= workspace do
		if cur:IsA("Model") then
			if cur:FindFirstChildOfClass("Humanoid") then break end
			best = cur
		end
		if cur == workspace.CurrentCamera then break end
		cur = cur.Parent
	end
	return best or inst.Parent
end

local hooked = setmetatable({}, { __mode = "k" })

local function hookGunSounds(inst)
	local root = findRoot(inst)
	if not root or hooked[root] then return end
	hooked[root] = true
	gunRoots[root] = true
	if root:IsA("Tool") then
		root.Unequipped:Connect(function() setBlur(0, SCOPE_BLUR.FadeOut) end)
	end
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("Sound") then styleSound(d) end
	end
	root.DescendantAdded:Connect(function(d)
		if d:IsA("Sound") then styleSound(d) end
	end)
end

local function applyGlow(inst)
	if not GLOW.Enabled then return end
	local part = inst:IsA("SpecialMesh") and inst.Parent or inst
	if not (part and part:IsA("BasePart")) or part:FindFirstChild("ArchGlow") then return end
	pcall(function()
		local light = Instance.new("PointLight")
		light.Name = "ArchGlow"
		light.Color = GLOW.Color
		light.Brightness = GLOW.Brightness
		light.Range = GLOW.Range
		light.Shadows = false
		light.Parent = part
		if GLOW.Outline then
			local h = Instance.new("Highlight")
			h.Name = "ArchGlowOutline"
			h.Adornee = part
			h.FillTransparency = 1
			h.OutlineColor = GLOW.Color
			h.OutlineTransparency = GLOW.OutlineTransparency
			h.DepthMode = Enum.HighlightDepthMode.Occluded
			h.Parent = part
		end
	end)
end

local function handle(inst, p)
	local ok, cur = pcall(function() return inst[p] end)
	if not ok then return end
	local id = parseId(cur)
	local new = id and lookup[id]
	if new == nil then return end

	swapped += 1
	if swapped <= 10 then
		print("[ArchKeyper] swapped " .. inst.ClassName .. "." .. p .. " (" .. tostring(id) .. ")")
	end

	if p == "MeshId" then
		if new == "" then
			hideMesh(inst)
		else
			applyMesh(inst, new)
			if meshIds[id] then
				scaleMesh(inst, SCALE_BY_ID[id])
				applyTexture(inst)
				hookGunSounds(inst)
				applyGlow(inst)
			end
		end
	else
		pcall(function() inst[p] = new end)
		if iconIds[id] then shrinkIcon(inst) end
	end
end

local function apply(inst)
	local props = PROPS[inst.ClassName]
	if not props or seen[inst] then return end
	seen[inst] = true
	if inst:IsA("Sound") then
		local sid = parseId(inst.SoundId)
		if AFFECT_ALL_SOUNDS or (sid and SOUND_IDS[sid]) then styleSound(inst) end
	end
	for _, p in ipairs(props) do
		handle(inst, p)
		pcall(function()
			inst:GetPropertyChangedSignal(p):Connect(function()
				handle(inst, p)
			end)
		end)
	end
end

local function scan()
	local n = 0
	for _, d in ipairs(game:GetDescendants()) do
		apply(d)
		n += 1
		if n % 2000 == 0 then task.wait() end
	end
end

scan()
game.DescendantAdded:Connect(apply)

task.spawn(function()
	while true do
		task.wait(5)
		scan()
	end
end)

print("[ArchKeyper] loaded")

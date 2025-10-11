-- Main variables
local frame_locked = 1;
local current_time = GetTime();
local new_time = GetTime();
local delta_time = 0;
local function calculate_delta_time()
	current_time = GetTime();
	delta_time = current_time - new_time;
	new_time = current_time;
end

local frame_alpha = 1;

-- Create main frames
local umber_drag_frame = CreateFrame("Frame", "Backgroundframe", UIParent);
umber_drag_frame:SetPoint("CENTER", umb_x, umb_y);
umber_drag_frame:SetWidth(1);
umber_drag_frame:SetHeight(1);

local umber_main_frame = CreateFrame("Frame", nil, UIParent);
umber_main_frame:SetPoint("CENTER", umber_drag_frame, "CENTER", 0, 0);
umber_main_frame:SetWidth(1);
umber_main_frame:SetHeight(1);

local drag_position_text = nil;
drag_position_text = umber_main_frame:CreateFontString("Target Name", "ARTWORK", "GameFontNormalSmall");
drag_position_text:SetPoint("CENTER", umber_main_frame, "CENTER", 0, 50);
drag_position_text:SetText("");

local frames = {};
local umber_frame = {};
function umber_frame:create(name, width, height, class, construct, update)
	local self = {};
	self.name = name;
	self.width = width;
	self.height = height;
	self.class = class;
	self.construct = construct;
	self.update = update;
	self.frame = CreateFrame("Frame", "Backgroundframe", umber_main_frame);
	return self;
end

local function get_frame_enabled(name)
	if umb_data["frame_" .. name .. "_enabled"] == nil then
		umb_data["frame_" .. name .. "_enabled"] = true;
		return true;
	else
		return umb_data["frame_" .. name .. "_enabled"];
	end
end
local function get_frame_class_enabled(class)
	if class == nil or class == "" then
		return true;
	else
		return select(2, UnitClass('player')) == class;
	end
end
local function get_frame_size(name)
	if umb_data["frame_" .. name .. "_size"] == nil then
		umb_data["frame_" .. name .. "_size"] = 1;
		return 1;
	else
		return umb_data["frame_" .. name .. "_size"];
	end
end
local function set_frame_enabled(name, value)
	if value == true or value == false then
		umb_data["frame_" .. name .. "_enabled"] = value;
	end
end
local function set_frame_size(name, value)
	if tonumber(value) ~= nil then
		umb_data["frame_" .. name .. "_size"] = value;
	end
end

local function get_frame(name)
	for i = 1, table.getn(frames) do
		if frames[i].name == name and get_frame_class_enabled(frames[i].class) == true then
			return i;
		end
	end
	return -1;
end

local function umber_setup()
	frame_creation_height = 0;

	if umb_x == nil then umb_x = 0; end
	if umb_y == nil then umb_y = 0; end
	if umb_data == nil then umb_data = {}; end
	if umb_combat == nil then umb_combat = false; end
	if umb_timers == nil then umb_timers = false; end

	if umb_combat == true then frame_alpha = 1; else frame_alpha = 0; end

	for i = 1, table.getn(frames) do
		frames[i].frame:SetPoint("TOP", umber_main_frame, "TOP", 0, frame_creation_height);
		frame_creation_height = frame_creation_height - frames[i].height;
		frames[i].frame:SetWidth(frames[i].width);
		frames[i].frame:SetHeight(frames[i].height);
		frames[i].frame:SetFrameLevel(15);

		if umb_data["frame_" .. frames[i].name .. "_enabled"] == nil then
			umb_data["frame_" .. frames[i].name .. "_enabled"] = true;
			umb_data["frame_" .. frames[i].name .. "_size"] = 1;
		end
	end
end

-- Components
local function update_alpha()
	if umb_combat == true then
		if UnitAffectingCombat("player") == true or frame_locked == 0 then
			frame_alpha = frame_alpha + delta_time * 5;
		else
			frame_alpha = frame_alpha - delta_time;
		end
	else
		frame_alpha = frame_alpha + delta_time * 5;
	end

	if frame_alpha < 0 then frame_alpha = 0; end
	if frame_alpha > 1 then frame_alpha = 1; end

	umber_main_frame:SetAlpha(frame_alpha);
end

local function format_big_number(value)
	if (value > 99999999) then return math.floor(value / 1000000) .. " M"; end
	if (value > 99999) then return math.floor(value / 1000) .. " K"; end
	return value;
end
local function format_percentage_number(value, maximum)
	if value == 0 or maximun == 0 then return 0; end
	return (floor((value / (maximum / 100)) * 10 ^ 0 + 0.5) / 10 ^ 0);
end

local rune_frames = nil;
local rune_background_textures = nil;
local rune_foreground_frames = nil;
local rune_foreground_textures = nil;
local rune_cooldown_frames = nil;
local rune_cooldown_textures = nil;
local rune_complete_frame = nil;
local rune_complete_textures = nil;
local rune_texts = nil;
local rune_ids = { 1, 2, 3, 4, 5, 6 };
local rune_anim = { 0, 0, 0, 0, 0, 0 };
local rune_glow_anim = { 0, 0, 0, 0, 0, 0 };
local rune_current_spec = -1;
local rune_english_spec_names = { "Blood", "Frost", "Unholy" };
local rune_uv_coord_x = { 0, 0.27, 0 };
local rune_uv_coord_y = { 0.27, 0.53, 0.27 };
local rune_uv_coord_z = { 0, 0, 0.53 };
local rune_uv_coord_w = { 0.27, 0.27, 0.80 };
local function setup_runes()
	if rune_frames == nil then
		base_frame = frames[get_frame("runes")];

		rune_frames = {};
		rune_background_textures = {};
		rune_foreground_frames = {};
		rune_foreground_textures = {};
		rune_cooldown_frames = {};
		rune_cooldown_textures = {};
		rune_complete_frame = {};
		rune_complete_textures = {};
		rune_texts = {};

		for i = 1, 6 do
			rune_frames[i] = CreateFrame("Frame", "Rune" .. i .. "BG", base_frame.frame);
			rune_frames[i]:SetPoint("CENTER", base_frame.frame, "CENTER",
				-(base_frame.width / 2) - (base_frame.height / 2) * 0.8 + (base_frame.width / 6) * i, 0);
			rune_frames[i]:SetWidth(base_frame.height);
			rune_frames[i]:SetHeight(base_frame.height);
			rune_frames[i]:SetFrameLevel(16);

			rune_background_textures[i] = rune_frames[i]:CreateTexture("ARTWORK");
			rune_background_textures[i]:SetAllPoints();
			rune_background_textures[i]:SetAlpha(0);
			rune_background_textures[i]:SetAtlas("DK-Rune-CD");

			rune_foreground_frames[i] = CreateFrame("Frame", "Rune" .. i .. "CD", rune_frames[i]);
			rune_foreground_frames[i]:SetPoint("CENTER", rune_frames[i], "CENTER", 0, 0);
			rune_foreground_frames[i]:SetWidth(base_frame.height);
			rune_foreground_frames[i]:SetHeight(base_frame.height);
			rune_foreground_frames[i]:SetFrameLevel(18);
			rune_foreground_textures[i] = rune_foreground_frames[i]:CreateTexture("ARTWORK");
			rune_foreground_textures[i]:SetAllPoints();
			rune_foreground_textures[i]:SetAlpha(1);
			rune_foreground_textures[i]:SetTexture("Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-SingleRune");

			rune_cooldown_frames[i] = CreateFrame("Frame", "Rune" .. i .. "CD", rune_frames[i]);
			rune_cooldown_frames[i]:SetPoint("CENTER", rune_frames[i], "CENTER", 0, 0);
			rune_cooldown_frames[i]:SetWidth(base_frame.height);
			rune_cooldown_frames[i]:SetHeight(base_frame.height);
			rune_cooldown_frames[i]:SetFrameLevel(19);

			rune_complete_frame[i] = CreateFrame("Frame", "Rune" .. i .. "Ring", rune_frames[i]);
			rune_complete_frame[i]:SetPoint("TOPLEFT", rune_frames[i], "TOPLEFT", 0, 0);
			rune_complete_frame[i]:SetWidth(base_frame.height);
			rune_complete_frame[i]:SetHeight(base_frame.height);
			rune_complete_frame[i]:SetFrameLevel(20);

			rune_cooldown_textures[i] = CreateFrame("Cooldown", "Rune" .. i .. "CDAnim", rune_cooldown_frames[i],
				"CooldownFrameTemplate");
			rune_cooldown_textures[i]:SetHideCountdownNumbers(true);
			rune_cooldown_textures[i]:SetFrameLevel(20);
			rune_cooldown_textures[i]:SetEdgeTexture("Interface\\PlayerFrame\\DK-BloodUnholy-Rune-CDSpark");
			rune_cooldown_textures[i]:SetReverse(true);
			rune_cooldown_textures[i]:SetUseCircularEdge(true);
			rune_cooldown_textures[i]:SetDrawBling(false);
			rune_cooldown_textures[i]:SetSwipeTexture("Interface\\PlayerFrame\\DK-Blood-Rune-CDFill");
			rune_cooldown_textures[i]:SetSwipeColor(255, 255, 255);


			rune_complete_textures[i] = rune_complete_frame[i]:CreateTexture("OVERLAY");
			rune_complete_textures[i]:SetAllPoints();
			rune_complete_textures[i]:SetAtlas("DK-Rune-Glow");
			rune_complete_textures[i]:SetAlpha(0);

			rune_texts[i] = rune_complete_frame[i]:CreateFontString("Runic Power Number", "ARTWORK", "TextStatusBarText");
			rune_texts[i]:SetPoint("CENTER", rune_complete_frame[i], "CENTER", 0, 0);
			rune_texts[i]:SetText(0);
		end
	end
end
local function update_runes()
	-- Disable blizzard runes
	RuneFrame:Hide();

	local current_spec = GetSpecialization();
	if rune_current_spec ~= current_spec and current_spec ~= nil then
		rune_current_spec = current_spec;
		for i = 1, 6 do
			rune_foreground_textures[i]:SetTexture("Interface\\PlayerFrame\\ClassOverlayDeathKnightRunes");
			rune_foreground_textures[i]:SetTexCoord(rune_uv_coord_x[current_spec], rune_uv_coord_y[current_spec],
				rune_uv_coord_z[current_spec], rune_uv_coord_w[current_spec]);
			rune_cooldown_textures[i]:SetSwipeTexture("Interface\\PlayerFrame\\DK-" ..
			rune_english_spec_names[current_spec] .. "-Rune-CDFill");
		end
	end


	for i = 1, 6 do
		rune_start, rune_duration = GetRuneCooldown(rune_ids[i]);

		if umb_timers == true then
			if rune_start == 0 then
				rune_texts[i]:SetText("");
			else
				rune_time = math.floor(rune_duration - (GetTime() - rune_start));
				if rune_time < 0 then rune_time = 0; end
				rune_texts[i]:SetText(rune_time);
			end
		else
			rune_texts[i]:SetText("");
		end

		if rune_start ~= 0 and rune_start ~= nil and rune_duration ~= nil then
			rune_cooldown_textures[i]:SetCooldown(rune_start, rune_duration);
			rune_anim[i] = 1;
			rune_foreground_textures[i]:SetAlpha(0);
			rune_background_textures[i]:SetAlpha(1);
		else
			if rune_anim[i] == 1 then
				rune_anim[i] = 0;
				rune_cooldown_textures[i]:SetCooldown(0, 0);
				rune_foreground_textures[i]:SetAlpha(1);
				rune_background_textures[i]:SetAlpha(0);
				rune_glow_anim[i] = 1;
			end
		end
	end

	for i = 1, 6 do
		if rune_glow_anim[i] ~= 0 then
			rune_glow_anim[i] = rune_glow_anim[i] - delta_time * 2;
			if rune_glow_anim[i] < 0 then
				rune_glow_anim[i] = 0;
			end
			rune_complete_textures[i]:SetAlpha(math.sin(rune_glow_anim[i] * math.pi));
		end
	end
end

frames[table.getn(frames) + 1] = umber_frame:create("runes", 120, 24, "DEATHKNIGHT", setup_runes, update_runes);

-- On update
local isdragging = false;
local isscaling = false;
local frame_selected = -1;
local x_drag_start = 0;
local y_drag_start = 0;
local x_dist = 0;
local y_dist = 0;
local has_init = false;
umber_main_frame:SetScript("OnUpdate", function(self, elapsed)
	if has_init == false then
		for i = 1, table.getn(frames) do
			if get_frame_class_enabled(frames[i].class) == true then
				frames[i].construct();
			end
		end
		has_init = true;
	end

	calculate_delta_time();

	update_alpha();

	window_width = GetScreenWidth() * UIParent:GetEffectiveScale();
	window_height = GetScreenHeight() * UIParent:GetEffectiveScale();

	if frame_locked == 0 then
		for i = 1, table.getn(frames) do frames[i].frame:EnableMouse(true); end

		if isdragging == false and isscaling == false then
			frame_selected = -1;
			for i = 1, table.getn(frames) do
				if get_frame_enabled(frames[i].name) == true and get_frame_class_enabled(frames[i].class) == true then
					if GetMouseFocus() == frames[i].frame then frame_selected = i; end
				end
			end
			if IsMouseButtonDown(1) == true then
				if frame_selected ~= -1 then
					x_drag_start, y_drag_start = GetCursorPosition();
					x_drag_start = (x_drag_start - window_width / 2) / UIParent:GetEffectiveScale();
					y_drag_start = (y_drag_start - window_height / 2) / UIParent:GetEffectiveScale();
					x_dist = umb_x - x_drag_start;
					y_dist = umb_y - y_drag_start;
					isdragging = true;
				end
			elseif IsMouseButtonDown(2) == true then
				if frame_selected ~= -1 then
					x_drag_start, y_drag_start = GetCursorPosition();
					isscaling = true;
				end
			end
		end

		if isdragging and IsMouseButtonDown(1) == false then isdragging = false end;
		if isscaling and IsMouseButtonDown(2) == false then isscaling = false end;

		if isdragging == true then
			new_x, new_y = GetCursorPosition();
			new_x = (new_x - window_width / 2) / UIParent:GetEffectiveScale();
			new_y = (new_y - window_height / 2) / UIParent:GetEffectiveScale();
			umb_x = new_x + x_dist;
			umb_y = new_y + y_dist;
		elseif isscaling == true then
			current_scale = get_frame_size(frames[frame_selected].name);
			xPos, yPos = GetCursorPosition();
			distance = (y_drag_start - yPos) / 50;
			current_scale = current_scale - distance;
			if current_scale < 0.5 then current_scale = 0.5 end
			if current_scale > 3 then current_scale = 3 end
			set_frame_size(frames[frame_selected].name, current_scale);
			x_drag_start, y_drag_start = GetCursorPosition();
		end
	else
		for i = 1, table.getn(frames) do frames[i].frame:EnableMouse(false); end
	end

	if umb_x < -GetScreenWidth() / 2 then umb_x = -GetScreenWidth() / 2; end
	if umb_y < -GetScreenHeight() / 2 then umb_y = -GetScreenHeight() / 2; end
	if umb_x > GetScreenWidth() / 2 then umb_x = GetScreenWidth() / 2; end
	if umb_y > GetScreenHeight() / 2 then umb_y = GetScreenHeight() / 2; end
	umb_x = math.floor(umb_x);
	umb_y = math.floor(umb_y);

	if frame_locked == 0 then
		drag_position_text:SetText(umb_x .. ", " .. umb_y);
	else
		drag_position_text:SetText("");
	end

	largest_width = 1;
	total_height = 1;
	frame_current_height = 0;
	for i = 1, table.getn(frames) do
		if get_frame_enabled(frames[i].name) == true and get_frame_class_enabled(frames[i].class) == true then
			frames[i].frame:SetScale(get_frame_size(frames[i].name));
			frames[i].frame:Show();

			if frames[i].width >= largest_width then largest_width = frames[i].width; end;
			total_height = total_height + frames[i].height * get_frame_size(frames[i].name);
			frames[i].frame:SetPoint("TOP", umber_main_frame, "TOP", 0,
				frame_current_height / get_frame_size(frames[i].name));
			frame_current_height = frame_current_height - frames[i].height * get_frame_size(frames[i].name);
		else
			frames[i].frame:Hide();
		end
	end

	umber_drag_frame:SetWidth(largest_width);
	umber_drag_frame:SetHeight(total_height);
	umber_main_frame:SetPoint("TOP", umber_drag_frame, "TOP", 0, 0);

	umber_drag_frame:ClearAllPoints();
	umber_drag_frame:SetPoint("CENTER", umb_x, umb_y);

	for i = 1, table.getn(frames) do
		if get_frame_enabled(frames[i].name) == true and get_frame_class_enabled(frames[i].class) == true then
			frames[i].update();
		end
	end
end)

-- On events
umber_main_frame:RegisterEvent("ADDON_LOADED");
umber_main_frame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		umber_main_frame:UnregisterEvent("ADDON_LOADED");
		umber_setup();
		umber_main_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	end

	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, type, _, sourceGUID, _, _, _, destGUID, _, _, _ = ...;
		if type == "SWING_DAMAGE" and sourceGUID == UnitGUID("player") and destGUID == UnitGUID("target") then
			swingtimer_value = GetTime();
		end
	end
end)

-- Slash commands
local header_start = "|cFFFFA07AUmberRunes: |cffffffff";
local command_color = "|cFF00FFFF";
local text_color = "|cffffffff";
SLASH_UMBER1 = '/umber';
local function handler(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if command == "lock" then
		if frame_locked == 1 then
			frame_locked = 0; print(header_start .. "Frame unlocked.")
		else
			frame_locked = 1; print(header_start .. "Frame locked.")
		end;
	elseif command == "reset" then
		umb_x = 0; umb_y = 0;
		for i = 1, table.getn(frames) do umb_data["frame_" .. frames[i].name .. "_size"] = 1; end
		for i = 1, table.getn(frames) do umb_data["frame_" .. frames[i].name .. "_enabled"] = true; end
		print(header_start .. "Frame reset.");
	elseif command == "setscale" then
		scale = tonumber(rest);
		if scale ~= nil then
			if scale >= 0.5 and scale <= 3 then
				for i = 1, table.getn(frames) do umb_data["frame_" .. frames[i].name .. "_size"] = scale; end
			else
				print(header_start .. "Use a number between 0.5 and 3 to set the scale.");
			end
		else
			print(header_start .. "Use a number between 0.5 and 3 to set the scale.");
		end
	elseif command == "combat" then
		if umb_combat == true then
			umb_combat = false; print(header_start .. "Will remain visible while out of combat.")
		else
			umb_combat = true; print(header_start .. "Will hide while out of combat.")
		end;
	else
		print("|cFFFFA07AUmberRunes:");
		print(command_color .. "/umber lock - " .. text_color .. "Lock/unlock the main frame.");
		print(command_color .. "/umber reset - " .. text_color .. "Reset the position of the main frame.");
		print(command_color ..
		"/umber setscale - " .. text_color .. "Set the scale of all components. (Value between 0.5 and 3, 1 is default).");
		print(command_color .. "/umber combat - " .. text_color .. "Toggle hiding when out of combat.");
	end
end
SlashCmdList["UMBER"] = handler;

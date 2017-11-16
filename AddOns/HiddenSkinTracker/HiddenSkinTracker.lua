HST = { };
HST["version"] = "1.03"

local completion_status = { };
completion_status["dungeons"] = 0;
completion_status["world_quests"] = 0;
completion_status["honorable_kills"] = 0;

local DUNGEONS_MAX = 100;
local WORLD_QUESTS_MAX = 200;
local HONORABLE_KILLS_MAX = 1000;

SlashCmdList["HST"] = function()
	HST:updateStats()
	HST:printStats()
end
SLASH_HST1 = "/hst"
SLASH_HST2 = "/HST"
SLASH_HST3 = "/hiddenskintracker"

local function getDungeonStats()
	-- Dungeon achievement is divided by dungeons. Total number completed is a sum of these.
	local dungeon_count = 0

	for i=1, 12 do
		local _, _, _, dungeon, _ = GetAchievementCriteriaInfo(11152, i);
		dungeon_count = dungeon_count + dungeon
	end
	if (dungeon_count > 100) then
		return 100
	else
		return dungeon_count
	end
end

local function colorPercByValue(ratio)
	-- Yolo
	local red = "|cffD50000"
	local orange = "|cffFF6D00"
	local yellow = "|cffFFEA00"
	local green = "|cff00C853"
	local return_string = ""

	if (ratio <= 33) then
		return_string = red .. ratio .. "%|r"
	elseif (ratio > 33 and ratio <= 67) then
		return_string = orange .. ratio .. "%|r"
	elseif (ratio > 67 and ratio < 100 ) then
		return_string = yellow .. ratio .. "%|r"
	else
		return_string = green .. ratio .. "%|r"
	end
	return return_string
end

local function numberSpacesByString(string)
	spaces = ""
	for i=1, 4-string:len() do
		spaces = spaces .. " "
	end
	return string .. spaces
end

function HST:updateStats()
	-- Do the stuff
	local dungeons_done = getDungeonStats();
	local _, _, _, world_quests_done, _ = GetAchievementCriteriaInfo(11153,1);
	local _, _, _, honorable_kills_done, _ = GetAchievementCriteriaInfo(11154,1);
	completion_status["dungeons"] = dungeons_done;
	completion_status["world_quests"] = world_quests_done;
	completion_status["honorable_kills"] = honorable_kills_done;
end

function HST:printStats()
	-- Make it pretty
	local dungeons_completed = completion_status["dungeons"]
	local wqs_completed = completion_status["world_quests"]
	local hks_completed = completion_status["honorable_kills"]

	local dung_perc = colorPercByValue((completion_status["dungeons"] / DUNGEONS_MAX) * 100);
	local wq_perc = colorPercByValue((completion_status["world_quests"] / WORLD_QUESTS_MAX) * 100);
	local hk_perc = colorPercByValue((completion_status["honorable_kills"] / HONORABLE_KILLS_MAX) * 100);

	print("|cff2962FFHiddenSkinTracker v" .. HST["version"] .. "|r")
	print("You have completed:")
	print("|cff2962FF" .. dungeons_completed .. "|r of |cff2962FF100|r (" .. dung_perc ..") dungeons")
	print("|cff2962FF" .. wqs_completed .. "|r of |cff2962FF200|r (" .. wq_perc ..") world quests")
	print("|cff2962FF" .. hks_completed .. "|r of |cff2962FF1000|r (" .. hk_perc ..") honourable kills")
end

local frame = CreateFrame("FRAME", "HiddenSkinTrackerFrame");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED");
frame:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED");
frame:RegisterEvent("QUEST_LOG_UPDATE");
frame:RegisterEvent("PET_BATTLE_CLOSE");
local function eventHandler(self, event, ...)
	HST:updateStats();
end

frame:SetScript("OnEvent", eventHandler);
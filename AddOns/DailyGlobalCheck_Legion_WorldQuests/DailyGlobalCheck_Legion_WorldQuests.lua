-- Daily Global Check - Legion World Quests plugin
-- Jadya EU-Well of Eternity

local tinsert, tremove, tsort = table.insert, table.remove, table.sort

local Z = DailyGlobalCheck.Z
local WQ = DailyGlobalCheck.WorldQuests

if not WQ then
 C_Timer.After(1, function() print("Daily Global Check - The |cff00ff00Legion World Quests|r plugin cannot be loaded due to core updates that require a newer version of |cff00ff00Daily Global Check|r, please update |cff00ff00Daily Global Check|r") end)
 return
end

local initialized = 0
local svar
local questsdata
local order_cache =
 {
  -- by zone
   {
    {Z[1015]},
    {Z[1018]},
	{Z[1024]},
	{Z[1017]},
	{Z[1033]},
	{Z[1014]},
	{Z[1096]},
	{Z[1021]},
	{Z[1135]},
	{Z[1171]},
	{Z[1170]},
   },
  -- by type
   {
    {WORLD_QUEST_BANNER},
    {CALENDAR_TYPE_DUNGEON},
    {ELITE},
    {BATTLE_PET_SOURCE_5},
    {GUILD_INTEREST_PVP},
    {BATTLE_PET_SOURCE_4},
   },
  -- by reward
   {
    {ARTIFACT_POWER},
	{select(1, GetCurrencyInfo(1220))},
	{BONUS_ROLL_REWARD_MONEY},
	{RELICSLOT},
	{BAG_FILTER_EQUIPMENT},
	{"Blood of Sargeras"},
	{BATTLE_PET_SOURCE_4},
	{OTHER},
   },
  -- by faction
   {
    {select(1, GetFactionInfoByID(1894))}, -- wardens
    {select(1, GetFactionInfoByID(1900))}, -- court
    {select(1, GetFactionInfoByID(1090))}, -- kirin
    {select(1, GetFactionInfoByID(1859))}, -- night
    {select(1, GetFactionInfoByID(1883))}, -- dreamw
    {select(1, GetFactionInfoByID(1828))}, -- high
    {select(1, GetFactionInfoByID(1948))}, -- dreamw
    {select(1, GetFactionInfoByID(2045))}, -- armies
    {select(1, GetFactionInfoByID(2165))}, -- army of the light
    {select(1, GetFactionInfoByID(2170))}, -- argussian
   },
 }

local plugin_data = {
 ["Title"] = "Legion World Quests",
 ["Icon"]  = "Interface\\Icons\\Achievement_BG_ABshutout",
 ["Version"] = 1004,
 ["Options"] = {
				{"Radiobutton","Sort by Zone"      ,true},
				{"Radiobutton","Sort by Quest Type",false},
				{"Radiobutton","Sort by Reward"    ,false},
				{"Radiobutton","Sort by Faction"   ,false},
			   },
 ["Order"] = {},
}

local zone_indexes = {
                      [1015] = 1,
                      [1018] = 2,
                      [1024] = 3,
                      [1017] = 4,
                      [1033] = 5,
                      [1014] = 6,
                      [1096] = 7,
                      [1021] = 8,
                      [1135] = 9,
                      [1171] = 10,
                      [1170] = 11,
					 }
local type_indexes = {
                      [LE_QUEST_TAG_TYPE_PROFESSION] = 6,
					  [LE_QUEST_TAG_TYPE_PVP] = 5,
					  [LE_QUEST_TAG_TYPE_PET_BATTLE] = 4,
					  [LE_QUEST_TAG_TYPE_DUNGEON] = 2,
					 }
					 
local type_factions = {
                       [1894] = 1,
                       [1900] = 2,
					   [1090] = 3,
					   [1859] = 4,
					   [1883] = 5,
					   [1828] = 6,
					   [1948] = 7,
					   [2045] = 8,
					   [2165] = 9,
					   [2170] = 10,
					  }

local function determine_group(opt, v, info)
 if opt == 1 and v[5] then
  return zone_indexes[v[5][1]]
 elseif opt == 2 then
   return (info[5] and info[3] == LE_QUEST_TAG_TYPE_NORMAL) and 3 or (type_indexes[info[3]] or 1)
 elseif opt == 3 then
  if info[8] then
   if info[10] == "artifact_power" then
    return 1
   elseif IsArtifactRelicItem(info[8]) then
    return 4
   elseif info[8] == 124124 then
    return 6
   elseif WQ.ItemClass[info[8]] == 4 then
    return 5
   else
    return 8
   end
  elseif info[7] then
   return 2
  elseif info[3] == LE_QUEST_TAG_TYPE_PROFESSION then
   return 7
  elseif info[6] > 0 then
   return 3
  else
   return 8
  end
 elseif opt == 4 then
  return type_factions[info[9]] or 1
 else
  return 1
 end
end

local function sortfunc(a, b)
 if type(a) == "string" then return true end
 if type(b) == "string" then return false end
 return C_TaskQuest.GetQuestTimeLeftMinutes(a or 0) < C_TaskQuest.GetQuestTimeLeftMinutes(b or 0)
end

local function setup_order()
 local opt
 if svar and svar.options then
  for i = 1,4 do
   if svar.options[i] then
    opt = i
    break
   end
  end
  if not opt then opt = 1 end
 else
  opt = 1
 end

 plugin_data.Order[1] = order_cache[opt]
 local order = plugin_data.Order[1]
 
 for _,v in pairs(order) do
  for i = 2,#v do
   v[i] = nil
  end
 end
 
 for k,v in pairs(questsdata) do
  local info = WQ.TagInfo[k]
  if info then
   local group = determine_group(opt, v, info)
   order[group][#order[group] + 1] = k
  end
 end

 for k,v in pairs(plugin_data.Order[1]) do
  tsort(v, sortfunc)
 end
end

local function GenerateData()
 setup_order()
 DailyGlobalCheck:Refresh(plugin_data)
end

local function world_quests_update()
 setup_order()
 DailyGlobalCheck:Refresh(plugin_data)
end

local last_opt
local function option_changed(opt, value, list)
 if list ~= plugin_data then return end

 if last_opt ~= opt then
  setup_order()
  last_opt = opt
 end
end

local function Initialize()
 svar = DailyGlobalCheck_PluginData and DailyGlobalCheck_PluginData["Legion World Quests"]
 
 order_cache[3][6][1] = DailyGlobalCheck.LocalizeSection(order_cache[3], 6, 1, "Blood of Sargeras", "item", 124124, 1)
 
 DGCEventFrame:Hook("OPTION_CHANGED_PLUGIN", option_changed)
 DGCEventFrame:Hook("WORLD_QUESTS_UPDATE", world_quests_update)
end

WQ:Initialize(plugin_data)
questsdata = WQ.Data

plugin_data.Initialize = Initialize
plugin_data.GenerateData = GenerateData
DailyGlobalCheck:LoadPlugin(plugin_data, questsdata)






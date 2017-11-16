-- Made by Porth @ Thrall-US Horde
-- Based on "Purge", which was written by Kynetix @ Kil'Jaden-US Alliance

function InterruptAndDispel_OnLoad(this)	
	SLASH_InterruptAndDispel1= "/iad";
	SlashCmdList["InterruptAndDispel"] = InterruptAndDispel_CommandParse;
	
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("PLAYER_LOGOUT");
	this:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

function InterruptAndDispel_OnEvent(this, event, ...)	
	if (event == "PLAYER_LOGIN") then
		if (IAD_On == nil) then
			IAD_On = true
		end
		if (IAD_InterruptOn == nil) then
			IAD_InterruptOn = true
		end
		if (IAD_DispelOn == nil) then
			IAD_DispelOn = true
		end
		if (IAD_AnnounceTo == nil) then
			IAD_AnnounceTo = "SAY"
		end
		if (IAD_DispelFriendly == nil) then
			IAD_DispelFriendly = false
		end
	end
	
	if (event == "PLAYER_LOGOUT") then
		--IAD_On = IAD_On;
		--IAD_AnnounceTo = IAD_AnnounceTo;
		--IAD_InterruptOn = IAD_InterruptOn;
		--IAD_DispelOn = IAD_DispelOn;
		this:UnregisterEvent("PLAYER_LOGIN");
		this:UnregisterEvent("PLAYER_LOGOUT");
		this:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	end
	

	local _, eventType, _, _, sourceName, _, _, _, targetName, targetFlags, _, sourceSpellID, _, _, spellId, spellName, schoolnumber = select(1, ...)
	local playerName = UnitName("player");
	
	if (event=="COMBAT_LOG_EVENT_UNFILTERED" and IAD_On == true) then
		if(eventType == "SPELL_INTERRUPT" and IAD_InterruptOn == true)  then
			if (sourceName == playerName) then
				SendChatMessage(GetSpellLink(spellId).." interrupted!",""..IAD_AnnounceTo.."")
			end
		end

		if(eventType == "SPELL_STOLEN" and IAD_DispelOn == true)  then
			if (sourceName == playerName) then
				SendChatMessage(GetSpellLink(spellId).." stolen!",""..IAD_AnnounceTo.."")
			end
		end

		if(eventType == "SPELL_DISPEL" and IAD_DispelOn == true)  then			
			if (sourceName == playerName) then
				if bit.band(targetFlags, 0x00000010) then
					if IAD_DispelFriendly then
						SendChatMessage("Dispelled "..GetSpellLink(spellId)..".",""..IAD_AnnounceTo.."")
					end
				else
					SendChatMessage("Dispelled "..GetSpellLink(spellId)..".",""..IAD_AnnounceTo.."")
				end
			end
		end
	end
end

function InterruptAndDispel_Message(message)
	DEFAULT_CHAT_FRAME:AddMessage(InterruptAndDispel_ColorMessage("[ InterruptAndDispel ] ", "yellow") .. message, 1, 1, 1);
end

function InterruptAndDispel_ColorMessage(message, color)
	if (color == 'yellow') then
		return "\124cffffff00\124h" .. message .. "\124h\124r"
	elseif (color == 'red') then
		return "\124cfff00001\124h" .. message .. "\124h\124r"
	elseif (color == 'green') then
		return "\124cff00cc33\124h" .. message .. "\124h\124r"
	elseif (color == 'orange') then
		return "\124cffff9900\124h" .. message .. "\124h\124r"
	elseif (color == 'blue') then
		return "\124cff00B4FF\124h" .. message .. "\124h\124r"
	else
		return message
	end
end

function InterruptAndDispel_CommandParse(parameterstring)
	local command = nil;
	local isOn = "";
	local intOn = "";
	local disOn = "";
	
	command = string.lower(parameterstring);
	if IAD_On then 
		isOn = "On"
	else
		isOn = "Off"
	end
	if IAD_InterruptOn then
		intOn = "On"
	else
		intOn = "Off"
	end
	if IAD_DispelOn then
		disOn = "On"
	else
		disOn = "Off"
	end
	if IAD_DispelFriendly then
		friendlyOn = "On"
	else 
		friendlyOn = "Off"
	end

	if (command == 'off') then
		IAD_On = false
		isOn = "Off"
		InterruptAndDispel_Message(InterruptAndDispel_ColorMessage('InterruptAndDispel', 'yellow') .. ' is ' .. InterruptAndDispel_ColorMessage(isOn, 'red'));
	elseif (command == 'on') then
		IAD_On = true
		isOn = "On"
		InterruptAndDispel_Message(InterruptAndDispel_ColorMessage('InterruptAndDispel', 'yellow') .. ' is ' .. InterruptAndDispel_ColorMessage(isOn, 'green'));
	elseif (command == 'interrupton') then
		IAD_InterruptOn = true
		intOn = "On"
		InterruptAndDispel_Message('Interrupt announcements are ' .. InterruptAndDispel_ColorMessage(intOn, 'green'));
	elseif (command == 'dispelon') then
		IAD_DispelOn = true
		disOn = "On"
		InterruptAndDispel_Message('Dispel announcements are ' .. InterruptAndDispel_ColorMessage(disOn, 'green'));
	elseif (command == 'dispelfriendlyon') then
		IAD_DispelFriendly = true
		friendlyOn = "On"
		InterruptAndDispel_Message('Friendly Dispels are ' .. InterruptAndDispel_ColorMessage(friendlyOn, 'green'));
	elseif (command == 'dispelfriendlyoff') then
		IAD_DispelFriendly = false
		friendlyOn = "Off"
		InterruptAndDispel_Message('Friendly Dispels are ' .. InterruptAndDispel_ColorMessage(friendlyOn, 'red'));
	elseif (command == 'interruptoff') then
		IAD_InterruptOn = false
		intOn = "Off"
		InterruptAndDispel_Message('Interrupt announcements are ' .. InterruptAndDispel_ColorMessage(intOn, 'red'));
	elseif (command == 'dispeloff') then
		IAD_DispelOn = false
		disOn = "Off"
		InterruptAndDispel_Message('Dispel announcements are ' .. InterruptAndDispel_ColorMessage(disOn, 'red'));
	elseif (command == 'self') then
		IAD_AnnounceTo = "SELF"
		InterruptAndDispel_Message('Output is now on ' .. IAD_AnnounceTo);
	elseif (command == 'say') then
		IAD_AnnounceTo = "SAY"
		InterruptAndDispel_Message('Output is now on ' .. IAD_AnnounceTo);
	elseif (command == 'yell') then
		IAD_AnnounceTo = "YELL"
		InterruptAndDispel_Message('Output is now on ' .. InterruptAndDispel_ColorMessage(IAD_AnnounceTo, 'red'));
	elseif (command == 'party') then
		IAD_AnnounceTo = "PARTY"
		InterruptAndDispel_Message('Output is now on ' .. InterruptAndDispel_ColorMessage(IAD_AnnounceTo, 'blue'));
	elseif (command == 'raid') then
		IAD_AnnounceTo = "RAID"
		InterruptAndDispel_Message('Output is now on ' .. InterruptAndDispel_ColorMessage(IAD_AnnounceTo, 'orange'));
	elseif (command == 'rw') then
		IAD_AnnounceTo = "RAID_WARNING"
		InterruptAndDispel_Message('Output is now on ' .. InterruptAndDispel_ColorMessage(IAD_AnnounceTo, 'orange'));
	elseif (command == 'emote') then
		IAD_AnnounceTo = "EMOTE"
		InterruptAndDispel_Message('Output is now on ' .. InterruptAndDispel_ColorMessage(IAD_AnnounceTo, 'red'));
	elseif (command == 'instance') then
		IAD_AnnounceTo = "INSTANCE_CHAT"
		InterruptAndDispel_Message('Output is now on ' .. InterruptAndDispel_ColorMessage(IAD_AnnounceTo, 'orange'));
	elseif (command == 'current') or (command == 'settings') then
		if isOn then
			InterruptAndDispel_Message('InterruptAndDispel is ' .. InterruptAndDispel_ColorMessage(isOn, 'green'))
		else
			InterruptAndDispel_Message('InterruptAndDispel is ' .. InterruptAndDispel_ColorMessage(isOn, 'red'))
		end
		if intOn then
			InterruptAndDispel_Message('Interrupt announce is ' .. InterruptAndDispel_ColorMessage(intOn, 'green'))
		else
			InterruptAndDispel_Message('Interrupt announce is ' .. InterruptAndDispel_ColorMessage(intOn, 'red'))
		end
		if disOn then
			InterruptAndDispel_Message('Dispel announce is ' .. InterruptAndDispel_ColorMessage(disOn, 'green'))
		else
			InterruptAndDispel_Message('Dispel announce is ' .. InterruptAndDispel_ColorMessage(disOn, 'red'))
		end
		if friendlyOn then
			InterruptAndDispel_Message('Friendly Dispel announce is ' .. InterruptAndDispel_ColorMessage(disOn, 'green'))
		else
			InterruptAndDispel_Message('Friendly Dispel announce is ' .. InterruptAndDispel_ColorMessage(disOn, 'red'))
		end
		
		if (IAD_AnnounceTo == "PARTY") then
			InterruptAndDispel_Message('Announcing to ' .. InterruptAndDispel_ColorMessage(IAD_AnnounceTo, 'blue'))
		elseif (IAD_AnnounceTo == "RAID" or IAD_AnnounceTo == "RAID_WARNING" or IAD_AnnounceTo == "INSTANCE_CHAT") then
			InterruptAndDispel_Message('Announcing to ' .. InterruptAndDispel_ColorMessage(IAD_AnnounceTo, 'orange'))
		elseif (IAD_AnnounceTo == "YELL" or IAD_AnnounceTo == "EMOTE") then
			InterruptAndDispel_Message('Announcing to ' .. InterruptAndDispel_ColorMessage(IAD_AnnounceTo, 'red'))
		else
			InterruptAndDispel_Message('Announcing to ' .. IAD_AnnounceTo)
		end
	else
		InterruptAndDispel_Message('Commands are based on /iad (ex: /iad on)')
		InterruptAndDispel_Message('  ' .. InterruptAndDispel_ColorMessage('on', 'green') .. 
								   ' | ' .. InterruptAndDispel_ColorMessage('off', 'red') .. 
								   ' (Toggles the addon)')
		InterruptAndDispel_Message('  ' .. InterruptAndDispel_ColorMessage('interrupton', 'green') .. 
								   ' | ' .. InterruptAndDispel_ColorMessage('interruptoff', 'red') .. 
								   ' (Toggles interrupt announcements)')
		InterruptAndDispel_Message('  ' .. InterruptAndDispel_ColorMessage('dispelon', 'green') .. 
								   ' | ' .. InterruptAndDispel_ColorMessage('dispeloff', 'red') .. 
								   ' (Toggles dispel announcements)')
		InterruptAndDispel_Message('  ' .. InterruptAndDispel_ColorMessage('dispelfriendlyon', 'green') .. 
								   ' | ' .. InterruptAndDispel_ColorMessage('dispelfriendlyoff', 'red') .. 
								   ' (Toggles dispel announcements)')
		InterruptAndDispel_Message('  self (Output only to self)')
		InterruptAndDispel_Message('  say | ' .. InterruptAndDispel_ColorMessage('yell', 'red') .. 
								   ' | ' .. InterruptAndDispel_ColorMessage('party', 'blue') .. 
								   ' | ' .. InterruptAndDispel_ColorMessage('raid', 'orange') .. 
								   ' | ' .. InterruptAndDispel_ColorMessage('rw', 'orange') .. 
								   ' | ' .. InterruptAndDispel_ColorMessage('emote', 'red') .. 
								   ' | ' .. InterruptAndDispel_ColorMessage('instance', 'orange') .. 
								   ' (Announces to /s ' .. InterruptAndDispel_ColorMessage('/y', 'orange') .. 
								   ' ' .. InterruptAndDispel_ColorMessage('/p', 'blue') .. 
								   ' ' .. InterruptAndDispel_ColorMessage('/r', 'orange') .. 
								   ' ' .. InterruptAndDispel_ColorMessage('/rw', 'orange') .. 
								   ' ' .. InterruptAndDispel_ColorMessage('/e', 'red') .. 
								   ' or ' .. InterruptAndDispel_ColorMessage('/i', 'orange'))
		InterruptAndDispel_Message('  ' .. InterruptAndDispel_ColorMessage('current', 'orange') .. 
								   ' | ' .. InterruptAndDispel_ColorMessage('settings', 'orange') .. 
								   ' (prints current settings)')
	end

end
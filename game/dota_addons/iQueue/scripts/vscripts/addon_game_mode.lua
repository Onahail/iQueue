
-- Generated from template

-- Needed to communicate with the iQueue.lua file
require('iQueue')




if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	
	-- For iQueue standalone, not needed for functionality of mod
	PrecacheResource("model", "models/props_structures/bad_ancient_destruction.vmdl", context)
	PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee_mega.vmdl", context)
	PrecacheResource("model", "models/buildings/building_racks_melee_reference.vmdl", context)
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_ogre_med/n_creep_ogre_med.vmdl", context)
	PrecacheResource("model", "models/props_structures/good_barracks_melee001.vmdl", context)
	PrecacheResource("particle", "particles/iqueue_particles/rally_flag.vpcf", context)
	PrecacheResource("particle", "particles/ui_mouseactions/clicked_unit_select.vpcf", context)
	
	
	
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
	iQueue:Init() -- Required for initialize iQueue system
end

function CAddonTemplateGameMode:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
end

-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end
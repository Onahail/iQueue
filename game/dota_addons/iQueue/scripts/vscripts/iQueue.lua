--[[
There are iQueue specific functions within OnEntityKilled and OnHeroInGame
]]
require('iQueue_BuildingQueue')
require('iQueue_RallyPoints')

UPGRADE_MODIFIER_ITEM = CreateItem( "item_upgrade_modifiers", source, source)


-- Temporary function. Will be remove from the library
function CreateBuilding( event )
		local caster = event.caster
		local hero = caster:GetPlayerOwner():GetAssignedHero()
		local playerID = hero:GetPlayerID()
		local player = PlayerResource:GetPlayer(playerID)
		local team = caster:GetTeam()
		local target = event.target_points[1]
		local buildingName = event.Building
		
		local building = CreateUnitByName(buildingName, target, true, player, player, team)
		building:SetControllableByPlayer(playerID, true)
		building:SetOwner(player)
		building:SetModelScale(0.5)
		
		--print("Player is: ", player)
		--print("Building is: ", building)
		if FindUnitLabel(building, "CanQueue") then
			BuildingQueue:InitializeBuildingEntity( building )
		end


		--print('Building created')
end
-------------------------------------------------------

if iQueue == nil then
	_G.iQueue = class({})
end


function iQueue:Init()

	print("Initiating iQueue")

	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
	GameRules.HeroKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
	GameRules.ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
	GameRules.Upgrades = LoadKeyValues("scripts/kv/upgrades.kv")
	
	--Register game listeners
	ListenToGameEvent('entity_killed', Dynamic_Wrap(iQueue, 'EntityKilled'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(iQueue, 'NPCSpawned'), self)
	
	--Register Custom Listeners
	CustomGameEventManager:RegisterListener( "mass_queue_units", Dynamic_Wrap(iQueue, "MassQueueUnits"))
	CustomGameEventManager:RegisterListener( "queue_research_or_upgrade", Dynamic_Wrap(iQueue, "QueueResearchOrUpgrade"))
	CustomGameEventManager:RegisterListener( "remove_from_queue", Dynamic_Wrap(iQueue, "RemoveFromQueue"))
	CustomGameEventManager:RegisterListener( "destroy_queue_timer", Dynamic_Wrap(iQueue, "DestroyQueueTimer"))
	CustomGameEventManager:RegisterListener( "player_set_rally_point_ground", Dynamic_Wrap(RallyPoints, "PlayerSetRallyPointGround"))
	CustomGameEventManager:RegisterListener( "player_set_rally_point_entity", Dynamic_Wrap(RallyPoints, "PlayerSetRallyPointEntity"))
	CustomGameEventManager:RegisterListener( "player_removed_rally_point", Dynamic_Wrap(RallyPoints, "PlayerRemovedRallyPoint")) 

end


function iQueue:NPCSpawned( keys )

	local npc = EntIndexToHScript(keys.entindex)

	if npc:IsRealHero() and npc.FirstSpawn == nil then
		npc.FirstSpawn = true
		iQueue:HeroInGame(npc)
	end
end

function iQueue:HeroInGame( hero )

	hero.IsBuilding = false;
	
	local player = hero:GetOwner()
	local playerID = player:entindex()
	print("Creating player tables for PlayerID: ", playerID)
	player['upgrades'] = player['upgrades'] or {} -- Tracks all upgrades a player has completed
	player['units'] = player['units'] or {} -- Tracks all units a player owns for applying upgrades
	player['structures'] = player['structures'] or {} -- Tracks all structures a player owns for applying upgrades
	player['research'] = player['research'] or {} -- Tracks all completed research to remove it from future buildings
	player['QueueTrack'] = player['QueueTrack'] or {} -- Contains flags to handle hiding/showing abilities on buildings
	table.insert(player['units'], hero)
end



function iQueue:EntityKilled( keys )

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
	local player = killedUnit:GetOwner()
	
	if killedUnit.IsBuilding == true then
		player['structures'][killedUnit] = nil
	else
		player['units'][killedUnit] = nil
	end
	-- Uncomment this block of code is you need any of these values
	--[[ 
	-- The Killing entity
  local killerEntity = nil
  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  -- The ability/item used to kill, or nil if not killed by an item/ability
  local killerAbility = nil

  if keys.entindex_inflictor ~= nil then
    killerAbility = EntIndexToHScript( keys.entindex_inflictor )
  end

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
	]]--
end


function iQueue:MassQueueUnits( event )
	print("Executing order")
	--print("abilityName is: ", event.AbilityName)
	local building = EntIndexToHScript(event.entIndex)
	local queueTime = event.QueueTime
	local queueType = event.QueueType
	local whatToQueue = event.WhatToQueue
	if building:FindAbilityByName(event.AbilityName) ~= nil then
		if #building['Queue'] + 1 < MAX_BUILDING_QUEUE then
			building['RUSlot'][#building['Queue']+1] = true;
		end
		building:AddToQueue( event.AbilityName, queueTime, queueType, whatToQueue )
	else
		print("This building does not have the specified ability")
	end
end


function iQueue:QueueResearchOrUpgrade( event )
	local mainSelectedBuilding = EntIndexToHScript(event.entIndexMainSelected)
	local selectedEntities = event.selectedEntities
	local queueTime = event.QueueTime
	local queueType = event.QueueType
	local whatToQueue = event.WhatToQueue
	local building = FindFreeSlot(mainSelectedBuilding, selectedEntities, event.AbilityName)
	if building ~= nil then
			--print("Adding queue to building. Index:", building:GetEntityIndex())
			building:AddToQueue( event.AbilityName, queueTime, queueType, whatToQueue)
	end
end





function iQueue:RemoveFromQueue( event )
	local building = EntIndexToHScript(event.entindex)
	local player = building:GetOwner()
	local queuePosition = event.slotNumber
	local abilityName = building['Queue'][queuePosition].abilityName
	if building['Queue'][queuePosition].queueType == ("Upgrade" or "Research") then
		player['QueueTrack'][abilityName].inQueue = false;
		ShowHideOrRemoveAbility( player, abilityName, building['Queue'][queuePosition].whatToQueue )
	end
	building['RUSlot'][#building['Queue']] = false;
	--print("RUSlot ", #building['Queue'], "is", building['RUSlot'][#building['Queue']])
	local x = table.remove(building['Queue'], queuePosition)
	if queuePosition == 1 then
		building:DestroyQueueTimer()
	end
end


function Queue( event )
	
	local player = event.caster:GetOwner()
	local abilityName = event.ability:GetAbilityName()
	--print("abilityName is: ", abilityName)
	local whatToQueue = nil --What is being queued up?
	if event.QueueType == "Unit" then
		whatToQueue = event.UnitName
		CustomGameEventManager:Send_ServerToPlayer( player, "mass_queue", {AbilityName = abilityName, WhatToQueue = whatToQueue, QueueTime = event.QueueTime, QueueType = event.QueueType} )	
	elseif event.QueueType == "Research" then
		whatToQueue = event.ResearchName
	elseif event.QueueType == "Upgrade" then
		whatToQueue = event.UpgradeName
		event.ability:SetHidden(true)
		CustomGameEventManager:Send_ServerToPlayer( player, "research_or_upgrade_queue", {AbilityName = abilityName, WhatToQueue = whatToQueue, QueueTime = event.QueueTime, QueueType = event.QueueType} )	
	else
		print ("No QueueType specified... Breaking")
		return;
	end
end

function UpdatePlayerUpgrades( player, upgradeName, abilityName )
	local player_upgrades = GameRules.Upgrades
	print(upgradeName)
	local maxRank = player_upgrades[upgradeName]["max_rank"]
	local modifier = "modifier_"..upgradeName
	--print(modifier)
	if player['upgrades'][upgradeName] == nil then
		player['upgrades'][upgradeName] = {}
		player['upgrades'][upgradeName].rank = 1
		--DeepPrintTable(player['upgrades'])
		--print(upgradeName, "sucessfully upgraded, it is now rank 1")
		player['QueueTrack'][abilityName].inQueue = false
		ShowHideOrRemoveAbility( player, abilityName, upgradeName )
	elseif maxRank > 1 and player['upgrades'][upgradeName].rank < maxRank then
		player['upgrades'][upgradeName].rank = player['upgrades'][upgradeName].rank + 1
		--print(upgradeName, "sucessfully upgraded again, it is now rank", player['upgrades'][upgradeName].rank)
		player['QueueTrack'][abilityName].inQueue = false
		ShowHideOrRemoveAbility( player, abilityName, upgradeName )
	else
		print("Something went wrong in UpdatePlayerUpgrades")
	end
	for _,unit in pairs(player['units']) do	
		ApplyUpgrade(upgradeName, unit, modifier, player['upgrades'][upgradeName].rank)
	end
end


function ApplyUpgrade( upgrade, unit, modifier, rank )
	--print("Rank within ApplyUpgrade", rank)
	local player_upgrades = GameRules.Upgrades
	local unitName = unit:GetUnitName()
	
	if player_upgrades[upgrade][unitName] then	
		if rank == 1 then
			GiveUnitDataDrivenModifier(unit, unit, modifier, -1)
		elseif unit:HasModifier(modifier) then
			unit:SetModifierStackCount(modifier, unit, rank)
		else
			GiveUnitDataDrivenModifier(unit, unit, modifier, -1)
			unit:SetModifierStackCount(modifier, unit, rank)
		end
	end
end


function SpawnUnit( unit, building, player )

	local playerID = player:GetPlayerID()
	local team = player:GetTeam()
	local location = building:GetAbsOrigin()
	
	local unitSpawned =	CreateUnitByName(unit, location, true, player, player, team)
	unitSpawned:SetControllableByPlayer(playerID, true)
	unitSpawned:SetOwner(player)
	unitSpawned.IsBuilding = false;
	table.insert(player['units'], unitSpawned)
	--Apply owned upgrades to new spawned units
	unitName = unitSpawned:GetUnitName()
	
	if player['upgrades'] ~= nil then
		for upgradeOwned,_ in pairs(player['upgrades']) do
			local modifier = "modifier_"..upgradeOwned
			ApplyUpgrade(upgradeOwned, unitSpawned, modifier, player['upgrades'][upgradeOwned].rank)
		end
	end
	
	
	if building['RallyPoint'].rallySet == true then
		building:MoveToRallyPoint(unitSpawned)
	end
end


function UnlockResearch()
end

function FindFreeSlot(mainSelectedBuilding, selectedEntities, abilityName)
	local mainEntity = mainSelectedBuilding:GetEntityIndex()
		for slotNumber=1,6 do
			if mainSelectedBuilding['RUSlot'][slotNumber] == false then
				mainSelectedBuilding['RUSlot'][slotNumber] = true
				return mainSelectedBuilding
			end
			for indexAsString, selectedEntity in pairs(selectedEntities) do 
				if selectedEntity ~= mainEntity or slotNumber ~= 1 then 
					local building = EntIndexToHScript(selectedEntity)
					if building:FindAbilityByName(abilityName) ~= nil then
						if building['RUSlot'][slotNumber] == false then
							building['RUSlot'][slotNumber] = true
							return building
						end
					else
						print("Building does not have specified ability. Moving on.")
					end
				end
			end
		end
	return nil, nil
end



function ShowHideOrRemoveAbility( player, abilityName, upgradeName)
	local player_upgrades = GameRules.Upgrades
	local maxRank = player_upgrades[upgradeName]["max_rank"]
	
	for _,building in pairs(player['structures']) do
		if player['QueueTrack'][abilityName].inQueue == true then
			building:HideAbility(abilityName)
		elseif player['QueueTrack'][abilityName].inQueue == false then
			building:ShowAbility(abilityName)
		else
			print("Something went wrong in ShowHideOrRemoveAbility")
		end
	end
	
	if player['upgrades'][upgradeName] then
		if player['upgrades'][upgradeName].rank == maxRank then
			print(abilityName, "is now max rank. Removing from all buildings")
			for _,building in pairs(player['structures']) do
				building:RemoveAbility(abilityName)
			end
		end
	end
end


function GiveUnitDataDrivenModifier(source, target, modifier, dur)
    --source and target should be hscript-units. The same unit can be in both source and target
    UPGRADE_MODIFIER_ITEM:ApplyDataDrivenModifier( source, target, modifier, {duration=dur} )
end

function FindUnitLabel(entity, queryLabel)
	local unitLabel = entity:GetUnitLabel()
	if string.match(unitLabel, queryLabel) then
		return true
	else
		--print("Unit does not contain", queryLabel)
		return false
	end
end

function table_invert(t)
  local u = { }
  for k, v in pairs(t) do u[v] = k end
  return u
end


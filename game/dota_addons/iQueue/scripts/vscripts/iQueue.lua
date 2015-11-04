--[[

There are iQueue specific functions within OnEntityKilled and OnHeroInGame

]]

require('iQueue_upgrades')

MAX_BUILDING_QUEUE = 6

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
		InitalizeBuildingQueue( building )
		building.IsBuilding = true;
		table.insert(player['structures'], building)
		for abilityName,_ in pairs(player['QueueTrack']) do
			--print(abilityName)
			local ability = building:FindAbilityByName(abilityName)
			if ability ~= nil then
				if player['QueueTrack'][abilityName].inQueue == true then
					ability:SetHidden(true)
				end
			end
		end
		
		
		--print('Building created')
		
end

function InitalizeBuildingQueue( building )
	
	local buildingName = building:GetUnitName()
	local unitLabel = building:GetUnitLabel()
	
	if unitLabel == "CanQueue" then
		--print("Queue created for: ", buildingName)
		building['Queue'] = {}
		building['RUSlot'] = {}
		
		-- Queue slot flags for Research and Upgrade
		-- These flags will handle queue behavior for Researchs and Upgrades
		
		
		building['RUSlot'][1] = false;
		building['RUSlot'][2] = false;
		building['RUSlot'][3] = false;
		building['RUSlot'][4] = false;
		building['RUSlot'][5] = false;
		building['RUSlot'][6] = false;
		--building['Queue']['UnitTable'] = {}
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



function IQueue:MassQueueUnits( event )

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
		
		AddToQueue(building, event.AbilityName, queueTime, queueType, whatToQueue)
	else
		print("This building does not have the specified ability")
	end

end


function IQueue:QueueResearchOrUpgrade( event )

	local mainSelectedBuilding = EntIndexToHScript(event.entIndexMainSelected)
	local selectedEntities = event.selectedEntities
	
	local queueTime = event.QueueTime
	local queueType = event.QueueType
	local whatToQueue = event.WhatToQueue
	
	local building = FindFreeSlot(mainSelectedBuilding, selectedEntities, event.AbilityName)
	if building ~= nil then
			--print("Adding queue to building. Index:", building:GetEntityIndex())
			AddToQueue(building, event.AbilityName, queueTime, queueType, whatToQueue)
	end
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


function AddToQueue( building, abilityName, queueTime, queueType, whatToQueue )

	local player = building:GetOwner()
	local playerID = building:GetOwner():GetPlayerID()
	local team = player:GetTeam()
	
	building.state = building.state or "Not Building"
	
	local queueTable = {whatToQueue = whatToQueue, queueTime = queueTime, abilityName = abilityName, queueType = queueType}
	
	if building['Queue'] == nil then
		InitalizeBuildingQueue( building )
		print("Building Queue never initialized. Creating it now. This should never happen")
	end
	
	if #building['Queue'] < MAX_BUILDING_QUEUE then
		table.insert(building['Queue'], queueTable)
		
		
		
		if queueType == ("Upgrade" or "Research") then
			player['QueueTrack'][abilityName] = abilityName;
			player['QueueTrack'][abilityName] = {};
			player['QueueTrack'][abilityName].inQueue = true;

			ShowHideOrRemoveAbility(player, abilityName, building['Queue'][1].whatToQueue)
		end

		CustomGameEventManager:Send_ServerToPlayer( player, "add_to_queue", { queueTime = queueTime, abilityName = abilityName, entindex = building:entindex() })
		if building.state == "Not Building" then
			
			--print ("Starting queue")
			StartQueue(building, queueTime, queueType, abilityName)
		
		end
	else
		print("MAX QUEUE LIMIT REACHED!")
	end
end

function StartQueue(building, queueTime, queueType, abilityName )

	local player = building:GetOwner()
	local playerID = building:GetOwner():GetPlayerID()
	local team = player:GetTeam()
	
	local currentGameTime = GameRules:GetGameTime();
	
	--print(currentGameTime)
	--print("StartQueue called")
	--print(queueType ,building['Queue'][1].whatToQueue, "has started, it will be finished in ", queueTime, " seconds.")
	
	building.state = "Building"
	
	CustomGameEventManager:Send_ServerToPlayer( player, "show_timer", { queueTime = queueTime, currentGameTime = currentGameTime, index = building:entindex() })

	building.timer = Timers:CreateTimer(building['Queue'][1].queueTime, function()
			
		if queueType == "Unit" then
			SpawnUnit(building, player, playerID, team)
		elseif queueType == "Research" then
			UnlockResearch()
		elseif queueType =="Upgrade" then
			UpdatePlayerUpgrades(building, player, playerID, abilityName)
		else	
			print("QueueType not specified... Breaking")
			return;
		end
		

		local x = table.remove(building['Queue'], 1)
		
		CustomGameEventManager:Send_ServerToPlayer( player, "remove_from_queue", { entindex = building:entindex() })
		if #building['Queue'] > 0 then
				StartQueue( building, building['Queue'][1].queueTime, building['Queue'][1].queueType, building['Queue'][1].abilityName )
		else
			building.state = "Not Building"
			return;
		end
	end)
end



function UnlockResearch()

end

function SpawnUnit(building, player, playerID, team)
	
	local unitSpawned =	CreateUnitByName(building['Queue'][1].whatToQueue, building:GetAbsOrigin(), true, player, player, team)
	
	unitSpawned:SetControllableByPlayer(playerID, true)
	unitSpawned:SetOwner(player)
	unitSpawned.IsBuilding = false;
	table.insert(player['units'], unitSpawned)
	
	--Apply owned upgrades to new spawned units
	unitName = unitSpawned:GetUnitName()
	upgradesKV = GameRules.Upgrades
	
	if player['upgrades'] ~= nil then
		for upgradeOwned,_ in pairs(player['upgrades']) do
			--print(upgradeOwned)
			--print(player['upgrades'][upgradeOwned].rank)
			if upgradesKV[upgradeOwned][unitName] then
				local modifier = "modifier_"..upgradeOwned
				local rank = player['upgrades'][upgradeOwned].rank
				GiveUnitDataDrivenModifier(unitSpawned, unitSpawned, modifier, -1)
				unitSpawned:SetModifierStackCount(modifier, unitSpawned, rank)
			end
		end
	end
	
end


function IQueue:RemoveFromQueue( event )

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
		DestroyQueueTimer( building )
	end
end


function DestroyQueueTimer( building )

	local player = building:GetOwner()
	
	Timers:RemoveTimer( building.timer )
  Timers.timers[ building.timer ] = nil
	
	if #building['Queue'] > 0 then
			StartQueue( building, building['Queue'][1].queueTime, building['Queue'][1].queueType )
			CustomGameEventManager:Send_ServerToPlayer( player, "update_timer", { entindex = building:entindex() })
	else
		building.state = "Not Building"
		CustomGameEventManager:Send_ServerToPlayer( player, "change_timer_state", { entindex = building:entindex() })
	return;
	end
	
end
	

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end




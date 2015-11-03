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
		
		print("Player is: ", player)
		print("Building is: ", building)
		InitalizeBuildingQueue( building )
		building.IsBuilding = true;
		table.insert(player['structures'], building)
		
		
		print('Building created')
		
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
	print("abilityName is: ", abilityName)
	local whatToQueue = nil --What is being queued up?
	
	if event.QueueType == "Unit" then
		whatToQueue = event.UnitName
		CustomGameEventManager:Send_ServerToPlayer( player, "mass_queue", {ability = event.ability, AbilityName = abilityName, WhatToQueue = whatToQueue, QueueTime = event.QueueTime, QueueType = event.QueueType} )	
	elseif event.QueueType == "Research" then
		whatToQueue = event.ResearchName
	elseif event.QueueType == "Upgrade" then
		whatToQueue = event.UnitName -- Testing upgrade and research queue behavior
		--whatToQueue = event.UpgradeName
		CustomGameEventManager:Send_ServerToPlayer( player, "research_or_upgrade_queue", {ability = event.ability, AbilityName = abilityName, WhatToQueue = whatToQueue, QueueTime = event.QueueTime, QueueType = event.QueueType} )	
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
	
	
	if building:FindAbilityByName(event.AbilityName):GetEntityIndex() == nil then
		print("This building does not have the specified ability")
		return
	end
	
	AddToQueue(building, event.ability, event.AbilityName, queueTime, queueType, whatToQueue)
		
	
end


function IQueue:QueueResearchOrUpgrade( event )

	local mainSelectedBuilding = EntIndexToHScript(event.entIndexMainSelected)
	local selectedEntities = event.selectedEntities
	
	local queueTime = event.QueueTime
	local queueType = event.QueueType
	local whatToQueue = event.WhatToQueue
	
	local building = FindFreeSlot(mainSelectedBuilding, selectedEntities)
	if building ~= nil then
			print("Adding queue to seperate building. Index:", building:GetEntityIndex())
			AddToQueue(building, event.ability, event.AbilityName, queueTime, queueType, whatToQueue)
	end
end



function FindFreeSlot(mainSelectedBuilding, selectedEntities)

	local slotFound = false;
	local building = nil;
	local mainEntity = mainSelectedBuilding:GetEntityIndex()
	local slotNumber = 1
	
	
	while slotFound == false do
	
		if mainSelectedBuilding['RUSlot'][slotNumber] == false then
			mainSelectedBuilding['RUSlot'][slotNumber] = true
			print("Value of building['RUSlot'][",slotNumber,"]", "is now", mainSelectedBuilding['RUSlot'][slotNumber])
			slotFound = true
			print("Open slot found on building entity", selectedEntity)
			return mainSelectedBuilding;
		end
	
		for indexAsString, selectedEntity in pairs(selectedEntities) do 
		
			if selectedEntity ~= mainEntity then
				building = EntIndexToHScript(selectedEntity)
				--print("Index of building in FindFreeSlot", building:GetEntityIndex())
				--print("Value of building['RUSlot'][",slotNumber,"]", "is", building['RUSlot'][slotNumber])
				
				if building['RUSlot'][slotNumber] == false then
					building['RUSlot'][slotNumber] = true
					print("Value of building['RUSlot'][",slotNumber,"]", "is now", building['RUSlot'][slotNumber])
					slotFound = true
					print("Open slot found on building entity", selectedEntity)
					return building;
				end
			end
    end		
		if slotNumber < 6 then
			slotNumber = slotNumber + 1
			print("No buildings have RUSlotNumber", slotNumber, "free. Iterating around to RUSlotNumber", slotNumber + 1)
		else
			print("Reached maximum number of available research slots")
			break;
		end
	end
end





function AddToQueue( building, ability, abilityName, queueTime, queueType, whatToQueue )

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
		CustomGameEventManager:Send_ServerToPlayer( player, "add_to_queue", { queueTime = queueTime, abilityName = abilityName, entindex = building:entindex() })
		if building.state == "Not Building" then
			
			--print ("Starting queue")
			StartQueue(building, queueTime, queueType)
		
		end
	else
		print("MAX QUEUE LIMIT REACHED!")
	end
end

function StartQueue(building, queueTime, queueType )

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
			SpawnUnit(building, player, playerID, team)
			--UpdatePlayerUpgrades(building, player, playerID)
		else	
			print("QueueType not specified... Breaking")
			return;
		end
		
		local x = table.remove(building['Queue'], 1)
		CustomGameEventManager:Send_ServerToPlayer( player, "remove_from_queue", { entindex = building:entindex() })
		if #building['Queue'] > 0 then
				StartQueue( building, queueTime, queueType )
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
	
end


function IQueue:RemoveFromQueue( event )

	local building = EntIndexToHScript(event.entindex)
	local queuePosition = event.slotNumber
	
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





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
		
		
		print('Building created')
		
end

function InitalizeBuildingQueue( building )
	
	local buildingName = building:GetUnitName()
	local unitLabel = building:GetUnitLabel()
	
	if unitLabel == "CanQueue" then
		print("Queue created for: ", buildingName)
		building['Queue'] = {}
		building['Queue']['UnitTable'] = {}
	end
end




function Queue( event )
	
	local player = event.caster:GetOwner()
	local abilityName = event.ability:GetAbilityName()
	print("abilityName is: ", abilityName)
	local whatToQueue = nil --What is being queued up?
	
	if event.QueueType == "Unit" then
		whatToQueue = event.UnitName
	elseif event.QueueType == "Research" then
		whatToQueue = event.ResearchName
	elseif event.QueueType == "Upgrade" then
		whatToQueue = event.UpgradeName
	else
		print ("No QueueType specified... Breaking")
		return;
	end
	

	CustomGameEventManager:Send_ServerToPlayer( player, "mass_queue", {ability = event.ability,
																																		 AbilityName = abilityName,
																																		 WhatToQueue = whatToQueue, 
																																		 QueueTime = event.QueueTime,
																																		 QueueType = event.QueueType} )
	
end



function IQueue:ExecuteOrder( event )

	print("Executing order")
	--print("abilityName is: ", event.AbilityName)
	
	local unitHandle = EntIndexToHScript(event.entIndex)
	local queueTime = event.QueueTime
	local queueType = event.QueueType
	local whatToQueue = event.WhatToQueue
	
	
	if unitHandle:FindAbilityByName(event.AbilityName):GetEntityIndex() == nil then
		print("This building does not have the specified ability")
		return
	end
	
	AddToQueue(unitHandle, event.ability, event.AbilityName, queueTime, queueType, whatToQueue)
	
end


function AddToQueue( building, ability, abilityName, queueTime, queueType, whatToQueue )

	local player = building:GetOwner()
	local playerID = building:GetOwner():GetPlayerID()
	local team = player:GetTeam()
	
	building.state = building.state or "Not Building"
	
	local queueTable = {whatToQueue = whatToQueue, queueTime = queueTime, abilityName = abilityName}
	
	if building['Queue'] == nil then
		InitalizeBuildingQueue( building )
		print("Building Queue never initialized. Creating it now. This should never happen")
	end
	
	
	print (whatToQueue, "added to queue, it will be finished in ", queueTime, " seconds.")
	
	if #building['Queue'] < MAX_BUILDING_QUEUE then
		table.insert(building['Queue'], queueTable)
		CustomGameEventManager:Send_ServerToPlayer( player, "add_to_queue", { queueTime = queueTime, abilityName = abilityName })
		if building.state == "Not Building" then
			
			print ("Starting queue")
			function building.StartQueue()

				print("StartQueue called")
			
				building.state = "Building"

				building.timer = Timers:CreateTimer(building['Queue'][1].queueTime, function()
						
						if queueType == "Unit" then
							SpawnUnit(building, player, playerID, team)
						elseif queueType == "Research" then
							UnlockResearch()
						elseif queueType =="Upgrade" then
							ApplyUpgrade()
						else	
							print("QueueType not specified... Breaking")
							return;
						end
						
						local queueItem = table.remove(building['Queue'], 1)
						CustomGameEventManager:Send_ServerToPlayer( player, "remove_from_queue", { entindex = building:entindex() })
						if building['Queue'][1] ~= nil then
								building.StartQueue()
						else
							building.state = "Not Building"
							return;
						end
					end)
				end
				building.StartQueue()
		end
	else
		print("MAX QUEUE LIMIT REACHED!")
	end
end


function ApplyUpgrade()

end

function UnlockResearch()

end

function SpawnUnit(building, player, playerID, team)
	
	local unitSpawned =	CreateUnitByName(building['Queue'][1].whatToQueue, building:GetAbsOrigin(), true, player, player, team)
	
	unitSpawned:SetControllableByPlayer(playerID, true)
	unitSpawned:SetOwner(player)
	
end

	






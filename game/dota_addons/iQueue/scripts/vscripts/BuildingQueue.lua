MAX_BUILDING_QUEUE = 6



if BuildingQueue == nil then
	print ('[BUILDINGQUEUE] creating BuildingQueue')
	BuildingQueue = {}
	BuildingQueue.__index = BuildingQueue
end

function BuildingQueue:new( o )
	o = o or {}
	setmetatable( o, BuildingQueue )
	return o
end

function BuildingQueue:start()
	BuildingQueue = self
end

function BuildingQueue:InitializeBuildingEntity( building )

	local owner = building:GetOwner()
	
	building.IsBuilding = true;
	building.state = "Not Building"
	table.insert(owner['structures'], building)
	
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
	
	for buildingAbilities,_ in pairs(owner['QueueTrack']) do
		local buildingAbility = building:FindAbilityByName(buildingAbilities)
		if buildingAbility ~= nil then
			if owner['QueueTrack'][buildingAbilities].inQueue == true then
				buildingAbility:SetHidden(true)
			end
		end
	end

	function building:AddToQueue( abilityName, queueTime, queueType, whatToQueue )

		local queueTable = {whatToQueue = whatToQueue, queueTime = queueTime, abilityName = abilityName, queueType = queueType}
		
		if #building['Queue'] < MAX_BUILDING_QUEUE then
			table.insert(building['Queue'], queueTable)
			if queueType == ("Upgrade" or "Research") then
				owner['QueueTrack'][abilityName] = abilityName;
				owner['QueueTrack'][abilityName] = {};
				owner['QueueTrack'][abilityName].inQueue = true;
				ShowHideOrRemoveAbility(owner, abilityName, building['Queue'][1].whatToQueue)
			end
			CustomGameEventManager:Send_ServerToPlayer( owner, "add_to_queue", { queueTime = queueTime, abilityName = abilityName, entindex = building:entindex() })
			if building.state == "Not Building" then
				--print ("Starting queue")
				building:StartQueue(queueTime, queueType, abilityName)
			end
		else
			print("MAX QUEUE LIMIT REACHED!")
		end
	end
	
	function building:StartQueue( queueTime, queueType, abilityName )

		local currentGameTime = GameRules:GetGameTime();
		print(queueType ,building['Queue'][1].whatToQueue, "has started, it will be finished in ", queueTime, " seconds.")
		building.state = "Building"
		CustomGameEventManager:Send_ServerToPlayer( owner, "show_timer", { queueTime = queueTime, currentGameTime = currentGameTime, index = building:entindex() })
		building.timer = Timers:CreateTimer(building['Queue'][1].queueTime, function()
			if queueType == "Unit" then
				SpawnUnit(building['Queue'][1].whatToQueue, building:GetAbsOrigin(), owner )
			elseif queueType == "Research" then
				UnlockResearch()
			elseif queueType =="Upgrade" then
				local upgradeName = building['Queue'][1].whatToQueue
				UpdatePlayerUpgrades( owner, building['Queue'][1].whatToQueue, abilityName )
			else	
				print("QueueType not specified... Breaking")
				return;
			end
			local x = table.remove(building['Queue'], 1)
			CustomGameEventManager:Send_ServerToPlayer( owner, "remove_from_queue", { entindex = building:entindex() })
			if #building['Queue'] > 0 then
					StartQueue( building, building['Queue'][1].queueTime, building['Queue'][1].queueType, building['Queue'][1].abilityName )
			else
				building.state = "Not Building"
				return;
			end
		end)
	end
		
	function building:DestroyQueueTimer()
		Timers:RemoveTimer( building.timer )
		Timers.timers[ building.timer ] = nil
		if #building['Queue'] > 0 then
				building:StartQueue( building['Queue'][1].queueTime, building['Queue'][1].queueType )
				CustomGameEventManager:Send_ServerToPlayer( owner, "update_timer", { entindex = building:entindex() })
		else
			building.state = "Not Building"
			CustomGameEventManager:Send_ServerToPlayer( owner, "change_timer_state", { entindex = building:entindex() })
		return;
		end
	end



end
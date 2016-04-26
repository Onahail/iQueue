MAX_BUILDING_QUEUE = 6
BUILDING_THINK = 0.01



if BuildingQueue == nil then
	print ('[BUILDINGQUEUE] creating BuildingQueue')
	_G.BuildingQueue = class({})
end


function BuildingQueue:InitializeBuildingEntity( building )

	local owner = building:GetOwner()
	
	if FindUnitLabel(building, "CanRally") then
		RallyPoints:AttachRallyPointControl( building )
	end
		
	
	building.queueCancelled = false
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
				building:StartQueue()
			end
		else
			print("MAX QUEUE LIMIT REACHED!")
		end
	end
	
	function building:StartQueue()
	
		local queueTime = building['Queue'][1].queueTime
		local queueType = building['Queue'][1].queueType
		local whatToQueue = building['Queue'][1].whatToQueue
		local abilityName = building['Queue'][1].abilityName
	
		local currentGameTime = GameRules:GetGameTime();
		local endTime = queueTime + currentGameTime
		print(queueType, whatToQueue, "has started, it will be finished in ", queueTime, " seconds.")
		building.state = "Building"
		CustomGameEventManager:Send_ServerToPlayer( owner, "show_timer", { queueTime = queueTime, currentGameTime = currentGameTime, index = building:entindex() })
		
		if (USE_POPULATION == true and queueType == "Unit") then
			owner:AddToPopulation( GameRules.UnitKV[whatToQueue]["PopCost"] )
		end 
	
	
		building:SetThink(function()
			local timeRemaining = endTime - GameRules:GetGameTime()
			if building:IsAlive() then
				if timeRemaining > 0 and building.queueCancelled == false and IsValidEntity(building) then
					return BUILDING_THINK
				elseif building.queueCancelled == false then
					if queueType == "Unit" then
						SpawnUnit(whatToQueue, building, owner )
					elseif queueType == "Research" then
						UnlockResearch()
					elseif queueType =="Upgrade" then
						local upgradeName = whatToQueue
						UpdatePlayerUpgrades( owner, whatToQueue, abilityName )
					else	
						print("QueueType not specified... Breaking")
						return;
					end
					local x = table.remove(building['Queue'], 1)
					CustomGameEventManager:Send_ServerToPlayer( owner, "remove_from_queue", { entindex = building:entindex() })
					if #building['Queue'] > 0 then
						if (USE_POPULATION == true and queueType == "Unit") then
							if owner['population'].current + GameRules.UnitKV[whatToQueue]["PopCost"] <= owner['population'].total then
								building:StartQueue()
								return BUILDING_THINK
							else
								return BUILDING_THINK
							end
						else
							building:StartQueue()
							return BUILDING_THINK
						end
					else
						building.state = "Not Building"
						return nil
					end
				else
					building.queueCancelled = false
					if #building['Queue'] > 0 then
						return BUILDING_THINK
					else
						return nil
					end
				end	
			else
			 return nil
			end
		end)
	end
	
	function building:DestroyQueueTimer()
		building.queueCancelled = true
		if #building['Queue'] > 0 then
				building:StartQueue( building['Queue'][1].queueTime, building['Queue'][1].queueType )
				CustomGameEventManager:Send_ServerToPlayer( owner, "update_timer", { entindex = building:entindex() })
		else
			building.state = "Not Building"
			CustomGameEventManager:Send_ServerToPlayer( owner, "change_timer_state", { entindex = building:entindex() })
			return;
		end
	end
	
	function building:AbilityHide( abilityName )
		local ability = building:FindAbilityByName(abilityName)
		if ability ~= nil then
			ability:SetHidden(true)
		end	
	end	
	
	function building:AbilityShow( abilityName )
		local ability = building:FindAbilityByName(abilityName)
		if ability ~= nil then
			ability:SetHidden(false)
		end
	end
	
	function building:AbilityRemove( abilityName )
		local ability = building:FindAbilityByName(abilityName)
		if ability ~= nil then
			ability:SetHidden(true)
			building:RemoveAbilityFromBuilding(abilityName)
		end
	end

end

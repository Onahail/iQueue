if Population == nil then
	print ('[POPULATION] creating Population')
	_G.Population = class({})
end

function Population:InitializePopulationForPlayer( player )

	player['population'] = player['population'] or {}
	player['population'].totalUsable = BASE_POPULATION
	player['population'].currentValue = 0
	player['population'].actualTotal = player['population'].totalUsable -- Used for tracking population values past MAX_POPULATION in order to keep track of loss of population sources valuing past MAX_POPULATION
	
	
	
	function Player:IncreaseTotalPopulation( amount )
		
		if player['population'].totalUsable + amount <= MAX_POPULATION then
			player['population'].totalUsable = player['population'].totalUsable + amount
			player['population'].actualTotal = player['population'].totalUsable
	 else
			player['population'].actualTotal = player['population'].actualTotal + amount
			player['population'].totalUsable = MAX_POPULATION
			--print("PLAYER AT MAXIMUM ALLOWABLE POPULATION")
		end

	end

	function Player:DecreaseTotalPopulation( amount )
		
		if player['population'].actualTotal - amount <= MAX_POPULATION then
			player['population'].totalUsable = player['population'].actualTotal - amount
			player['population'].actualTotal = player['population'].totalUsable
			return
		end
		player['population'].actualTotal = player['population'].actualTotal - amount
	end
	
	
	function player:AddToPopulation( amount )
	
		player['population'].current = player['population'].current + amount
		print("Player Current Population:", player['population'].current, "/", player['population'].total)
	
	
	end
	
	function player:RemoveFromPopulation( amount )
		player['population'].current = player['population'].current - amount
		print("Player Current Population:", player['population'].current, "/", player['population'].total)
	end
	
end

function Population:QueuePopulationCheck( player, building )
	
	if building['Queue'][1].queueType ~= "Unit" then
		return true
	end
	
	if player['population'].current + GameRules.UnitKV[building['Queue'][1].whatToQueue]["PopCost"] <= player['population'].totalUsable then
		return true
	else
		return false
	end

end

function Population:TemporaryProductionHalt( player, building )

	--print("Not enough population for:", building['Queue'][1].whatToQueue, ". Halting queue!")
	
	building.queueHalted = true
	
	building:SetThink(function() 
		
		if #building['Queue'] == 0 then
			building:ProcessQueue()
			return nil 
		end
		
		if player['population'].current + GameRules.UnitKV[building['Queue'][1].whatToQueue]["PopCost"] > player['population'].totalUsable then
			return BUILDING_THINK
		end
		building:ProcessQueue()
		CustomGameEventManager:Send_ServerToPlayer( owner, "update_timer", { entindex = building:entindex() })
		return nil
	end, "QueueHaltPopulationCheck")
end

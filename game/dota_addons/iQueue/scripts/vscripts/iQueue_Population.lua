if Population == nil then
	print ('[POPULATION] creating Population')
	_G.Population = class({})
end

 function Activate ()
   GameRules:GetGameModeEntity():SetThink(PrintHello)
 end

 function ForcePopulationOverlayUpdateOnSpawn( player )
   
   return nil
 end

function Population:InitializePopulationForPlayer( player )

	print("Initialing population")
	player['population'] = player['population'] or {}
	player['population'].totalUsable = BASE_POPULATION
	player['population'].current = 0
	player['population'].actualTotal = player['population'].totalUsable -- Used for tracking population values past MAX_POPULATION in order to keep track of loss of population sources valuing past MAX_POPULATION
	
	player:SetThink(function()
		CustomGameEventManager:Send_ServerToPlayer( player, "update_population_values", {currentPopulation = player['population'].current, totalPopulation = player['population'].totalUsable} )
	end, 0.1)
	
	function player:IncreaseTotalPopulation( amount )
		
		if player['population'].totalUsable + amount <= MAX_POPULATION then
			player['population'].totalUsable = player['population'].totalUsable + amount
			player['population'].actualTotal = player['population'].totalUsable
	 else
			player['population'].actualTotal = player['population'].actualTotal + amount
			player['population'].totalUsable = MAX_POPULATION
			--print("PLAYER AT MAXIMUM ALLOWABLE POPULATION")
		end

		CustomGameEventManager:Send_ServerToPlayer( player, "update_population_values", {currentPopulation = player['population'].current, totalPopulation = player['population'].totalUsable} )	
	end

	function player:DecreaseTotalPopulation( amount )
		
		if player['population'].actualTotal - amount <= MAX_POPULATION then
			player['population'].totalUsable = player['population'].actualTotal - amount
			player['population'].actualTotal = player['population'].totalUsable
			CustomGameEventManager:Send_ServerToPlayer( player, "update_population_values", {currentPopulation = player['population'].current, totalPopulation = player['population'].totalUsable} )
			return
		end
		player['population'].actualTotal = player['population'].actualTotal - amount
		
	end
	
	
	function player:AddToPopulation( amount )
		player['population'].current = player['population'].current + amount
		print("Player Current Population:", player['population'].current, "/", player['population'].totalUsable)
		CustomGameEventManager:Send_ServerToPlayer( player, "update_population_values", {currentPopulation = player['population'].current, totalPopulation = player['population'].totalUsable} )
	end
	
	function player:RemoveFromPopulation( amount )
		player['population'].current = player['population'].current - amount
		print("Player Current Population:", player['population'].current, "/", player['population'].totalUsable)
		CustomGameEventManager:Send_ServerToPlayer( player, "update_population_values", {currentPopulation = player['population'].current, totalPopulation = player['population'].totalUsable} )
	end
	
end


function Population:InitializePopulationForBuilding( building )

	local player = building:GetOwner()
		
	function building:QueuePopulationCheck( unitName )
		if player['population'].current + GetPopulationCost( unitName ) <= player['population'].totalUsable then
			return true
		else
			print("Maximum population reached")
			return false
		end
	end
	
	function building:TemporaryProductionHalt()

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

end


function Population:EntityKilled( keys )

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
	local player = killedUnit:GetOwner()
	
	if FindUnitLabel(killedUnit, "PopSource") then
		player:DecreaseTotalPopulation( GetPopulationValue( killedUnit ) )
	end
	
	if GetPopulationCost( killedUnit ) ~= nil then
 		player:RemoveFromPopulation( GetPopulationCost( killedUnit ) )
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



function GetPopulationValue( entity )
	local name = entity
	if type(entity) ~= "string" then 
		name = entity:GetUnitName()
	end
	return GameRules.UnitKV[name]["PopValue"]
end

function GetPopulationCost( entity )
	local name = entity
	if type(entity) ~= "string" then
		name = entity:GetUnitName()
	end
	if GameRules.UnitKV[name] ~= nil then
		return GameRules.UnitKV[name]["PopCost"]
	elseif GameRules.HeroKV[name] ~= nil then
		return GameRules.HeroKV[name]["PopCost"]
	else
		return nil
	end
end 

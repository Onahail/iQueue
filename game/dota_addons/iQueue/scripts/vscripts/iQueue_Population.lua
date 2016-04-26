if Population == nil then
	print ('[POPULATION] creating Population')
	_G.Population = class({})
end

function Population:InitializePopulationForPlayer( player )

	player['population'] = player['population'] or {}
	player['population'].total = BASE_POPULATION
	player['population'].current = 0
	
	function player:IncreasePopulation( amount )
	
		if player['population'].total < MAX_POPULATION then
			player['population'].total = player['population'].total + amount
			print("Player Available Population:", player['population'].total)
		else
			print("PLAYER AT MAXIMUM POPULATION")
		end
	
	
	end
	
	function player:DecreasePopulation( amount )
	
	
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

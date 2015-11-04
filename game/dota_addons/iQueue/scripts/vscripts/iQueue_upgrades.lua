UPGRADE_MODIFIER_ITEM = CreateItem( "item_upgrade_modifiers", source, source)


function UpdatePlayerUpgrades(building, player, playerID, abilityName)
	local upgradesKV = GameRules.Upgrades
	local upgradeName = building['Queue'][1].whatToQueue
	local maxRank = upgradesKV[upgradeName]["max_rank"]
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
		local unitName = unit:GetUnitName()
		if upgradesKV[upgradeName][unitName] then
			--print(unitName, "is eligible for", upgradeName)
			ApplyUpgrade(unit, modifier, player['upgrades'][upgradeName].rank)
		end
	end
end



function ApplyUpgrade( unit, modifier, rank )
	--print("Rank within ApplyUpgrade", rank)
	if rank == 1 then
		GiveUnitDataDrivenModifier(unit, unit, modifier, -1) -- "-1" means that it will last forever
	else
		unit:SetModifierStackCount(modifier, unit, rank)
	end
end


function ShowHideOrRemoveAbility( player, abilityName, upgradeName)
	local upgradesKV = GameRules.Upgrades
	local maxRank = upgradesKV[upgradeName]["max_rank"]
	if player['QueueTrack'][abilityName].inQueue == true then
		--print(abilityName, "currently queued. Hiding from all structures")
		for _,building in pairs(player['structures']) do
			local ability = building:FindAbilityByName(abilityName)
			if ability ~= nil then
				ability:SetHidden(true)
			end
		end
	elseif player['QueueTrack'][abilityName].inQueue == false then
		--print(abilityName, "no longer queued. Showing ability if not max rank")
		for _,building in pairs(player['structures']) do
			local ability = building:FindAbilityByName(abilityName)
			if ability ~= nil then
				ability:SetHidden(false)
			end
		end
	else
		print("Something went wrong in ShowHideOrRemoveAbility")
	end
	if player['upgrades'][upgradeName] then
		if player['upgrades'][upgradeName].rank == maxRank then
			print(abilityName, "is now max rank. Removing from all buildings")
			for _,building in pairs(player['structures']) do
				local ability = building:FindAbilityByName(abilityName)
				if ability ~= nil then
					ability:SetHidden(true)
					building:RemoveAbility(abilityName)
				end
			end
		end
	end
end


function GiveUnitDataDrivenModifier(source, target, modifier, dur)
    --source and target should be hscript-units. The same unit can be in both source and target
    UPGRADE_MODIFIER_ITEM:ApplyDataDrivenModifier( source, target, modifier, {duration=dur} )
end
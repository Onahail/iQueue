
function UpdatePlayerUpgrades(building, player, playerID)

	local upgrades = GameRules.Upgrades
	local upgradeName = building['Queue'][1].whatToQueue
	local maxRank = upgrades[upgradeName][max_rank]

	if table.contains(player['upgrades'], upgradeName) == false then
		table.insert(player['upgrades'], upgradeName)
		player['upgrades'][upgradeName].rank = 1
		print(upgradeName, "sucessfully upgraded, it is now rank 1")
		-- Insert function to apply upgrade modifier
		
		for _,unit in pairs(player['units']) do
			CheckUpgradeEligibility( unit, player )
		end
		
		--GiveUnitDataDrivenModifier(source, target, "modifier_make_deniable", -1) -- "-1" means that it will last forever
		
		
		
	elseif maxRank > 1 and player['upgrades'][upgradeName].rank < maxRank then
		player['upgrades'][upgradeName].rank = player['upgrades'][upgradeName].rank + 1
		print(upgradeName, "sucessfully upgraded again, it is now rank", player['upgrades'][upgradeName].rank)
		-- Insert function to set modifier stacks for upgrade
	else
		print("Something went wrong with the upgrade application")
	end
	
	if player['upgrades'][upgradeName].rank == maxRank then
		print(upgradeName, "is now at max level")
		-- Insert removal function here for upgrade ability
	end
end



function CheckUpgradeEligibility( unit, player )



end



function GiveUnitDataDrivenModifier(source, target, modifier, dur)
    --source and target should be hscript-units. The same unit can be in both source and target
    local item = CreateItem( "item_upgrade_modifiers", source, source)
    item:ApplyDataDrivenModifier( source, target, modifier, {duration=dur} )
end

if Harvesting == nil then
	print ('[HARVESTING] creating Harvesting')
	_G.Harvesting = class({})
end

function Harvesting:FindTreeUnderMouse( event )

	local player = PlayerResource:GetPlayer(event.playerID)
	local mainSelected = EntIndexToHScript(event.mainSelected)
	local mouseVector = Vector(event.mouseLocation["0"], event.mouseLocation["1"], event.mouseLocation["2"])
	local tree = GridNav:GetAllTreesAroundPoint(mouseVector, 10, true)
	local targetCircle = ParticleManager:CreateParticleForPlayer("particles/ui_mouseactions/clicked_unit_select.vpcf", PATTACH_ABSORIGIN, mainSelected, player)
	local bWasTreeClicked = false;

	if tree then
		for k, v in pairs(tree) do
		--print(k, v)
		--print("Making particle")
		bWasTreeClicked = true; 
		ParticleManager:SetParticleControl( targetCircle, 0, v:GetAbsOrigin())
		ParticleManager:SetParticleControl( targetCircle, 1, Vector(0,255,0))
		ParticleManager:SetParticleControl( targetCircle, 2, Vector(50,1,1))
		CustomGameEventManager:Send_ServerToPlayer( player, "tree_clicked", {bWasTreeClicked = bWasTreeClicked})
	end

	end
	

end

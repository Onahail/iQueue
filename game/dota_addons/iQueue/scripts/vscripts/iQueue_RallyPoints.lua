if RallyPoints == nil then
	print ('[RALLYPONTS] creating RallyPoints')
	_G.RallyPoints = class({})
end

function RallyPoints:PlayerSetRallyPointGround( event )
	local building = EntIndexToHScript(event.entIndex)
	local targetPoint = event.targetPoint
	building:SetRallyPointGround(targetPoint)
end

function RallyPoints:PlayerSetRallyPointEntity( event )
	local building = EntIndexToHScript(event.entIndex)
	local targetEntity = EntIndexToHScript(event.targetEntity)
	building:SetRallyPointEntity(targetEntity)
	--print("Target is:", targetEntity:GetUnitName())
end

function RallyPoints:PlayerRemovedRallyPoint( event )
	local building = EntIndexToHScript(event.entIndex)
	building:RemoveRallyPoint()
end

function RallyPoints:AttachRallyPointControl( building )

	-- Initial location of rally point is on the building itself
	local owner = building:GetOwner()
	building['RallyPoint'] = {}
	building['RallyPoint'].rallySet = false
	building['RallyPoint'].TargetRally = false
	building['RallyPoint'].GroundRally = false
	
	function building:SetRallyPointGround(location) -- Coordinates passed from PlayerSetRallyPointGround	
	
		building['RallyPoint'].GroundRally = true
		building['RallyPoint'].TargetRally = false
		
		building['RallyPoint'].position = Vector(location["0"], location["1"], location["2"])
		--print("Vector:", building['RallyPoint'].position)
		building['RallyPoint'].rallySet = true 
	end
	
	function building:SetRallyPointEntity(unitHandle)
		
		building['RallyPoint'].TargetRally = true
		building['RallyPoint'].GroundRally = false
		
		building['RallyPoint'].targetEntity = unitHandle
		building['RallyPoint'].rallySet = true
	end
	
	function building:RemoveRallyPoint()
		building['RallyPoint'].TargetRally = false
		building['RallyPoint'].GroundRally = false
		building['RallyPoint'].position = building:GetAbsOrigin()
	end
	
	
	function building:MoveToRallyPoint(unit)
		
		if building['RallyPoint'].GroundRally == true then
			local order = {UnitIndex = unit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = building['RallyPoint'].position,	 Queue = true}
			ExecuteOrderFromTable(order)
		elseif building['RallyPoint'].TargetRally == true then
			print("Moving to ", building['RallyPoint'].targetEntity:GetUnitName(), building['RallyPoint'].targetEntity:entindex())
			local order = {UnitIndex = unit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET, TargetIndex = building['RallyPoint'].targetEntity:entindex(),	Queue = true}
			ExecuteOrderFromTable(order)
		end
		
		
		
	end
	
	function building:MoveToRallyPointEntity(unit)
		
		local order = {UnitIndex = unit:entindex(),
									 OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
									 Position = building['RallyPoint'].position,
									 Queue = true}
		
		ExecuteOrderFromTable(order)
		
	end	
	

end

------------------------------------------------------------------------
-- Village class - container for early generation of citizens
-- 'k2cp-village' entity as the representation of a village.
------------------------------------------------------------------------
Village = {}

function Village:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
	
function Village:init(i, c, e)
	self.state = {
		index = i,
		cpc = c,
		entity = e,
	}
end

function Village:update(needs)
	if not (self.state.entity.valid) then return end
	local village_inventory = self.state.entity.get_inventory(1)
	local citizen_count = self.state.cpc - 10

	if (village_inventory.can_insert({name="k2cp-citizen", count=10})) then
		village_inventory.insert({name="k2cp-citizen", count=10})
	end		

	if (village_inventory.can_insert({name="k2cp-citizen", count=citizen_count})) then 
		local supply = false
		local warehouses = self.state.entity.surface.find_entities_filtered({name={"k2cp-warehouse"}, position=self.state.entity.position, radius=64})
		for _, w in ipairs(warehouses) do
			local warehouse_inventory = w.get_inventory(1)
			for _, n in ipairs(needs) do
				if (warehouse_inventory.get_item_count(n) >= citizen_count*2) then
					warehouse_inventory.remove({name=n, count=citizen_count*2})
					village_inventory.insert({name="k2cp-citizen", count=citizen_count})
					supply = true
					break
				end		
			end
			if supply then break end
		end
	end
end

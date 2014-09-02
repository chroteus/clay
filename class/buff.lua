Buff = Base:subclass("Buff")

function Buff:initialize(name, duration, effect)
	self.name = name
	self.image = love.graphics.newImage("assets/image/buffs/" .. self.name .. ".png")
	self.duration = duration -- in turns
	self.effect = effect
end

function Buff:exec(target)
	if self.duration > 1 then
		self.effect(target)
		self.duration = self.duration - 1
	end
end

function Buff:apply(target)
	for k,buff in pairs(target.buffs) do
		if buff.name == self.name then
			table.remove(target.buffs, k)
		end
	end
	
	table.insert(target.buffs, self:clone())
end

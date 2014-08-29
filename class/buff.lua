Buff = Base:subclass("Buff")

function Buff:initialize(name, duration, effect)
	self.name = name
	self.image = love.graphics.newImage("assets/image/buffs/" .. self.name .. ".png")
	self.duration = duration -- in turns
	self.effect = effect
end

function Buff:exec(target)
	if self.duration > 0 then
		self.effect(target)
		self.duration = self.duration - 1
	end
end

function Buff:apply(target)
	table.insert(target.buffs, self:clone())
end

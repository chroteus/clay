Buff = class("Buff")

function Buff:initialize(name, duration, effect)
	self.name = name
	self.duration = duration -- in turns
	self.effect = function(target) 
					if self.duration > 0 then
						effect(target)
						self.duration = self.duration - 1
					end
				end
end

function Buff:apply(target)
	table.insert(target.buffs, self)
end

buffs = {
	-- Buff(name, duration, effect)
	fire = Buff("Fire", 4, 
				function(target) 
					target.hp = target.hp - math.random(10,15) 
					battle.showDmg(target)
				end),
}

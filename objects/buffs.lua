buffs = {
	-- Buff(name, duration, effect)
	fire = Buff("Fire", 3, 
		function(target) 
			target.hp = target.hp - math.random(5,10) 
			battle.showDmg(target)
		end),
}

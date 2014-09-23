upgrades = {
	Defense = Upgrade{name = "Defense", 
					  desc = "Adds to the defense when attacked.",
					  func = function(level,region)
								region.defense = level
							 end,
					  cost = 15},
					 
}

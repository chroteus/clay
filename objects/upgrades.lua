upgrades = {
	defense = Upgrade{name = "Defense", 
					  desc = "Adds to the defense when attacked.",
					  func = function(self,level,region)
								region.defense = level
							 end,
					  cost = 15},
					 
}

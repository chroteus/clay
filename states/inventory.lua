inventory = {}

function inventory.load()
	inventory.btn = nil
	inventory.btn = GuiOrderedTable()
	for _,item in pairs(Player.items) do
		inventory.btn:insert(InvButton(item))
	end
end

function inventory:init()
	inventory.load()
end

function inventory:enter()
	inventory.load()
end

function inventory:update(dt)
	inventory.btn:update()
end

function inventory:draw()
	inventory.btn:draw()
end

function inventory:mousereleased(x,y,button)
	inventory.btn:mousereleased(x,y,button)
end


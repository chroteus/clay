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
	love.mouse.setVisible(true)
	inventory.load()
end

function inventory:update(dt)
	inventory.btn:update()
end

function inventory:draw()
	inventory.btn:draw()
	if #Player.items == 0 then
		love.graphics.setFont(gameFont[50])
		love.graphics.printf("Your inventory is empty!", 0, 100, the.screen.width, "center")
		love.graphics.setFont(gameFont[16])
	end
end

function inventory:mousereleased(x,y,button)
	inventory.btn:mousereleased(x,y,button)
end


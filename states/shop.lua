shop = {}

function shop:init()
	shop.itemWidth = 300
	shop.itemHeight = 300

	-- GuiOrderedTable(columns, yOrder)
	shop.btn = GuiOrderedTable(3, 2)
	
	for _,item in pairs(items) do
		shop.btn:insert(ShopButton(item))
	end
end

function shop:enter()
	love.mouse.setVisible(true)
end

function shop:update(dt)
	shop.btn:update()
end

function shop:draw()
	love.graphics.printf("Money: ".. Player.money .. "G", 0, 50, the.screen.width, "center") 
	shop.btn:draw()
end

function shop:mousereleased(x,y,button)
	shop.btn:mousereleased(x,y,button)
end

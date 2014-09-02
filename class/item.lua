Item = Base:subclass("Item")

function Item:initialize(name, cost, info, onEquip, onUnequip)
    self.name = name
    self.info = info
    self.cost = cost
    self.img = love.graphics.newImage("assets/image/items/" .. self.name .. ".png")
    self.onEquip = assert(onEquip)
    self.onUnequip = assert(onUnequip)
    
    self.equipped = false
end

function Item:equip()
	self.equipped = true
	self.onEquip()
end

function Item:add()
	 -- check to see if an item is worn already
    local num = 0
    for _,item in pairs(Player.items) do
        if item.name == self.name then
            num = num + 1
        end
    end
    
    -- if item isn't found, add.
    if num == 0 then
        table.insert(Player.items, self)
    end
end

function Item:unequip()
    self.equipped = false
	self.onUnequip()
end

function Item:drawInfo(x,y)
	local PADDING = 5
	local w = 150
	local title_h = 30
	
	local font = love.graphics.getFont()
	local _,linenum = font:getWrap(self.info, w)
	local h = linenum * font:getHeight() + title_h + PADDING*2

	local fontHeight = font:getHeight()
	
	guiRect(x,y,w,h)
	guiRect(x,y,w,title_h)
	
	love.graphics.setColor(guiColors.fg)
	love.graphics.printf(self.name, x+PADDING, y+title_h/2-fontHeight/2, w, "left")
	love.graphics.printf(self.info, x+PADDING, y+title_h+PADDING, w, "left")
	love.graphics.setColor(255,255,255)
end

OffensiveItem = Item:subclass("OffensiveItem")
-- Adds to attack

function OffensiveItem:initialize(name, cost, info, amount)
	-- Player.addAttack is attack added by weapons.
	local function onEquip() 
		Player.attack = Player.attack + amount
		Player.addAttack = Player.addAttack + amount 
	end
	
	local function onUnequip() 
		Player.attack = Player.attack - amount
		Player.addAttack = Player.addAttack - amount 
	end
	
	Item.initialize(self, name, cost, info, onEquip, onUnequip)
end

Item = Base:subclass("Item")

function Item:initialize(name, info, func)
    self.name = name
    self.info = info
    self.img = love.graphics.newImage("assets/image/items/"..self.name..".png")
    self.func = assert(func)
    
    self.isWorn = false
end

function Item:equip()
    -- check to see if an item is worn already
    local num = 0
    for _,item in pairs(Player.items) do
        if item.name == self.name then
            num = num + 1
            item.isWorn = true
        end
    end
    
    -- if item isn't found, add one.
    if num == 0 then
        self.isWorn = true
        table.insert(Player.items, self:clone())
    end
end

function Item:unequip()
    for _,item in pairs(Player.items) do
        if item.name == self.name then
            item.isWorn = false
        end
    end
end
    
function Item:update(dt)
    self.func()
end

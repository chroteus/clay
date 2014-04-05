-- upgrades state. 
upg = {}
upg.message = ""

function upg:init()
    upg.btn = {}

    UpgBtn = Button:subclass("UpgradeBtn")

    function UpgBtn:initialize(xOrder, yOrder, text, desc, func)
        self.height = 70
        self.width = 150
        self.y = self.height * (yOrder*2)
        self.text = text
        self.desc = desc
        self.func = func
        self.activated = false
                 
        if xOrder == 1 then
            self.x = the.screen.width/2 - self.width*3
        elseif xOrder == 2 then
            self.x = the.screen.width/2 - self.width/2
        elseif xOrder == 3 then
            self.x = the.screen.width/2 + self.width*2
        else
            error("xOrder passed to UpgBtn should be between 1-3")
        end
        
        Button.initialize(self, self.x, self.y, self.width, self.height, self.text, self.func)
    end
end

function upg:enter()

end

function upg:update(dt)

end

function upg:draw()

end

function upg:mousereleased(x,y,button)

end

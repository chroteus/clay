diplScr = {} -- Diplomacy screen
diplScr.margin = 20
diplScr.country = ""
diplScr.enabled = false -- indicates if player clicked on the country to talk

local rectW,rectH = 130,80

function diplScr:init()
	diplScr.msg = require "misc.randMsg"
	
    diplCam = Camera(the.screen.width/2, the.screen.height/2)
    
    local btnW,btnH = 150,50
    -- buttons when talk screen is present
    diplScr.cBtn = {
        disBtn = GenericButton(6, "<< Back", function() diplScr.enabled = false end),
        peace = Button(the.screen.width/2-btnW/2, the.screen.height/2 + 100, btnW, btnH,
                    "Offer peace",
                    function()
                        diplScr.message = diplScr.msg.foe.denyPeace()
                    end
                ),
    }
    
    diplScr.initBtn = function()
		diplScr.btn = nil
        diplScr.btn = {}
        local btnH = 30
        for i,foe in ipairs(Player:returnCountry(true).foes) do
			if not foe.isDead then
				table.insert(diplScr.btn,
					Button(the.screen.width/2-rectW/2, ((rectH*1.5)*i)+rectH, rectW, btnH, "Talk", 
						function() 
							diplScr.country = foe
							diplScr.enabled = true
							diplScr.message = diplScr.msg.foe.enter(foe)
						end
					)
				)
			end
        end
    end
    
    diplScr.initBtn()
end

function diplScr:enter()
    local player_country = Player:returnCountry()
	for k,foe in pairs(player_country.foes) do
        if foe.isDead then
            table.remove(player_country.foes, k)
        end
    end
    
    love.mouse.setVisible(true)
    
    love.graphics.setFont(gameFont[22])
    
    if #nameToCountry(Player.country).foes == 0 then
        diplScr.noFoes = true
    else
        diplScr.noFoes = false
    end
    
    diplScr.initBtn()
end

function diplScr:update(dt)
    if not diplScr.enabled then
        -- Converting camera to mouse coordinates so that mouse's coordinates would be correct.
        the.mouse.x, the.mouse.y = diplCam:mousepos()
        
        for _,btn in pairs(diplScr.btn) do
            btn:update()
        end
    else
        for _,btn in pairs(diplScr.cBtn) do
            btn:update()
        end
    end
    
    the.mouse.x, the.mouse.y = love.mouse.getPosition()
end




function diplScr:draw()
    if not diplScr.enabled then
        diplCam:attach()
        
        for i,foe in pairs(Player:returnCountry(true).foes) do
			if not foe.isDead then
				love.graphics.setColor(guiColors.bg)
				love.graphics.rectangle("fill",the.screen.width/2-rectW/2, ((rectH*1.5)*i), rectW, rectH)
				love.graphics.setColor(guiColors.fg)
				love.graphics.rectangle("line",the.screen.width/2-rectW/2, ((rectH*1.5)*i), rectW, rectH)
				love.graphics.printf(foe.name, 0, diplScr.margin*2.5+(rectH*1.5*i), the.screen.width, "center")
				love.graphics.setColor(255,255,255)

				local ball = foe.miniature
				ball:setFilter("nearest", "nearest")
				love.graphics.push()
				love.graphics.scale(2)
				love.graphics.draw(ball, (the.screen.width/4)-(ball:getWidth()/2), (rectH*0.75*i)+diplScr.margin/4) --0.75 because it's scaled
				love.graphics.pop()
			end
        end
        
        love.graphics.setFont(gameFont[22])
        if diplScr.noFoes then
            love.graphics.printf("You have no enemies!", 0, diplScr.margin+50, the.screen.width, "center")
            
        else
             love.graphics.printf("Foes", 0, diplScr.margin, the.screen.width, "center")
        end
        
        love.graphics.setFont(gameFont[16])
        
        for _,btn in pairs(diplScr.btn) do
            btn:draw()
        end
        
        diplCam:detach()
    
    else -- if talking with country
        love.graphics.setFont(gameFont[22])
        love.graphics.draw(
			diplScr.country.leftImage, 
			the.screen.width/2 - diplScr.country.leftImage:getWidth()/2,
			the.screen.height/2 - diplScr.country.leftImage:getHeight())
 
        love.graphics.printf(diplScr.country.name, 0, diplScr.margin, 
							 the.screen.width, "center")
       
        love.graphics.printf(diplScr.message, the.screen.width/4, 
							the.screen.height/2 + diplScr.margin, 
							the.screen.width/2, "center")
	
		-- enemies and allies columns
		local y = the.screen.height/2 - diplScr.country.leftImage:getHeight()
		local w = 150
		local pad = 5 -- padding
		
		local space = 150 -- space between image and columns
		local enemies_x = the.screen.width/2 - w*2 - space
		
		-- enemies column
		guiRect(enemies_x-pad, y-pad,w+pad,the.screen.height-y*2)
		guiRect(enemies_x-pad, y-pad,w+pad, 22+pad*2)
		
		love.graphics.setColor(guiColors.fg)
		love.graphics.printf("Enemies", enemies_x,y, w, "left")	
        love.graphics.setFont(gameFont[16])
        
        local foeStr = ""
        for _,foe in pairs(diplScr.country.foes) do
			foeStr = foeStr .. foe.name .. "\n"
		end
		
		if foeStr == "" then foeStr = "No enemies" end
		love.graphics.printf(foeStr, enemies_x, y+35, w, "left")
		
		-- allies column
		local allies_x = the.screen.width/2 + space + w
		guiRect(allies_x-pad, y-pad,w+pad,the.screen.height-y*2)
		guiRect(allies_x-pad, y-pad,w+pad, 22+pad*2)
		
		love.graphics.setFont(gameFont[22])
		love.graphics.setColor(guiColors.fg)
		love.graphics.printf("Allies", allies_x,y, w, "left")	
		love.graphics.setFont(gameFont[16])
		
		local alliesStr = ""
        for _,ally in pairs(diplScr.country.allies) do
			alliesStr = alliesStr .. ally.name .. "\n"
		end
		
		if alliesStr == "" then alliesStr = "No allies" end
		love.graphics.printf(alliesStr, allies_x, y+35, w, "left")
		--------------
		
        for _,btn in pairs(diplScr.cBtn) do
            btn:draw()
        end
    end
end

function diplScr:mousepressed(x,y,button)
    if button == "wu" then
        Timer.tween(0.2, diplCam, {y = diplCam.y - 40}, "out-quad")
    elseif button == "wd" then
        Timer.tween(0.2, diplCam, {y = diplCam.y + 40}, "out-quad")
    end
end

function diplScr:mousereleased(x,y,button)    
    if not diplScr.enabled then
        for _,btn in pairs(diplScr.btn) do
            btn:mousereleased(x,y,button)
        end
    else
        for _,btn in pairs(diplScr.cBtn) do
            btn:mousereleased(x,y,button)
        end
    end
end

function diplScr:leave()
    love.graphics.setFont(gameFont[16])
end

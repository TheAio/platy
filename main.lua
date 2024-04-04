function love.load()
    camera = require 'libraries/camera'
    cam = camera()
    wf = require 'libraries/windfield'
    world = wf.newWorld(0, 1)
    --audio
    sounds={}
    --player
    player = {}
    player.x = 200
    player.y = 200
    player.collider = world:newRectangleCollider(200,200,101,101)
    player.collider:setFixedRotation(true)
    player.speed = 300
    slowedPostFirst = 0
    speedAtLast = 0
    postFirst = false
    --earth
    earth=world:newBSGRectangleCollider(100,500,50,50,5)
    earth:setType('static')
    --obsticale
    obsticle=world:newRectangleCollider(400,400,10,100)
    obsticle:setType('static')
    --sprites
    player.sprite = love.graphics.newImage('media/sprites/char.png')
    --map = love.graphics.newImage('sprites/map.png')
end

function generateObsticale()
    if obsticle:getX() < player.x then
        postFirst = true
        local vx,vy = player.collider:getLinearVelocity()
        if vx < speedAtLast and speedAtLast > 5 then
            slowedPostFirst = slowedPostFirst+1
        end
        speedAtLast = vx
        obsticle=world:newRectangleCollider(player.x+(math.abs(vx)*3)+math.abs(vy)*10,400,math.abs(vx)/100,math.max(math.abs(vy)*50,50))
        obsticle:setType('static')
    end
end

function love.update(dt)
    generateObsticale()
    if slowedPostFirst > 5 then
        love.quit()
    end
    local vx,vy = player.collider:getLinearVelocity()
    local score = ((player.x/vx)/(100*(slowedPostFirst+1)))
    if score > 0.5 and vx > 100 then love.quit() end
    earth:setX(player.x+(vx/1000))
    --if love.keyboard.isDown("d") then
        player.collider:applyForce(1000,0)
    --end
    player.collider:applyForce(0,4000)
    player.collider:setLinearVelocity(vx,vy)
    cam:lookAt(player.x,player.y)
    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()
end

function love.draw()
    cam:attach()
        world:draw()
        love.graphics.draw(player.sprite, player.x-50, player.y-50)
    cam:detach()
    local vx,vy = player.collider:getLinearVelocity()
    local score = ((player.x/vx)/(100*(slowedPostFirst+1)))
    love.graphics.print("SCORE: "..string.rep("#",10*(score/0.5)).." ",300,500)
    love.graphics.print("LIVES: "..string.rep("#",10*((5-slowedPostFirst)/5)),300,510)
end

function love.keypressed(key)
    local vx,vy = player.collider:getLinearVelocity()
    if key == "w" and vy < 1 and vy > -1 then
        player.collider:applyLinearImpulse(0,(math.abs(vx)*-1)-5000)
    end
end

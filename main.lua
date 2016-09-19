local HC = require 'HC'
require 'mapLoader'
require 'player'
require 'camera'
require 'world'
require 'TEsound'

debug = true
local blockingObj = {}
local spaceReleased = true

function love.keyreleased(key, scancode)
  if scancode == 'space' then
    spaceReleased = true
  end
end

function love.keypressed(key, scancode, isrepeat)
  if scancode == 'm' and isrepeat == false then
    myWorld.mute()
  end
end

function love.load()
  gravity = 50
  map = mapLoader:new('maps/map2.lua', 'assets/Sprute.png')
  collider = HC.new(300)
  myPlayer = player:new(100, 100, 300, 300, 16, 0.4, collider, gravity)
  blockingObj = map:getMapObjectLayer(collider, 'blocking')
  myWorld = world:new(map, collider, 500)

  mountains = love.graphics.newImage('assets/mountains.png')
  background = love.graphics.newImage('assets/background.png')
  foreground = love.graphics.newImage('assets/closebg.png')

  myCamera = camera:new(map:getWidth(), map:getHeight(), 0, 1, 1)
  myCamera:newLayer(1, 1.3, function()
    love.graphics.setColor(256, 256, 256)
    --map:draw(1, 1)
    love.graphics.draw(foreground, 0, 100)
  end)
  myCamera:newLayer(-1, 1.0, function()
    love.graphics.setColor(255, 255, 255)
    myPlayer:draw()
  end)
  myCamera:newLayer(0, 1, function()
    love.graphics.setColor(255, 255, 255)
    map:draw(2, 10)
    if debug == true then
      love.graphics.setColor(100, 100, 100, 150)
      for i, v in ipairs(blockingObj) do
        v:draw('fill')
      end
    end
  end)
  myCamera:newLayer(-5, 0.3, function()
    love.graphics.setColor(256, 256, 256)
    --map:draw(1, 1)
    love.graphics.draw(mountains)
  end)
  myCamera:newLayer(-10, 0, function()
    love.graphics.setColor(256, 256, 256)
    --map:draw(1, 1)
    love.graphics.draw(background)
  end)

end

function love.update(dt)

  -- movement handler
  if love.keyboard.isScancodeDown('left', 'a') then
    myPlayer:moveLeft(dt)
  end
  if love.keyboard.isScancodeDown('right', 'd') then
    myPlayer:moveRight(dt)
  end
  if love.keyboard.isScancodeDown('space') then
    spaceReleased = false
    myPlayer:jump(dt, spaceReleased)
  end

  if love.keyboard.isScancodeDown('escape') then
    love.event.quit()
  end

  myPlayer:update(dt, spaceReleased)
  myCamera:centerOn(myPlayer:getX(), myPlayer:getY())
  TEsound.cleanup()
end

function love.draw()
  myCamera:draw()

  if debug == true then
    if spaceReleased then love.graphics.print('true', 100, 100)
    else love.graphics.print('false', 100, 100) end
    love.graphics.print(myPlayer:getYVelocity(), 100, 120)
  end
end

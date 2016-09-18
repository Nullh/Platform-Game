local HC = require 'HC'
require 'mapLoader'
require 'player'
require 'screen'
require 'world'

debug = true
local blockingObj = {}
local spaceReleased = true

function love.keyreleased(key, scancode)
  if scancode == 'space' then
    spaceReleased = true
  end
end


function love.load()
  gravity = 50
  map = mapLoader:new('maps/map2.lua', 'assets/Sprute.png')
  myScreen = screen:new(map:getWidth(), map:getHeight())
  collider = HC.new(300)
  myPlayer = player:new('assets/luigi.png', 100, 100, 300, 300, 16, 0.4, collider, gravity)
  blockingObj = map:getMapObjectLayer(collider, 'blocking')
  myWorld = world:new(map, collider, 500)
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

  if love.keyboard.isScancodeDown('m') then
    myPlayer:setSpeed(1000)
  end

  --myWorld:gravity(myPlayer, dt)
  myPlayer:update(dt, spaceReleased)
  screen:centerOn(myPlayer:getX(), myPlayer:getY())
end

function love.draw()
  love.graphics.push()
  screen:translate()
  map:draw(1, 1)
  myPlayer:draw()
  map:draw(2, 10)

  if debug == true then
    love.graphics.setColor(100, 100, 100, 150)
    for i, v in ipairs(blockingObj) do
      v:draw('fill')
    end
    love.graphics.setColor(256, 256, 256)
  end
  love.graphics.pop()
  if debug == true then
    if spaceReleased then love.graphics.print('true', 100, 100)
    else love.graphics.print('false', 100, 100) end
    love.graphics.print(myPlayer:getJumpTimer(), 100, 120)
  end
end

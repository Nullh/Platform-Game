local class = require 'middleclass'
require 'TEsound'

world = class('world')

local _collider
local _gravity
local _map
local _width
local _height
local _leftBorder
local _rightBorder
local _botBorder
local _topBorder
local _muted = false

function world:initialize(map, collider, gravity)
  _map = map
  _collider = collider
  _gravity = gravity
  _width = map:getWidth()
  _height = map:getHeight()

  -- add walls at screen edge
  _leftBorder = collider:rectangle(-10, -10, 10, _height + 20)
  _rightBorder = collider:rectangle(_width, -10, 10, _height + 20)
  _botBorder = collider:rectangle(-10, _height, _width + 20, 10)
  _topBorder = collider:rectangle(-10, -10, _width + 20, 10)

  TEsound.playLooping('assets/MSTR_-_MSTR_-_Choro_bavario_Loop.ogg', 'bgm')
end

function world:mute()
  if _muted == false then
    TEsound.pause('bgm')
    _muted = true
  else
    TEsound.resume('bgm')
    _muted = false
  end
end

-- what happens when two things collide
-- testObj is the object to be tested
-- exclude is the name of objects to exclude
function world:collideWith(testObj, exclude)
  for shape, delta in pairs(collider:collisions(testObj:getCollObj())) do
    if shape.name ~= exclude then
      testObj:setCoords(testObj:getX() + delta.x, testObj:getY() + delta.y)
      --testObj:setYVelocity(0)
      if delta.y < 0 then
        testObj:setYVelocity(0)
      elseif delta.y > 0 then
        testObj:setYVelocity(0.1)
      end
    end
  end
end

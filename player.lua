local class = require 'middleclass'

player = class('player')

local _speed
local _collObj
local _x
local _y
local _sprite
local _jumpSpeed
local _onGround = false
local _yVelocity = 0
local _g
local _jumpTimer
local _jumpTimerMax
local _canJump = true
local _jumping = false


function player:initialize(sprite, x, y, speed, jumpSpeed, jumpHeight, jumpTimer, collider, g)
  _sprite = love.graphics.newImage(sprite)
  _x = x
  _y = y
  _speed = speed
  _jumpSpeed = jumpSpeed
  _jumpHeight = -jumpHeight
  _jumpTimer = jumpTimer
  _jumpTimerMax = jumpTimer
  _g = g
  _collObj = collider:rectangle(_x, _y, _sprite:getWidth(), _sprite:getHeight())
end

function player:getX()
  return _x
end

function player:setX(x)
  _x = x
  _collObj:moveTo(_x, _y)
end

function player:getY()
  return _y
end

function player:setY(y)
  _y = y
  _collObj:moveTo(_x, _y)
end

function player:setCoords(x, y)
  _y = y
  _x = x
  _collObj:moveTo(_x, _y)
end

function player:moveLeft(dt)
  _x = _x - (_speed * dt)
  _collObj:moveTo(_x, _y)
end

function player:moveRight(dt)
  _x = _x + (_speed * dt)
  _collObj:moveTo(_x, _y)
end

function player:moveUp(dt)
  _y = _y - (_speed * dt)
  _collObj:moveTo(_x, _y)
end

function player:moveDown(dt)
  _y = _y + (_speed * dt)
  _collObj:moveTo(_x, _y)
end

function player:setSpeed(newSpeed)
  _speed = newSpeed
end

function player:getCollObj()
  return _collObj
end

function player:getJumpTimer()
  return _jumpTimer
end

function player:jump()
  _jumping = true
end

function player:update(dt, spaceReleased)
if _jumping then
  if _jumpTimer > 0 and _canJump == true then
    _yVelocity = _yVelocity - _jumpSpeed * (dt / (_jumpTimerMax*5))
    if spaceReleased == true then
      _jumpTimer = -1
    end
    if _yVelocity < _jumpHeight then
      _yVelocity = _jumpHeight
      _canJump = false
    end
    _jumpTimer = _jumpTimer - dt
    _collObj:moveTo(_x, _y)
  end
end

  _yVelocity = _yVelocity + (_g * dt)
  _y = _y + _yVelocity
  _collObj:moveTo(_x, _y)
  for shape, delta in pairs(collider:collisions(_collObj)) do
    _x = _x + delta.x
    _y = _y + delta.y
    if delta.y < 0 then
      _yVelocity = 0
      _jumpTimer = _jumpTimerMax
      if spaceReleased then
        _canJump = true
        _jumping = false
      end
    elseif delta.y > 0 then
      _yVelocity = 0.1
      _canJump = false
    end
  end
  _collObj:moveTo(_x, _y)
end

function player:getYVelocity()
  return _yVelocity
end

function player:draw()
  love.graphics.draw(_sprite, _x-_sprite:getWidth()/2, _y-_sprite:getHeight()/2)
  if debug == true then
    love.graphics.setColor(100, 100, 100, 150)
    _collObj:draw('fill')
    love.graphics.setColor(256, 256, 256)
  end
end

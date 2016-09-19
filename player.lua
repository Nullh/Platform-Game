local class = require 'middleclass'
local anim8 = require 'anim8'
require 'TEsound'

player = class('player')

local _speed
local _collObj
local _x
local _y
local _sprite
local _spriteWidth
local _spriteHeight
local _jumpSpeed
local _onGround = false
local _yVelocity = 0
local _g
local _jumpTimer
local _jumpTimerMax
local _canJump = true
local _jumping = false
local _grid
local _animations = {}
local _facingRight = true
local _moving = false
local _canBark = true
local _jumpSound


function player:initialize(x, y, speed, jumpSpeed, jumpHeight, jumpTimer, collider, g)
  _sprite = love.graphics.newImage('assets/Penny2.png')
  _spriteWidth = 64
  _spriteHeight = 64
  _x = x
  _y = y
  _speed = speed
  _jumpSpeed = jumpSpeed
  _jumpHeight = -jumpHeight
  _jumpTimer = jumpTimer
  _jumpTimerMax = jumpTimer
  _g = g
  _collObj = collider:rectangle(_x, _y, _spriteWidth, _spriteHeight)
  _grid = anim8.newGrid(64, 64, _sprite:getWidth(), _sprite:getHeight())
  _animations['walkLeft'] = anim8.newAnimation(_grid('5-8', 4), 0.2)
  _animations['walkRight'] = anim8.newAnimation(_grid('5-8', 4), 0.2):flipH()
  _animations['idleLeft'] = anim8.newAnimation(_grid('1-4', 2), 0.2)
  _animations['idleRight'] = anim8.newAnimation(_grid('1-4', 2), 0.2):flipH()
  _jumpSound = love.sound.newSoundData('assets/bark.mp3')
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
  _moving = true
  _facingRight = false
  _x = _x - (_speed * dt)
  _collObj:moveTo(_x, _y)
end

function player:moveRight(dt)
  _moving = true
  _facingRight = true
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

local function flipCanBark()
  _canBark = true
end

function player:jump()
  if _canBark and _canJump then
    _canBark = false
    TEsound.play(_jumpSound, 'jump', 1, 1, flipCanBark)
  end
  _jumping = true
end

function player:update(dt, spaceReleased)
  -- if we're jumping accelerate the player up
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
  -- have gravity affect the player
  _yVelocity = _yVelocity + (_g * dt)
  _y = _y + _yVelocity
  if _yVelocity > 0 then
    _canJump = false
  end
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
  -- update the animations
  _animations['walkLeft']:update(dt)
  _animations['walkRight']:update(dt)
  _animations['idleLeft']:update(dt)
  _animations['idleRight']:update(dt)
end

function player:getYVelocity()
  return _yVelocity
end

function player:draw()
  -- draw the player
  if _moving == true then
    if _facingRight == true then
      _animations['walkRight']:draw(_sprite, _x-(_spriteWidth/2), _y-(_spriteHeight/2)+6)
    else
      _animations['walkLeft']:draw(_sprite, _x-(_spriteWidth/2), _y-(_spriteHeight/2)+6)
    end
  else
    if _facingRight == true then
      _animations['idleRight']:draw(_sprite, _x-(_spriteWidth/2), _y-(_spriteHeight/2)+6)
    else
      _animations['idleLeft']:draw(_sprite, _x-(_spriteWidth/2), _y-(_spriteHeight/2)+6)
    end
  end
  -- if debug draw the collision object
  if debug == true then
    love.graphics.setColor(100, 100, 100, 150)
    _collObj:draw('fill')
    love.graphics.setColor(256, 256, 256)
  end
  -- reset the moving flag
  _moving = false
end

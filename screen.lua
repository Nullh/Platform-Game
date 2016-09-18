local class = require 'middleclass'

screen = class('screen')

local _width = nil
local _height = nil
local _transformationX = nil
local _transformationY = nil
local _mapWidth
local _mapHeight

function screen:initialize(mapWidth, mapHeight)
  _width = love.graphics.getWidth()
  _height = love.graphics.getHeight()
  _mapWidth = mapWidth
  _mapHeight = mapHeight
end

function screen:centerOn(x, y)
  if _width < _mapWidth then
    _transformationX = math.floor(-x + (_width/2))
    if _transformationX > 0 then
      _transformationX = 0
    elseif _transformationX < -(_mapWidth - _width) then
      _transformationX = -(_mapWidth - _width)
    end
  else
    _transformationX = (_width - _mapWidth)/2
  end

  if _height < _mapHeight then
    _transformationY = math.floor(-y + (_height/2))
    if _transformationY > 0 then
      _transformationY = 0
    elseif _transformationY < -(_mapHeight - _height) then
      _transformationY = -(_mapHeight - _height)
    end
  else
    _transformationY = (_height - _mapHeight)/2
  end
end

function screen:translate()
  love.graphics.translate(_transformationX, _transformationY)
end

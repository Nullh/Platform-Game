local class = require 'middleclass'

mapLoader = class('mapLoader')

local _file = {} -- a handle to the lua map file
local _atlas = nil -- the image to use asthe tilemap
local _tiles = {} -- a table indexed for each tileid


function mapLoader:initialize(path, atlaspath)
  -- load the map file
  _file = love.filesystem.load(path)()
  -- load the atlas
  -- TODO: make this load each atlas per layer
  _atlas = love.graphics.newImage(atlaspath)
  -- load the tiles for the map
  local ids = {} -- list of all tileIds
  local tileids = {} -- list of non-duplicate tileIds
  local hash = {} -- used for de-dup
  -- union all map data across layers
  local n = 1
  for i=1, table.getn(_file.layers) do
    if _file.layers[i].type == "tilelayer" then
      for v in pairs(_file.layers[i].data) do
        ids[n] = _file.layers[i].data[v]
        n = n+1
      end
    end
  end
  -- get unique tileIDs
  for _,v in ipairs(ids) do
    if (not hash[v]) then
      tileids[#tileids+1] = v
      hash[v] = true
    end
  end
  -- create the table containing the quads
  for i=1, table.getn(tileids) do
    r = tileids[i]
    _tiles[r] = self:getQuad(r)
  end
end --loadMap()

-- Return the quad for a tileid
function mapLoader:getQuad(tileId)
  -- Get the x index of the tile
  tileX = (((tileId -1) % (_file.tilesets[1].imagewidth/_file.tilesets[1].tilewidth)) * _file.tilesets[1].tilewidth)
  -- get the y index of the tile
  tileY = ((math.floor((tileId - 1) / (_file.tilesets[1].imagewidth/_file.tilesets[1].tilewidth))) * _file.tilesets[1].tilewidth)
  return love.graphics.newQuad(tileX, tileY, _file.tilesets[1].tilewidth, _file.tilesets[1].tileheight, _file.tilesets[1].imagewidth, _file.tilesets[1].imageheight)
end -- getQuad()

function mapLoader:getHeight()
  return _file.height * _file.tileheight
end

function mapLoader:getWidth()
  return _file.width * _file.tilewidth
end


function mapLoader:draw(minLayer, maxLayer)
  -- iterate layers
  if table.getn(_file.layers) < maxLayer then
    maxLayer = table.getn(_file.layers)
  end
  if minLayer <= 0 then
    minLayer = 1
  end
  for n = minLayer, maxLayer do
    if _file.layers[n].type == "tilelayer" then
        local row = 1
        local column = 1
        -- for each data elemnt in the layer's table
        for l = 1, table.getn(_file.layers[n].data) do
          -- goto the next row if we've passed the screen width and reset columns
          if column > _file.layers[n].width then
            column = 1
            row = row + 1
          end
          -- draw the tile as long as it's not 0 (empty)
          if _file.layers[n].data[l] ~= 0 then
            love.graphics.setColor(256,256,256)
            love.graphics.draw(_atlas, _tiles[_file.layers[n].data[l]],
              (column * _file.tileheight) - _file.tileheight, (row * _file.tilewidth) - _file.tilewidth)
          end
          -- move to the next column
          column = column + 1
        end
      end
    end
end -- drawMap()

-- get objects from a named object layer
function mapLoader:getMapObjectLayer(collider, blockingLayerString)
  local collisionTileTable = {}
  local blockinglayer = nil
  local row = 1
  local column = 1

  for i=1, table.getn(_file.layers) do
    if _file.layers[i].name == blockingLayerString then
      -- find the blocking layer
      blockinglayer = i
    end
  end

  -- draw each blocking object
  for i=1, table.getn(_file.layers[blockinglayer].objects) do
    if _file.layers[blockinglayer].objects[i].shape == "rectangle" then
      table.insert(collisionTileTable, collider:rectangle(_file.layers[blockinglayer].objects[i].x, _file.layers[blockinglayer].objects[i].y,
          _file.layers[blockinglayer].objects[i].width, _file.layers[blockinglayer].objects[i].height))
      collisionTileTable[table.getn(collisionTileTable)].name = blockingLayerString
    elseif _file.layers[blockinglayer].objects[i].shape == "ellipse" then
      table.insert(collisionTileTable, collider:circle(_file.layers[blockinglayer].objects[i].x + (_file.layers[blockinglayer].objects[i].width/2),
          _file.layers[blockinglayer].objects[i].y + (_file.layers[blockinglayer].objects[i].width/2),
          _file.layers[blockinglayer].objects[i].width/2))
      collisionTileTable[table.getn(collisionTileTable)].name = blockingLayerString
    end
  end
  return collisionTileTable
end -- getMapObjectLayer()

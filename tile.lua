---@class LTTile
---@field x number The x coordinate
---@field y number The y coordinate
local Tile = {}
Tile.__index = Tile

function Tile.new(x, y)
	return setmetatable({
		x = x,
		y = y
	}, Tile)
end

return Tile
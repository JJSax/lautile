---@class LTTile
---@field grid Luatile The Grid the tile is inside
---@field x number The x coordinate
---@field y number The y coordinate
local Tile = {}
Tile.__index = Tile

function Tile.new(grid, x, y)
	return setmetatable({
		grid = grid,
		x = x,
		y = y
	}, Tile)
end

-- Default neighbor methods assume a lattice graph, though may still be useful

function Tile:getNeighbors()
	return {
		self.grid:isValidCell(self.x, self.y - 1),
		self.grid:isValidCell(self.x + 1, self.x),
		self.grid:isValidCell(self.x, self.y + 1),
		self.grid:isValidCell(self.x - 1, self.x),
	}
end

function Tile:getDiagonalNeighbors()
	return {
		self.grid:isValidCell(self.x + 1, self.y - 1),
		self.grid:isValidCell(self.x + 1, self.y + 1),
		self.grid:isValidCell(self.x - 1, self.y + 1),
		self.grid:isValidCell(self.x - 1, self.y - 1)
	}
end

function Tile:getAllNeighbors()
	return {
		self.grid:isValidCell(self.x, self.y - 1),		-- Top
		self.grid:isValidCell(self.x + 1, self.y),		-- Right
		self.grid:isValidCell(self.x, self.y + 1),		-- Bottom
		self.grid:isValidCell(self.x - 1, self.y),		-- Left
		self.grid:isValidCell(self.x + 1, self.y - 1),	-- Top-right
		self.grid:isValidCell(self.x + 1, self.y + 1),	-- Bottom-right
		self.grid:isValidCell(self.x - 1, self.y + 1),	-- Bottom-left
		self.grid:isValidCell(self.x - 1, self.y - 1)	-- Top-left
	}
end



return Tile
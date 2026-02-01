---@class LTTile
---@field x number The x coordinate
---@field y number The y coordinate
local Tile = {}
Tile.__index = Tile

-- function Tile.new(x, y)
-- 	return setmetatable({
-- 		x = x,
-- 		y = y
-- 	}, Tile)
-- end

function Tile.new(a, b, c)
	local grid, x, y

	if c == nil then
		-- New API: Tile.new(x, y)
		x = a
		y = b
	else
		-- Old API (deprecated): Tile.new(grid, x, y)
		grid = a
		x = b
		y = c

		print(
			"Deprecated: Tile.new(grid, x, y) is deprecated. " ..
			"Use Tile.new(x, y) instead."
		)
	end

	return setmetatable({
		grid = grid, -- will be nil in new API
		x = x,
		y = y,
	}, Tile)
end

---@deprecated Use Grid:getNeighbors instead.
-- Default neighbor methods assume a lattice graph, though may still be useful
function Tile:getNeighbors()
	-- error("Use Grid:getNeighbors instead.", 2)
	return {
		self.grid:isValidCell(self.x, self.y - 1),
		self.grid:isValidCell(self.x + 1, self.y),
		self.grid:isValidCell(self.x, self.y + 1),
		self.grid:isValidCell(self.x - 1, self.y),
	}
end

---@deprecated Use Grid:getDiagonalNeighbors instead.
function Tile:getDiagonalNeighbors()
	-- error("Use Grid:getDiagonalNeighbors instead.", 2)
	return {
		self.grid:isValidCell(self.x + 1, self.y - 1),
		self.grid:isValidCell(self.x + 1, self.y + 1),
		self.grid:isValidCell(self.x - 1, self.y + 1),
		self.grid:isValidCell(self.x - 1, self.y - 1)
	}
end

---@deprecated Use Grid:getAllNeighbors instead.
function Tile:getAllNeighbors()
	-- error("Use Grid:getAllNeighbors instead.", 2)
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
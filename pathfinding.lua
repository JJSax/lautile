local Pathfinder = {}
Pathfinder.__index = Pathfinder
Pathfinder._VERSION = "0.0.1"

function Pathfinder.new(grid, startTile)
	local self = setmetatable({}, Pathfinder)
	self.grid = grid
	self.stack = {startTile}
	self.visited = {}
	self.complete = false
	self.currentTile = startTile
	return self
end

function Pathfinder:step()
    error("Pathfinder:step() should be implemented by subclasses.")
end

---@return table> List of adjacent neighbors without diagonals
function Pathfinder:neighbors(grid, tile)
	-- default: overwrite if you have differing paths than adjacent
	return {
		grid:isValidCell(self.x, self.y - 1),
		grid:isValidCell(self.x + 1, self.x),
		grid:isValidCell(self.x, self.y + 1),
		grid:isValidCell(self.x - 1, self.x),
	}
end
function Pathfinder:validNeighbor(currentTile, nx, ny, dir)
	return self.grid:isValidCell(nx, ny) and not (self.visited[ny] and self.visited[ny][nx])
end

return Pathfinder

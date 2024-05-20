local Pathfinder = {}
Pathfinder.__index = Pathfinder
Pathfinder._VERSION = "0.0.2"

function Pathfinder.new(grid, startTile, target)
	local self = setmetatable({}, Pathfinder)
	self.grid = grid
	self.stack = {startTile}
	self.target = target
	self.visited = {}
	self.complete = false
	self.currentTile = startTile
	return self
end

function Pathfinder:step()
	error("Pathfinder:step() should be implemented by subclasses.")
end

function Pathfinder:run()
	repeat
		self:step()
	until self.complete
end

function Pathfinder:validNeighbor(currentTile, nx, ny, dir)
	return self.grid:isValidCell(nx, ny) and not (self.visited[ny] and self.visited[ny][nx])
end

function Pathfinder:isTarget(tile)
	return tile == self.target
end

return Pathfinder

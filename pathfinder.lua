local Pathfinder = {}
Pathfinder.__index = Pathfinder
Pathfinder._VERSION = "0.0.6"

---Common initialization of pathfinding algorithms.
function Pathfinder.new(grid, startTile, target)
	local self = setmetatable({}, Pathfinder)
	self.grid = grid
	self.start = startTile
	self.target = target
	self.visited = {[startTile] = true}
	self.complete = false
	self.currentTile = startTile
	self.path = {}
	return self
end

--- Step through pathfinding algorithm.  Should be implemented elsewhere.
function Pathfinder:step()
	error("Pathfinder:step() should be implemented by subclasses.")
end

---Run pathfinding algorithm until it completes.
function Pathfinder:run()
	repeat
		self:step()
	until self.complete
end

---Returns if tile == target
function Pathfinder:isTarget(tile)
	return tile == self.target
end

--- returns all the tiles that tile:getNeighbors() passes, then culls ones that were visited.
function Pathfinder:getUnvisitedNeighbors(cell)
	local neighbors = cell:getNeighbors()
	local unvisited = {}
	for _, neighbor in ipairs(neighbors) do
		if not self.visited[neighbor] then
			table.insert(unvisited, neighbor)
		end
	end
	return unvisited
end

---Create blank functions for common use in cubclassess.
local function __NULL__(...) end
for _,v in ipairs({"exploreTile", "markDeadEnd"}) do
	Pathfinder[v] = __NULL__
end

return Pathfinder

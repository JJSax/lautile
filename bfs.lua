local HERE = (...):gsub('%.[^%.]+$', '')
local Pathfinding = require(HERE..".pathfinding")

local bfs = setmetatable({}, { __index = Pathfinding })
bfs.__index = bfs
bfs._VERSION = "0.0.3"

function bfs.new(grid, startTile, target)
	local self = setmetatable(Pathfinding.new(grid, startTile, target), bfs)
	self.queue = {startTile}
	return self
end

local function __NULL__(...) end
for _,v in ipairs({"exploreTile"}) do
	bfs[v] = __NULL__
end

function bfs:step()
	if #self.queue > 0 and not self.complete then
		local currentCell = table.remove(self.queue, 1)
		self.currentTile = currentCell -- the tile object
		self:exploreTile(currentCell)
		if self:isTarget(currentCell) then
			self.complete = true
			return self.visited
		end
		local neighbors = self:getUnvisitedNeighbors(currentCell)
		for _, nextCell in ipairs(neighbors) do
			self.visited[nextCell] = true
			table.insert(self.queue, nextCell)
		end
	else
		self.complete = true
	end
end

function bfs:getUnvisitedNeighbors(cell)
	local neighbors = cell:getNeighbors()
	local unvisited = {}
	for _, neighbor in ipairs(neighbors) do
		if not self.visited[neighbor] then
			table.insert(unvisited, neighbor)
		end
	end
	return unvisited
end

return bfs
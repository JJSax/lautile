local HERE = (...):gsub('%.[^%.]+$', '')
local Pathfinder = require(HERE..".pathfinder")

local bfs = setmetatable({}, { __index = Pathfinder })
bfs.__index = bfs
bfs._VERSION = "0.1.0"

function bfs.new(grid, startTile, target)
	local self = setmetatable(Pathfinder.new(grid, startTile, target), bfs)
	self.queue = {startTile}
	self.parents = {}
	return self
end

local function __NULL__(...) end
for _,v in ipairs({"exploreTile"}) do
	bfs[v] = __NULL__
end

function bfs:backtrace()
	local path = {self.target}
	while path[#path] ~= self.start do
		table.insert(path, self.parents[path[#path]])
	end

	local npath = {}
	for i = #path, 1, -1 do
		table.insert(npath, path[i])
	end
	self.path = npath
	return npath
end

function bfs:step()
	if #self.queue > 0 and not self.complete then
		local currentCell = table.remove(self.queue, 1)
		self.currentTile = currentCell -- the tile object
		self:exploreTile(currentCell)
		if self:isTarget(currentCell) then
			self.complete = true
			self:backtrace()
			return self.visited
		end
		local neighbors = self:getUnvisitedNeighbors(currentCell)
		for _, nextCell in ipairs(neighbors) do
			self.visited[nextCell] = true
			self.parents[nextCell] = currentCell
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
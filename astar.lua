local HERE = (...):gsub('%.[^%.]+$', '')
local Pathfinder = require(HERE..".pathfinder")

local astar = setmetatable({}, { __index = Pathfinder })
astar.__index = astar
astar._VERSION = "0.0.4"

function astar.new(grid, startTile, target)
	local self = setmetatable(Pathfinder.new(grid, startTile, target), astar)
	self.parents = {}
	self.openList = {startTile} -- Tiles to be visited
	self.openSet = { -- This is the set for O(1) lookup
		[startTile] = true
	}
	self.gScore = { -- cost from start node
		[startTile] = 0
	}
	self.fScore = { -- cost combined gScore and heuristic
		[startTile] = self:heuristic(startTile, self.target)
	}
	self.visited = {
		[startTile] = true
	}
	self.complete = false
	self.currentTile = startTile
	self.start = startTile
	self.target = target
	self.path = {}

	return self
end

local function __NULL__(...) end
for _,v in ipairs({"exploreTile", "markDeadEnd"}) do
	astar[v] = __NULL__
end

function astar:backtrace()
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

function astar:step()
	if #self.openList > 0 and not self.complete then
		-- Sort the openList based on the f score
		table.sort(self.openList, function(a, b) return self.fScore[a] < self.fScore[b] end)
		local currentCell = table.remove(self.openList, 1)
		self.openSet[currentCell] = nil -- Remove from set
		self.currentTile = currentCell -- the tile object
		self:exploreTile(currentCell)

		if self:isTarget(currentCell) then
			self.complete = true
			return self:backtrace()
		end

		local neighbors = currentCell:getNeighbors()
		for _, neighbor in ipairs(neighbors) do
			local tentative_gScore = self.gScore[currentCell] + self:distance(currentCell, neighbor)

			if not self.visited[neighbor] or tentative_gScore < self.gScore[neighbor] then
				self.parents[neighbor] = currentCell
				self.gScore[neighbor] = tentative_gScore
				self.fScore[neighbor] = self.gScore[neighbor] + self:heuristic(neighbor, self.target)

				if not self.openSet[neighbor] then
					table.insert(self.openList, neighbor)
					self.openSet[neighbor] = true
				end
			end
		end

		self.visited[currentCell] = true

		-- Only mark as a dead end if it's fully explored
		-- This only runs on the end of the dead end
		if #self:getUnvisitedNeighbors(currentCell) == 0 then
			self:markDeadEnd(currentCell)
		end
	else
		self.complete = true
	end
end

function astar:getUnvisitedNeighbors(cell)
	local neighbors = cell:getNeighbors()
	local unvisited = {}
	for _, neighbor in ipairs(neighbors) do
		if not self.visited[neighbor] then
			table.insert(unvisited, neighbor)
		end
	end
	return unvisited
end

function astar:distance(cell1, cell2)
	return 1
end

function astar:heuristic(cell, target)
	-- Implement the heuristic function to estimate the distance from cell to target
	-- Common choices are Euclidean distance, Manhattan distance, etc.
	local dx = math.abs(cell.x - target.x)
	local dy = math.abs(cell.y - target.y)
	return dx + dy
end


return astar
local HERE = (...):gsub('%.[^%.]+$', '')
local Pathfinder = require(HERE..".pathfinder")

local astar = setmetatable({}, { __index = Pathfinder })
astar.__index = astar
astar._VERSION = "0.0.6"
astar.MinHeap = nil -- Pass Tablua's MinHeap (https://github.com/JJSax/Tablua) before use.

---Create the astar
function astar.new(grid, startTile, target)
	assert(type(astar.MinHeap) == "table" and astar.MinHeap.pop, "Please pass the minHeap library from Tablua before astar use.")

	local self = setmetatable(Pathfinder.new(grid, startTile, target), astar)
	self.parents = {}
	self.openList = astar.MinHeap.new({startTile}, function(a, b) return self.fScore[a] < self.fScore[b] end) -- Tiles to be visited
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

---Construct path from the target to start; Use after pathing complete
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

---Runs Single step through the astar
function astar:step()
	if #self.openList > 0 and not self.complete then
		local currentCell = self.openList:pop()
		self.openSet[currentCell] = nil -- Remove from set
		self.currentTile = currentCell -- the tile object
		self:exploreTile(currentCell)

		if self:isTarget(currentCell) then
			self.complete = true
			return self:backtrace()
		end

		local neighbors = currentCell:getNeighbors(self.grid)
		for _, neighbor in ipairs(neighbors) do
			local tentative_gScore = self.gScore[currentCell] + self:distance(currentCell, neighbor)

			if not self.visited[neighbor] or tentative_gScore < self.gScore[neighbor] then
				self.parents[neighbor] = currentCell
				self.gScore[neighbor] = tentative_gScore
				self.fScore[neighbor] = self.gScore[neighbor] + self:heuristic(neighbor, self.target)

				if not self.openSet[neighbor] then
					self.openList:insert(neighbor)
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

---The distance between two tiles
function astar:distance(tile1, tile2)
	return 1
end

---The distance to target; Without square root for efficiency.
function astar:heuristic(tile, target)
	local dx = math.abs(tile.x - target.x)
	local dy = math.abs(tile.y - target.y)
	return dx + dy
end


return astar
local HERE = (...):gsub('%.[^%.]+$', '')
local Pathfinder = require(HERE..".pathfinder")

local dfs = setmetatable({}, { __index = Pathfinder })
dfs.__index = dfs
dfs._VERSION = "0.1.1"

---Create the dfs
function dfs.new(grid, startTile, target)
	local self = setmetatable(Pathfinder.new(grid, startTile, target), dfs)
	self.stack = {startTile}
	return self
end

---Runs Single step through the DFS
function dfs:step()
	if #self.stack > 0 and not self.complete then
		local currentCell = table.remove(self.stack)
		self.currentTile = currentCell -- the tile object
		self:exploreTile(currentCell)
		if self:isTarget(currentCell) then
			self.complete = true
			return self.visited
		end
		local neighbors = self:getUnvisitedNeighbors(currentCell)
		if #neighbors > 0 then
			table.insert(self.path, currentCell)
			table.insert(self.stack, currentCell)
			local nextCell = neighbors[math.random(1, #neighbors)]
			self.visited[nextCell] = true
			table.insert(self.stack, nextCell)
		else
			table.remove(self.path)
			self:markDeadEnd(currentCell)
		end
	else
		self.complete = true
	end
end

return dfs
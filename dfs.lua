local HERE = (...):gsub('%.[^%.]+$', '')
local Pathfinding = require(HERE..".pathfinding")

local dfs = setmetatable({}, { __index = Pathfinding })
dfs.__index = dfs
dfs._VERSION = "0.0.1"

function dfs.new(grid, startTile)
	return setmetatable(Pathfinding.new(grid, startTile), dfs)
end

function dfs:run()
	repeat
		self:step()
	until self.complete
end

local function __NULL__(...) end
for k,v in ipairs({"exploreTile", "markCorrect", "markDeadEnd"}) do
	dfs[v] = __NULL__
end

function dfs:step()
	if #self.stack > 0 and not self.complete then
		local currentCell = table.remove(self.stack)
		self.currentTile = currentCell -- the tile object
		local neighbors = self:getUnvisitedNeighbors(currentCell)
		if #neighbors > 0 then
			table.insert(self.stack, currentCell)
			local nextCell = neighbors[love.math.random(1, #neighbors)]
			self.visited[nextCell] = true
			self:exploreTile(nextCell)
			-- self:markCorrect(currentCell)
			table.insert(self.stack, nextCell)
		else
			self:markDeadEnd(currentCell)
		end
	else
		self.complete = true
	end
end

function dfs:getUnvisitedNeighbors(cell)
	local neighbors = cell:getNeighbors()
	local unvisited = {}
	for k,v in ipairs(neighbors) do
		if not self.visited[v] then
			table.insert(unvisited, v)
		end
	end
	return unvisited
end

return dfs
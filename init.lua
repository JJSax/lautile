
----------------------------------------
-- Desc: Generic Grid Library.  This creates a rectangular grid.
-- By: JJSax
-- Date: 3/1/2023
----------------------------------------


local Grid = {}
Grid.__index = Grid
Grid._version = "0.1.22"

local Cell = {}
Cell.__index = Cell

function Grid.new(width, height, properties)

	--@ width/height is how many cells horizontally and vertically
	--@ properties requires a table passed
	--@ properties.cellWidth/cellHeight is predefined as the 2d space taken by a cell

	properties = properties or {}
	local self = setmetatable({}, Grid)
	self.width = width
	self.height = height
	self.cellWidth = properties.cellWidth or properties.squareCellSize
	self.cellHeight = properties.cellHeight or properties.squareCellSize
	self._is2D = self.cellWidth and true or false

	for x = 1, width do
		self[x] = {}
		for y = 1, height do
			self[x][y] = self:newCell(x, y, properties)
		end
	end

	return self
end

function Grid:newCell(x, y, properties)

	-- local cWidth = properties.cellWidth
	-- local cHeight = properties.cellHeight

	return setmetatable({
		x = x, y = y, grid = self
	}, Cell)

end

function Grid:isValidCell(x, y)
	if type(x) == "table" then return x.grid == self end
	return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

function Grid:getAdjacent(x, y, diagonals)

	-- loop through adjacent cells to x, y
	-- if diagonals is true, add diagonals

	local adjacent = {}
	for lx = -1, 1 do
		for ly = -1, 1 do
			if lx == 0 and ly == 0 then -- do nothing
			elseif self:isValidCell(x + lx, y + ly) and
			((diagonals and lx ~= 0 and ly ~= 0) or (lx==0 or ly==0)) then
				table.insert(adjacent, self[x + lx][y + ly])
			end
		end
	end return adjacent

end

function Grid:iterate()
	local i = 0
	return function()
		i = i + 1
		if i <= self.width * self.height then
			local x, y = (i-1) % self.width + 1, -- x
						 math.ceil(i/self.width) -- y
			return self[x][y], x, y
		end
	end
end

function Grid:iterateAdjacent(x, y, diagonals)
	local adjacent = self:getAdjacent(x, y, diagonals)
	local i = 0
	return function()
		i = i + 1
		if i <= #adjacent then
			return self[adjacent[i].x][adjacent[i].y], adjacent[i].x, adjacent[i].y
		end
	end
end

function Grid:getRandomLocation()
	return math.random(self.width), math.random(self.height)
end
function Grid:getRandomCell()
	local x, y = self:getRandomLocation()
	return self[x][y]
end

function Grid:coordsToIndex(x, y)
	return x + (y - 1) * self.width
end

function Grid:depthFirstSearch(x, y)
	local stack = {
		{x = x, y = y}
	}
	local visited = {}
	while #stack > 0 do
		local cell = table.remove(stack)
		if not visited[cell.x] then
			visited[cell.x] = {}
		end
		if not visited[cell.x][cell.y] then
			visited[cell.x][cell.y] = true
			local adjacent = self:getAdjacent(cell.x, cell.y)
			for i = 1, #adjacent do
				table.insert(stack, adjacent[i])
			end
		end
	end
	return visited
end

function Grid:cellFromScreen(x, y)
	-- x, y is point in window to check
	-- this will *not* account for translation.
	assert(self._is2D, "Requires 2D cells. Pass in width and height into grid.new()")
	local ox, oy = math.ceil(x / self.cellWidth), math.ceil(y / self.cellHeight)
	return self:isValidCell(ox, oy) and self[ox][oy] or false
end

function Cell:getLocation()
	return (self.x - 1) * self.grid.cellWidth, (self.y - 1) * self.grid.cellHeight
end

function Cell:getPosition() return self.x, self.y end

function Grid:setSize(w, h)
	self.cellWidth  = w
	self.cellHeight = h
end

return Grid
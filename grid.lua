

local Grid = {}
Grid.__index = Grid
Grid._VERSION = "2.0.3"


--[[
Tiles will have x and y to be it's position in the Grid
Also width/height will be what is used for 2d operations.
]]

local function expect(p, exp, name)
	if type(p) ~= exp then
		error('param "' .. name .. '" expects type(' .. exp .. ').  Got: ' .. type(p), 2)
	end
end

local function clone(t)
	if type(t) ~= "table" then return t end
	local output = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			output[k] = clone(v)
		else
			output[k] = v
		end
	end
	return output
end

local function interpretDefault(d)
	if type(d) == "table" then
		return function() return d end
	elseif type(d) == "function" then
		return d
	elseif type(d) == "nil" then
		return function() return {} end
	else
		error("type of tile can only be of type table or function.", 3)
	end
end

Grid.__index = Grid

function Grid.__call(self, x, y)
	expect(x, "number", "x")
	expect(y, "number", "y")

	if self.tiles[x] and self.tiles[x][y] then
		return self.tiles[x][y], true
	end

	assert(not self.strict, "Grid is strict; You cannot index cells that don't exist.")

	local t = self.defaultTile(self, x, y)
	t.x, t.y = x, y
	if not self.tiles[x] then self.tiles[x] = {} end
	self.tiles[x][y] = t
	return self.tiles[x][y], false
end

function Grid.new(tile, width, height, strict) -- strict disallows indexing cells that are oustide w/h
	local self = setmetatable({
		tiles = {},
		defaultTile = interpretDefault(tile),
	}, Grid)

	if not width then return self end
	assert(height, "Cannot have a grid width without a grid height.")

	for x = 1, width do
		for y = 1, height do
			self(x, y)
		end
	end

	self.strict = strict -- after so cell creation can happen

	return self
end

function Grid:isValidCell(x, y)
	if type(x) == "table" then return x.grid == self end
	return self.tiles[x] and self.tiles[x][y]
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
				table.insert(adjacent, self.tiles[x + lx][y + ly])
			end
		end
	end
	return adjacent
end

function Grid:iterate()
	return coroutine.wrap(function()
		for _, xt in pairs(self.tiles) do
			for _, tile in pairs(xt) do
				coroutine.yield(tile, tile.x, tile.y)
			end
		end
	end)
end

function Grid:iterateAdjacent(x, y, diagonals)
	local adjacent = self:getAdjacent(x, y, diagonals)
	local i = 0
	return function()
		i = i + 1
		if i <= #adjacent then
			return adjacent[i], adjacent[i].x, adjacent[i].y
		end
	end
end

function Grid:getRandomCell()
	return
end

return Grid
---@class Luatile
---@field tiles table<number, table<number, LTTile>> A 2D array of tiles.
---@field defaultTile LTTile The default tile to use when none is specified.
---@field tileList LTTile[] A list of all tiles.
---@field strict boolean Whether new cell creations can happen.
---@field _VERSION string The version of the Grid class.
local Grid = {}
Grid.__index = Grid
Grid._VERSION = "2.0.6"

local HERE = (...):gsub('%.[^%.]+$', '')
local Tile = require(HERE .. ".tile")

local function expect(p, exp, name)
	if type(p) ~= exp then
		error('param "' .. name .. '" expects type(' .. exp .. ').  Got: ' .. type(p), 2)
	end
end

function Grid.__call(self, x, y)
	expect(x, "number", "x")
	expect(y, "number", "y")

	if self.tiles[x] and self.tiles[x][y] then
		return self.tiles[x][y], true
	end

	assert(not self.strict, "Grid is strict; You cannot index cells that don't exist.")

	local t = self.defaultTile.new(x, y)
	if not self.tiles[x] then self.tiles[x] = {} end
	self.tiles[x][y] = t

	table.insert(self.tileList, t)

	return self.tiles[x][y], false
end

function Grid.new(tile, width, height, strict)
	local default = tile or Tile
	assert(default.new, "Tile object passed require a constructor called 'new'")
	local self = setmetatable({
		tiles = {},
		defaultTile = default,
		tileList = {}
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

function Grid:deleteTile(x, y)
	assert(not self.strict, "Attemt to delete a protected tile; strict mode on.")
	local t = self:isValidCell(x, y)
	assert(t, "Attempt to delete a non-existent tile.")

	for k, v in pairs(self.tileList) do --! O(n); will need to rework this
		if v == t then
			table.remove(self.tileList, k)
		end
	end

	self.tiles[x][y] = nil
end

--- Checks if the cell at (x[, y]) is valid.
--- @param x number The x-coordinate.
--- @param y number The y-coordinate.
--- @return table|nil> The tile if it exists, otherwise nil.
function Grid:isValidCell(x, y)
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
				((diagonals and lx ~= 0 and ly ~= 0) or (lx == 0 or ly == 0)) then
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

function Grid:unpack(tile)
	return tile.x, tile.y
end

function Grid:getRandomLocation()
	return self:unpack(self.tileList[math.random(#self.tileList)])
end

function Grid:getRandomCell()
	return self.tileList[math.random(#self.tileList)]
end



local neighbors = {
	{ x = 0,  y = -1 }, -- Top
	{ x = 1,  y = 0 }, -- Right
	{ x = 0,  y = 1 }, -- Bottom
	{ x = -1, y = 0 }, -- Left
	{ x = 1,  y = -1 }, -- Top-right
	{ x = 1,  y = 1 }, -- Bottom-right
	{ x = -1, y = 1 }, -- Bottom-left
	{ x = -1, y = -1 }, -- Top-left
}

function Grid:getNeighbors(x, y)
	assert(self:isValidCell(x, y), "Invalid cell coordinates")
	local out = {}
	for i = 1, 4 do
		if self:isValidCell(x + neighbors[i].x, y + neighbors[i].y) then
			table.insert(out, self(x + neighbors[i].x, y + neighbors[i].y))
		end
	end
	return out
end

function Grid:getDiagonalNeighbors(x, y)
	assert(self:isValidCell(x, y), "Invalid cell coordinates")
	local out = {}
	for i = 5, 8 do
		if self:isValidCell(x + neighbors[i].x, y + neighbors[i].y) then
			table.insert(out, self(x + neighbors[i].x, y + neighbors[i].y))
		end
	end
	return out
end

function Grid:getAllNeighbors(x, y)
	assert(self:isValidCell(x, y), "Invalid cell coordinates")
	local out = {}
	for i = 1, 8 do
		if self:isValidCell(x + neighbors[i].x, y + neighbors[i].y) then
			table.insert(out, self(x + neighbors[i].x, y + neighbors[i].y))
		end
	end
	return out
end

function Grid:getTileNeighbors(tile)
	return self:getNeighbors(tile.x, tile.y)
end

function Grid:getTileDiagonalNeighbors(tile)
	assert(self:isValidCell(tile.x, tile.y), "Invalid cell coordinates")
	return self:getDiagonalNeighbors(tile.x, tile.y)
end

function Grid:getTileAllNeighbors(tile)
	assert(self:isValidCell(tile.x, tile.y), "Invalid cell coordinates")
	return self:getAllNeighbors(tile.x, tile.y)
end

return Grid

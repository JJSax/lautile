

local Grid = {}
Grid.__index = Grid
Grid._VERSION = "2.0.0"

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
		return function() end
	else
		error("type of tile can only be of type table or function.", 3)
	end
end

local function call(self, x, y)

end

-- function Grid.__index(self, i)

-- end
Grid.__index = Grid
-- Grid.__newindex = function(self, k, v)
-- 	print(self, k, v)
-- end

function Grid.__call(self, x, y)
	expect(x, "number", "x")
	expect(y, "number", "y")

	if self.tiles[x] and self.tiles[x][y] then
		return self.tiles[x][y], true
	end

	assert(not self.strict, "Grid is strict; You cannot index cells that don't exist.")

	local t = self.defaultTile()
	t.x, t.y = x, y
	if not self.tiles[x] then self.tiles[x] = {} end
	self.tiles[x][y] = t
	return self.tiles[x][y], false
end

function Grid.new(tile, width, height, strict) -- strict disallows indexing cells that are oustide w/h
	local self = setmetatable({
		tiles = {},
		defaultTile = interpretDefault(tile)
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

function Grid:setTile(x, y, data)
	--? consider new file to be used in this file
	--? that allows unordered indices still have a single size integer
	if not data then
		assert(self.tiles[x], "Requires x position to be valid.")
		self.tiles[x][y] = nil
		return
	end
	self.tiles[x] = self.tiles[x] or {}
	self.tiles[x][y] = data
end

function Grid:getTile(x, y)
	if not self.tiles[x] then
		return {}
	end
	return self.tiles[x][y] or {}
end

return Grid
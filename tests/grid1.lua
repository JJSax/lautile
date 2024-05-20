
-- run in terminal in luatile folder
---@diagnostic disable-next-line: different-requires
local Grid = require("./grid")

-- Test Grid creation
local grid = Grid.new(nil, 5, 5, true)  -- Create a 5x5 grid with strict mode
assert(#grid.tileList == 25, "Grid creation failed")

-- Test getting a cell
local tile, notNew = grid(3, 3)
assert(notNew == true, "Getting existing cell failed")
assert(tile.x == 3 and tile.y == 3, "Cell coordinates mismatch")

-- Test setting a tile
local isNewTile
local err = pcall(function() _, isNewTile = grid(6, 6) end)
assert(not err, "Strict mode failed to protect from new tiles")
assert(isNewTile == nil, "Setting tile outside grid failed")

-- Test deleting a tile while strict
local err = pcall(function() grid:deleteTile(3, 3) end)
assert(not err, "Assert failed to catch deleting tile under strict mode.")

-- Test deleting a nil tile
local err = pcall(function() grid:deleteTile(6, 6) end)
assert(not err, "Assert failed to catch deleting non-existent tile.")

-- Test getting adjacent cells
local adjacent = grid:getAdjacent(3, 3, false)
assert(#adjacent == 4, "Adjacent cells count mismatch")

-- Test getting adjacent cells
local adjacent = grid:getAdjacent(3, 3, true)
assert(#adjacent == 8, "Adjacent cells count mismatch")

-- Test iterating through cells
local count = 0
for _ in grid:iterate() do
	count = count + 1
end
assert(count == 25, "Iterating through cells failed")

-- Test iterating through adjacent cells
local countAdjacent = 0
for _ in grid:iterateAdjacent(3, 3, false) do
	countAdjacent = countAdjacent + 1
end
assert(countAdjacent == 4, "Iterating through adjacent cells failed")

-- Test iterating through adjacent cells w/ diagonals
local countAdjacent = 0
for _ in grid:iterateAdjacent(3, 3, true) do
	countAdjacent = countAdjacent + 1
end
assert(countAdjacent == 8, "Iterating through adjacent cells failed")

-- Test unpacking a tile
local x, y = grid:unpack(tile)
assert(x == 3 and y == 3, "Unpacking tile failed")

-- Test getting random location
local randX, randY = grid:getRandomLocation()
assert(grid:isValidCell(randX, randY) ~= nil, "Getting random location failed")

-- Test getting random cell
local randomCell = grid:getRandomCell()
assert(randomCell ~= nil, "Getting random cell failed")

print("All tests passed successfully!")

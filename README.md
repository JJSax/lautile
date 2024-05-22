# lautile Version 2 (Beta)





## Version 2 changes

* Allow passing a default tile object

* Disable new tile creations with strict mode.

* Tiles get created when called; respects strict mode.

* Allow getting a tile via a __Call(x, y)

* Comes included with pathfinding modules.  Created separately, if you don't need them no extra ram is used.

Example:
```lua
local tile = Grid(5, 4) -- gets the tile at position x = 5, y = 4
``````

* No longer limited by a rectangular grid
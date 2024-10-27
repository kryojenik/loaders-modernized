[![shield](https://img.shields.io/badge/Ko--fi-Donate%20-hotpink?logo=kofi&logoColor=white)](https://ko-fi.com/M4M2LCWTH) [![shield](https://img.shields.io/badge/dynamic/json?color=orange&label=Factorio&query=downloads_count&suffix=%20downloads&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2Floaders-modernized)](https://mods.factorio.com/mod/loaders-modernized)

## Loaders Modernized

A Space Aged, compact loader the size of a single tile.  This loader should be UPS friendly and does
not use LUA to move items.  It also does not use hidden inserters to move inventory.  However, they
do use power.  So keep those power poles handy!

### Features

- Works in Factorio 2.0 and supports Space Age
- Control circuit supported.
- Works with cargo wagons.
- Loaders snap to belts and away from non-belts
- Able to migrate Miniloaders.

**CAUTION: Backup your save file before migrating Miniloaders**

As a startup setting, you can enable migration of existing Miniloaders.  This will attempt to find all
miniloaders and replace them with equivilent Loaders Modernized.  This may not be perfect, and I'll fix
what I can when reported.  Please backup your save file before attempting migration.  Specific Belt
overhaul mods are not implemented yet.  Please drop a message if one is needed.

### TODO

- Support belts from overhaul mods
- Provide interface for overhaul mods to generate their own loaders
- Support belt stacking

### Acknowledgements

- Inspired by [Miniloader](https://mods.factorio.com/mod/miniloader) by therax.
- The artwork (at this time) is borrowed from Miniloader.  I am not an artist.  Anyone interested
- in contributing new art please let me know.
- Arch666Angel is acknowledged for initial creation of the artwork.  The artwork is under GPLv3 license.

### Known issues

- Unable to set filters as a blacklist filter.  This is currently a limitation of the game engine.
- Input loaders (filling a container) ignore filters.  This is currently a limitation of the game engine.

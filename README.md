Sunburn [sunburn]
=================

A Minetest mod where sunlight simply kills you directly

Version: 0.1.0

License:
  Code: LGPL 2.1 (see included LICENSE file)
  Textures: CC-BY-SA (see http://creativecommons.org/licenses/by-sa/4.0/)

Report bugs or request help on the forum topic.

Description
-----------

This is a mod for MineTest. Its goal is to make sunlight dangerous
by causing "sunburn", which damages you directly. Your only chance
is to burrow down when the sun comes up.

Current behavior
----------------

If you stand in a node with light level 14 or more, you slowly
accumulate "sunburn", represented by a hud bar with sun symbols.
The more sunburn you have, the more you get damaged per second.

The sunburn will heal in darkness, but slowly. Until it is fully
healed, you'll continue to take damage even if you're no longer
in the sun!

Future plans
------------

None.

Dependencies
------------
* hud (optional): https://forum.minetest.net/viewtopic.php?f=11&t=6342 (see HUD.txt for configuration)
* hudbars (optional): https://forum.minetest.net/viewtopic.php?f=11&t=11153

Installation
------------

Unzip the archive, rename the folder to to `bewarethedark` and
place it in minetest/mods/

(  Linux: If you have a linux system-wide installation place
    it in ~/.minetest/mods/.  )

(  If you only want this to be used in a single world, place
    the folder in worldmods/ in your worlddirectory.  )

For further information or help see:
http://wiki.minetest.com/wiki/Installing_Mods

# Core API
The core API is composed of several functions to make registering new items, nodes, and recipes for items and nodes more efficient and intuitive. Code for this public API is in `./api.lua`. This documentation is divided up per function.

#### `register_recipe(output, def)`
__Usage:__ `microexpansion.register_recipe(<output (string)>, <recipe (table)>)`

Though this may seem rather complex to understand, this is a very useful timesaving function when registering recipes. It allows registering multiple recipes at once in one table. The output must always remain the same as is specified as the first parameter, while the second parameter should be a table structured like one of the tables below.

__Single Recipe:__
```lua
microexpansion.register_recipe("default:steelblock", {
  "single",
  {
    { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
    { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
    { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
  },
})
```

The above registers a single recipe for the item specified.

__Multiple Recipes:__
```lua
microexpansion.register_recipe("default:steelblock", {
  "multiple",
  {
    { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
    { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
    { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
  },
  {
    { "default:steel_ingot", "default:steel_ingot" },
    { "default:steel_ingot", "default:steel_ingot" },
  }
})
```

The above registers multiple recipes for the item specified.

#### `register_item(itemstring, def)`
__Usage:__ `microexpansion.register_item(<itemstring (string)>, <item definition (table)>`

This API function accepts the same parameters in the definition table as does `minetest.register_craftitem`, however, it makes several modifications to the parameters before passing them on. A new parameter, `usedfor`, is introduced, which if provided is appened on a new line in grey to the item description, a good way to specify what the item does or include more information about it. The `inventory_image` parameter is modified to enforce the naming style adding `microexpansion_` to the beginning of the specified path, and `.png` to the end. If not `inventory_image` is provided, the itemstring is used and then undergoes the above modification. This allows shortening and even removing the `inventory_image` code, while passing everything else (aside from `usedfor`) on to `minetest.register_craftitem`.

#### `register_node(itemstring, def)`
__Usage:__ `microexpansion.register_node(<itemstring (string)>, <item definition (table)>`

This API function accepts the same parameters in the definition table as does `minetest.register_craftitem`, however, it makes several modifications to the parameters before passing them on. A new parameter, `usedfor`, is introduced, which if provided is appened on a new line in grey to the item description, a good way to specify what the item does or include more information about it. The `tiles` table is modified so as to simplify the definition when registering the node. Each texture in the `tiles` table has `microexpansion_` added to the beginning and `.png` to the end. This means that rather than specifying something like `microexpansion_chest_top.png`, only `chest_top` is required. __Note:__ the texture path "autocomplete" functionality can be disabled by settings `auto_complete` to `false` in the definition (useful if using textures from another mod).
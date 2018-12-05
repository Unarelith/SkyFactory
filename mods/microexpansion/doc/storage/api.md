# Storage API
The storage API introduces functions to help register and handle storage devices and related machines and controllers.

#### `register_cell(itemstring, def)`
__Usage:__ `microexpansion.register_cell(<itemstring (string)>, <cell definition (table)>`

This function registers an item storage cell modifying and adding content to the definition table before passing it on to `minetest.register_craftiem`. Only some definition fields are passed on, as drives are not functional outside of a drive bay or ME Chest. Only the `description` and `capacity` must be required. However, if the `inventory_image` base is any different from the `itemstring`, it should be provided as well. The capacity should be an integer specifying the number of items (not slots, or something else) that the drive can store.

#### `get_cell_size(name)`
__Usage:__ `microexpansion.get_cell_size(<full itemstring (string)>)`<br />
__Example__:__ `microexpansion.get_cell_size("microexpansion:cell_8k")`

Returns the integer containing the size of the storage cell specified (size as in max number of items). __Note:__ The itemstring should be for example `microexpansion:cell_8k`, not just `cell_8k`.

#### `int_to_stacks(int)`
__Usage:__ `microexpansion.int_to_stacks(int)`

Calculates the approximate number of stacks from the provided integer which should contain the max number of items.

#### `int_to_pagenum(int)`
__Usage:__ `microexpansion.int_to_pagenum(int)`

Calculates the approximate number of pages from the integer provided which should represent the total number of items.

#### `move_inv(inv1, inv2)`
__Usage:__ `microexpansion.move_inv(<from inventory (userdata)>, <to inventory (userdata)>)`

Moves all the contents of one inventory (`inv1`) to another inventory (`inv2`).

#### `cell_desc(inv, listname, stack_pos)`
__Usage:__ `microexpansion.cell_desc(<inventory (userdata)>, <list name (string)>, <stack position (integer)>)`

Updates the description of an ME Storage Cell to show the amount of items in it vs the max amount of items. The first parameter should be a `userdata` value representing the inventory in which the list containing the cell itemstack is found. The second parameter should contain the name of the list in which the cell itemstack is found. The third (and final) parameter must be an integer telling at what position to storage cell is in the inventory list.
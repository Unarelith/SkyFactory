# Universal Fluid API
This API adds support for `fluid_buffers` inside nodes. This means that nodes can contain fluid.

## How to Use
1. Add the node to the `fluid_container` group.
2. Add the following to the node defintion:
```
    fluid_buffers = {
        buffer_name = {
            capacity = 2000,
            accepts = {"default:water_source", "group:water_source"}, -- you can also set this to true to accept any fluid!
            drainable = true,
        },
    }
```
3. Set the appropriate metadata.

* **buffer_name_fluid** = `string` 		- Source node of the fluid.
* **buffer_name_fluid_storage** = `int` 	- How much fluid there is in this buffer.

## API
All numbers are in **milli-buckets** (1 bucket = 1000 mB).

* `fluid_lib.get_node_buffers(pos)`
	* Returns all the fluid buffers present inside a node.

* `fluid_lib.get_buffer_data(pos, buffer)`
	* Returns all the information about this buffer.
```
    {
        fluid     = fluid source block,
        amount    = amount of fluid,
        accepts   = list of accepted fluids,
        capacity  = capacity of the buffer,
        drainable = is this buffer drainable,
    }
```

* `fluid_lib.buffer_accepts_fluid(pos, buffer, fluid)`
	* Returns `true` if `fluid` can go inside the `buffer` at `pos`.

* `fluid_lib.can_insert_into_buffer(pos, buffer, fluid, count)`
	* Returns the amount of `fluid` that can go inside the `buffer` at `pos`. If all of it fits, it returns `count`.

* `fluid_lib.insert_into_buffer(pos, buffer, fluid, count)`
	* Actually does the inserting.

* `fluid_lib.can_take_from_buffer(pos, buffer, count)`
	* Returns the amount of `fluid` that can be taken from the `buffer` at `pos`.

* `fluid_lib.take_from_buffer(pos, buffer, count)`
	* Actually takes the fluid. On success, returns the source block that was taken and how much was actually taken.

* `bucket.register_liquid(source, flowing, itemname, inventory_image, name, groups, force_renew)`
	* Works exactly the same as the default `bucket` mod, except it adds callbacks to insert/take fluid from nodes.
	* `inventory_image` can be a **ColorString**.

## License
### bucket
See [bucket/license.txt](bucket/license.txt)
### fluid_lib
See [LICENSE](LICENSE)

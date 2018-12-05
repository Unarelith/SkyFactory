# Documentation
The APIs provided by MicroExpansion are divided among several different files. Unless otherwise mentioned, the `.md` documentation file is labeled the same as the Lua file containing the code. However, for modules, documentation is found in a subdirectory. Below, the main documentation sections are found before being divided depending on the module.

### `modules.md`
Non-API portions of MicroExpansion are loaded as modules to allow them to be easily enabled or disabled. This documents the API for loading, configuring, and interacting with modules.

### `api.lua`
This section documents the "core" API that is always loaded before any modules (`api.lua`). This API is mostly made up of functions to make registering items, nodes, and recipes quicker and more intuitive.
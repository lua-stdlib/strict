# std.strict NEWS - User visible changes

## Noteworthy changes in release 1.0 (2016-02-07) [stable]

### Incompatible changes

  - To avoid clashing with PUC-Rio strict.lua, rename this package to
    std.strict.  You should change client packages to load from its
    new location:

    ```lua
    local strict = require "std.strict"
    ```

  - To minimise the number of places the release number needs to be
    updated, the `std.strict._VERSION` constant has been replaced by a
    generated `std.strict.version` submodule.


## Noteworthy changes in release 1.0 (2016-01-19) [stable]

### New features

  - Initial release, now separated out from lua-stdlib.

### Incompatible changes

  - The standalone implementation no longer requires or is affected by
    the value of `std.debug_init._DEBUG.strict`.  If you still want to
    do that you can write:

    ```lua
    local strict = require "strict"
    local _DEBUG = require "std.debug_init"._DEBUG

    local _ENV = _ENV
    if nil ~= (_DEBUG or {}).strict then
      _ENV = strict.strict (_ENV)
    end
    if rawget (_G, "setfenv") ~= nil then
      setfenv (1, _ENV)
    end
    ```

# std.strict NEWS - User visible changes

## Noteworthy changes in release ?.? (????-??-??) [?]


## Noteworthy changes in release 1.4 (2023-01-07) [stable]

### New Features

  - Support importing into another project directly with:

    ```sh
    $ cp ../strict/lib/std/strict/init.lua lib/std/strict.lua
    ```


## Noteworthy changes in release 1.3.2 (2018-09-23) [stable]

### New Features

  - Initial support for Lua 5.4.


## Noteworthy changes in release 1.3.1 (2017-10-14) [stable]

### Documentation changes

  - removed references to `_DEBUG` and `require 'std.debug_init'`; for
    completeness, with a modern version of 'std._debug' you could:

    ```lua
    local _ENV = setmetatable({}, {__index=_G})
    if require 'std._debug'.strict == true then
       _ENV = require 'std.strict'.strict(_ENV)
    end
    if rawget(_G, 'setfenv') ~= nil then
       setfenv(1, _ENV)
    end
    ```

    ...or you could just let the 'std.normalize' library take care of
    all this for you!


## Noteworthy changes in release 1.3 (2017-09-17) [stable]

### Bug Fixes

  - where available, use setfenv to enforce `_ENV` table.


## Noteworthy changes in release 1.2 (2017-02-04) [stable]

### New features

  - Builds and installs with `luke` instead of Make.

  - In order to support `__call` responses from deeper in the call
    stack, accept an optional `level` argument.


## Noteworthy changes in release 1.1 (2016-04-10) [stable]

### New features

  - Strict environments created by this module now correctly proxy
    `len` and `pairs` calls to the environment table.

    Note that `ipairs` works by looking for the first numeric key
    with a `nil` value, and a `nil` valued key in the environment table
    is the exact criterion for an undeclared variable access.  This
    means that passing a strict environment table to `ipairs` always
    triggers an 'assignment to undeclared variable <#env + 1>' error.

### Incompatible changes

  - To avoid clashing with PUC-Rio strict.lua, rename this package to
    std.strict.  You should change client packages to load from its
    new location:

    ```lua
    local strict = require 'std.strict'
    ```

  - To minimise the number of places the release number needs to be
    updated, the `std.strict._VERSION` constant has been replaced by a
    generated `std.strict.version` submodule.


## Noteworthy changes in strict release 1.0 (2016-01-19) [stable]

### New features

  - Initial release, now separated out from lua-stdlib.

### Incompatible changes

  - The standalone implementation no longer requires or is affected by
    the value of `std.debug_init._DEBUG.strict`.  If you still want to
    do that you can write:

    ```lua
    local strict = require 'strict'
    local _DEBUG = require 'std.debug_init'._DEBUG

    local _ENV = _ENV
    if nil ~= (_DEBUG or {}).strict then
       _ENV = strict.strict(_ENV)
    end
    if rawget(_G, 'setfenv') ~= nil then
       setfenv(1, _ENV)
    end
    ```

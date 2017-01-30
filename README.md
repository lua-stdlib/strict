Diagnose uses of undeclared variables
=====================================

Copyright (C) 2010-2017 [std.strict authors][authors]

[![License](https://img.shields.io/:license-mit-blue.svg)](https://mit-license.org)
[![travis-ci status](https://secure.travis-ci.org/lua-stdlib/strict.png?branch=master)](https://travis-ci.org/lua-stdlib/strict/builds)
[![codecov.io](https://codecov.io/github/lua-stdlib/strict/coverage.svg?branch=master)](https://codecov.io/github/lua-stdlib/strict?branch=master)
[![Stories in Ready](https://badge.waffle.io/lua-stdlib/strict.png?label=ready&title=Ready)](https://waffle.io/lua-stdlib/strict)

All variables (including functions!) must be "declared" through a regular
assignment (even assigning `nil` will do) in a strict scope before being
used anywhere or assigned to inside a nested scope.

Use the callable returned by this module to interpose a strictness check
proxy table to the given environment.  The callable runs `setfenv`
appropriately in Lua 5.1 interpreters to ensure the semantic equivalence.

This is a pure Lua library compatible with [LuaJIT][], [Lua][] 5.1,
5.2 and 5.3.

[authors]: https://github.com/lua-stdlib/strict/blob/master/AUTHORS.md "std.strict contributors"
[lua]: https://www.lua.org "The Lua Project"
[luajit]: http://luajit.org "The LuaJIT Project"


Installation
------------

The simplest and best way to install strict is with [LuaRocks][]. To
install the latest release (recommended):

```bash
    luarocks install std.strict
```

To install current git master (for testing, before submitting a bug
report for example):

```bash
    luarocks install https://raw.githubusercontent.com/lua-stdlib/strict/master/std.strict-git-1.rockspec
```

The best way to install without [LuaRocks][] is to copy the
`std/strict` directory into your package search path.

[luarocks]: https://www.luarocks.org "Lua package manager"


Use
---

The strict package returns a callable "functable" that returns an
environment that requires all variables be declared before use.

```lua
   local strict = require 'std.strict'

   -- For use of the global environment from this scope.
   local _ENV = strict(_G)

   -- Or, prevent all access to global environment.
   local _ENV = strict{}

   -- Or, control access to limited environment from this scope.
   local _ENV = strict{
      setmetatable = setmetatable,
      type         = type,
      table_unpack = table.unpack or unpack,
   }
```



Documentation
-------------

The latest release is [documented with LDoc][github.io].
Pre-built HTML files are included in the [release tarball][].

[github.io]: https://lua-stdlib.github.io/strict "Documentation"
[release]: https://lua-stdlib.github.io/strict/releases "Releases"


Bug reports and code contributions
----------------------------------

Please make bug reports and suggestions as [GitHub Issues][issues].
Pull requests are especially appreciated.

But first, please check that your issue has not already been reported by
someone else, and that it is not already fixed by [master][github] in
preparation for the next release (see Installation section above for how
to temporarily install master with [LuaRocks][]).

There is no strict coding style, but please bear in mind the following
points when proposing changes:

0. Follow existing code. There are a lot of useful patterns and avoided
   traps there.

1. 3-character indentation using SPACES in Lua sources: It makes rogue
   TABs easier to see, and lines up nicely with 'if' and 'end' keywords.

2. Simple strings are easiest to type using single-quote delimiters,
   saving double-quotes for where a string contains apostrophes.

3. Save horizontal space by only using SPACES where the parser requires
   them.

4. Use vertical spacing to separate out compound statements to help the
   coverage reports discover untested lines.

[github]: https://github.com/lua-stdlib/strict/ "Github repository"
[issues]: https://github.com/lua-stdlib/strict/issues "Github issues"

--[[
 Strict variable declarations for Lua 5.1, 5.2, 5.3 & 5.4.
 Copyright (C) 2006-2023 std.strict authors
]]
--[[--
 Diagnose uses of undeclared variables.

 All variables(including functions!) must be "declared" through a regular
 assignment(even assigning `nil` will do) in a strict scope before being
 used anywhere or assigned to inside a nested scope.

 Use the callable returned by this module to interpose a strictness check
 proxy table to the given environment.   The callable runs `setfenv`
 appropriately in Lua 5.1 interpreters to ensure the semantic equivalence.

 @module std.strict
]]


local setfenv = rawget(_G, 'setfenv') or function() end
local debug_getinfo = debug.getinfo


-- Return callable objects.
-- @function callable
-- @param x an object or primitive
-- @return *x* if *x* can be called, otherwise `nil`
-- @usage
--   (callable(functable) or function()end)(args, ...)
local function callable(x)
   -- Careful here!
   -- Most versions of Lua don't recurse functables, so make sure you
   -- always put a real function in __call metamethods.  Consequently,
   -- no reason to recurse here.
   -- func=function() print 'called' end
   -- func() --> 'called'
   -- functable=setmetatable({}, {__call=func})
   -- functable() --> 'called'
   -- nested=setmetatable({}, {__call=function(self, ...) return functable(...)end})
   -- nested() -> 'called'
   -- notnested=setmetatable({}, {__call=functable})
   -- notnested()
   -- --> stdin:1: attempt to call global 'nested' (a table value)
   -- --> stack traceback:
   -- -->	stdin:1: in main chunk
   -- -->		[C]: in ?
   if type(x) == 'function' or (getmetatable(x) or {}).__call then
      return x
   end
end


-- Return named metamethod, if callable, otherwise `nil`.
-- @param x item to act on
-- @string n name of metamethod to look up
-- @treturn function|nil metamethod function, if callable, otherwise `nil`
local function getmetamethod(x, n)
   return callable((getmetatable(x) or {})[n])
end


-- Length of a string or table object without using any metamethod.
-- @function rawlen
-- @tparam string|table x object to act on
-- @treturn int raw length of *x*
-- @usage
--    --> 0
--    rawlen(setmetatable({}, {__len=function() return 42}))
local function rawlen(x)
   -- Lua 5.1 does not implement rawlen, and while # operator ignores
   -- __len metamethod, `nil` in sequence is handled inconsistently.
   if type(x) ~= 'table' then
      return #x
   end

   local n = #x
   for i = 1, n do
      if x[i] == nil then
         return i -1
      end
   end
   return n
end


-- Deterministic, functional version of core Lua `#` operator.
--
-- Respects `__len` metamethod (like Lua 5.2+).   Otherwise, always return
-- one less than the lowest integer index with a `nil` value in *x*, where
-- the `#` operator implementation might return the size of the array part
-- of a table.
-- @function len
-- @param x item to act on
-- @treturn int the length of *x*
-- @usage
--    x = {1, 2, 3, nil, 5}
--    --> 5 3
--    print(#x, len(x))
local function len(x)
   return (getmetamethod(x, '__len') or rawlen)(x)
end


-- Like Lua `pairs` iterator, but respect `__pairs` even in Lua 5.1.
-- @function pairs
-- @tparam table t table to act on
-- @treturn function iterator function
-- @treturn table *t*, the table being iterated over
-- @return the previous iteration key
-- @usage
--    for k, v in pairs {'a', b='c', foo=42} do process(k, v) end
local pairs = (function(f)
   if not f(setmetatable({},{__pairs=function() return false end})) then
      return f
   end

   return function(t)
      return(getmetamethod(t, '__pairs') or f)(t)
   end
end)(pairs)


-- What kind of variable declaration is this?
-- @treturn string 'C', 'Lua' or 'main'
local function what()
   local d = debug_getinfo(3, 'S')
   return d and d.what or 'C'
end


return setmetatable({
   --- Module table.
   -- @table strict
   -- @string version release version identifier


   --- Require variable declarations before use in scope *env*.
   --
   -- Normally the module @{strict:__call} metamethod is all you need,
   -- but you can use this method for more complex situations.
   -- @function strict
   -- @tparam table env lexical environment table
   -- @treturn table *env* proxy table with metamethods to enforce strict
   --    declarations
   -- @usage
   --   local _ENV = setmetatable({}, {__index = _G})
   --   if require 'std._debug'.strict then
   --      _ENV = require 'std.strict'.strict(_ENV)
   --   end
   --   -- ...and for Lua 5.1 compatibility, without triggering undeclared
   --   -- variable error:
   --   if rawget(_G, 'setfenv') ~= nil then
   --      setfenv(1, _ENV)
   --   end
   strict = function(env)
      -- The set of declared variables in this scope.
      local declared = {}

      --- Environment Metamethods
      -- @section environmentmetamethods

      return setmetatable({}, {
         --- Detect dereference of undeclared variable.
         -- @function env:__index
         -- @string n name of the variable being dereferenced
         __index = function(_, n)
            local v = env[n]
            if v ~= nil then
               declared[n] = true
            elseif not declared[n] and what() ~= 'C' then
               error("variable '" .. n .. "' is not declared", 2)
            end
            return v
         end,

         --- Proxy `len` calls.
         -- @function env:__len
         -- @tparam table t strict table
         __len = function() return len(env) end,

         --- Detect assignment to undeclared variable.
         -- @function env:__newindex
         -- @string n name of the variable being declared
         -- @param v initial value of the variable
         __newindex = function(_, n, v)
            local x = env[n]
            if x == nil and not declared[n] then
               local w = what()
               if w ~= 'main' and w ~= 'C' then
                  error("assignment to undeclared variable '" .. n .. "'", 2)
               end
            end
            declared[n] = true
            env[n] = v
         end,

         --- Proxy `pairs` calls.
         -- @function env:__pairs
         -- @tparam table t strict table
         __pairs = function()
            return pairs(env)
         end,
      })
   end,
}, {
   --- Module Metamethods
   -- @section modulemetamethods

   --- Enforce strict variable declarations in *env*.
   -- @function strict:__call
   -- @tparam table env lexical environment table
   -- @tparam[opt=1] int level stack level for `setfenv`, 1 means
   --    set caller's environment
   -- @treturn table *env* which must be assigned to `_ENV`
   -- @usage
   --   local _ENV = require 'std.strict'(_G)
   __call = function(self, env, level)
      env = self.strict(env)
      setfenv(1 + (level or 1), env)
      return env
   end,

   --- Lazy loading of strict submodules.
   -- Don't load everything on initial startup, wait until first attempt
   -- to access a submodule, and then load it on demand.
   -- @function __index
   -- @string name submodule name
   -- @treturn table|nil the submodule that was loaded to satisfy the missing
   --    `name`, otherwise `nil` if nothing was found
   -- @usage
   --   local strict = require 'std.strict'
   --   local version = strict.version
   __index = function(self, name)
      local ok, t = pcall(require, 'std.strict.' .. name)
      if ok then
         rawset(self, name, t)
         return t
      end
   end,
})

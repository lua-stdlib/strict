--[[
 Strict variable declarations for Lua 5.1, 5.2, 5.3 & 5.4.
 Copyright (C) 2014-2018 std.strict authors
]]
--[[--
 Some minimal subset of std.normalize to make sure strict is
 deterministic in its implementation, regardless of the Lua implementation
 hosting it.

 @module std.strict._base
]]

local _ENV = {
   getmetatable = getmetatable,
   pairs = pairs,
   setfenv = setfenv or function() end,
   setmetatable = setmetatable,
   type = type,
}
setfenv(1, _ENV)


--- Return named metamethod, if callable, otherwise `nil`.
-- @param x item to act on
-- @string n name of metamethod to look up
-- @treturn function|nil metamethod function, if callable, otherwise `nil`
local function getmetamethod(x, n)
   local m = (getmetatable(x) or {})[n]
   if type(m) == 'function' then
      return m
   end
   if type((getmetatable(m) or {}).__call) == 'function' then
      return m
    end
end


--- Functional version of core Lua `#` operator.
-- @param x item to act on
-- @treturn int the length of *x*
local function len(x)
   local m = getmetamethod(x, '__len')
   if m then
      return m(x)
   end
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


if not not pairs(setmetatable({},{__pairs=function() return false end})) then
   local _pairs = pairs

   --- Add support for __pairs when missing.
   -- @tparam table t table to iterate over
   -- @treturn function iterator function
   -- @treturn table *t*, the table being iterated over
   -- @return the previous iteration key
   pairs = function(t)
      return(getmetamethod(t, '__pairs') or _pairs)(t)
   end
end


--- @export
return {
   len   = len,
   pairs = pairs,
}

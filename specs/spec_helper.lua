local inprocess = require "specl.inprocess"
local hell      = require "specl.shell"
local std       = require "specl.std"

badargs = require "specl.badargs"

package.path = std.package.normalize ("./lib/?.lua", "./lib/?/init.lua", package.path)



--[[ ================== ]]--
--[[ Normalize Lua API. ]]--
--[[ ================== ]]--


local _base	= require "std.strict._base"

len	= _base.len
pairs	= _base.pairs
unpack	= table.unpack or unpack



-- Allow user override of LUA binary used by hell.spawn, falling
-- back to environment PATH search for "lua" if nothing else works.
local LUA = os.getenv "LUA" or "lua"


-- In case we're not using a bleeding edge release of Specl...
_diagnose = badargs.diagnose
badargs.diagnose = function (...)
  if have_typecheck then
    return _diagnose (...)
  end
end


local function mkscript (code)
  local f = os.tmpname ()
  local h = io.open (f, "w")
  h:write (code)
  h:close ()
  return f
end


--- Run some Lua code with the given arguments and input.
-- @string code valid Lua code
-- @tparam[opt={}] string|table arg single argument, or table of
--   arguments for the script invocation.
-- @string[opt] stdin standard input contents for the script process
-- @treturn specl.shell.Process|nil status of resulting process if
--   execution was successful, otherwise nil
function luaproc (code, arg, stdin)
  local f = mkscript (code)
  if type (arg) ~= "table" then arg = {arg} end
  local cmd = {LUA, f, unpack (arg)}
  -- inject env and stdin keys separately to avoid truncating `...` in
  -- cmd constructor
  cmd.env = { LUA_PATH=package.path, LUA_INIT="", LUA_INIT_5_2="" }
  cmd.stdin = stdin
  local proc = hell.spawn (cmd)
  os.remove (f)
  return proc
end


local function tabulate_output (code)
  local proc = luaproc (code)
  if proc.status ~= 0 then return error (proc.errout) end
  local r = {}
  proc.output:gsub ("(%S*)[%s]*",
    function (x)
      if x ~= "" then r[x] = true end
    end)
  return r
end


--- Show changes to tables wrought by a require statement.
-- There are a few modes to this function, controlled by what named
-- arguments are given.  Lists new keys in T1 after `require "import"`:
--
--     show_apis {added_to=T1, by=import}
--
-- List keys returned from `require "import"`, which have the same
-- value in T1:
--
--     show_apis {from=T1, used_by=import}
--
-- List keys from `require "import"`, which are also in T1 but with
-- a different value:
--
--     show_apis {from=T1, enhanced_by=import}
--
-- List keys from T2, which are also in T1 but with a different value:
--
--     show_apis {from=T1, enhanced_in=T2}
--
-- @tparam table argt one of the combinations above
-- @treturn table a list of keys according to criteria above
function show_apis (argt)
  return tabulate_output ([[
    local before, after = {}, {}
    for k in pairs (]] .. argt.added_to .. [[) do
      before[k] = true
    end

    local M = require "]] .. argt.by .. [["
    for k in pairs (]] .. argt.added_to .. [[) do
      after[k] = true
    end

    for k in pairs (after) do
      if not before[k] then print (k) end
    end
  ]])
end


do
  local matchers = require "specl.matchers".matchers

  matchers.raise = matchers.error
end

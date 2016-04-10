package = "std.strict"
version = "git-1"

description = {
  summary = "Check for use of undeclared variables",
  detailed = [[
    Enforce strict declaration of all variables (including functions) in
    an environment before being used or reassigned from a nested scope.
  ]],
  homepage = "http://lua-stdlib.github.io/strict",
  license = "MIT/X11",
}

source = {
  url = "git://github.com/lua-stdlib/strict.git",
}

dependencies = {
  "lua >= 5.1, < 5.4",
}

build = {
  type = "builtin",
  modules = {
    ["std.strict"]		= "lib/std/strict/init.lua",
    ["std.strict._base"]	= "lib/std/strict/_base.lua",
    ["std.strict.version"]	= "lib/std/strict/version.lua",
  },
}

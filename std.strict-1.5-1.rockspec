local _MODREV, _SPECREV = '1.5', '-1'

package = 'std.strict'
version = _MODREV .. _SPECREV

rockspec_format = '3.0'

description = {
   summary = 'Check for use of undeclared variables',
   detailed = [[
      Enforce strict declaration of all variables (including functions) in
      an environment before being used or reassigned from a nested scope.
   ]],
   homepage = 'https://lua-stdlib.github.io/strict',
   issues_url = 'https://github.com/lua-stdlib/strict/issues',
   license = 'MIT/X11',
}

source = {
   url = 'https://github.com/lua-stdlib/strict/archive/v' .. _MODREV .. '.zip',
   dir = 'strict-' .. _MODREV,
}

dependencies = {
   'lua >= 5.1, < 5.6',
}

build = {
   type = 'command',
   build_command = '$(LUA) build-aux/luke'
      .. ' package="' .. package .. '"'
      .. ' version="' .. _MODREV .. '"'
      .. ' PREFIX="$(PREFIX)"'
      .. ' LUA="$(LUA)"'
      ,
   install_command = '$(LUA) build-aux/luke install --quiet'
      .. ' INST_LUADIR="$(LUADIR)"'
      ,
   copy_directories = {'doc'},
}

test_dependencies = {
   'ansicolors',
   'luacov',
   'specl >= 15',
}

test = {
   type = 'command',
   command = 'specl -vfreport --coverage spec/*_spec.yaml',
}

if _MODREV == 'dev' then
   -- luarocks.org's ldoc fails on Lua 5.5; gvvaughan's works.
   build_dependencies = {'gvvaughan/ldoc'}

   build.copy_directories = nil

   source = {
      url = 'git+https://github.com/lua-stdlib/strict.git',
   }
else
   -- A release commits its LDocs, so don't build them again.
   build.build_command = build.build_command .. ' LDOC=true'
end

package = 'std.strict'
version = 'git-1'

description = {
   summary = 'Check for use of undeclared variables',
   detailed = [[
      Enforce strict declaration of all variables (including functions) in
      an environment before being used or reassigned from a nested scope.
   ]],
   homepage = 'http://lua-stdlib.github.io/strict',
   license = 'MIT/X11',
}

source = {
   url = 'git://github.com/lua-stdlib/strict.git',
}

dependencies = {
   'lua >= 5.1, < 5.4',
}

build = {
   type = 'command',
   build_command = 'build-aux/luke'
      .. ' PACKAGE="' .. package .. '"'
      .. ' VERSION="' .. version .. '"'
      .. ' PREFIX="$(PREFIX)"'
      .. ' LUA="$(LUA)"'
      .. ' INST_LIBDIR="$(LIBDIR)"'
      .. ' INST_LUADIR="$(LUADIR)"'
      ,
   install_command = 'build-aux/luke install --quiet'
      .. ' INST_LIBDIR="$(LIBDIR)"'
      .. ' INST_LUADIR="$(LUADIR)"'
      ,
   copy_directories = {'doc'},
}

local _MODREV, _SPECREV = '1.3.1', '-1'

package = 'std.strict'
version = _MODREV .. _SPECREV

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
   url = 'http://github.com/lua-stdlib/strict/archive/v' .. _MODREV .. '.zip',
   dir = 'strict-' .. _MODREV,
}

dependencies = {
   'lua >= 5.1, < 5.4',
}

build = {
   type = 'builtin',
   modules = {
      ['std.strict']		= 'lib/std/strict/init.lua',
      ['std.strict._base']	= 'lib/std/strict/_base.lua',
      ['std.strict.version']	= 'lib/std/strict/version.lua',
   },
   copy_directories = {'doc'},
}

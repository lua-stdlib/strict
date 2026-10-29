local _MODREV, _SPECREV = 'dev', '-1'

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

build_dependencies = {
   'luarocks-build-luke >= 0.3.1',
}

build = {
   type = 'luke',

   modules = {
      {['std.strict']            = 'lib/std/strict/init.lua'},
      {['std.strict._normalize'] = 'lib/std/strict/_normalize.lua'},
      {['std.strict.version']    = 'lib/std/strict/version.lua.in'},
   },

   -- A release commits its LDocs to install.
   copy_directories = {'doc'},
}

test_dependencies = {
   'luacov',
   'specl >= 17.1',
}

test = {
   type = 'command',
   command = 'specl -vfreport --coverage spec/*_spec.yaml',
}

if _MODREV == 'dev' then
   -- luarocks.org's ldoc fails on Lua 5.5; gvvaughan's works.
   build_dependencies[#build_dependencies + 1] = 'gvvaughan/ldoc'

   -- Stamp a development build with who made it, and from which commit.
   build.version = '$USER/$gitref'

   build.copy_directories = nil

   source = {
      url = 'git+https://github.com/lua-stdlib/strict.git',
   }
end

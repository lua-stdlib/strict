#  Strict variable declarations for Lua 5.1, 5.2, 5.3 & 5.4.
#  Copyright (C) 2010-2023 std.strict authors

LDOC	= ldoc
LUA	= lua
MKDIR	= mkdir -p
SED	= sed
SPECL	= specl

VERSION	= git

luadir	= lib/std/strict
SOURCES =				\
	$(luadir)/init.lua		\
	$(luadir)/version.lua		\
	$(NOTHING_ELSE)


all: $(luadir)/version.lua


$(luadir)/version.lua: .FORCE
	@echo 'return "Strict Variable Declaration / $(VERSION)"' > '$@T';	\
	if cmp -s '$@' '$@T'; then						\
	    rm -f '$@T';							\
	else									\
	    echo 'echo return "Strict Variable Declaration / $(VERSION)" > $@';	\
	    mv '$@T' '$@';							\
	fi

doc: build-aux/config.ld $(SOURCES)
	$(LDOC) -c build-aux/config.ld .

build-aux/config.ld: build-aux/config.ld.in
	$(SED) -e "s,@PACKAGE_VERSION@,$(VERSION)," '$<' > '$@'


CHECK_ENV = LUA=$(LUA)

check: $(SOURCES)
	LUA=$(LUA) $(SPECL) $(SPECL_OPTS) spec/*_spec.yaml


.FORCE:

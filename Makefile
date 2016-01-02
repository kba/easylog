VERSION = $(shell grep version package.json | grep -oE '[0-9\.]+')
PKGNAME = $(shell grep name package.json |/bin/grep -o '[^"]*",'|/bin/grep -o '[^",]*')

COFFEE = coffee -c -b -p

CP = cp -r
RM = rm -rf
MKDIR = mkdir -p

BIN_TARGETS = $(shell find src/bin -type f -name "*.coffee"|sed 's,src/,,'|sed 's,\.coffee,,')
LIB_TARGETS = $(shell find src/lib -type f -name "*.coffee"|sed 's,src/,,'|sed 's,\.coffee,\.js,')
TEST_TARGETS = $(shell find src/test -type f -name "*.coffee"|sed 's,\.coffee,\.js,')

.PHONY: all json-schema

all: lib bin test

bin: ${BIN_TARGETS} lib
	chmod a+x ${BIN_TARGETS}

bin/%: src/bin/%.coffee
	@$(MKDIR) $(shell dirname $@)
	$(COFFEE) $< > $@
	sed -i '1i #!/usr/bin/env node' $@

lib: ${LIB_TARGETS}

lib/%.js: src/lib/%.coffee
	@$(MKDIR) $(shell dirname $@)
	$(COFFEE) $< > $@

test: ${TEST_TARGETS}
	$(CP) src/test test
	@find test -type f -name '*.coffee' -exec rm {} \;

src/test/%.js: src/test/%.coffee
	@$(MKDIR) $(shell dirname $@)
	$(COFFEE) $< > $@

clean:
	$(RM) lib
	$(RM) bin
	$(RM) ${TEST_TARGETS}
	$(RM) test
	$(RM) schema-*.json

docson:
	git submodule update

json-schema: bin schema-basic.json schema-fragment.json

default-config.json:

schema-%.json:
	./bin/ezlog-schema --level=$* > $@


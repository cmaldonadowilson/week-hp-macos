SWIFT_BIN = $(shell dirname "$$(xcrun --find swift)")
# Swift Build sometimes misses the Swift Testing macros plugin when building
# with the Command Line Tools ("plugin for module 'TestingMacros' not found"),
# so pass its folder explicitly.
TESTING_PLUGINS = $(SWIFT_BIN)/../lib/swift/host/plugins/testing

.PHONY: build test clean

build:
	swift build -c release

test:
	swift test -Xswiftc -plugin-path -Xswiftc "$(TESTING_PLUGINS)"

clean:
	rm -rf .build

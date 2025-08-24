.DEFAULT_GOAL := help
PROJECTNAME=$(shell basename "$(PWD)")

# ##############################################################################
# # GENERAL
# ##############################################################################

.PHONY: help
help: Makefile
	@echo
	@echo " Available actions in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## :

# ##############################################################################
# # RECIPES
# ##############################################################################

## all: Compile iOS, Android and bindings targets
all: ios macos android bindings

## ios: Compile the iOS universal library
ios: target/universal/release/libexample.a

target/universal/release/libexample.a: $(SOURCES) ndk-home
	@if [ $$(uname) == "Darwin" ] ; then \
		cargo lipo --release ; \
		else echo "Skipping iOS compilation on $$(uname)" ; \
	fi
	@echo "[DONE] $@"

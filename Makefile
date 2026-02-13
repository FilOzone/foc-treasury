SUBMODULES := $(wildcard lib/*)
SUBMODULE_BUILD := $(addsuffix /build,$(SUBMODULES))
SUBMODULE_CLEAN := $(addsuffix /clean,$(SUBMODULES))
SUBMODULE_TEST := $(addsuffix /test,$(SUBMODULES))
SUBMODULE_PHONY := $(SUBMODULE_BUILD) $(SUBMODULE_CLEAN) $(SUBMODULE_TEST)

.PHONY: build clean default test $(SUBMODULE_BUILD) $(SUBMODULE_CLEAN) $(SUBMODULE_TEST)

default: build

GEN := $(patsubst src/gen/%.sh,src/gen/%.sol,$(wildcard src/gen/*.sh))

$(SUBMODULE_PHONY):
	$(MAKE) -C $(dir $@) $(notdir $@)

build: $(GEN) $(SUBMODULE_BUILD)
	forge build

test: build $(SUBMODULE_TEST)
	forge test

clean: $(SUBMODULE_CLEAN)
	rm -rf out


src/gen/TreasuryStorageView.sol: src/gen/TreasuryStorageView.sh src/TreasuryStorage.sol
	$^ | forge fmt -r - > $@

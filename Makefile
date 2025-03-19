.PHONY: all clean clean-all format-code gen_uuid %-run-in-simulator %-run-in-debugger

.DEFAULT_GOAL = all

ifeq ($(wildcard ${HOME}/.Garmin/ConnectIQ/current-sdk.cfg), )
$(error "Please install the ConnectIQ SDK first - See https://github.com/cyberang3l/garmin-linux-development-environment")
endif

BASE_NAME=$(shell xmllint --xpath 'string(//*[local-name()="application"]/@entry)' manifest.xml)
PRG_FILE=$(BASE_NAME).prg
IQ_FILE=$(BASE_NAME).iq
ACTIVE_SDK_PATH=$(shell cat ${HOME}/.Garmin/ConnectIQ/current-sdk.cfg)
GREEN='\033[1;32m'
NC='\033[0m'

# Ensure developer key can be found - we need it to compile stuff
ifneq ($(wildcard .developer_key_path), )
DEV_KEY_PATH=$(shell cat .developer_key_path)
else
$(error Please create the file $(shell pwd)/.developer_key_path. The file should contain a single line that points to your Garmin developer key file)
endif

GARMIN_LINUX_DEV_ENV_PATH=garmin-linux-development-environment

SUBMODULE_PATHS=$(GARMIN_LINUX_DEV_ENV_PATH)/Makefile

$(SUBMODULE_PATHS):
	git submodule update --init --recursive
	git submodule foreach git checkout main
	git submodule foreach git pull

update_submodules: $(SUBMODULE_PATHS)
	git submodule foreach git checkout main
	git submodule foreach git pull

# The actual source code files that when modified, we must rebuild our targets
SOURCES=$(wildcard *.xml) $(wildcard source/*.mc) $(wildcard resources*/*) $(wildcard resources*/**/*)

# Get the supported devices from the manifest file
SUPPORTED_DEVICES=$(shell cat manifest.xml | grep -oP "iq:product id=\"\K\w+")
SIM_DEVICES=$(addsuffix _sim, $(SUPPORTED_DEVICES))
ALL_DEVICES=$(SUPPORTED_DEVICES) $(SIM_DEVICES)

# Each device will have a different binary (PRG file). Auto generate
# the list of files that is expected to be found for each device. Each
# of these files become a Make target
prgs_release=$(addsuffix /$(PRG_FILE), $(addprefix build/, $(ALL_DEVICES)))
prgs_debug=$(addsuffix /debug_$(PRG_FILE), $(addprefix build/, $(ALL_DEVICES)))
iqs=$(addsuffix /$(IQ_FILE), $(addprefix build/, $(ALL_DEVICES)))
# Assign a TARGET-Specifc DEVICE_ID variable.
# Convert the slashes to spaces with substr, and pick the
# second word that is the DEVICE ID (enduro3, fenix7, etc)
$(prgs_release): DEVICE_ID=$(word 2, $(subst /, ,$@))
$(prgs_release): $(SOURCES) $(SUBMODULE_PATHS)
	make -C resources/icons all -j $$(nproc)
	mkdir -p build/$(DEVICE_ID)
	java -Xms1g -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -jar $(ACTIVE_SDK_PATH)/bin/monkeybrains.jar --output $@ --jungles 'monkey.jungle' --private-key $(DEV_KEY_PATH) --device $(DEVICE_ID) --warn --release --build-stats 0
	@echo - Release build binary for $@ at $(GREEN)$@$(NC) \($$(stat $@ | grep -oP "Size: \K\d+") bytes\)

$(prgs_debug): DEVICE_ID=$(word 2, $(subst /, ,$@))
$(prgs_debug): $(SOURCES) $(SUBMODULE_PATHS)
	make -C resources/icons all -j $$(nproc)
	mkdir -p build/$(DEVICE_ID)
	java -Xms1g -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -jar $(ACTIVE_SDK_PATH)/bin/monkeybrains.jar --output $@ --jungles 'monkey.jungle' --private-key $(DEV_KEY_PATH) --device $(DEVICE_ID) --warn --build-stats 0
	@echo - Release build binary for $@ at $(GREEN)$@$(NC) \($$(stat $@ | grep -oP "Size: \K\d+") bytes\)

build/$(IQ_FILE): $(SOURCES) $(SUBMODULE_PATHS)
	make -C resources/icons all -j $$(nproc)
	mkdir -p build
	java -Xms1g -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -jar $(ACTIVE_SDK_PATH)/bin/monkeybrains.jar --output $@ --jungles 'monkey.jungle' --private-key $(DEV_KEY_PATH) --package-app --release --warn --build-stats 0
	@echo - Connect QI binary for $@ at $(GREEN)$@$(NC) \($$(stat $@ | grep -oP "Size: \K\d+") bytes\)

# Generate a user-friendly target with only the name of the device.
# This target only depends on the actual PRG target for the device
$(SUPPORTED_DEVICES): % : build/%/$(PRG_FILE)

export-for-iq-store: build/$(IQ_FILE)

# We also need to add simulator targets to allow for testing
SIMULATOR_TARGETS = $(addsuffix -run-in-simulator, $(SUPPORTED_DEVICES))
%-run-in-simulator:
	make build/$*_sim/$(PRG_FILE)
	./run-simulator "$(GARMIN_LINUX_DEV_ENV_PATH)/garmin-env" "$(ACTIVE_SDK_PATH)" "build/$*_sim" "$(BASE_NAME)" "$*"
$(SIMULATOR_TARGETS): %-run-in-simulator

# We also need to add debugger targets to allow for using with mdd debugger
# https://developer.garmin.com/connect-iq/core-topics/debugging/
DEBUG_TARGETS = $(addsuffix -run-in-debugger, $(SUPPORTED_DEVICES))
%-run-in-debugger:
	make build/$*_sim/debug_$(PRG_FILE)
	./run-simulator "$(GARMIN_LINUX_DEV_ENV_PATH)/garmin-env" "$(ACTIVE_SDK_PATH)" "build/$*_sim" "$(BASE_NAME)" "$*" "DEBUG"
$(DEBUG_TARGETS): %-run-in-debugger

# The 'all' target should only build the PRGs for all the supported devices
all: $(SUPPORTED_DEVICES)

format-code:
	@bash -c ./format-code

gen_uuid:
	@uuidgen | sed 's/-//g'

clean:
	rm -rf build
	rm -rf bin
	rm -rf Device*.txt
	make -C resources/icons clean

clean-all:
	git clean -ffdx

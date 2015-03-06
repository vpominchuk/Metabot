# Project targets
# Defines here your cpp source files
# Ex : main.cpp test.cpp ...
SRC_FILES = main.cpp kinematic.cpp locomotion.cpp rhock-functions.cpp rhock-store.cpp rhock-commands.cpp

# Uncomment to disable robot campus commands
CFLAGS += -DHAS_DXL -DHAS_TERMINAL -DDISABLE_SERVOS_COMMANDS
# CFLAGS += -DDXL_VERSION_1

RHOCK = rhock/rhock
CFLAGS += -I$(shell pwd)/rhock

debug:
	echo $(CFLAGS)

BUILDDIRS += $(BUILD_PATH)/rhock/rhock

SRC_FILES += $(RHOCK)/chain.c \
		$(RHOCK)/context.c \
		$(RHOCK)/crc16.c \
		$(RHOCK)/event.c \
		$(RHOCK)/memory.c \
		$(RHOCK)/native.c \
		$(RHOCK)/natives.c \
		$(RHOCK)/obj.c \
		$(RHOCK)/opcode.c \
		$(RHOCK)/program.c \
		$(RHOCK)/std.c \
		$(RHOCK)/store.c \
		$(RHOCK)/stream.c \
		$(RHOCK)/vm.c

OBJ_FILES_CPP = $(SRC_FILES:.cpp=.o)
OBJ_FILES = $(addprefix $(BUILD_PATH)/,$(OBJ_FILES_CPP:.c=.o))

$(BUILD_PATH)/%.o: %.cpp
	$(SILENT_CXX) $(CXX) $(CFLAGS) $(CXXFLAGS) $(LIBMAPLE_INCLUDES) $(WIRISH_INCLUDES) -o $@ -c $< 

$(BUILD_PATH)/libmaple.a: $(BUILDDIRS) $(TGT_BIN)
	- rm -f $@
	$(AR) crv $(BUILD_PATH)/libmaple.a $(TGT_BIN)

library: $(BUILD_PATH)/libmaple.a

.PHONY: library

$(BUILD_PATH)/$(BOARD).elf: $(BUILDDIRS) $(TGT_BIN) $(OBJ_FILES)
	$(SILENT_LD) $(CXX) $(LDFLAGS) -o $@ $(TGT_BIN) $(OBJ_FILES) -Wl,-Map,$(BUILD_PATH)/$(BOARD).map

$(BUILD_PATH)/$(BOARD).bin: $(BUILD_PATH)/$(BOARD).elf
	$(SILENT_OBJCOPY) $(OBJCOPY) -v -Obinary $(BUILD_PATH)/$(BOARD).elf $@ 1>/dev/null
	$(SILENT_DISAS) $(DISAS) -d $(BUILD_PATH)/$(BOARD).elf > $(BUILD_PATH)/$(BOARD).disas
	@echo " "
	@echo "Object file sizes:"
	@find $(BUILD_PATH) -iname "*.o" | xargs $(SIZE) -t > $(BUILD_PATH)/$(BOARD).sizes
	@cat $(BUILD_PATH)/$(BOARD).sizes
	@echo " "
	@echo "Final Size:"
	@$(SIZE) $<
	@echo $(MEMORY_TARGET) > $(BUILD_PATH)/build-type

$(BUILDDIRS):
	@mkdir -p $@

MSG_INFO:
	@echo "================================================================================"
	@echo ""
	@echo "  Build info:"
	@echo "     BOARD:          " $(BOARD)
	@echo "     MCU:            " $(MCU)
	@echo "     MEMORY_TARGET:  " $(MEMORY_TARGET)
	@echo ""
	@echo "  See 'make help' for all possible targets"
	@echo ""
	@echo "================================================================================"
	@echo ""

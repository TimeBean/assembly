.SUFFIXES:
MAKEFLAGS += --no-builtin-rules

AS = nasm
ASFLAGS = -f elf64
LD = ld
LDFLAGS =

TARGET = ksh
BUILD_DIR = build

SOURCES = src/io.asm src/main.asm 
OBJECTS = $(BUILD_DIR)/io.o $(BUILD_DIR)/main.o $(BUILD_DIR)/utils.o

.PHONY: all clean run

all: $(TARGET)
	rm -rf $(BUILD_DIR)

run: $(TARGET)
	rm -rf $(BUILD_DIR)
	./$(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/io.o: src/io.asm | $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/main.o: src/main.asm include/io.inc | $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/utils.o: src/utils.asm | $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $@

clean:
	rm -rf $(BUILD_DIR) $(TARGET)

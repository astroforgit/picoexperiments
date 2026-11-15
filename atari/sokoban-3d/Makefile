MADS ?= mads
TARGET := bin/sokoban-3d.xex

.PHONY: all clean test

all: $(TARGET)

$(TARGET): main.asm | bin
	$(MADS) main.asm -o:$(TARGET)

bin:
	mkdir -p bin

test: $(TARGET)
	@test -s $(TARGET)
	@printf 'Built %s (%s bytes)\n' "$(TARGET)" "$$(wc -c < $(TARGET))"

clean:
	rm -f $(TARGET) bin/sokoban-3d.lab

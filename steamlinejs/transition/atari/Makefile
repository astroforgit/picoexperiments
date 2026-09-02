MADS ?= mads
TARGET := bin/transition.xex

.PHONY: all clean test title-assets

all: $(TARGET)

$(TARGET): main.asm levels.inc assets/romek-title.2bpp | bin
	$(MADS) main.asm -o:$(TARGET)

title-assets:
	python3 tools/make_title.py

bin:
	mkdir -p bin

test: $(TARGET)
	@test -s $(TARGET)
	@printf 'Built %s (%s bytes)\n' "$(TARGET)" "$$(wc -c < $(TARGET))"

clean:
	rm -f $(TARGET) bin/transition.lab

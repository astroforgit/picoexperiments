.PHONY: all test levels run
all:
	./build.sh
test: all
	python3 tools/test_runtime.py
levels: test
	python3 tools/test_levels.py
run:
	./run.sh

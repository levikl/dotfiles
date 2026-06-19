# Resolve the nlohmann-json header without needing `brew` on PATH (this builds at
# launch from sketchybarrc, where PATH may be lean). Covers Apple Silicon + Intel.
NLOHMANN := $(firstword $(wildcard /opt/homebrew/opt/nlohmann-json/include /usr/local/opt/nlohmann-json/include))

logical-space: logical-space.cc
	clang++ -std=c++17 -O2 -I$(NLOHMANN) logical-space.cc -o logical-space

.PHONY: clean
clean:
	rm -f logical-space

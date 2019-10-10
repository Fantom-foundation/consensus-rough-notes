#
# Constants
#
tex = pdflatex
src = src/offscale-consensus.tex
pdf = doc/offscale-consensus.pdf

#
# Targets
#
all: $(pdf)

$(pdf): $(src) output_dir
	cd $(shell dirname $@) && \
	$(tex) ../$< -o $(shell basename $@) && \
	$(tex) ../$< -o $(shell basename $@) # This second pass is required for the references.

output_dir:
	mkdir -p $(shell dirname $(pdf))

.PHONY: clean

clean:
	rm -rf $(shell dirname $(pdf))

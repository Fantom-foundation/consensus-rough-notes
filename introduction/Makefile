#
# Constants
#
tex = pdflatex
src = src/introduction.tex
pdf = doc/introduction.pdf

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

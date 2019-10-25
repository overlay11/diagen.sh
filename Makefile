MARKDOWN := $(shell find . -name '*.md')
DIAGRAMS := $(shell find . -name '*.gv.m4')

HTML := $(MARKDOWN:.md=.html)

.PHONY: html svg clean

html: svg $(HTML)

svg: $(DIAGRAMS:.gv.m4=.svg)

clean:
	rm -f $(HTML)

%.html: %.md
	pandoc -s -f gfm -o $@ $<

%.svg: %.gv.m4
	./diagen.sh $< $@

DRAFTS := $(wildcard draft-*.md)
XML    := $(DRAFTS:.md=.xml)
TXT    := $(DRAFTS:.md=.txt)
HTML   := $(DRAFTS:.md=.html)

.PHONY: all txt html xml clean check list

all: txt

txt:  $(TXT)
html: $(HTML)
xml:  $(XML)

%.xml: %.md
	kramdown-rfc $< > $@

%.txt: %.xml
	xml2rfc --text $< -o $@

%.html: %.xml
	xml2rfc --html $< -o $@

# Verify every {{reference}} used in a draft is declared in its front matter.
check:
	@python3 -c 'import re,glob,sys; bad=0; \
	[ (lambda f,s: (lambda d,u: (print("FAIL",f,sorted(u-d)) or globals().__setitem__("bad",1)) if u-d else print("ok  ",f))( \
	set(re.findall(r"^\s{2}([A-Za-z0-9.\-]+):\s*$$", s.split("---",2)[1], re.M)), \
	set(re.findall(r"\{\{([A-Za-z0-9.\-]+)\}\}", s))))(f, open(f).read()) for f in sorted(glob.glob("draft-*.md")) ]; \
	sys.exit(globals()["bad"])'

list:
	@for f in $(DRAFTS); do printf "%-46s %s\n" "$$f" "$$(grep -m1 '^title:' $$f | cut -d'"' -f2)"; done

clean:
	rm -f $(XML) $(TXT) $(HTML)

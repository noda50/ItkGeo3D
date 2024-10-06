## -*- Mode: Makefile -*-
##--------------------------------------------------
.SUFFIXES: .tex .dvi .pdf .ps

##--------------------------------------------------
TARGET= note


SUBSOURCE = $(wildcard ./*.tex) \
            $(wildcard Fig/*.eps) $(wildcard Graph/*.eps)

##--------------------------------------------------
#top : pdf ps dvi
top : pdf dvi

clean :
	\rm -f *.log *.aux *.bbl *.ps *.pdf *.dvi *~ *.toc

##--------------------------------------------------
.tex.dvi:
	platex $(basename $<)
	pbibtex $(basename $<) || true
	platex $(basename $<)
	platex $(basename $<)

.dvi.ps: 
	dvips $(basename $^)

.dvi.pdf:
	dvipdf $(basename $^)
#	dvipdfmx $(basename $^)

##--------------------------------------------------
dvi : $(addsuffix .dvi,$(TARGET))

pdf: $(addsuffix .pdf,$(TARGET))

ps : $(addsuffix .ps,$(TARGET))

##--------------------------------------------------
note.dvi : $(SUBSOURCE)


BOOK = TECS-First
TEX_SRC=$(BOOK).tex
PDF=$(BOOK).pdf
DVI=$(BOOK).dvi
PS=$(BOOK).ps
# include Makefile.lst
LIST = TECS-First.txt

pdf : $(PDF)

# $(PDF) : $(PS)
# 	ps2pdf $(PS) $(PDF)
# 
# $(PS) : $(DVI)
# 	dvi2ps $(DVI) > $(PS)

$(PDF) : $(DVI)
	dvipdfmx $(DVI)

$(DVI) : $(TEX_SRC)
	platex -kanji=utf8 $(TEX_SRC)
	platex -kanji=utf8 $(TEX_SRC)
#	platex -8bit $(TEX_SRC)
#	platex -8bit $(TEX_SRC)

tex : $(TEX_SRC)

$(TEX_SRC) : $(LIST) $(FIG)
	ruby texnize.rb $(LIST) > $(TEX_SRC)

clean :
	rm -f $(TEX_SRC) $(DVI) $(PS) $(PDF) tex*.log tecs_spec.*

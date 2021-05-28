.PHONY: all
all: paper report presentation fig-2.pdf fig-1.pdf

paper: fig-1.pdf fig-2.pdf paper.Rmd

report: fig-1.pdf fig-2.pdf report.Rmd

presentation: fig-1.pdf fig-2.pdf presentation.Rmd

clean-data.csv: raw-data.csv data-cleaning.R

fig-1.pdf: fig-1.R clean-data.csv
	Rscript $<

fig-2.pdf: fig-2.R clean-data.csv
	Rscript $<


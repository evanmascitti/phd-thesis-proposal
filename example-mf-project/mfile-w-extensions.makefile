.PHONY: all
all: paper.pdf report.pdf presentation.html

paper.pdf: paper.Rmd fig-1.pdf fig-2.pdf 
	Rscript -e 'rmarkdown::render("paper.Rmd")'

report.pdf: report.Rmd fig-1.pdf fig-2.pdf
	Rscript -e 'rmarkdown::render("report.Rmd")'

presentation.html: presentation.Rmd fig-1.pdf fig-2.pdf 
	Rscript -e 'rmarkdown::render("presentation.Rmd")'

fig-1.pdf: fig-1.R clean-data.csv
	Rscript fig-1.R

fig-2.pdf: fig-2.R clean-data.csv
	Rscript fig-2.R

clean-data.csv: data-cleaning.R raw-data.csv
	Rscript data-cleaning.R
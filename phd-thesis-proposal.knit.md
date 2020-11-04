---
title: "Evan's PhD thesis proposal"
author: "Evan C Mascitti"
date: "last updated 2020-11-04"
site: bookdown::bookdown_site
documentclass: book
classoption: 
  - openany
linestretch: 1.15
links-as-notes: true
papersize: letter
geometry:
  - margin=1in
bibliography: [book.bib, packages.bib, library.bib]
csl: soil-science-society-of-america-journal.csl
biblio-title: "References"
biblio-style: apalike
link-citations: yes
description: "This is my first attempt at compiling a large document with the **bookdown** package in R."
mainfont: Arial
mathfont: Fira Math Regular
urlcolor: blue
linkcolor: blue
citecolor: blue
toccolor: blue
editor_options: 
  chunk_output_type: inline

---



# Overview {#overview}

Baseball fields are built from soil. Therefore, soil behavior determines the safety and function of the field. The purpose of this dissertation is to study how soil behavior relates to baseball infields. 

The production of artificial soils has received much study. However, there are
no published scientific experiments on this topic as it pertains to baseball and
softball fields.

This proposal is organized into four sections:

[**Purpose and objectives**](#purpose-objectives): A broad description of the scope and aims of the project

[**Definition of terms**](#definition-of-terms): Explicit meanings of verbiage used this document (these may vary across scientific fields)

[**Review of literature**](#lit-review): A summary of scientific research pertaining to this topic

[**Proposed experiments**](#proposed-experiments): The planned course of laboratory research, organized as anticipated publication units.






<!--chapter:end:index.Rmd-->

# Purpose and objectives {#purpose-objectives}

The purpose of my thesis is to create a new way to think about the soils used on baseball and softball infields. 

**My objective is to answer these open-ended questions:**

1. How can infield soil performance be quantified without an experienced grounds manager's expertise?
2. How can an infield soil mixture be designed to achieve a given set of desired properties?
3. What simple lab tests can be used to predict the performance of the mix?

**The anticipated outcomes and deliverables from this project are:**
  
1. A general framework for understanding the behavior of sand-clay mixes in a quantitative way
2. Specific recommendations for the ratios which common clayey soils should be mixed with sand for optimal performance at any maintenance level
3. Suggestions for how to beneficiate poorly-performing clay soils with other kinds of clays to maximize the locally available materials by "spiking" the local clay with a small percentage of imported solum

<!--chapter:end:01-Purpose-and-objectives.Rmd-->

# Definition of terms {#definition-of-terms}

**clay**: a soil material which can be permanently reshaped or molded when moist and which retains develops high strength when dry

**clay-size**: an individual mineral grain which settles in through a column of fluid at the same rate as a spherical particle of 2 &mu;m

**sand**: a soil material which is predominantly composed of mineral particles having sieve diameters between 53 and 2000 &mu;m

**packing fraction**: the volume fraction occupied by solids, normalized to the total soil volume (1-void fraction); $V_{s}$

<!--chapter:end:02-Definition-of-terms.Rmd-->

---
output: html_document
editor_options: 
  chunk_output_type: console
---

# Review of literature {#lit-review}




This literature review is organized into four sections to address the following topics:

**\@ref(infield-performance)** [**Function and performance of baseball/softball infields**](#infield-performance)

**\@ref(soil-behavior-fundamentals)** [**Soil behavior terminology and measures**](#soil-behavior-fundamentals)

**\@ref(artificial-soil-mixtures)** [**Design and properties of artificial soil mixtures**](#artificial-soil-mixtures)

**\@ref(lab-methods-review)** [**Laboratory test methods pertinent to the research questions**](#lab-methods-review)

## Function and performance of baseball infields {#infield-performance} 

Athletes engage with the playing surface in two ways: directly (by running, pivoting, and sliding) and indirectly (by fielding batted balls).
O
During play, forces are imposed to the infield skin by athletes feet and bodies, and by the ball. This section outlines the goals of a baseball grounds manager and prior scientific research (scant as it is) on this topic. 


### Qualitative description of the importance of the infield 





A full-size baseball field occupies 1 ha. About 74% of this total area is surfaced with natural turfgrass or synthetic turf. An additional ~ 16% is occupied by the warning track, which is designed to alert players that they are nearing the wall. Only about 8% of the total playing surface is occupied by the infield skin, yet it plays a disproportionally large influence on the game.

Data from MLB contests demonstrate that the average ground ball produces 0.04 runs while causing 0.80 outs. In contrast, the average ball hit in the air created 0.23 runs and 0.62 outs. On a runs-per-outs basis, a fly ball is nearly 8 times s valuable to the offense as a ground ball [@Carruth2010]. It is in the defense's interest to encourage the offense to hit as many ground balls as possible, and this heightens the importance of the infield skin. 

The majority of important plays occur on the infield skin. At a given moment, all the offensive players, all four infielders, and the pitcher and catcher are standing on the infield skin \@ref(fig:player-locations). A large majority of batted balls either land or are fielded here.  As a result, the effort and funds devoted to maintaining is disproportionately large (Figure (\@ref(fig:labor-per-area))^[Data used to compute these values is compiled in the Appendix, see Table \@ref(tab:labor-per-area-tab)].

\begin{figure}
\includegraphics[width=1\linewidth]{images/illustrations/player_locations/player_locations} \caption{Locations of players during a professional baseball game, note the paucity of players on turf (blue arrows) compared to bare soil/skin areas (red arrows).}(\#fig:player-locations)
\end{figure}

















---
output: html_document
editor_options: 
  chunk_output_type: inline
---

# Review of literature {#lit-review}


```r
knitr::opts_chunk$set(cache = T,
                      error = T)
library(tidyverse)
library(measurements)
library(latex2exp)
library(hrbrthemes)
library(scales)
library(ImaginR)
library(imager)
library(here)
library(cowplot)
library(baseballr)
library(ecmfuns)
library(balldensityplots)
library(magick)
theme_set(theme_cowplot())
```


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


```r
pnc_areas <- read_csv('data/lit-review-data/pnc-google-earth-dims.csv') %>% 
  group_by(type) %>% 
  summarise(total_area_ft2= sum(ft2)) %>% 
  mutate(total_area_ha= measurements::conv_unit(total_area_ft2, from = "ft2", to = "hectare"),
         area_pct= total_area_ha/ sum(total_area_ha))
```

```
## 
## -- Column specification ---------------------------
## cols(
##   name = col_character(),
##   type = col_character(),
##   ft2 = col_double()
## )
```

```
## `summarise()` ungrouping output (override with `.groups` argument)
```

```r
compute_area_pct <- function(df, area) {
  area_pct <- df %>% 
    filter(type == {{area}}) %>% 
    .$area_pct*100 %>% 
  signif(digits = 2)
  
  return(area_pct)
}

skin_area_pct <- compute_area_pct(pnc_areas, "Infield skin")
hp_area_pct <- compute_area_pct(pnc_areas, "Home plate")
mounds_area_pct <- compute_area_pct(pnc_areas, "Game mound/bullpen")
turf_area_pct <- compute_area_pct(pnc_areas, "Turf")
wt_area_pct <- compute_area_pct(pnc_areas, "Warning track")
```


```r
labor_man_hrs <- read_csv('data/lit-review-data/maintenance-man-hrs.csv') %>% 
  mutate(time_hr= time_min/60) %>% 
  group_by(type)  %>% 
  summarise(total_man_hr= sum(people*time_hr) )
```

```
## 
## -- Column specification ---------------------------
## cols(
##   name = col_character(),
##   type = col_character(),
##   time = col_character(),
##   people = col_double(),
##   time_min = col_double()
## )
```

```
## `summarise()` ungrouping output (override with `.groups` argument)
```

A full-size baseball field occupies 1 ha. About 74% of this total area is surfaced with natural turfgrass or synthetic turf. An additional ~ 16% is occupied by the warning track, which is designed to alert players that they are nearing the wall. Only about 8% of the total playing surface is occupied by the infield skin, yet it plays a disproportionally large influence on the game.

Data from MLB contests demonstrate that the average ground ball produces 0.04 runs while causing 0.80 outs. In contrast, the average ball hit in the air created 0.23 runs and 0.62 outs. On a runs-per-outs basis, a fly ball is nearly 8 times s valuable to the offense as a ground ball [@Carruth2010]. It is in the defense's interest to encourage the offense to hit as many ground balls as possible, and this heightens the importance of the infield skin. 

The majority of important plays occur on the infield skin. At a given moment, all the offensive players, all four infielders, and the pitcher and catcher are standing on the infield skin \@ref(fig:player-locations). A large majority of batted balls either land or are fielded here.  As a result, the effort and funds devoted to maintaining is disproportionately large (Figure (\@ref(fig:labor-per-area))^[Data used to compute these values is compiled in the Appendix, see Table \@ref(tab:labor-per-area-tab)].


```r
knitr::include_graphics('images/illustrations/player_locations/player_locations.png')
```

<div class="figure">
<img src="images/illustrations/player_locations/player_locations.png" alt="Locations of players during a professional baseball game, note the paucity of players on turf (blue arrows) compared to bare soil/skin areas (red arrows)." width="100%" />
<p class="caption">(\#fig:player-locations)Locations of players during a professional baseball game, note the paucity of players on turf (blue arrows) compared to bare soil/skin areas (red arrows).</p>
</div>


```r
# read the data file for all batted balls in 2020
batted_balls_2020 <- read_csv('data/lit-review-data/complete-2020-savant-data.csv') %>%
  filter(hc_x != 'null',
         hc_y != 'null') %>% 
  mutate(hc_x= as.double(hc_x),
         hc_y= as.double(hc_y)) %>%
  select(home_team, game_date, hc_x, hc_y) %>% 
  drop_na()
```

```
## Warning: Duplicated column names deduplicated:
## 'pitcher' => 'pitcher_1' [60], 'fielder_2' =>
## 'fielder_2_1' [61]
```

```
## 
## -- Column specification ---------------------------
## cols(
##   .default = col_double(),
##   pitch_type = col_character(),
##   game_date = col_date(format = ""),
##   player_name = col_character(),
##   events = col_character(),
##   description = col_character(),
##   spin_dir = col_logical(),
##   spin_rate_deprecated = col_logical(),
##   break_angle_deprecated = col_logical(),
##   break_length_deprecated = col_logical(),
##   des = col_character(),
##   game_type = col_character(),
##   stand = col_character(),
##   p_throws = col_character(),
##   home_team = col_character(),
##   away_team = col_character(),
##   type = col_character(),
##   hit_location = col_character(),
##   bb_type = col_character(),
##   on_3b = col_character(),
##   on_2b = col_character()
##   # ... with 10 more columns
## )
## i Use `spec()` for the full column specifications.
```

```
## Warning: 2120 parsing failures.
##  row                             col expected actual                                                 file
## 1114 hit_distance_sc                 a double   null 'data/lit-review-data/complete-2020-savant-data.csv'
## 1114 launch_speed                    a double   null 'data/lit-review-data/complete-2020-savant-data.csv'
## 1114 launch_angle                    a double   null 'data/lit-review-data/complete-2020-savant-data.csv'
## 1114 estimated_ba_using_speedangle   a double   null 'data/lit-review-data/complete-2020-savant-data.csv'
## 1114 estimated_woba_using_speedangle a double   null 'data/lit-review-data/complete-2020-savant-data.csv'
## .... ............................... ........ ...... ....................................................
## See problems(...) for more details.
```

```r
# set the number of total data points in a character vector object with length 1 
n_value <- scales::comma(length(batted_balls_2020$hc_x))


# make a kernel density plot of all the batted balls 
batted_balls_2020_plot <- batted_balls_2020 %>%
  ggspraychart_ecm(high_color =  "#940000")+
  labs(title= 'Kernel density of MLB batted balls',
       caption = paste0('- Coordinates indicate where ball was fielded by defender.\n\n- Data shown for 2020 season (n = ', n_value, '; source: MLB Statcast).'),
       fill= 'Density')+
  theme_ballfield()+
  theme(plot.margin = margin(0,0,0,0, unit = "pt"),
        plot.title= element_text(size = 13),
        legend.title = element_text(size = 11),
        plot.caption = element_text(size = 9))
```

```
## Loading required package: extrafont
```

```
## Registering fonts with R
```

```r
# Now for the second part, the field boundaries subset the data to just one
# game, Aug 9 at PNC Park (no particular reason for choosing this game - just
# need to pare down the size of the data set so the boundaries are not drawn
# many times)

pit_aug_2020_batted_balls <- batted_balls_2020 %>% 
  filter(home_team== "PIT",
         game_date== "2020-08-09")

# plot the field boundaries
field_boundaries <- pit_aug_2020_batted_balls %>%
  ggspraychart_ecm_skeleton() +
  labs(title= 'Kernel density of MLB batted balls',
       caption = paste0('- Coordinates indicate where ball was fielded by defender.\n\n- Data shown for 2020 season (n = ', n_value, '; source: MLB Statcast).'),
       fill= 'Density')+
  scale_fill_gradient(low = 'transparent', high = 'transparent') +
  geom_ballfield()+
  theme_ballfield()+
  theme(plot.title= element_text(size = 13),
        legend.title = element_text(size = 11),
        plot.caption = element_text(size = 9))

# combine the actual data with the field boundaries "layer" using cowplot::draw_plot

batted_balls_w_boundaries <- ggdraw() +
  draw_plot(batted_balls_2020_plot)+ 
  draw_plot(field_boundaries)
```

```
## Warning: Removed 253 rows containing non-finite values
## (stat_density2d).
```

```
## Warning: Removed 253 rows containing non-finite values
## (stat_density2d).
```



```r
area_colors <- readr::read_csv('data/lit-review-data/useful_soil_colors_for_thesis.csv') %>% 
  dplyr::mutate(type= soil_description)
```

```
## 
## -- Column specification ---------------------------
## cols(
##   soil_description = col_character(),
##   hex_color = col_character()
## )
```

```r
labor_per_area <- pnc_areas %>% 
  left_join(labor_man_hrs) %>% 
  mutate(total_area_m2 = conv_unit(total_area_ha, "hectare", "m2"),
         man_hr_per_m2= total_man_hr / total_area_m2,
         man_hr_per_100m2= 100*man_hr_per_m2 ) %>% 
  select(type, man_hr_per_100m2) %>% 
  left_join(area_colors) %>% 
  filter(type %in% c("Turf", "Warning track", "Infield skin")) %>% 
  mutate(type= as_factor(type),
         type= fct_reorder(type, 1/man_hr_per_100m2),
         label= paste0("**", as.character(type), "**") )
```

```
## Joining, by = "type"
```

```
## Joining, by = "type"
```

```r
labor_per_area_plot <- labor_per_area %>% 
  ggplot(aes(man_hr_per_100m2, type, fill= hex_color, label= label))+
  geom_col()+
  labs(title= "Labor allocation on a typical MLB game day",
       caption= "Values computed by the author from personal experience.",
       y="Field component",
       x= TeX("Labor intensity, worker-hr $\\m^{-2}$") )+
  ggtext::geom_richtext(aes(x= man_hr_per_100m2 +0.01), #, color= hex_color),
                            color= "black",
                            fill= NA, 
                            label.color= NA, 
                            size= 10/.pt, 
                            hjust= 0) +
  scale_fill_identity()+
  scale_color_identity()+
  scale_x_continuous(limits= c(0, 1.5), n.breaks = 5)+
  background_grid()+
  theme_minimal_vgrid(font_family = "Arial")+
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.line.y = element_blank(),
        axis.line.x= element_line(size = 0.5),
        plot.margin = margin(0,0,0,0, unit="pt")
        )#+
  # theme(plot.title=element_text(size= 12, hjust=0.5),
  #       axis.text.x.bottom = element_text(size = 9),
  #       axis.title.x= element_text(size=10, face = "bold"),
  #       plot.caption = element_text(size = 9, hjust = 1),
  #       plot.background= element_rect(fill= "transparent"),
  #       panel.background= element_rect(fill= "transparent"),
  #       plot.margin= margin(t=10, l=20, r=20, b=10, unit = "mm"),
        # panel.grid.major.y = element_blank(),
        # axis.text.y = element_blank(), # element_text(hjust = 0),
        # axis.title.y = element_blank(),
        # axis.ticks.y = element_blank(),
        # axis.line.y = element_blank(),
        # panel.border = element_blank()
        #) 
```


```r
labor_per_area_plot
```

<div class="figure">
<img src="03-Review-of-Literature_files/figure-html/labor-per-area-1.png" alt="The infield skin consumes a majority of inputs despite comprising less than 10 percent of the playing surface area." width="100%" />
<p class="caption">(\#fig:labor-per-area)The infield skin consumes a majority of inputs despite comprising less than 10 percent of the playing surface area.</p>
</div>



```r
plot_grid(batted_balls_w_boundaries, labor_per_area_plot, labels = "AUTO", rel_widths = c(1, 1), rel_heights = c(1,1), ncol = 2)
```

<div class="figure">
<img src="03-Review-of-Literature_files/figure-html/battedballs-maintenance-1.png" alt="A) Intensity of play on the infield skin. B) The infield skin consumes a majority of inputs despite comprising only ~8% of the playing surface." width="100%" />
<p class="caption">(\#fig:battedballs-maintenance)A) Intensity of play on the infield skin. B) The infield skin consumes a majority of inputs despite comprising only ~8% of the playing surface.</p>
</div>


The main properties of interest to the athlete (and therefore to the grounds manager) are footing and ball response. Each can be further subdivided. 

#### Footing 

##### Traction

Traction allows the athlete to run, change directions, and perform other maneuvers without slipping, sliding, or losing their balance. Traction is not directly analagous to pure planar friction [   ..........  ]

##### The corkboard effect

Minimal surface disruption is a crucial element of field quality. A majority of batted balls are fielded by defensive players on the infield skin. Figure [ ] shows a breakdown of batted ball outcomes in the MLB over several years. A quality infield skin ensures the game's outcome is decided by the players' performance alone and is not influenced by chance events such as an errant ball bounce. 

Grounds managers consider ideal infield performance as follows: an athlete's studded footwear readily penetrates the soil at footstrike. As the athlete moves across the surface, the cleats release without separating any soil solids from the zone surrounding the cleat. No soil adheres to the studs or sole of the shoe. Thus, surface deformation is limited to a small indentation matching the shape of the stud. This phenomenon is colloquially known as the “corkboard effect,” or “cleat-in, cleat-out.” In contrast, a poor-quality infield is one on which soil is readily torn from the surface in larger clods or easily fragmented into powder. 

 Small cleat indentations are not likely to cause errant ball response Larger depressions excavated by player's cleats (or the soil clods themeselves) are impediments which tend to deflect the ball. This property allows the game to continue without the possibility of errant ball-to-surface interactions (Figure \@ref(fig:corkboard-concept)). 


```r
knitr::include_graphics('images/illustrations/cleatmarks/corkboard_concept.png')
```

<div class="figure">
<img src="images/illustrations/cleatmarks/corkboard_concept.png" alt="The &quot;cleat-in, cleat-out&quot; effect ensures predictable ball response." width="976" />
<p class="caption">(\#fig:corkboard-concept)The "cleat-in, cleat-out" effect ensures predictable ball response.</p>
</div>


Deviations from this ideal occur due to the nature of the constituent particles in the soil and their interactions with water. Rotational and translational motions of the athlete impose shearing forces on the infield surface. Shear force is defined as a force component coplanar with a potential failure surface (Coloumb or similar reference). If the shear force is large enough to induce yield, the yield may manifest as either ductile deformation of the soil matrix, or as a complete rupture of the soil at a depth approximating the stud length. A clod of soil decoupled from the surrounding area creates two surface imperfections: the clod itself, and an indentation in the surface. If impacted by a batted ball, these imperfections may alter the ball’s trajectory and cause a fielder to misplay the hop. Clods are unsightly, and once abraded to their constituent soil particles, contribute to surface dust and stickiness. Therefore, groundskeepers attempt to maintain the infield in a condition which maximizes ductile behavior and minimizes the generation of clods during play. 

Soil clods are generated via brittle failure in the soil. Brittle failure is defined as a mode of yield accompanied by little to no plastic deformation preceding separation of the solid. Energy dissipation during brittle failure is low, and mostly localized along cracks which act to concentrate the stress. In contrast, plastic deformation attenuates more energy through mechanical strain and generation of heat (Kuipers, 1984; Perez, 2017). 
The transition between brittle and ductile stages was first described in soil by the Swedish chemist Albert Atterberg. These phases are termed the semi-solid state and plastic state, and are governed by soil water content (Atterberg, 1911). Crumbling of soil is controlled by the distribution of imperfections or “weakest links” in the soil matrix (Dexter, 2004). Yield must occur for a player’s cleat to penetrate the soil surface. If the soil is in the brittle condition, the yield occurs in the form of microcracks which propagate through the soil mass, weakening its skeleton. If the soil is in the plastic condition, the remolded zone around the cleat is likely to be smaller and more uniform with space (Deepa et al., 2013). 

### Research on infield surface performance 

@Goodall2005 is the only published account of research on infield soil mixtures. The authors installed several soils which were commercially available within their region. 

@Brosnan2008a surveyed the surface conditions of the infield skin on extant playing fields at three maintenance levels. Particle size analyses were performed on soil sampled from each infield skin. The USDA soil texture of those samples is plotted in \@ref(fig:brosnan-survey-usda). These soils were sampled from the upper 13 mm and contained large granules of calcined clay infield conditioner; therefore, the texture measured with this method is coarser than the "true" texture of the base soil. 

<div class="figure" style="text-align: center">
<img src="images/brosnan_survey_PSA.PNG" alt="Infield soils suyveyed by Brosnan (2008a)" width="100%" />
<p class="caption">(\#fig:brosnan-survey-usda)Infield soils suyveyed by Brosnan (2008a)</p>
</div>


Additionally, Brosnan et al. published research on the infield skin's role in athlete-to-surface interactions [-@Brosnan2009] and ball-to-surface interactions [-@Brosnan2011]. Bulk density (&rho;~bulk~) was shown to influence surface properties, although the range of bulk densities tested (1.2-1.8 Mg m^-3^) was beneath values typically encountered on infield skins (author's personal observation; data not shown).

However, the work of Brosnan et al. [-@Brosnan2009; -@Brosnan2011] was performed on a single soil material and focused on construction and maintenance practices rather than mix design.

### Use of artificial soil mixtures on baseball infields

Baseball was first played in the early 19th century, but the definitive origins of the game are likely lost to history [@Walker1994]. The earliest recorded attempt to alter the physical properties of an infield soil were by Harry Wright in 1875. Wright and his contemporaries incorporated various materials into their infield soils to enhance stability, firmness, or drainage of the playing surface. Amendments included organic debris (straw, ashes) and and inorganic materials (sand, lime, cinders) [@Morris2007].

Infield soil mixes were produced off-site and imported beginning in the 1960s ?Zwasksa?.

## Soil behavior terminology and measures {#soil-behavior-fundamentals} 

Toughness is really the most defining feature of clay soil. 





## Design and properties of artificial soil mixtures {#artificial-soil-mixtures}

Natural soil materials are excavated and deliberately blended for many uses. Potting mixes and green roof media are the largest means of production by volume (reference ??). The purpose of blending multiple soil materials is to create a product having properties not exhibited by any naturally occurring soil material. Even if the desired properties _could_ be found in a single naturally occurring material, the properties of natural soils are subject to spatial variation. In such a scenario, the properties of the mixture can be held constant simply by adjusting the ratio of the components. 

The Atterberg limits and unconfined compression testing are the primary means which have been used to charazcterize soil mixtures. These mixtures may contain two components(sand and clay), or three components (sand and two separate types of clay soil)




## Laboratory methods for evaluating soil behavior and physical properties {#lab-methods-review} 



### Particle size analysis

### Compaction tests

### Compression and shear strength tests

### Atterberg limits

#### Origins of the test methods
A common definition of plasticity is the tendency of a material to deform under an applied load, without fracturing into multiple pieces, and to retain its new shape when the load is removed [@Andrade2011] . The earliest test methods for soil plasticity were developed by Atterberg -@Atterberg1911, -@Atterberg1974. Atterberg noted that although plasticity is easy to observe, the phenomenon does not lend itself to simple measurement. He showed that the consistency of the soil was determined by its water content, and he reasoned that soil was plastic only within a finite range of water content, which differed for every soil. The upper water content boundary was defined as the flow limit, at which two batches of soil paste flowed together when jarred, and the lower water content boundary was defined as the rolling limit, at which the soil could no longer be rolled into thin threads. Atterberg called the difference between these two characteristic water contents the “plasticity number” (now known as the plasticity index or PI). He defined five other thresholds of soil behavior, though the others are not commonly used today. 

Atterberg deemed the plasticity number as the most reliable means of measuring plasticity, though upon reading his work one senses a reluctance to accept this simple number as a fully adequate measure of such a complex phenomenon. He pointed out that his ‘plasticity number’ provides no information amount of plastic strain incurred during deformation, nor does it enumerate the stress required to impart the deformation. He considered the effort needed to deform the soil a separate property, which translates to English as ‘viscosity;’ this property was later termed ‘toughness’ by @Casagrande1932. 

The value of Atterberg’s work has never been fully realized in his own discipline of soil science. However, the utilty of his test methods was clear to those in the then-novel field of geotechnical engineering. @Terzaghi1926 and @Casagrande1932 modified and standardized the Atterberg limit tests, leading to their widespread adoption for the design and control of earthworks projects. @Terzaghi1926 acknowledged the arbitrary nature of the tests, yet emphasized their value as a preliminary soil classification tool. He scorned qualitative definitions of soil behavior and favored the use of quantitative descriptions:

> “Every engineer should develop the habit of expressing the plasticity and grain-size characteristics of soils by numerical values rather than adjectives…..the degree of plasticity should be indicated by the estimated value of the plasticity index and not by the words ‘trace of plasticity’ or ‘highly plastic.’ ” 
@Terzaghi1996

#### Mechanics of the liquid limit test

The liquid limit test described by @Atterberg1911 required the soil to be agitated manually, introducing an unacceptable degree of operator dependence. The test method was first standardized by @Casagrande1932. The Casagrande method uses a brass cup fixed to a rotating cam, which agitates the soil paste by dropping the cup against a hard rubber base of specified height. A recent survey by @Haigh2016 supports Casagrande’s warning that the stiffness of the rubber base can significantly affect the results obtained with this method in addition to the device’s geometry and operator technique,.

An alternative test device for liquid limit determination was adopted by BS ______ (reference from Holtz et al. ?? )

#### Mechanics of the plastic limit test

Current protocols for the plastic limit include ASTM D4318, AASHTO T 90, and B.S. 1377. In the test, a soil is first wetted to the liquid limit to encourage full saturation. After performing the liquid limit test, a ~10 g sample of soil is gradually dried by gentle blow drying and re-molding with the operator’s fingers. Once the soil can be molded without sticking to the operator’s skin, the soil is rolled into a thread of 3 mm diameter, broken apart, and pressed into a new lump. This process is repeated until the soil crumbles when the rolling action is applied. 

@Terzaghi1926 introduced the use of a fixed thread diameter. Recently, the significance of the thread diameter has been questioned [@Barnes2013]. The stability of the soil thread is related to the maximum particle diameter and the rolling technique, and (Barnes, 2013) argued that emphasis should be shifted away from a specific thread diameter and toward observation of the thread during the test. 
Efforts have been made to improve the plastic limit test. The following section describes alternative test methods developed to improve upon the original thread-rolling method. 

Most attempts to improve the plastic limit test have focused on mechanizing the thread-rolling procedure. Test operators utilize different combinations of force, speed, and displacement when rolling the soil. Collectively these variables were termed ‘rolling path’ by [@Barnes2013]. @Bobrowski1992 described a simple apparatus to aid the operator in producing a thread of precisely 3.2 mm. The device consists of a flat plexiglass plate which is used to roll the thread, rather than the operator’s hand. (Bobrowski and Griekspoor, 1992) also state that paper should be affixed to the base of the device to prevent the thread from sliding and to expedite the drying process. Use of this device is allowed, but not mandated, in the current version of ASTM D4318. This device has been criticized by (Barnes, 2013), who cited the data of (Rashid et al., 2008) to assert the rolling device produces excessively rapid drying and eliminates the soil thread from the view of the operator. 

A fully mechanized thread rolling apparatus was developed by (Temyingyong et al., 2002). Their device used two acrylic plates similar to (Bobrowski and Griekspoor, 1992) and added a DC motor to apply the rolling action. The DC voltage was adjusted to control the rolling speed, and the downward force was altered by the addition of weights to the upper plate. They found that the initial diameter of the soil mass explained a larger amount of variation in the test result than did factors which might be ascribed to the subjective manual method (speed and pressure). The device still appears to be a significant improvement over the hand-rolling method; unfortunately, the device is not commercially available and its use has not been adopted by governing bodies. 
Barnes (2009) introduced a novel thread-rolling apparatus which allows precise control of the load applied to the soil thread. The device comprises two stainless steel plates: a fixed base and an upper loading plate which is manually oscillated. The load is adjusted by sliding a weight ballast along the side of the device opposite the handle. The further the ballast weight is from a pivot point, the lesser the load on the soil thread. The device is still operated by hand and a constant rate of rolling must be maintained through careful operation. A thin smear of petrolatum is used on the stainless steel plates to encourage extrusion of the soil thread. A number of other useful properties have been developed with this device, as described in the section of this review on soil toughness. 
Moreno-Marato and Alonso-Azcàrate described a plastic limit test in a soil thread is bent rather than rolled. The soil is wetted to a moldable consistency and flattened to ~3 mm.  A special slicing tool is used to create a rectangular prism of soil having precise dimensions of 3 mm x 3mm x 50 mm. The specimen is then rounded into a cylindrical thread using the same tool. The thread is carefully bent about its center, which is anchored around a stainless steel cylinder. When the thread begins to crack, a caliper is used to measure the distance between the two ends of the thread. The test is repeated for at least two other water contents and the water content of the threads is plotted against the displacement with segmented regression. The shallower segment is extrapolated to zero displacement and this water content is taken as the plastic limit. 

Moreno-Marato and Alonso-Azcàrate also described a faster version of their original thread-bending test. In this version only a single thread is prepared and its displacement and water content are extrapolated to zero displacement using an empirical equation. This test meets the original requirements of any plastic limit test which could replace the current method, namely:

1.	Rapid
2.	repeatable
3.	Operator-independent






#### Attempts to improve Atterberg limit methods 

Many soil tests have been developed with the goal of supplanting the Atterberg limits. However, due to the success and the abundance of data which has accumulated using these test methods, they are unlikely to be abandoned. 

Most criticism of the Atterberg limit tests center around operator tehcnique. 


### Toughness tests



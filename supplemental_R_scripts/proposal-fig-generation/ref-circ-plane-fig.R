library(rgl)
library(soilmesh)
library(magrittr)
library(magick)

rgl::clear3d()
rgl::shade3d(soilmesh::ref_circ, color = "#A57251")
soilmesh::add_origin_axes()
rgl::axes3d()

# manually adjust viewport to my liking, then take snapshot


# rgl::rgl.snapshot('./figs/png/ref-circ-plane.png')

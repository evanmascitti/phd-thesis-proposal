# ensure all the meshes were processed correctly based on the rt matrix 
library(magrittr)
library(rgl)

# interactively adjust viewer params to what they should be,
# then run the following 2 lines to save the parameters:
clear3d()
params <- par3d()

pattern <- "\\d{2}-02\\.ply$"

paths <- list.files(path = "../../data-lab/scanner-angle-calibration/analysis/data/derived_data/processed_meshes/2021-03-05/",
                    pattern = pattern, full.names = T)

mesh_names <- stringr::str_extract(paths, pattern = "\\d{2}-02(?=\\.ply$)")

meshes <- paths %>% 
  purrr::set_names(mesh_names) %>% 
  purrr::map(Rvcg::vcgImport) %>% 
  tibble::enframe(name = 'angle_cyl', value = 'mesh') %>% 
  tidyr::separate(angle_cyl, into = c("angle", "cylinder")) %>% 
  dplyr::mutate(angle = as.integer(angle))

screenshot_mesh <- function(mesh, angle){
  
  # meshes <- meshes

  rgl::clear3d()
  
  mesh_to_show <- mesh
    # mesh %>% 
    # dplyr::filter(angle == angle) %>% 
    # .[['mesh']] %>% 
    # .[[1]]
  
  plot_lab <- paste0(as.character(angle), "\u00b0")
  
  filepath <- here::here(paste0(
    "data/proposed-experiments-data/3D-scanning-data/verifying-rt-matrices-for-scanner-angle-calibration/", 
                                   angle, ".png"))
  
  params <- params
  
  rgl::wire3d(mesh_to_show, color = 'grey50')
  
  rgl::text3d(x= 50, y= 50, z= 50, texts = plot_lab, cex = 3)
  
  soilmesh::add_origin_axes(zmin = -40, zmax = 40)

  rgl::rgl.snapshot(filename = filepath)
  
}
clear3d()
# shade3d(meshes$mesh[[1]], color= 'grey50')

# screenshot_mesh(mesh = meshes$mesh[[1]], angle = 40)

# writes the snapshots to disk
purrr::map2(meshes$mesh, unique(meshes$angle), screenshot_mesh)

# reads them back in and writes a gif in same directory 
list.files(path = "data/proposed-experiments-data/3D-scanning-data/verifying-rt-matrices-for-scanner-angle-calibration/",
           pattern = "\\.png$", full.names = T) %>% 
  magick::image_read() %>% 
  magick::image_animate() %>% 
  magick::image_write_gif(delay = 1/2, path = 'data/proposed-experiments-data/3D-scanning-data/verifying-rt-matrices-for-scanner-angle-calibration/all-rt-matrices-worked.gif')






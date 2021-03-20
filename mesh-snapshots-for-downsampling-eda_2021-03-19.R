####

# Instructions 

# This script is relatively self-contained, but it contains some hard-coded paths 
# and requires the user to interactively choose the rgl window parameters 
# before assigning them as a global variable (see below).

# For safety, I have commented out the functions which create the screenshots; this 
# ensures the existing png images will not be over-written. If I do want to over-write 
# them later, the functions can be un-commented so the script will run.


####


raw_mesh_file <- "./data/proposed-experiments-data/3D-scanning-data/a-single-large-processed-mesh.ply"


mesh <- vcgImport(raw_mesh_file) 

# function for dne pre-process based on number of faces 
downsample_for_dne <- function(mesh, faces){
  
  mesh %>% 
    vcgQEdecim(tarface = faces) %>% 
    vcgClean(sel = c(2,1,4), iterate = T) %>%
    updateNormals()
  
}

meshes_for_dne <- tibble(
  faces = 1e3*c(25, 5, 1),
  mesh_name = paste0('dnemesh-', faces, 'faces'),
  mesh = list(mesh)
) %>% 
  mutate(decimated_mesh = map2(.x = mesh, .y = faces, .f = downsample_for_dne),
         dne_obj = map(decimated_mesh, molaR::DNE))


# save_dne_snapshot <- function(dne_obj, mesh_name){
#   
#   clear3d()
#   
#   path <- paste0("images/rgl-snapshots/", mesh_name, ".png")
#   
#   #browser()
#   
#   DNE3d(dne_obj)
#   
#   rgl.snapshot(filename = path)
#   
# }


purrr::map2(meshes_for_dne$dne_obj, meshes_for_dne$mesh_name, save_dne_snapshot)


# interactively adjust viewer params to what they should be,
# then run the following 2 lines to save the parameters:
clear3d()
params <- par3d()


# screenshot_mesh <- function(mesh, faces){
#   
#   rgl::clear3d()
#   
#   bg3d('grey75')
#   
#   plot_lab <- paste0(scales::comma(faces), " faces")
#   
#   filepath <- here::here(paste0("images/rgl-snapshots/sampled-to-", faces, "faces.png"))
#   
#   params <- params
#   
#   #browser()
#   
#   rgl::shade3d(mesh, color = inf_col)
#   
#   rgl::text3d(x= 0, y= 25, z= 50, texts = plot_lab, cex = 3)
#   
#   # soilmesh::add_origin_axes(zmin = -40, zmax = 40)
#   
#   rgl::rgl.snapshot(filename = filepath)
#   
# }

clear3d()
bg3d('grey75')

purrr::map2(meshes_for_dne$decimated_mesh, meshes_for_dne$faces,  screenshot_mesh)

purrr::map2(list(mesh), signif(length(mesh$it),2),  screenshot_mesh)



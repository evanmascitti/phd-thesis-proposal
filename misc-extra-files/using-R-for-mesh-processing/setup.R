library(rgl)
library(magrittr)

matrix <- readr::read_csv(
  file = './misc-extra-files/using-R-for-mesh-processing/rt-matrix_2021-06-28.csv',
  col_names = FALSE, 
  col_types = "dddd") %>% 
  as.matrix()

mesh1 <- Rvcg::vcgImport('./misc-extra-files/using-R-for-mesh-processing/colored-mesh.ply')

clear3d()
shade3d(mesh1, color = 'grey50')
soilmesh::add_origin_axes()
bg3d('grey80')
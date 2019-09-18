library(leaflet)
pal <- colorQuantile("YlOrRd", NULL, n = 8)
load("~/default/workspaceNotSynced/sbgnvizShiny/inst/extdata/geog495.RData")
leaflet(orstationc) %>% 
  addTiles() %>%
  addCircleMarkers(color = ~pal(tann))

library(xml2)
library(sbgnvizShiny)

sbgnml <- read_xml("~/default/workspaceNotSynced/sbgnvizShiny/inst/extdata/F002-eicosanoids-SBGNv02_color.sbgn")
sbgnml <- as.character(sbgnml)

sbgnvizShiny(sbgnml)

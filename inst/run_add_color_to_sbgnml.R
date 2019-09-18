library(sbgnvizShiny)

sbgnml_file <- system.file("extdata/F002-eicosanoids-SBGNv02.sbgn", package="sbgnvizShiny")

overall_df <- extract_elements(sbgnml_file, compartment_process_fill_color="#ffff00")
query_colors <- data.frame(query=c("RAF"), fill_color=c("#ff0000"), stringsAsFactors=FALSE)
overall_df <- map_colors(query_colors, overall_df)
sbgn_xml <- add_colors_to_sbgnml(sbgnml_file, overall_df=overall_df)
#as.character(sbgn_xml)
write_xml(sbgn_xml, "F002-eicosanoids-SBGNv02_color.sbgn")
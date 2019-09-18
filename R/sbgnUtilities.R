#' Get color XML content 
#' 
#' @param color_id a string id (e.g., color_1)
#' @param color_value a string hex color (e.g., #ffffff)
#' 
#' @return a string XML element 
#' 
#' @export
get_color_xml <- function(color_id, color_value) {
  template_color_definition <- '<colorDefinition id="@{color_id}" value="@{color_value}"/>'
  
  xml <- qq(template_color_definition)
  return(xml)
}

#' Get style XML content 
#' 
#' @param style_id a string id (e.g., color_1)
#' @param id_list a vector of SBGNML IDs 
#' @param stroke_color a color ID (e.g., color_1)
#' @param fill_color a color ID (e.g., color_1)
#' @param font_size a numeric font size 
#' @param font_family a font family name (should be compatible with web browsers)
#' @param font_weight a CSS font weight
#' @param stroke_width a numeric stroke width
#' 
#' @return a string XML element 
#' 
#' @export
get_style_xml <- function(style_id, id_list, type, stroke_color, fill_color=NULL, font_size=12, font_family="Helvetica", font_weight="normal", font_style="normal", stroke_width=2) {
  template_style_compartment <- '<style id="@{style_id}" idList="@{id_list}"><g fontSize="@{font_size}" fontFamily="@{font_family}" fontWeight="@{font_weight}" fontStyle="@{font_style}" stroke="@{stroke_color}" strokeWidth="@{stroke_width}" fill="@{fill_color}"/></style>'
  template_style_not_compartment_process <- '<style id="@{style_id}" idList="@{id_list}"><g fontSize="@{font_size}" fontFamily="@{font_family}" fontWeight="@{font_weight}" fontStyle="@{font_style}" stroke="@{stroke_color}" strokeWidth="@{stroke_width}" fill="@{fill_color}"/></style>'
  template_style_process <- '<style id="@{style_id}" idList="@{id_list}"><g stroke="@{stroke_color}" strokeWidth="@{stroke_width}" fill="@{fill_color}"/></style>'
  template_style_arc <- '<style id="@{style_id}" idList="@{id_list}"><g stroke="@{stroke_color}" strokeWidth="@{stroke_width}"/></style>'
  
  id_list <- paste(id_list, collapse=" ")
  
  if(type == "compartment") {
    template <- template_style_compartment
  } else if(type == "not_compartment_process") {
    template <- template_style_not_compartment_process
  } else if(type == "process") {
    template <- template_style_process
  } else if(type == "arc") {
    template <- template_style_arc
  }
  
  xml <- qq(template)
  return(xml)
}

#' Extract information for SBGNML elements from an SBGN file 
#' 
#' @param sbgnml_file an SBGNML filename 
#' @param a default stroke color (e.g., #555555)
#' @param a default compartment and process fill color (e.g., #ffffff)
#' 
#' @return a data.frame with information about the extracted elements: id, label, type, stroke_color, fill_color 
#' 
#' @export
extract_elements <- function(sbgnml_file, stroke_color="#555555", compartment_process_fill_color="#ffffff") {
  sbgn_xml <- read_xml(sbgnml_file)
  sbgn_ns <- xml_ns_rename(xml_ns(sbgn_xml), d1 = "sbgn")
  
  ## Extract glyphs
  compartments <- xml_find_all(sbgn_xml, '//sbgn:glyph[@class="compartment"]', sbgn_ns)
  processes <- xml_find_all(sbgn_xml, "//sbgn:glyph[contains(@class,'process')]", sbgn_ns)
  all <- xml_find_all(sbgn_xml, '//sbgn:glyph', sbgn_ns)
  arcs <- xml_find_all(sbgn_xml, '//sbgn:arc', sbgn_ns)
  
  compartment_ids <- xml_attr(compartments, "id")
  process_ids <- xml_attr(processes, "id")
  all_ids <- xml_attr(all, "id")
  not_compartment_process_ids <- all_ids[!(all_ids %in% c(compartment_ids, process_ids))]
  arc_ids <- xml_attr(arcs, "id")
  
  ## Get IDs with labels
  t1 <- xml_find_all(sbgn_xml, '//sbgn:glyph[sbgn:label]', sbgn_ns)
  ids <- xml_attr(t1, "id")
  t2 <- xml_find_all(t1, '//sbgn:label', sbgn_ns)
  labels <- xml_attr(t2, "text")
  labels_df <- data.frame(id=ids, label=labels, stringsAsFactors = FALSE)
  
  empty_df <- data.frame(id=character(0), type=character(0), fill_color=character(0), stringsAsFactors=FALSE)
  
  if(length(compartment_ids) > 0) {
    compartment_df <- data.frame(id=compartment_ids, type="compartment", fill_color=compartment_process_fill_color, stringsAsFactors=FALSE)    
  } else {
    compartment_df <- empty_df
  }

  if(length(process_ids) > 0) {
    process_df <- data.frame(id=process_ids, type="process", fill_color=compartment_process_fill_color, stringsAsFactors=FALSE)    
  } else {
    process_df <- empty_df
  }
  
  if(length(not_compartment_process_ids) > 0) {
    not_compartment_process_df <- data.frame(id=not_compartment_process_ids, type="not_compartment_process", fill_color=NA, stringsAsFactors=FALSE)    
  } else {
    not_compartment_process_df <- empty_df
  }
  
  if(length(arc_ids) > 0) {
    arc_df <- data.frame(id=arc_ids, type="arc", fill_color=NA, stringsAsFactors=FALSE)   
  } else {
    arc_df <- empty_df
  }

  overall_df <- do.call("rbind", list(compartment_df, process_df, not_compartment_process_df, arc_df))
  overall_df <- merge(overall_df, labels_df, by="id", all=TRUE)
  
  overall_df$stroke_color <- stroke_color
  
  return(overall_df)
}

#' Map colors with queries 
#' 
#' @param query_colors a two-column data.frame with query and fill_color columns. The query will be grepped against the labels in overall_df. 
#' @param overall_df see extract_elements function
#' @param default_fill_color a default color (e.g., #ffffff) mapped if not matched by any query
#' 
#' @return overall_df (see extract_elemnts function with updated colors 
#' 
#' @export
map_colors <- function(query_colors, overall_df, default_fill_color="#ffffff") {
  for(i in 1:nrow(query_colors)) {
    # i <- 1 
    
    query <- query_colors[i, "query"]
    color <- query_colors[i, "fill_color"]
    
    idx <- which(overall_df$type == "not_compartment_process" & grepl(query, overall_df$label))
    idx
    
    overall_df[idx, "fill_color"] <- color
  }
  
  idx <- which(overall_df$type == "not_compartment_process" & is.na(overall_df$fill_color))
  overall_df[idx, "fill_color"] <- default_fill_color 
  
  return(overall_df)
}

#' Add colors to SBGNML 
#' 
#' @param sbgnml_file an SBGNML filename 
#' @param overall_df see extract_elements
#' @param color_xml_file a template 
#' 
#' @return XML content (from xml2) with added color information 
#' 
#' @export
add_colors_to_sbgnml <- function(sbgnml_file, 
                                 overall_df,
                                 color_xml_file=system.file("templates/color_template.xml", package="sbgnvizShiny")) {
  sbgn_xml <- read_xml(sbgnml_file)
  sbgn_ns <- xml_ns_rename(xml_ns(sbgn_xml), d1 = "sbgn")
  
  color_xml <- read_xml(color_xml_file)
  color_ns <- xml_ns_rename(xml_ns(color_xml), d1 = "color")
  
  colors_1 <- unique(overall_df[!is.na(overall_df$fill_color), "fill_color"])
  colors_2 <- unique(overall_df[!is.na(overall_df$stroke_color), "stroke_color"])
  colors <- c(colors_1, colors_2)
  
  tmp <- xml_find_first(color_xml, '//color:listOfColorDefinitions', color_ns)
  
  for(i in 1:length(colors)) {
    color <- get_color_xml(paste0("color_", substring(colors[i], 2)), colors[i])
    xml_add_child(tmp, read_xml(color))
  }
  
  tmp <- xml_find_first(color_xml, '//color:listOfStyles', color_ns)
  for(i in 1:nrow(overall_df)) {
    #i <- 1 
    
    tmp_fill_color <- overall_df[i, "fill_color"]
    if(is.na(tmp_fill_color)) { 
      tmp_fill_color <- NULL 
    } else {
      tmp_fill_color <- paste0("color_", substring(tmp_fill_color, 2))
    }
    
    tmp_stroke_color <- overall_df[i, "stroke_color"]
    if(is.na(tmp_stroke_color)) { 
      tmp_stroke_color <- "#000000" 
    } else {
      tmp_stroke_color <- paste0("color_", substring(tmp_stroke_color, 2))  
    }
    
    style <- get_style_xml(style_id=paste0("style_", overall_df[i, "id"]), 
                           id_list=overall_df[i, "id"], 
                           type=overall_df[i, "type"], 
                           stroke_color=tmp_stroke_color, 
                           fill_color=tmp_fill_color)
    
    #as.character(style)
    xml_add_child(tmp, read_xml(style))
  }
  
  tmp <- xml_find_first(sbgn_xml, '//sbgn:map', sbgn_ns)
  xml_add_child(tmp, color_xml)
  tmp
  
  return(sbgn_xml)
}
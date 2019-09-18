library(shiny)
library(sbgnvizShiny)
library(htmlwidgets)
library(xml2)

# UI ----
ui = shinyUI(fluidPage(
  tags$head(
    tags$style("#sbgnvizShiny{height:95vh !important;}"),
    tags$link(href="https://raw.githubusercontent.com/cytoscape/cytoscape.js-panzoom/master/cytoscape.js-panzoom.css", rel="stylesheet", type="text/css"),
    tags$link(href="https://raw.githubusercontent.com/cytoscape/cytoscape.js-panzoom/master/font-awesome-4.0.3/css/font-awesome.css", rel="stylesheet", type="text/css")
    ),
  titlePanel("sbgnviz Shiny"),

  sidebarLayout(
     sidebarPanel(
       fileInput("sbgnml", "Choose SBGNML File",
                 multiple = FALSE,
                 accept = c("text/xml",
                            "text/plain",
                            ".sbgn",
                            ".sbgnml",
                            ".txt",
                            ".xml")),
        width=3
        ),
      mainPanel(
        withTags({
          div(span("Save: "),
              a(id="save-as-svg", href="#", "SVG"),
              a(id="save-as-png", href="#", "PNG")
          )
        }),
        sbgnvizShinyOutput('sbgnvizShiny'),
        width=9
        )
     ) # sidebarLayout
))

# Server ----
server = function(input, output, session) {
  output$sbgnvizShiny <- renderSbgnvizShiny({
    inFile <- input$sbgnml
    
    #cat("DEBUG: ", as.character(str(inFile)))

    if (!is.null(inFile)) {
      sbgn_xml <- read_xml(inFile$datapath)
    } else {
      sbgn_xml <- read_xml(system.file("extdata/neuronal_muscle_signaling_color.xml", package="sbgnvizShiny"))
    }
    
    sbgnvizShiny(sbgnml=as.character(sbgn_xml))
  })
} # server

shinyApp(ui = ui, server = server)

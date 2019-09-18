#' @importFrom htmlwidgets createWidget shinyWidgetOutput shinyRenderWidget
#' @import shiny
#'
#' @title sbgnvizShiny
# ----
#' sbgnvizShiny
#'
#' @description
#' This widget wraps cytoscape.js, a full-featured Javsscript network library for visualization and analysis.
#'
#' @aliases sbgnvizShiny
#' @rdname sbgnvizShiny
#'
#' @param sbgnml an R graphNEL instance (igraph support coming soon).
#' @param width integer  initial width of the widget.
#' @param height integer initial height of the widget.
#' @param elementId string the DOM id into which the widget is rendered, default NULL is best.
#'
#' @return a reference to an htmlwidget.
#'
#'
#' @examples
#' \dontrun{
#'   output$sbgnvizShiny <- rendersbgnvizShiny(sbgnvizShiny(sbgnml))
#' }
#'
#' @export
sbgnvizShiny <- function(sbgnml, width = NULL, height = NULL, elementId = NULL)
{
   x <- list(sbgnml=sbgnml)

   htmlwidgets::createWidget(
      name = 'sbgnvizShiny',
      x,
      width = width,
      height = height,
      package = 'sbgnvizShiny',
      elementId = elementId,
      sizingPolicy = htmlwidgets::sizingPolicy(browser.fill=TRUE)
      )

} # sbgnvizShiny constructor
# ----
#' Standard shiny ui rendering construct
#'
#' @param outputId the name of the DOM element to create.
#' @param width integer  optional initial width of the widget.
#' @param height integer optional initial height of the widget.
#'
#' @return a reference to an htmlwidget
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   mainPanel(sbgnvizShinyOutput('sbgnvizShiny'), width=10)
#' }
#'
#' @aliases sbgnvizShinyOutput
#' @rdname sbgnvizShinyOutput
#'
#' @export

sbgnvizShinyOutput <- function(outputId, width = '100%', height = '400')
{
    htmlwidgets::shinyWidgetOutput(outputId, 'sbgnvizShiny', width, height, package = 'sbgnvizShiny')
}
# ----
#' More shiny plumbing -  a sbgnvizShiny wrapper for htmlwidget standard rendering operation
#'
#' @param expr an expression that generates an HTML widget.
#' @param env environment in which to evaluate expr.
#' @param quoted logical specifies whether expr is quoted ("useuful if you want to save an expression in a variable").
#'
#' @return not sure
#'
#' @aliases renderSbgnvizShiny
#' @rdname renderSbgnvizShiny
#'
#' @export
renderSbgnvizShiny <- function(expr, env = parent.frame(), quoted = FALSE)
{
   if (!quoted){
      expr <- substitute(expr)
   } # force quoted

  htmlwidgets::shinyRenderWidget(expr, sbgnvizShinyOutput, env, quoted = TRUE)

}

#' save a png rendering of the current network view to the specified filename
#'
#' @param session a Shiny Server session object.
#' @param filename a character string
#'
#' @aliases savePNGtoFile
#' @rdname savePNGtoFile
#'
#' @export
# savePNGtoFile <- function(session, filename)
# {
#    session$sendCustomMessage(type="savePNGtoFile", message=list(filename))
# 
# } # savePNGtoFile
# ----

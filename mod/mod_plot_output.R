
source("./mod/mod_checkbox.R")

#' shiny plotOutput wrapper UI
#'
#' 
#'
#' @param height value to change the height of the plot (in pixels)
#' 
#'
#' @return tagList of Shiny UI elements
#'
#' @examples
#' mod_plot_output_UI("plot", height = 300)
#'
#' @export
mod_plot_output_UI <- function(id, height = 100) {
  ns <- NS(id)
  tagList(
    plotOutput(ns("plot"),
               brush = brushOpts(id = ns("brush"),
                                 resetOnNew = T,
                                 direction = "x"),
               dblclick = ns("dblclick"),
               hover = hoverOpts(id = ns("hover"), 
                                 nullOutside = T, 
                                 delayType = "throttle", 
                                 delay = 100),
               click = ns("click"),
               height = height)
  )
}


#' shiny plotOutput wrapper server
#'
#' 
#'
#' @param p a ggplot object
#' @param ranges, a reactive object to store current plot brush values
#' @param dnCNV_table, a reactive table to highlight potential dnCNV
#' @param zoom, a boolean to switch from static to dynamic plot output (default = T) If False, the plot will not zoom in when doubleclicked brush area.
#' 
#' 
#'
#' @return reactive ranges for other plots
#'
#' @examples
#' mod_plot_output_Server("plot", p, ranges, dnCNV_table, zoom = F)
#'
#' @export
mod_plot_output_Server <- function(id, p, ranges, dnCNV_table, zoom = T){
  moduleServer(
    id,
    function(input, output, session) {
      if (isTRUE(zoom)){
        output$plot <- renderPlot({
          if (!is.null(ranges$x)){
            p +
              coord_cartesian(xlim= ranges$x, ylim = ranges$y, expand = F)+
              scale_x_continuous(n.breaks = 20)+
              annotate("rect", fill = "orange", alpha =0.3, xmin = dnCNV_table$t$start, xmax = dnCNV_table$t$end, ymin = -Inf, ymax = Inf)
          } else {
            p +
              coord_cartesian(xlim= ranges$x, ylim = ranges$y, expand = F)+
              scale_x_continuous(n.breaks = 10)+
              annotate("rect", fill = "orange", alpha =0.3, xmin = dnCNV_table$t$start, xmax = dnCNV_table$t$end, ymin = -Inf, ymax = Inf)
          }
        })
      } else {
          output$plot <- renderPlot({
            if (is.null(ranges$x)){
              from <- 0
              to <- 0
              } else {
              from <- ranges$x[1]
              to <- ranges$x[2]
              }
            p +
              coord_cartesian(expand = F)+
              scale_x_continuous(n.breaks = 10)+
              annotate("rect", fill = "orange", alpha =0.3, xmin = dnCNV_table$t$start, xmax = dnCNV_table$t$end, ymin = -Inf, ymax = Inf)+
              annotate("rect", fill = "blue", alpha =0.3, xmin = from, xmax = to, ymin = -Inf, ymax = Inf)
          })
        }
      observe({
        ranges$cur <- input$hover$x
      })
      
      observeEvent(input$click, {
        pt <- input$click
        if (!is.null(pt)){
          ranges$click <- pt$x
        }
      })
      
      observeEvent(input$dblclick, {
        brush <- input$brush
        if (!is.null(brush)) {
          ranges$x <- c(brush$xmin, brush$xmax)
        } else {
          ranges$x <- NULL
        }
      })
      return (ranges) 
    }
)
}
  

#' shiny plotOutput wrapper UI
#'
#' 
#'
#' @param height value to change the height of the plot (in pixels)
#' 
#'
#' @return tagList of Shiny UI elements
#'
#' @examples
#' mod_plot_output_UI("plot", height = 300)
#'
#' @export
mod_plot_wg_UI <- function(id, height = 100) {
  ns <- NS(id)
  tagList(
    plotOutput(ns("plot"),
               brush = brushOpts(id = ns("brush"),
                                 resetOnNew = T,
                                 direction = "x"),
               dblclick = ns("dblclick"),
               height = height)
  )
}


#' shiny plotOutput wrapper server
#'
#' 
#'
#' @param p a ggplot object
#' @param ranges, a reactive object to store current plot brush values
#' @param dnCNV_table, a reactive table to highlight potential dnCNV
#' @param zoom, a boolean to switch from static to dynamic plot output (default = T) If False, the plot will not zoom in when doubleclicked brush area.
#' 
#' 
#'
#' @return reactive ranges for other plots
#'
#' @examples
#' mod_plot_output_Server("plot", p, ranges, dnCNV_table, zoom = F)
#'
#' @export
mod_plot_wg_Server <- function(id, p, ranges, dnCNV_table, zoom = T){
  moduleServer(
    id,
    function(input, output, session) {
      if (isTRUE(zoom)){
        output$plot <- renderPlot({
          
            p +
              coord_cartesian(xlim= ranges$x, ylim = ranges$y, expand = F)
        })
      } else{
        output$plot <- renderPlot({
          p +
            coord_cartesian(expand = F)
      })
      }
      
      observeEvent(input$dblclick, {
        brush <- input$brush
        if (!is.null(brush)) {
          ranges$x <- c(brush$xmin, brush$xmax)
        } else {
          ranges$x <- NULL
        }
      })
      return (ranges) 
    }
  )
}




#' Plot output toggle (show/hide) UI
#'
#' Allow showing and hiding plots when checkbox is ticked or unticked
#' requires shinyjs package
#'
#' @param height value to change the height of the plot (in pixels)
#'
#' @return tagList of Shiny UI elements
#'
#' @examples
#' mod_plot_switch_UI("plot")
#'
#' @export

mod_plot_switch_UI <- function(id, height = 70) {
  ns <- NS(id)
  shinyjs::useShinyjs()
  shinyjs::hidden(fluidRow(
    id =ns("panel"),
    tagList(
      column(12,mod_plot_output_UI(ns("plot"), height)
        )
      )
    )
  )
}


#' Plot output toggle (show/hide) server
#'
#' Allow showing and hiding plots when checkbox is ticked or unticked
#'
#' @param cbox checkbox value from checkboxInput
#' @param p ggplot object
#' @param ranges reactive ranges
#' @param zoom boolean for zoom in or not
#' 
#'
#' @return reactive brush ranges
#'
#' @examples
#' mod_plot_switch_Server("plot", boxVal, p, ranges)
#'
#' @export

mod_plot_switch_Server <- function(id, cbox, p, ranges, dnCNV_table, zoom = T) {
  moduleServer(
    id,
    function(input, output, session) {
      ranges <- mod_plot_output_Server("plot", p, ranges, dnCNV_table, zoom = zoom)
      observe({
        if (isTRUE(cbox())) {
          shinyjs::show(id = "panel")
        } else {
          shinyjs::hide(id = "panel")
        }
      })
      return(ranges)
    }
  )
}



#' Annotation table wrapper UI
#'
#' Creates UI elemnts for annotation table
#'
#'
#' @return tagList of Shiny UI elements
#'
#' @examples
#' anno_table_UI("table")
#'
#' @export
anno_table_UI <- function(id) {
  ns <- NS(id)
  tagList(
    downloadButton(ns("download"), "Download (.tsv)"),
    dataTableOutput(ns("table"))
  )
}

#' Annotation table wrapper UI
#'
#' preprocess tables for rendering
#'
#' @param df a dataframe for display, usually a .bed file
#' @param ranges a reactive object to store current plot brush values
#' @param chrn current chromosome number (beware: chr is expected to be a prefix here)
#' 
#'
#' @return reactive df table and reactive downloadhandler
#'
#' @examples
#' anno_table_Server("table", OMIM, ranges, "chr2")
#'
#' @export
anno_table_Server <- function(id, df, ranges, chrn) {
  moduleServer(
    id,
    function(input, output, session) {
      
      gr <- reactive({
        GRanges(seqnames = chrn, ranges = IRanges(ranges$x[1], ranges$x[2]))
      })
      
      
      df_table <- reactive({
        as.data.frame(subsetByOverlaps(as(df,"GRanges"),gr()))
      })
      
      output$table <- renderDataTable({
        df_table()
      })
      
      output$download <- downloadHandler(
        filename = function() {
          paste0(id,".tsv")
        },
        content = function(file) {
          write.table(df, file, sep = "\t", row.names = F, quote = F)
        }
      )
    }
  )
}





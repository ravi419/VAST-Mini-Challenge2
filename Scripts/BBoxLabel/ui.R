#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(shinyFiles)
# library(shinyjs)

# Constants
choice <- NULL # c("default.jpg")

# Define body of UI
dBody <- dashboardBody(
    useShinyjs(),
    box(
        title = "Browse The Path",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        fluidRow(
            column(
                width = 1,
                shinyDirButton(id = "choose__dir", label = "Browse", title = "Upload")
            ),
            column(
                width = 11,
                verbatimTextOutput(outputId = "browsed__dir", placeholder = TRUE)
            )
        )
    ),
    
    hidden(
        div(
            id = "image_details",
            fluidRow(
                box(
                    title = "Image Preview",
                    status = "warning",
                    solidHeader = TRUE,
                    width = 9,
                    imageOutput(
                        outputId = "image__disp",
                        width = "100%",
                        height = "100%"
                    ),
                    fluidRow(
                        column(
                            width = 1,
                            actionButton(inputId = "btn__prev", label = "<< Prev"),
                            tags$style(type = 'text/css', "#btn__prev { margin-top: 10px; }")
                        ),
                        column(width = 8),
                        column(
                            width = 1,
                            offset = 1,
                            actionButton(inputId = "btn__next", label = "Next >>"),
                            tags$style(type = 'text/css', "#btn__next { margin-top: 10px; }")
                        )
                    )
                ),
                
                box(
                    width = 3,
                    fluidRow(
                        box(
                            title = "Images",
                            status = "warning",
                            solidHeader = TRUE,
                            width = 12,
                            selectInput(
                                inputId = 'image__list',
                                label = NULL,
                                choices = choice,
                                multiple = TRUE,
                                selectize = FALSE,
                                size = 4
                            )
                        ),
                        box(
                            title = "Image Details",
                            status = "warning",
                            solidHeader = TRUE,
                            width = 12 #,
                            #verbatimTextOutput(outputId = "imgName"),
                            #verbatimTextOutput(outputId = "imgSize")
                        )
                    )
                )
            )
        )
    )
)

# Define UI for application
shinyUI(dashboardPage(
    dashboardHeader(title = "Bounding Box For Labeling Images", disable = TRUE),
    dashboardSidebar(disable = TRUE),
    dBody
))
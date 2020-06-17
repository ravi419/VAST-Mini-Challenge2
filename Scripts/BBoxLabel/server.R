#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(gtools) # for sorting list.files
library(jpeg) # for readJPEG
library(shinyjs)

# Define the constants
file_types <- c("JPG", "jpg", "JPEG", "jpeg", "PNG", "png", "GIF", "gif")
pattern <- "*.JPG|*.jpg|*.JPEG|*.jpeg|*.PNG|*.png|*.GIF|*.gif"

# Define server logic required
shinyServer(function(input, output, session) {
    shinyDirChoose(
        id = "choose__dir",
        input = input,
        roots = c(home = '~'),
        filetypes = file_types
    )
    
    global <- reactiveValues(data_path = "~", img_list = "", img_csv = "", count = 0)
    
    choose_dir <- reactive(input$choose__dir)
    output$browsed__dir <- renderText({
        global$data_path
    })
    
    # Send a pre-rendered image, and don't delete the image after sending it
    output$image__disp <- renderImage({
        
        # check condition for null values
        if(!is.null(input$image__list)) {
            # Read image__disp's width and height. 
            # These are reactive values, so this expression will re-run whenever they change.
            new_width  <- session$clientData$output_image__disp_width
            # new_height <- session$clientData$output_image__disp_height # height = 0
            
            # For high-res displays, this will be greater than 1
            pixel_ratio <- session$clientData$pixelratio
            
            image_src <- normalizePath(file.path(global$data_path, input$image__list))
            image_res <- dim(readJPEG(image_src, native = FALSE)) # [1:2]
            
            img_name <- unlist(strsplit(input$image__list, split = '.', fixed = TRUE))[1]
            print(paste("Name: ", img_name))
            print(paste("Size: ", image_res[1], " X ", image_res[2]))
            
            # Return a list containing the filename and alt text
            list(
                src = image_src,
                width = new_width,
                pixelratio = 100*pixel_ratio,
                alt = paste("Image number", input$image__list)
            )
        }
        else {
            image_src <- normalizePath(file.path(getwd(), "default.jpg"))
            
            list(
                src = image_src,
                alt = "Default Image is displayed"
            )
        }
    }, deleteFile = FALSE)
    
    observeEvent(
        ignoreNULL = TRUE,
        eventExpr = {
            input$choose__dir
        },
        handlerExpr = {
            if (!"path" %in% names(choose_dir()))
                return()
            home <- normalizePath("~")
            
            temp_data_path <-
                file.path(home, paste(unlist(choose_dir()$path[-1]), collapse = .Platform$file.sep))
            temp_img_list <-
                mixedsort(list.files(path = temp_data_path, pattern = pattern))
            temp_img_csv <- mixedsort(list.files(path = temp_data_path, pattern = "csv"))
            
            updateSelectInput(
                session = session,
                inputId = "image__list",
                choices = temp_img_list,
                selected = temp_img_list[1] # selected = head(temp_img_list, 1)
            )
            
            # set the global variables
            global$data_path <- temp_data_path
            global$img_list <- temp_img_list
            global$img_csv <- temp_img_csv
            global$count <- length(temp_img_list)
            
            
            if(global$count > 0) {
                show(id = "image_details", anim = TRUE)
                disable(id = "btn__prev")
            }
        }
    )
    
    observeEvent(input$btn__prev, {
        image_index = match(input$image__list, global$img_list)
        if(image_index > 1) {
            image_index = image_index - 1
            updateSelectInput(
                session = session,
                inputId = "image__list",
                selected = global$img_list[image_index]
            )
            if(image_index == (global$count - 1))
                enable(id = "btn__next")
        }
        
        if(image_index == 1)
            disable(id = "btn__prev")
    })
    
    observeEvent(input$btn__next, {
        image_index = match(input$image__list, global$img_list)
        if(image_index < global$count) {
            image_index = image_index + 1
            updateSelectInput(
                session = session,
                inputId = "image__list",
                selected = global$img_list[image_index]
            )
            
            if(image_index == 2) {
                enable(id = "btn__prev")
            }
        }
        
        if(image_index == global$count) {
            disable(id = "btn__next")
        }
    })
})
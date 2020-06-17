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

# Define variables
image_index <- 0
image_count <- 0

# Define server logic required
shinyServer(function(input, output, session) {
    shinyDirChoose(
        id = "choose__dir",
        input = input,
        roots = c(home = '~'),
        filetypes = file_types
    )
    
    global <- reactiveValues(data_path = "~", img_list = "")
    
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
            
            # Return a list containing the filename and alt text
            list(
                src = image_src,
                width = new_width,
                pixelratio = 100*pixel_ratio,
                alt = paste("Image number", input$image__list)
            )
        }
        else {
            new_width  <- session$clientData$output_image__disp_width
            pixel_ratio <- session$clientData$pixelratio
            image_src <- normalizePath(file.path(getwd(), "default.jpg"))
            image_res <- dim(readJPEG(image_src, native = FALSE)) # [1:2]
            
            list(
                src = image_src,
                width = new_width,
                pixelratio = 100*pixel_ratio,
                alt = paste("Image number", input$image__list)
            )
            
            # print("No image to be displayed")
            # return(NULL)
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
            
            image_count <- length(temp_img_list)
            
            updateSelectInput(
                session = session,
                inputId = "image__list",
                choices = temp_img_list,
                selected = temp_img_list[1] # selected = head(temp_img_list, 1)
            )
            
            # set the global variables
            global$data_path <- temp_data_path
            global$img_list <- temp_img_list
            
            
            if(image_count > 0)
                show(id = "image_details", anim = TRUE)
            
            
        }
    )
    
    observeEvent(input$btn__prev, {
        print("hello")
        image_index = match(input$image__list, global$img_list)
        print(image_index)
    })
    
    observeEvent(input$btn__next, {
        print("Hiii")
        image_index = match(input$image__list, global$img_list)
        print(image_index)
    })
})
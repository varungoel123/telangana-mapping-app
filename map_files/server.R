library(shiny)
library(RPostgreSQL)
library(maptools)
library(RColorBrewer)
library(dplyr)
#library(rgeos)
library(dplyr)
library(magrittr)
library(classInt)
library(scales)


#library(rgdal)
#library(reshape2)


#ls07var<-read.csv("dd_livestock_2007.csv",stringsAsFactors = F)
#ls07var$Variable %<>% tolower()

#varlist<-dir(path= "./data",pattern = "dd",full.names = T) ## list of table wise variables with descriptions
#varlist %<>% as.list() %>% lapply(read.csv,stringsAsFactors = F)
tablist <- read.csv("./data/dataset_lookup.csv",stringsAsFactors = F)
#image_name = NA

#names(varlist) <- tablist$table_var

## Postgresql database details
source("./db_details.R")

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

# load shapefile in R workspace
distshp <- readShapePoly("./data/telangana_dist2011.shp",
                         proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
state_line <- readShapeLines("./data/telangana_state2011.shp",
                             proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
distlabels=c("Adilabad","Hyderabad","Karimnagar","Khammam","Mahbubnagar","Medak","Nalgonda","Nizamabad","Rangareddy","Warangal")
#print(names(tablist))

shinyServer(function(input, output, session) {
  
  ## populate dataset names  
  output$choose_dataset <- renderUI({
    if(!is.null(tablist)){
      
      print(tablist)
      selectizeInput("table_name",
                     label = "Choose DataSet",
                     choices = tablist$description,
                     selected = tablist$description[1] ,
                     multiple = FALSE,
                     options = NULL)
    }
    
  })
  
  
  
  #  
  #
  #dbDisconnect(con)
  ## reactive function to populate variables
  read_hierarchy <- reactive({
    
    if(is.null(input$table_name)) return(NULL)
    validate(
      need(input$table_name != "", "Please select a data set")
    )
    cust_query1 <- paste("select level_code,level_description,var_code,var_description from hierarchy_lookup_",
                         tablist$code[tablist$description==input$table_name],
                         sep=""
    )
    con <- dbConnect(drv, dbname = dbname,
                     host = host, port = 5432,
                     user = username, password = pw)
    varlist <- dbGetQuery(con, cust_query1,stringsAsFactors=T) %>% filter(
      level_code!="state_code")
    dbDisconnect(con)
    print(varlist[1,])
    return(varlist)
  })
  
  #   
  #   #   observe({
  #   #   if(is.null(read_hierarchy())) return(NULL)
  #   #     level_dat<-distinct(read_hierarchy()[,1:2])
  #   #     for ( i in seq(level_dat[,1])){
  #   #       level_name <- level_dat[i,2]
  #   #       level_val <- level_dat[i,1]
  #   #       output[[level_val]] <- renderUI({
  #   #         if(is.null(read_hierarchy())) return(NULL)
  #   #         selectizeInput(level_val,
  #   #                        label = paste("Choose",level_name,sep=" "),
  #   #                        choices = filter(read_hierarchy(), level_code == level_val) %>% select(var_description),
  #   #                        selected = (filter(read_hierarchy(), level_code == level_val) %>% select(var_description))[1],
  #   #                        multiple = FALSE,
  #   #                        options = NULL)
  #   #       })
  #   #     }
  #   #   })
  #   
#   #   #### another way
#   #   
  output$choose_hierarchy <- renderUI({
    if(is.null(read_hierarchy())) return(NULL)
    # print(read_hierarchy()[1,])
    level_dat<-distinct(read_hierarchy()[,1:2])
    #print(level_dat)
    n <- nrow(level_dat)
    #print(n)
    if(n>0){
      LL <- vector("list",n)        
      for(i in seq(n)){
        level_name <- level_dat[i,2]
        level_val <- level_dat[i,1]
        LL[[i]] <- list( selectizeInput(level_val,
                                        label = paste("Choose",level_name,sep=" "),
                                        choices = filter(read_hierarchy(), level_code == level_val) %>% select(var_description),
                                        selected = (filter(read_hierarchy(), level_code == level_val) %>% select(var_description))[1],
                                        #selected = "ALL",
                                        multiple = FALSE,
                                        options = NULL)
                         
        )
      }       
      return(LL)
    }
  })
  #   
  read_variable <- reactive({
    if(is.null(input$table_name)) return(NULL)
    cust_query <- paste("select code, description from variables_",
                        tablist$code[tablist$description==input$table_name],
                        sep=""
    )
    con <- dbConnect(drv, dbname = dbname,
                     host = host, port = 5432,
                     user = username, password = pw)
    varlist<-dbGetQuery(con, cust_query,stringsAsFactors=T)
    dbDisconnect(con)
    return(varlist)
  })
  #   
  output$choose_var <- renderUI({
    #if()
    if(is.null(read_variable())) return(NULL)
    # print(read_variable()[1,])
    selectizeInput("table_var",
                   label = "Choose Variable",
                   choices = read_variable()[,2],
                   selected = read_variable()[1,2],
                   multiple = FALSE,
                   options = NULL)
  })
#   #   
  output_query <- reactive({
    if(is.null(input$table_name)) return(NULL)
    if(is.null(input$table_var)) return(NULL)
    if(is.null(read_variable())) return(NULL)
    if(identical(read_variable()[which(read_variable()[2] == input$table_var),1],
                 character(0))) return()
    #print(paste(input$table_var,"ss"))
    # print(read_variable()[which(read_variable()[2] == input$table_var),1])
    
    main_query <- paste0("select district_code, state_code, ", 
                         read_variable()[which(read_variable()[2] == input$table_var),1],
                         " from ", tablist$code[tablist$description==input$table_name])
    
    # main_query = "ddddd"
    if(is.null(read_hierarchy())) return(NULL)
    where_lev <- distinct(read_hierarchy()[1])
    nwhere <- length(where_lev[,1])
    
    if(nwhere == 0) output_string <- main_query
    else{
      # print(read_hierarchy())
      wherestr <- vector("character",nwhere)
      for (i in seq(nwhere))
      {
        where_querystring <- paste("input",where_lev[i,],sep="$")
        # print(eval(parse(text = where_querystring )))
        wherestr[i] <- paste0(where_lev[i,]," = ",
                              read_hierarchy()[which(read_hierarchy()[4]==eval(parse(text = where_querystring ))),3])
        
      }
      
      ext_query <- paste0(" where ",paste0(wherestr,collapse = " AND "))
      output_string <- paste0(main_query,ext_query)
    }
    #print(output_string)
    return(output_string)
  })
  #   
  #   output$samptext <- renderText({
  #     if(is.null(output_query())) return (NULL)
  #     paste(output_query())
  #     print(output_query())
  #     a<-dbGetQuery(con, output_query(),stringsAsFactors=T)
  #     paste("rows = ",nrow(a))
  #     #print(names(a))
  #   })
  
  output$choose_classes <- renderUI({
    
    numericInput("no_classes",
                 label = "Choose Classes",
                 value = 5,
                 min = 2,
                 max = 5,
                 step=1)
  })
#   
  output$break_type <- renderUI({
    #input$goButton
    # isolate({
    selectizeInput("type_breaks",
                   label = "Choose classification method",
                   choices = c("equal","quantile","jenks"),
                   selected = "jenks",
                   multiple = FALSE,
                   options = NULL)
    # })
    
  }) 
#   
  output$choose_col <- renderUI({
    selectizeInput("col_type",
                   label = "Choose color scheme",
                   choices = c("Blues","Greens","Greys","Oranges","Purples","Reds"),
                   selected = "Oranges",
                   multiple = FALSE,
                   options = NULL
    ) 
  })
#   
  plotmap <- function(){
    if(is.null(input$table_name)) return()
    if(is.null(input$table_var)) return()
    
    con <- dbConnect(drv, dbname = dbname,
                     host = host, port = 5432,
                     user = username, password = pw)
    
    
    a<-dbGetQuery(con, output_query(),stringsAsFactors=T)
    print(a)
    #       dbDisconnect(con)
    #       
    #       
    org_dat<- distshp@data
    names(distshp@data)[1] <- names(a)[1]
    distshp@data %<>% left_join(a)
    #       
    plotvar <- distshp@data[,3]
    # print(plotvar)
    nclr <- input$no_classes
    if(is.null(input$col_type)) return(NULL)
    plotclr <- brewer.pal(nclr,input$col_type)
    #       
    #       if(input$type_breaks == "fixed"){
    #         isolate({
    #           class <- classIntervals(plotvar, nclr, style = "fixed",
    #                                   fixedBreaks = eval(parse(text = paste0("c(",paste("input$class",1:(nclr+1),sep="",collapse = ","),")"))))
    #         })
    #       } else {
    class <- classIntervals(plotvar, nclr, style = input$type_breaks)
    #       }
    #       
    colcode <- findColours(class, plotclr)
    plot(distshp,xlim = distshp@bbox[1,], ylim = distshp@bbox[2,],col=alpha(colcode,1), border="black",lwd=0.5)
    plot(state_line,col="black",lwd=1, add=TRUE)
    text(coordinates(distshp)[,1],coordinates(distshp)[,2],distlabels, cex=0.75)
    title(main=input$table_var, 
          sub=input$table_name)
    
    image_name <<- names(distshp@data)[3]
    #print(image_name)
    legend("bottomleft", legend=names(attr(colcode, "table")), 
           fill=attr(colcode, "palette"), cex=1, bty="n")
    distshp@data = org_dat
    cons <- dbListConnections(drv)
    for(con in cons)  dbDisconnect(con)
    
  }
  #print(image_name)
  
  output$map <- renderPlot({
    input$goButton
    if (input$goButton == 0)
      return()
    output$plotDone <<- renderUI({tags$input(type="hidden", value="TRUE")})
    isolate({
      validate(
        need(input$table_name != "", "Please select a data set")
      )
      validate(
        need(input$table_var != "", "Please select a variable")
      )
      validate(
        need(input$type_breaks != "", "Please choose a classification type")
      )
      validate(
        need(input$col_type != "", "Please choose a color scheme")
      )
      plotmap()
      
    })
  },height = 800,width = 650, units = "px")
  #   
  
  output$downloadPlot2 <- downloadHandler(
    filename = function(){
      paste0(image_name,".png")
    },
    content = function(file) {
      png(file,width = 1000,res = 300)
      print(plotmap())
      dev.off()
    })
  
  
})

## level_code == varcode && level_code ==varcode
####

###specify mapping parameters such as breaks integers etc


## disconnect all existing connections (max is 16)



### check for multiple unnecessary instances
# e.g read_hierarchy is called twice , extra with choose_variable (remove is.null check ?)
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#


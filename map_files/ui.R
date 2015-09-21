shinyUI(fluidPage(
  tags$style(type='text/css', ".selectize-input { font-size: 12px; line-height: 12px;} 
             .selectize-dropdown { font-size: 12px; line-height: 12px; }"),
  fluidRow(
    column(4,
           wellPanel(
             uiOutput("choose_dataset"),
             uiOutput("choose_var"),
             uiOutput("choose_hierarchy")
            # uiOutput("samptext")
           ),
           fluidRow(
             column(12,
                    wellPanel(
                      uiOutput("break_type"),
                      uiOutput("choose_classes"),
                      uiOutput("choose_col")
                    ))),
           fluidRow(
             column(12, 
                    wellPanel(
                      #uiOutput(),
                      actionButton("goButton", "Generate Map"),
                      uiOutput('plotDone')
                    ),
                    
                    conditionalPanel("output.plotDone",wellPanel(
                      downloadButton('downloadPlot2', 'Download')))
                    
             )
           )
    )
    ,
    column(8,
           
           plotOutput("map"))
  )
  ))
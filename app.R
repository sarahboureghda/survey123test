list.of.packages <- c("shiny", "DT", "ggplot2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(shiny)
library(DT)
library(ggplot2)

# UI ----------------------------------------------------------------

ui <- fluidPage(
  titlePanel("Résultats test"),

  # Output tableau
  DTOutput("table_df3"),
  
  br(),
  
  # Output graphique
  plotOutput("graphique_nombre", height = "400px")
)

# Server --------------------------------------------------------------

server <- function(input, output, session) {
  
  # Lit le fichier à toutes les 10 sec
  data <- reactiveFileReader(
    intervalMillis = 10000,
    session,
    filePath = "data/donnees_pretes.rds",
    readFunc = readRDS
  )
  
  # Output du dt
  output$table_df3 <- renderDT({
    req(data())
    datatable(data()$df3)
  })
  
  # Output graphique
  output$graphique_nombre <- renderPlot({
    req(data())
    ggplot(data()$df3, aes(x = Date, y = Nombre, color = Salutations)) +
      geom_point(size = 3) +
      geom_line(aes(group = Salutations), alpha = 0.4) +
      labs(
        x = "Date",
        y = "Nombre"
      ) +
      theme_minimal()
  })
}

# Run --------------------------------------------------------------
shinyApp(ui, server)

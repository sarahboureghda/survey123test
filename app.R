list.of.packages <- c("shiny", "DT", "ggplot2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(shiny)
library(DT)
library(ggplot2)
library(httr)

# ---- UI ----------------------------------------------------------------

ui <- fluidPage(
  titlePanel("Résultats test"),

  DTOutput("table_df3"),

  br(),

  plotOutput("graphique_nombre", height = "400px")
)

# ---- SERVER --------------------------------------------------------------

server <- function(input, output, session) {

  # Lit les données depuis GitHub (dépôt privé), avec authentification
  # via token, et se rafraîchit automatiquement toutes les 30 secondes.
  data <- reactive({
    invalidateLater(30000, session)

    github_pat <- Sys.getenv("GITHUB_PAT")  # lu depuis les variables d'environnement

    url_rds <- "https://raw.githubusercontent.com/sarahboureghda/survey123test/main/data/donnees_pretes.rds"
    temp <- tempfile(fileext = ".rds")

    GET(
      url_rds,
      add_headers(Authorization = paste("token", github_pat)),
      write_disk(temp, overwrite = TRUE)
    )

    readRDS(temp)
  })

  output$table_df3 <- renderDT({
    req(data())
    datatable(data()$df3)
  })

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


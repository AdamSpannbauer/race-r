library(shiny)
# library(shinythemes)
library(shinycssloaders)
library(bslib)
library(plotly)

ui <- fluidPage(
  theme = bslib::bs_theme(preset = "darkly"),
  # theme = shinytheme("darkly"),
  prismDependencies,
  tags$head(
    includeHTML("www/meta-tags.html"),
    tags$link(rel = "shortcut icon", href = "favicon.ico"),
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "style.css"
    ),
    tags$script(HTML('
      $(document).ready(function() {
        Shiny.addCustomMessageHandler("focusInput", function(inputId) {
          $("#" + inputId).focus();
        });
      });
    '))
  ),
  fluidRow(
    column(
      width = 8,
      offset = 2,
      align = "center",
      img(src = "./full-title-logo.png", width = "50%"),
      br(),
      hr(),
      h1(textOutput("timer"), style = "font-size: 9rem; font-weight: bold;"),
      uiOutput("progress_bar"),
      wellPanel(
        div(
          align = "left",
          withSpinner(
            uiOutput("prompt"),
            type = 2,
            color = "#EEBC47",
            color.background = "#657DB4",
            proxy.height = "100px"
          ),
          textInput(
            inputId = "answer_box",
            label = "R!",
            placeholder = "R!"
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          align = "center",
          actionButton(
            inputId = "start_btn",
            label = "(re)Start!",
            icon = icon("face-laugh-beam"),
            class = "btn btn-primary"
          ),
          actionButton(
            inputId = "stop_btn",
            label = "Stop...",
            icon = icon("face-meh"),
            class = "btn btn-secondary"
          ),
          bslib::tooltip(
            actionButton(
              inputId = "intructions_btn",
              label = "How to play!",
              icon = icon("circle-question"),
              class = "btn btn-warning"
            ),
            includeMarkdown("www/instructions.md"),
            placement = "top"
          ),
          uiOutput("leadboard_name_input")
        )
      ),
      hr(),
      uiOutput("leaderboard_ui"),
      div(
        align = "center",
        tags$h4(
          tags$a(
            href = "https://github.com/AdamSpannbauer/raceR",
            target = "_blank",
            "Contribute code, prompts, and terms on",
            icon("github"),
            "Github!!"
          )
        )
      ),
      br()
    ),
  )
)

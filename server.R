library(shiny)
library(plotly)

server <- function(input, output, session) {
  # game state
  RV <- reactiveValues(
    run_timer = FALSE,
    start_time = Sys.time(),
    elapsed_time = Sys.time() - Sys.time(),
    current_problem = list(
      prompt = "\t# Code snippets with blanks (░░░░░) will appear below\n\t# Type out the correct code to fill in the ░░░░░\n\t# Press (re)Start to begin",
      answer = NA_character_
    ),
    n_correct = 0,
    terms = c(),
    leaderboard = if (HAS_SHEETS_CONNECTION) read_scores(GSHEETS) else NULL
  )

  observeEvent(input$start_btn, {
    RV$run_timer <- TRUE
    RV$start_time <- Sys.time()
    RV$elapsed_time <- Sys.time() - RV$start_time
    RV$current_problem <- sample_problem(ALL_PROBLEMS)
    RV$n_correct <- 0
    RV$terms <- c()

    # Place cursor in the answer box when start button is clicked
    session$sendCustomMessage(type = "focusInput", message = "answer_box")
  })

  observeEvent(input$stop_btn, {
    RV$run_timer <- FALSE
  })

  observeEvent(input$answer_box, {
    req(RV$run_timer)
    correct <- check_answer(input$answer_box, RV)

    if (isTRUE(correct)) {
      RV$terms[length(RV$terms) + 1] <- RV$current_problem$answer
      RV$n_correct <- RV$n_correct + 1
      updateTextInput(session, inputId = "answer_box", value = "")


      if (RV$n_correct >= WINNING_NUMBER) {
        RV$run_timer <- FALSE
        RV$current_problem <- list(
          prompt = "DONE!",
          answer = NA
        )
        if (HAS_SHEETS_CONNECTION) {
          player_name <- trimws(input$player_name)
          if (player_name == "Enter name for leaderboard" | player_name == "") {
            player_name <- "Anonymous"
          }
          store_record(GSHEETS, game_state = RV, name = player_name)
          RV$leaderboard <- read_scores(GSHEETS)
        }
      } else {
        RV$current_problem <- sample_problem(ALL_PROBLEMS)
      }
    }
  })

  observe({
    invalidateLater(100)
    running <- isolate(RV$run_timer)

    if (running) {
      start_time <- isolate(RV$start_time)
      RV$elapsed_time <- Sys.time() - RV$start_time
    }
  })

  output$timer <- renderText({
    sprintf("%.1f", abs(as.numeric(RV$elapsed_time, units = "secs")))
  })

  output$progress_bar <- renderUI({
    value <- 100 * (RV$n_correct / WINNING_NUMBER)

    sliderInput(
      inputId = "progress_bar",
      label = "",
      min = 0,
      max = 100,
      value = value,
      step = 1,
      ticks = FALSE
    )
  })

  output$prompt <- renderUI({
    req(RV$current_problem$prompt)

    prismCodeBlock(RV$current_problem$prompt)
  })

  output$leadboard_name_input <- renderUI({
    req(HAS_SHEETS_CONNECTION)

    textInput(
      inputId = "player_name",
      label = "Before you start!",
      value = "",
      placeholder = "Enter name for leaderboard"
    )
  })

  output$leaderboard_dt <- renderTable(
    {
      req(HAS_SHEETS_CONNECTION)

      lb <- RV$leaderboard
      lb$Time <- sprintf("%.1f", lb$finish_time)
      lb$Name <- lb$name

      rownames(lb) <- NULL
      lb <- lb[, c("Name", "Time")]
    },
    rownames = TRUE,
    striped = TRUE,
    bordered = TRUE
  )

  output$scores_dist_plot <- renderPlotly({
    req(HAS_SHEETS_CONNECTION)

    RV$run_timer
    plot_scores(GSHEETS)
  })

  output$leaderboard_ui <- renderUI({
    req(HAS_SHEETS_CONNECTION)

    fluidRow(
      column(
        width = 6,
        h4("Leaderboard"),
        tableOutput("leaderboard_dt")
      ),
      column(
        id = "plotly_time_dist",
        width = 6,
        plotlyOutput("scores_dist_plot")
      ),
      hr()
    )
  })
}

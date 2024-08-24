library(shiny)
library(shinythemes)
library(shinycssloaders)
library(shinydashboard)
library(htmltools)
library(bslib)

library(markdown)
library(DT)

library(googledrive)
library(googlesheets4)

library(plotly)

source("helpers/prompt_helpers.R")
source("helpers/progress_bar.R")
source("helpers/leaderboard.R")
source("helpers/syntax_highlighting.R")

# ------------------------------------------------------------------------
# Where's the data
QUIZ_TERMS_FILE <- "study_terms.txt"
QUIZ_QUERIES_FILE <- "study_snippets_dplyr_caps.txt"
QUIZ_QUERIES_FILE_DELIM <- "*********************************"

# How many prompts per round?
WINNING_NUMBER <- 10
# ------------------------------------------------------------------------

generated_problems <- gen_problems(QUIZ_TERMS_FILE, QUIZ_QUERIES_FILE, QUIZ_QUERIES_FILE_DELIM)
# generated_problems$term_counts # see number of prompts by term
ALL_PROBLEMS <- generated_problems$problems

GSHEETS <- NULL
HAS_SHEETS_CONNECTION <- FALSE

if (dir.exists(".secrets")) {
  tryCatch(
    expr = {
      timeout_seconds <- 2
      setTimeLimit(elapsed = timeout_seconds, transient = TRUE)
      setup_gsheets_auth()
      GSHEETS <<- read_scores_sheets()
    },
    error = function(e) {},
    finally = {
      setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
    }
  )
}

HAS_SHEETS_CONNECTION <- !is.null(GSHEETS)

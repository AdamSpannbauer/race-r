library(shiny)
library(shinythemes)
library(shinycssloaders)
library(shinydashboard)
library(htmltools)

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
QUIZ_QUERIES_FILE <- "study_snippets.txt"
QUIZ_QUERIES_FILE_DELIM <- "*********************************"

# How many prompts per round?
WINNING_NUMBER <- 10
# ------------------------------------------------------------------------

ALL_PROBLEMS <- gen_problems(QUIZ_TERMS_FILE, QUIZ_QUERIES_FILE, QUIZ_QUERIES_FILE_DELIM)

HAS_SHEETS_CONNECTION <- FALSE

# TODO: make leaderboard work
# GSHEETS <- NULL
# if (dir.exists(".secrets")) {
#   tryCatch(
#     expr = {
#       setup_gsheets_auth()
#       GSHEETS <<- read_scores_sheets()
#     },
#     error = function(e) {}
#   )
# }
#
# HAS_SHEETS_CONNECTION <- !is.null(GSHEETS)

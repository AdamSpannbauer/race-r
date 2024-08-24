parse_terms_file <- function(file_path) {
  terms <- readLines(file_path)
  trimws(terms, which = "right")
}


parse_query_file <- function(file_path, query_delim) {
  all_query_lines <- readLines(file_path)
  query_id <- cumsum(all_query_lines == query_delim)
  split_query_lines <- split(all_query_lines, query_id)

  # Drop first - contributing instructions
  # Drop last - should be nothing unless entry error
  split_query_lines <- head(split_query_lines, -1)
  split_query_lines <- tail(split_query_lines, -1)

  vapply(split_query_lines, function(q_lines) {
    # rm delim and blanks
    q_lines <- q_lines[q_lines != query_delim]
    q_lines <- q_lines[trimws(q_lines) != ""]

    # make single multi-line string
    paste(q_lines, collapse = "\n")
  }, character(1))
}

gen_problems <- function(quiz_words_file = "study_terms.txt",
                         quiz_queries_file = "study_snippets.txt",
                         query_delim = "*********************************",
                         blank_char = "░") { # ▒░
  terms <- parse_terms_file(quiz_words_file)
  queries <- parse_query_file(quiz_queries_file, query_delim)

  problems <- list()
  term_counts <- list()
  for (term in terms) {
    term_uses <- 0
    for (query in queries) {
      term_in_query <- grepl(term, query, fixed = TRUE)
      if (!term_in_query) next
      term_uses <- term_uses + 1

      blank <- gsub(".", blank_char, term)
      query_w_blanks <- gsub(term, blank, query, fixed = TRUE)

      if (term == "sum" & grepl("░░░mar", query_w_blanks)) next

      problem <- list(
        prompt = query_w_blanks,
        answer = term
      )

      problems[[length(problems) + 1]] <- problem
    }
    term_counts[[term]] <- term_uses
    if (term_uses == 0) {
      message(paste0("term `", term, "` is not used.\n"))
    }
  }

  term_counts_df <- data.frame(term = names(term_counts), count = as.numeric(term_counts))
  term_counts_df <- term_counts_df[order(term_counts_df$count), ]
  return(list(problems = problems, term_counts = term_counts_df))
}


sample_problem <- function(problems) {
  i <- sample(length(problems), size = 1)
  problem <- problems[[i]]

  return(problem)
}


SPECIAL_CASE_ANSWERS <- list(
  "summarise" = \(guess, answer) {
    guess %in% c("summarise", "summarize")
  }
)

check_answer <- function(user_input, game_state) {
  s1 <- user_input
  s2 <- game_state$current_problem$answer

  if (s2 %in% names(SPECIAL_CASE_ANSWERS)) {
    special_checker <- SPECIAL_CASE_ANSWERS[[s2]]

    is_correct <- special_checker(s1, s2)
  } else {
    is_correct <- s1 == s2
  }

  return(is_correct)
}

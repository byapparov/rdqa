library(DBI)


#' Functions logs data.table with incrorrect records to the database
#' @import DBI
#'
#' @param conn DBI connection
#' @param source name of the source system that contains incorrect record
#' @param type type of the error should be one of those: Orphan, Wrong, Missing, Duplicate
#' @param rule business rule that record violated
#' @param refs correlation references of records, e.g. primary key values
#' @param values wrong values
#' @param url.pattern sprintf pattern for the url which will be used with refs
#' @return TRUE if records are saved successfuly
logWrongValues <- function(conn, source, type, rule, refs, values, url.pattern = NA_character_) {

  date <- Sys.time()
  refs <- as.character(unlist(refs))
  values <- as.character(unlist(values))

  # Generate urls for the error records if pattern is available
  if (is.na(url.pattern)) {
    urls <- rep(NA_character_, length(values))
  }
  else {
    urls <- sprintf(url.pattern, refs)
  }

  dqa.records <- data.frame(date = date,
                            source = source,
                            type = type,
                            rule = rule,
                            ref = refs,
                            value = values,
                            url = urls)

  colnames(dqa.records) <- c(
    "date",
    "source",
    "type",
    "rule",
    "ref",
    "value",
    "url"
  )
  dbWriteTable(conn, "errors", dqa.records, append = TRUE)
}

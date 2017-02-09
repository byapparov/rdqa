library(DBI)


#' Functions logs data.table with incrorrect records to the database
#'
#' @param conn DBI connection
#' @param source name of the source system that contains incorrect record
#' @param type type of the error should be one of those: Orphan, Wrong, Missing, Duplicate
#' @param rule business rule that record violated
#' @param refs correlation references of records, e.g. primary key values
#' @param values wrong values
#' @param urls vector of urls to an object in the system, if not provided defaulted to NAs
#' @return TRUE if records are saved successfuly
logWrongValues <- function(conn, source, type, rule, refs, values, urls = rep(NA, length(values))) {

  date <- Sys.time()
  dqa.records <- data.frame(cbind(date = date,
                                  source = source,
                                  type = type,
                                  rule = rule,
                                  ref = refs,
                                  value = values,
                                  url = urls))
  colnames(dqa.records) <- c("date", "source", "type", "rule", "ref", "value", "url")
  dbWriteTable(conn, "errors", dqa.records, append = TRUE)
}


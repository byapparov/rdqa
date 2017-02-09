library(data.table)

setClass("DataRule", representation(name = "character",
                                      ref = "character", 
                                      type = "character")
         )

setGeneric("validate", function(rule, dt) standardGeneric("validate"))

setMethod("validate", signature("DataRule", "data.table"), function(rule, dt) {
  warning("This section of code should not run") 
  return(TRUE)
})

setClass("RecordRule", contains = "DataRule")
setClass("FieldRule", contains = "DataRule", representation(field = "character"))
setClass("ForeignKeyRule", contains = "FieldRule")
setClass("PrimaryKeyRule", contains = "RecordRule")

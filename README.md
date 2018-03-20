[![Build Status](https://travis-ci.org/byapparov/rdqa.svg?branch=master)](https://travis-ci.org/byapparov/rdqa)
[![codecov.io](https://codecov.io/github/byapparov/rdqa/coverage.svg?branch=master)](https://codecov.io/github/byapparov/rdqa?branch=master)

Data Quality package simplifies data validation and logging of errors to the database.

## Metadata Schema

Field | Suggested Type | Description
------------ | ------------- | -------------
Date | Timestamp | Time when error was logged
Source | String | Data source of the issue
Type | String | Type of the issue (enum)
Value | String | Value that contains the problem
URL | String | Link to the source record


## Error types

Type | Description
------ | ----------
Orphan | Foreign key does not match the primary key
Wrong | Value does not match the business rule
Missing | Value in the field is empty
Duplicate | Duplicated record


## Example

### Code

```R

library(rdqa)
# Defining the rules - here we don't need the data yet
r.smaller <- newConditionRule("small", condition = "< big")
r.unique <- newUniqueRule("big")
r.name.required <- newRequiredRule("name")

# Combine the rules in Rules Container
all.rules <- newRulesContainer("test.data.td", r.smaller, r.unique, r.name.required)

# Connect to the db where we want to log the results
conn <- dbConnect(dbDriver("SQLite"), "demo.db")

# We only need data just before the validation
dt <- data.table(id = c(1, 2, 3, 4, 5),
                 small = c(1, 10, 2, 3, 4),
                 big = c(10, 1, 20, 20, 40),
                 name = c("a", "", "c", "d", NA_character_),
                 key = "id")

# This call will validate the data againt all three rules
# and log results to the database
validateRules(conn, all.rules, dt)

# Check what we have in the errors table
res <- dbGetQuery(conn, "SELECT * FROM errors")


```

### Expected result

 date    |  source  | type |  rule | ref | value | url
-------- | -------- |----- | -------------------------- | --- | ----- | --------------------------
 1486681846 | test.data.td | Condition | Field [small] should matrch condition: < big |2|2|NA
 1486685164 | test.data.td | Unique | Field(s) big should be uqniue   | 4   |  4  | NA
 1486685164 | test.data.td | Required | Field [name] should ont be empty  | 2  |   2  | NA
 1486685164 | test.data.td | Required | Field [name] should ont be empty  | 5  |   5  | NA


### Defining rules through Schema object

Schema object allows to define rules in a more readable layout with rules seating inside the data structure:

```R

# Lets say we want to define rules for customer data, here is a sample schema:

schema.customers <- Schema(
"customer.data",
  schema = list(
    list(
      name = "id",
      description = "This is an integer primary key for our customer table",
      class = "integer", 
      required = TRUE,
      unique = TRUE
    ),
    list(
      name = "name",
      class = "character",
      regex = "\\w"
    ),
    list(
      name = "gender",
      class = "character",
      enum = c("male", "female")
    )
  ),
  rules = list(
    newConditionRule("id", "> 0"),
    newConditionRule("name", condition = expression(nchar(name) < 12))
  )
) 

# These are our customers:
customers <- data.table(
  id = c(1L, 2L, NA_integer_, 3L, 4L, -1L),
  name = c("John", "Isabellarose", "Anna", "Bob", NA_character_, ""),
  gender = c("male", "other", "female", "female", "male", "male"),
  key = "id"
)

# We need to connect to our meta database with [errors] table in it:
conn <- dbConnect(dbDriver("SQLite"), "test.db") # makes a new file

# Validate rules and log problems
errors <- validateRules(conn, schema.customers, customers)
print(errors)

# Lets check what is the errors table
res <- dbGetQuery(conn, "SELECT * FROM errors")
dbDisconnect(conn)
   
print(res)

```
This what will be logged into the errors table for this example:

 date    |  source  | type |  rule | ref | value | url
-------- | -------- |----- | -------------------------- | --- | ----- | --------------------------
1521504963 | customer.data | Condition |                Field [id] should match condition: > 0 | -1 | -1 | NA
1521504963 | customer.data | Condition | Field [name] should match condition: nchar(name) < 12 | 2 | Isabellarose | NA
1521504963 | customer.data | Required |                       Field [id] should not be empty | NA | NA | NA
1521504963 | customer.data |     Regex |               Field [name] should matrch pattern \\w | -1 |     | NA
1521504963 | customer.data |     Enum  |   Field [gender] should should be one of enum values |  2 |  other | NA

This specification can be used within ETL or data import procedure to identify records with erros. 

It will also raise error if column names or types don't match the schema. You can also stop execution based on the records in `errors` ouput. e.g.:

```R
assert_that(nrow(errors) == 0)
```

Once you have schemas set up for your data processes it is quite easy to add monitoring suite using `errors` table.

[![Build Status](https://travis-ci.org/byapparov/rdqa.svg?branch=master)](https://travis-ci.org/byapparov/rdqa)
[![codecov.io](https://codecov.io/github/byapparov/rdqa/coverage.svg?branch=master)](https://codecov.io/github/byapparov/rdqa?branch=master)

Data Quality package allows logging of errors to the database with predefined schema.


## Schema

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

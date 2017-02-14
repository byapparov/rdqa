library(rdqa)
library(data.table)
library(RSQLite)

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

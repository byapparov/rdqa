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

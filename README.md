Data Quality package allows logging of errors to the database with predefined schema.


## Schema

Field | Suggested Type | Description
------------ | ------------- | -------------
Date | Timestamp | Time when error was logged
Source | String | Data source of the issue
Type | String | Type of the issue (enum)
Value | String | Value that contains the problem
URL | String | Link to the source record

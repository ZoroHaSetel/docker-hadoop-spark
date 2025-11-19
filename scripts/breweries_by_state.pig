-- Sample Pig script for processing breweries data
-- This script groups breweries by state and counts them

-- Load the breweries CSV file from HDFS
breweries = LOAD '/data/openbeer/breweries/breweries.csv' 
            USING PigStorage(',') 
            AS (id:int, name:chararray, city:chararray, state:chararray);

-- Remove the header row (id will be a chararray for the header)
breweries_filtered = FILTER breweries BY id > 0;

-- Group breweries by state
by_state = GROUP breweries_filtered BY state;

-- Count breweries per state
state_counts = FOREACH by_state GENERATE group as state, COUNT(breweries_filtered) as count;

-- Sort by count descending
state_counts_sorted = ORDER state_counts BY count DESC;

-- Store results to HDFS
STORE state_counts_sorted INTO '/output/breweries_by_state' USING PigStorage(',');

-- Print to console (for local mode)
DUMP state_counts_sorted;

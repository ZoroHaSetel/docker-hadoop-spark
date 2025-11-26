-- Simple test script to verify Pig setup
-- Load from /input/passwd that was created in the quick start

data = LOAD '/input/passwd' USING PigStorage(':') 
       AS (username:chararray, password:chararray, uid:int, gid:int, info:chararray, home:chararray, shell:chararray);

-- Show first 10 records
limited = LIMIT data 10;

-- Dump results
DUMP limited;

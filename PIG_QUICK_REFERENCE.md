# Pig Quick Reference Guide

## Common Pig Operations

### Data Loading

```pig
-- Load from HDFS
data = LOAD '/path/to/file.txt' AS (col1:int, col2:chararray);

-- Load CSV with specific delimiter
csv_data = LOAD '/path/to/file.csv' USING PigStorage(',') AS (id:int, name:chararray, city:chararray);

-- Load without schema (all fields as chararray)
data = LOAD '/path/to/file.txt';
```

### Data Transformation

```pig
-- SELECT specific columns
selected = FOREACH data GENERATE col1, col2;

-- FILTER rows
filtered = FILTER data BY col1 > 100;

-- CREATE new calculated columns
transformed = FOREACH data GENERATE col1, col2, (col1 * col2) as product;

-- UNION two datasets
combined = UNION data1, data2;
```

### Grouping and Aggregation

```pig
-- GROUP BY
grouped = GROUP data BY col1;

-- COUNT
row_count = FOREACH grouped GENERATE group, COUNT(data);

-- SUM
totals = FOREACH grouped GENERATE group, SUM(data.amount);

-- AVG, MIN, MAX
stats = FOREACH grouped GENERATE group, AVG(data.value), MIN(data.value), MAX(data.value);
```

### Joins

```pig
-- INNER JOIN
result = JOIN table1 BY key, table2 BY key;

-- LEFT OUTER JOIN
result = JOIN table1 BY key LEFT OUTER, table2 BY key;

-- RIGHT OUTER JOIN
result = JOIN table1 BY key RIGHT OUTER, table2 BY key;

-- FULL OUTER JOIN
result = JOIN table1 BY key FULL OUTER, table2 BY key;
```

### Sorting

```pig
-- ORDER BY ascending
sorted = ORDER data BY col1;

-- ORDER BY descending
sorted = ORDER data BY col1 DESC;

-- Multiple columns
sorted = ORDER data BY col1 ASC, col2 DESC;
```

### Advanced Operations

```pig
-- DISTINCT values
unique = DISTINCT data;

-- LIMIT results
limited = LIMIT data 100;

-- FLATTEN nested data
flattened = FOREACH data GENERATE FLATTEN(nested_field);

-- SPLIT into multiple outputs
SPLIT data INTO bad IF col1 < 0, good IF col1 >= 0;
```

### Output Operations

```pig
-- DUMP to console
DUMP result;

-- STORE to HDFS
STORE result INTO '/output/path' USING PigStorage(',');

-- Store as text (default)
STORE result INTO '/output/path';

-- Store as Parquet
STORE result INTO '/output/path' USING org.apache.pig.builtin.ParquetStorer();
```

## Data Types

- `int`: 32-bit integer
- `long`: 64-bit integer
- `float`: Single-precision floating point
- `double`: Double-precision floating point
- `boolean`: TRUE or FALSE
- `chararray`: Character string (text)
- `bytearray`: Untyped byte array
- `tuple`: Ordered set of fields
- `bag`: Collection of tuples
- `map`: Set of key-value pairs

## Built-in Functions

### String Functions
- `LOWER(string)`: Convert to lowercase
- `UPPER(string)`: Convert to uppercase
- `STRLEN(string)`: String length
- `SUBSTRING(string, start, end)`: Extract substring
- `CONCAT(string1, string2, ...)`: Concatenate strings

### Math Functions
- `ABS(number)`: Absolute value
- `SQRT(number)`: Square root
- `ROUND(number)`: Round to nearest integer
- `FLOOR(number)`: Round down
- `CEIL(number)`: Round up

### Aggregate Functions
- `COUNT(bag)`: Count elements
- `SUM(bag)`: Sum values
- `AVG(bag)`: Average
- `MIN(bag)`: Minimum value
- `MAX(bag)`: Maximum value

## Useful Makefile Commands

```bash
# Build Pig image
make build-pig

# Enter Pig interactive shell
make pig-shell

# Run Pig in local mode
make pig-local

# Run Pig in MapReduce mode
make pig-mapreduce

# Connect to Hadoop namenode
make shell
```

## Example Pig Script Template

```pig
-- Load data from HDFS
data = LOAD '/input/path' AS (col1:int, col2:chararray, col3:float);

-- Transform
filtered = FILTER data BY col1 > 0;
grouped = GROUP filtered BY col2;
result = FOREACH grouped GENERATE group, COUNT(filtered), AVG(filtered.col3);

-- Store results
STORE result INTO '/output/path' USING PigStorage(',');
```

## Tips and Best Practices

1. **Use descriptive variable names**: Makes scripts easier to understand
2. **Add comments**: Start lines with `--` for comments
3. **Test in local mode first**: Use `-x local` before running on cluster
4. **Check HDFS paths**: Verify data exists before loading
5. **Monitor jobs**: Check YARN ResourceManager at http://localhost:8088
6. **Use intermediate results**: Save stages to debug issues
7. **Specify data types**: More efficient than using bytearray
8. **Consider partitioning**: For large datasets, partition output

## Error Messages and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `java.io.FileNotFoundException` | File doesn't exist in HDFS | Check path with `hdfs dfs -ls` |
| `OutOfMemoryError` | Not enough memory | Increase JVM heap size |
| `java.lang.ClassNotFoundException` | Missing JAR or UDF | Check classpath and available functions |
| `NullPointerException` | Null values in data | Filter nulls or handle in script |
| `java.io.IOException: Connection refused` | Hadoop not running | Start cluster with `make up` |

## Additional Resources

- [Apache Pig Official Documentation](https://pig.apache.org/)
- [Pig Latin Language Reference](https://pig.apache.org/docs/r0.17.0/index.html)
- [Main Setup Guide](./PIG_SETUP.md)

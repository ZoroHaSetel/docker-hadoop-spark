# Apache Pig on Hadoop

This Dockerfile builds a Pig container that's configured to work with the Hadoop cluster.

## Building the Pig Image

```bash
make build-pig
```

## Running Pig Interactive Shell

```bash
# Enter the Pig container shell
docker exec -it pig bash

# Start Pig in local mode
pig -x local

# Start Pig in mapreduce mode (requires Hadoop cluster)
pig -x mapreduce
```

## Running Pig Scripts

```bash
# Copy your Pig script to the container
docker cp my_script.pig pig:/root/

# Execute the script in mapreduce mode
docker exec pig pig -x mapreduce /root/my_script.pig

# Or in local mode
docker exec pig pig -x local /root/my_script.pig
```

## Example: Process Breweries Data with Pig

```bash
# 1. First, ensure data is in HDFS (see main README.md)
#    hdfs dfs -put breweries.csv /data/openbeer/breweries/

# 2. Create a Pig script (breweries.pig)
cat > breweries.pig << 'EOF'
breweries = LOAD '/data/openbeer/breweries/breweries.csv' 
            USING PigStorage(',') 
            AS (id:int, name:chararray, city:chararray, state:chararray);

-- Remove the header row
breweries_filtered = FILTER breweries BY id > 0;

-- Group by state
by_state = GROUP breweries_filtered BY state;

-- Count breweries per state
state_counts = FOREACH by_state GENERATE group as state, COUNT(breweries_filtered) as count;

-- Store results
STORE state_counts INTO '/output/breweries_by_state' USING PigStorage(',');
EOF

# 3. Run the Pig script
docker cp breweries.pig pig:/root/
docker exec pig pig -x mapreduce /root/breweries.pig

# 4. Check the results
docker exec -it namenode bash
hdfs dfs -cat /output/breweries_by_state/*
```

## Pig Modes

- **local**: Runs on local file system, useful for testing
- **mapreduce**: Runs on Hadoop cluster using YARN

## Key Commands

- `pig`: Start interactive Pig shell
- `pig -f script.pig`: Execute a Pig script
- `pig -x local`: Run in local mode
- `pig -x mapreduce`: Run in mapreduce mode
- `pig -h`: Show help

## Connecting to Hadoop

The Pig container is automatically configured with:
- HADOOP_HOME pointing to /opt/hadoop-3.3.6
- JAVA_HOME pointing to Java 11
- Network access to HDFS at `hdfs://namenode:9000`
- Network access to YARN ResourceManager

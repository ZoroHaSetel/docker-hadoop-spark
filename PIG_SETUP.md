# Installing and Using Apache Pig on Hadoop Cluster

This guide walks you through installing and using Apache Pig with your Docker-based Hadoop cluster.

## Quick Start

### 1. Build the Pig Docker Image

```bash
make build-pig
```

Or rebuild all images including Pig:

```bash
make build
```

### 2. Start the Cluster with Pig

```bash
docker compose up -d
```

This starts all services including the new Pig container that's configured to connect to your Hadoop cluster.

### 3. Verify Pig Installation

```bash
make pig-shell
# Inside the container:
pig -version
```

## Using Pig

### Interactive Mode (Local)

```bash
make pig-local
```

This opens the Pig interactive shell in local mode (processes files locally).

```
grunt> A = LOAD 'test.txt' AS (x:int, y:chararray);
grunt> B = FOREACH A GENERATE x, y;
grunt> DUMP B;
```

### Interactive Mode (MapReduce on Hadoop)

```bash
make pig-mapreduce
```

This opens the Pig interactive shell in MapReduce mode (runs on Hadoop cluster).

### Run Pig Scripts

#### Method 1: From Your Local Machine

```bash
# Copy script to pig container
docker cp my_script.pig pig:/root/

# Execute in local mode
docker exec pig pig -x local /root/my_script.pig

# Or execute in mapreduce mode (on Hadoop)
docker exec pig pig -x mapreduce /root/my_script.pig
```

#### Method 2: Using the scripts Volume

The `scripts` directory is mounted in the Pig container at `/root/scripts`.

```bash
# Place your script in the scripts directory
cp my_script.pig scripts/

# Execute from within the Pig container
make pig-shell
pig -x local /root/scripts/my_script.pig
```

## Example: Process Breweries Data with Pig

### Step 1: Prepare Data in HDFS

First, upload the breweries CSV to your Hadoop cluster:

```bash
# Copy data to namenode
docker cp breweries.csv namenode:/

# Connect to namenode
docker exec -it namenode bash

# Create HDFS directory
hdfs dfs -mkdir -p /data/openbeer/breweries

# Upload CSV file
hdfs dfs -put breweries.csv /data/openbeer/breweries/

# Verify
hdfs dfs -ls /data/openbeer/breweries/
```

### Step 2: Run the Sample Pig Script

```bash
# The sample script is at scripts/breweries_by_state.pig
# It counts breweries by state

# Run in MapReduce mode
docker exec pig pig -x mapreduce /root/scripts/breweries_by_state.pig
```

### Step 3: View the Results

```bash
# Connect to namenode
docker exec -it namenode bash

# Check the output
hdfs dfs -ls /output/breweries_by_state/
hdfs dfs -cat /output/breweries_by_state/*
```

## Pig Script Examples

### Example 1: Simple Data Load and Filter

```pig
-- Load data
data = LOAD '/data/input.txt' AS (name:chararray, age:int);

-- Filter
filtered = FILTER data BY age > 25;

-- Output
DUMP filtered;
```

### Example 2: Group and Aggregate

```pig
-- Load data
users = LOAD '/data/users.txt' AS (name:chararray, department:chararray, salary:int);

-- Group by department
by_dept = GROUP users BY department;

-- Calculate statistics
dept_stats = FOREACH by_dept GENERATE 
    group as department, 
    COUNT(users) as count,
    AVG(users.salary) as avg_salary,
    MAX(users.salary) as max_salary;

-- Store results
STORE dept_stats INTO '/output/dept_stats' USING PigStorage(',');
```

### Example 3: Join Two Datasets

```pig
-- Load datasets
orders = LOAD '/data/orders.txt' AS (order_id:int, customer_id:int, amount:float);
customers = LOAD '/data/customers.txt' AS (customer_id:int, name:chararray, city:chararray);

-- Join on customer_id
joined = JOIN orders BY customer_id, customers BY customer_id;

-- Project specific columns
result = FOREACH joined GENERATE 
    orders::order_id, 
    customers::name, 
    customers::city, 
    orders::amount;

-- Store results
STORE result INTO '/output/order_summary' USING PigStorage(',');
```

## Pig Modes Explained

### Local Mode (`pig -x local`)
- Runs on local file system
- Useful for testing and development
- No need for Hadoop cluster to be running (though it is in your case)
- Processes data stored locally or in HDFS

### MapReduce Mode (`pig -x mapreduce`) or (`pig -x mr`)
- Default mode
- Submits jobs to Hadoop YARN
- Scales across the cluster
- Distributes data processing across nodes
- Required for production workloads

## Troubleshooting

### Pig Command Not Found

```bash
# Verify Pig installation
docker exec pig which pig

# Check PATH
docker exec pig echo $PATH
```

### HDFS Connection Issues

```bash
# Test HDFS connectivity from Pig container
docker exec pig hdfs dfs -ls hdfs://namenode:9000/

# Check if namenode is running
docker exec -it namenode bash
jps
```

### Job Submission Failures

```bash
# Check Hadoop logs
docker exec namenode tail -f /opt/hadoop-3.3.6/logs/*.log

# Check YARN ResourceManager status
docker exec pig yarn node -list -all
```

### Out of Memory Errors

Edit docker-compose.yml to increase JVM memory for Pig container:

```yaml
pig:
  # ... other settings ...
  environment:
    JAVA_OPTS: "-Xmx2g -Xms1g"
```

## Key Pig Files and Locations

- **Pig Home**: `/opt/pig-0.17.0`
- **Pig Binaries**: `/opt/pig-0.17.0/bin/`
- **Pig Scripts**: `/root/scripts/`
- **Sample Data**: `/data/openbeer/breweries/` (in HDFS)

## Environment Variables

The Pig container inherits Hadoop configuration:

- `HADOOP_HOME`: `/opt/hadoop-3.3.6`
- `JAVA_HOME`: `/usr/lib/jvm/java-11-openjdk-amd64/`
- `HADOOP_CONF_DIR`: `/etc/hadoop`
- `PIG_HOME`: `/opt/pig-0.17.0`

## Additional Resources

- [Apache Pig Official Documentation](https://pig.apache.org/)
- [Pig Latin Reference](https://pig.apache.org/docs/r0.17.0/basic.html)
- [Main Cluster README](../README.md)

## Next Steps

1. Create your own Pig scripts in the `scripts` directory
2. Upload your data to HDFS
3. Run your scripts in MapReduce mode on the cluster
4. Monitor job progress through the Hadoop UI at `http://localhost:8088`

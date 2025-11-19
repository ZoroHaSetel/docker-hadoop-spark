# Getting Started with Pig on Your Hadoop Cluster - Step by Step

This walkthrough will guide you through your first Pig experience on the cluster.

## Prerequisites

- Docker and Docker Compose installed
- Your workspace at `/workspaces/docker-hadoop-spark`
- 5-10 minutes

## Steps

### Step 1: Build the Pig Docker Image (1 minute)

```bash
cd /workspaces/docker-hadoop-spark
make build-pig
```

**What's happening**: Docker is building a container image with Pig 0.17.0, Java, and Hadoop integration.

**Expected output**:
```
docker build -t bde2020/hadoop-pig:master ./pig
Sending build context to Docker daemon
...
Successfully tagged bde2020/hadoop-pig:master
```

### Step 2: Start Your Hadoop Cluster with Pig (2-3 minutes)

```bash
make up
```

**What's happening**: Docker Compose is starting all services including namenode, datanode, YARN, and the new Pig container.

**Wait for initialization**: Give it 30-60 seconds for all services to fully start.

**Verify services are running**:
```bash
docker ps
```

You should see containers for: namenode, datanode, resourcemanager, nodemanager, pig, and others.

### Step 3: Verify Pig Installation (1 minute)

```bash
bash test-pig-install.sh
```

**Expected output**:
```
✓ Docker is running
✓ Pig container found
✓ Pig is installed: Apache Pig version 0.17.0
✓ HDFS is accessible from Pig container
✓ YARN is accessible from Pig container
✓ Sample Pig script found at scripts/breweries_by_state.pig
```

### Step 4: Test Pig in Local Mode (2 minutes)

```bash
make pig-local
```

This enters the Pig interactive shell. You'll see the `grunt>` prompt.

**Try these commands**:

```
-- Create some test data in memory
A = LOAD 'data.txt' AS (x:int, y:chararray);
B = FOREACH A GENERATE x, y;
DUMP B;
```

**To exit**: Type `quit` and press Enter

**What you've done**: You've successfully run a Pig script locally!

### Step 5: Test with the Sample Script (3 minutes)

First, prepare sample data:

```bash
# Exit the Pig shell if you're still in it
# Then run these commands:

docker cp breweries.csv namenode:/
docker exec namenode bash << 'EOF'
hdfs dfs -mkdir -p /data/openbeer/breweries
hdfs dfs -put breweries.csv /data/openbeer/breweries/
hdfs dfs -cat /data/openbeer/breweries/breweries.csv | head -5
EOF
```

Now run the sample Pig script:

```bash
docker exec pig pig -x mapreduce /root/scripts/breweries_by_state.pig
```

**Expected behavior**:
- The script runs on your Hadoop cluster
- YARN jobs are submitted
- Results are stored in `/output/breweries_by_state`

View the results:

```bash
docker exec namenode hdfs dfs -cat /output/breweries_by_state/*
```

**Expected output**: Breweries grouped by state with counts

### Step 6: Create Your Own Pig Script (5 minutes)

Create a file called `my_script.pig` in the `scripts/` directory:

```bash
cat > /workspaces/docker-hadoop-spark/scripts/my_first_script.pig << 'EOF'
-- My First Pig Script
-- This script counts lines in a file

-- Load the breweries data
breweries = LOAD '/data/openbeer/breweries/breweries.csv' 
            USING PigStorage(',') 
            AS (id:int, name:chararray, city:chararray, state:chararray);

-- Count total breweries
total = FOREACH (GROUP breweries ALL) GENERATE COUNT(breweries) as count;

-- Dump to console
DUMP total;

-- Also store to HDFS
STORE total INTO '/output/brewery_count' USING PigStorage(',');
EOF
```

Run your script:

```bash
docker exec pig pig -x mapreduce /root/scripts/my_first_script.pig
```

Check the output:

```bash
docker exec namenode hdfs dfs -cat /output/brewery_count/*
```

## Congratulations! 🎉

You've successfully:
- ✓ Built a Pig Docker image
- ✓ Integrated it with your Hadoop cluster
- ✓ Ran Pig in local mode
- ✓ Ran Pig in MapReduce mode
- ✓ Created and executed a custom Pig script

## Next Steps

### Learn More About Pig

1. **Reference Guide**: `PIG_QUICK_REFERENCE.md`
2. **Full Documentation**: `PIG_SETUP.md`
3. **Container Info**: `pig/README.md`

### Common Tasks

**Enter the Pig container shell**:
```bash
make pig-shell
```

**Run multiple scripts**:
```bash
docker exec pig pig -x mapreduce /root/scripts/script1.pig
docker exec pig pig -x mapreduce /root/scripts/script2.pig
```

**Monitor job progress**:
- Open http://localhost:8088 in your browser
- Watch YARN resource manager

**Copy files to/from Pig container**:
```bash
# Copy to
docker cp local_file.pig pig:/root/

# Copy from
docker cp pig:/root/output.txt local_output.txt
```

## Troubleshooting

### "Pig container not found"
```bash
# Make sure containers are running
docker ps | grep pig

# If not, start them
make up
```

### "HDFS not accessible"
```bash
# Wait a moment, namenode takes time to initialize
sleep 30
docker exec pig hdfs dfs -ls hdfs://namenode:9000/
```

### "Can't find data file"
```bash
# Verify file exists in HDFS
docker exec namenode hdfs dfs -ls /data/openbeer/breweries/

# Or copy it
docker cp breweries.csv namenode:/
docker exec namenode hdfs dfs -put breweries.csv /data/openbeer/breweries/
```

### "Out of Memory"
```bash
# Stop services
docker compose down

# Edit docker-compose.yml and add under pig > environment:
# JAVA_OPTS: "-Xmx2g"

# Restart
make up
```

## Useful Commands Reference

```bash
# Start cluster
make up

# Build Pig image
make build-pig

# Access containers
make pig-shell          # Pig container shell
make shell              # Hadoop namenode shell
make pig-local          # Pig in local mode
make pig-mapreduce      # Pig in mapreduce mode

# View files
docker exec namenode hdfs dfs -ls /data/          # List HDFS directories
docker exec namenode hdfs dfs -cat /file/*        # View HDFS file
docker logs pig                                   # View Pig container logs

# Stop all
docker compose down
```

## What Files Are Available?

- `PIG_INSTALLATION_SUMMARY.md` - Overview of what was installed
- `PIG_SETUP.md` - Comprehensive guide (read this for details!)
- `PIG_QUICK_REFERENCE.md` - Pig language reference and examples
- `pig/README.md` - Container-specific documentation
- `scripts/breweries_by_state.pig` - Example script
- `test-pig-install.sh` - Verification script

## Tips

1. **Start simple**: Use local mode for testing
2. **Use DUMP**: Print intermediate results to debug
3. **Check HDFS**: Verify input data exists before running
4. **Monitor UI**: Watch http://localhost:8088 for job progress
5. **Save outputs**: Always STORE important results to HDFS

---

**Need help?** Check the detailed guides in the documentation files or re-run `test-pig-install.sh` to verify everything is set up correctly.

Happy Pig scripting! 🐷🐘

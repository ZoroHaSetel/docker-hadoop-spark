# Pig Installation Summary

## What Has Been Installed

Apache Pig 0.17.0 has been successfully integrated into your Docker-based Hadoop cluster. Here's what was added:

### New Files and Directories

```
pig/
├── Dockerfile          # Pig container definition
└── README.md          # Pig-specific documentation

scripts/
└── breweries_by_state.pig    # Example Pig script

PIG_SETUP.md                  # Comprehensive setup and usage guide
PIG_QUICK_REFERENCE.md        # Quick reference for Pig commands
test-pig-install.sh           # Installation verification script
```

### Modified Files

1. **docker-compose.yml**: Added `pig` service with:
   - Automatic build from `pig/Dockerfile`
   - Dependencies on Hadoop services (namenode, datanode, resourcemanager)
   - Volume mount for `/root/scripts` (local `scripts/` directory)
   - Environment configuration for Hadoop integration

2. **Makefile**: Added new commands:
   - `make build-pig`: Build just the Pig image
   - `make pig-shell`: Enter Pig container shell
   - `make pig-local`: Launch Pig in local mode
   - `make pig-mapreduce`: Launch Pig in MapReduce mode

### Key Features

✅ **Pig 0.17.0** - Latest stable version
✅ **Hadoop Integration** - Fully configured to work with your cluster
✅ **Two Execution Modes** - Local and MapReduce
✅ **Volume Mounting** - Easily share scripts between host and container
✅ **Sample Script** - Example provided for data processing
✅ **Complete Documentation** - Multiple guide files included

## Quick Start (5 minutes)

### Step 1: Build the Pig Image
```bash
make build-pig
```

### Step 2: Start the Cluster
```bash
docker compose up -d
```

Wait a few seconds for services to initialize.

### Step 3: Verify Installation
```bash
bash test-pig-install.sh
```

### Step 4: Run Pig
```bash
# Interactive shell in local mode
make pig-local

# Or enter the shell
make pig-shell
```

## Usage Modes

### Local Mode (Testing)
```bash
make pig-local
# Then in the Pig shell:
# A = LOAD 'data.txt' AS (x:int, y:chararray);
# DUMP A;
```

### MapReduce Mode (Production)
```bash
make pig-mapreduce
# Runs jobs on your Hadoop cluster via YARN
```

### Run Scripts
```bash
# From your local machine
docker cp my_script.pig pig:/root/
docker exec pig pig -x mapreduce /root/my_script.pig

# Or place in scripts/ directory and run from container
# make pig-shell, then: pig -x mapreduce /root/scripts/my_script.pig
```

## Example: Process Data with Pig

### 1. Upload data to HDFS (one-time setup)
```bash
docker cp breweries.csv namenode:/
docker exec namenode bash -c 'hdfs dfs -mkdir -p /data/openbeer/breweries && hdfs dfs -put breweries.csv /data/openbeer/breweries/'
```

### 2. Run the sample Pig script
```bash
docker exec pig pig -x mapreduce /root/scripts/breweries_by_state.pig
```

### 3. View results
```bash
docker exec namenode hdfs dfs -cat /output/breweries_by_state/*
```

## Documentation Files

1. **PIG_SETUP.md** (Read This First)
   - Complete installation guide
   - Detailed usage instructions
   - Examples and troubleshooting

2. **PIG_QUICK_REFERENCE.md**
   - Common Pig operations cheat sheet
   - Data types and functions
   - Error messages and solutions

3. **pig/README.md**
   - Container-specific information
   - Pig configuration details
   - Connection settings

## Important Paths

Inside the Pig container:
- **Pig Installation**: `/opt/pig-0.17.0`
- **Pig Binary**: `/opt/pig-0.17.0/bin/pig`
- **Scripts Directory**: `/root/scripts/` (mounted from local `scripts/`)
- **Working Directory**: `/root`

In HDFS (Hadoop):
- **Input Data**: `/data/openbeer/breweries/`
- **Output Location**: `/output/` (or custom path)

## Troubleshooting

### Pig container won't start
```bash
docker logs pig
# Check if hadoop services are running
docker ps | grep -E "namenode|datanode|resourcemanager"
```

### Connection to Hadoop fails
```bash
# Verify from within Pig container
docker exec pig hdfs dfs -ls hdfs://namenode:9000/
docker exec pig yarn node -list
```

### Pig command not found
```bash
docker exec pig bash -c "which pig && pig -version"
```

### Out of memory
Edit docker-compose.yml pig service:
```yaml
environment:
  JAVA_OPTS: "-Xmx2g -Xms1g"
```

## What's Next?

1. **Read**: Start with `PIG_SETUP.md` for detailed instructions
2. **Learn**: Check `PIG_QUICK_REFERENCE.md` for Pig syntax
3. **Write**: Create your own Pig scripts in the `scripts/` directory
4. **Run**: Execute scripts on your Hadoop cluster
5. **Monitor**: Watch progress at http://localhost:8088 (YARN ResourceManager)

## Support Resources

- [Apache Pig Official Documentation](https://pig.apache.org/)
- [Pig Language Reference](https://pig.apache.org/docs/r0.17.0/basic.html)
- [Pig Examples](https://pig.apache.org/docs/r0.17.0/start.html)

## Docker Compose Services Overview

Your cluster now includes:

| Service | Port | Purpose |
|---------|------|---------|
| namenode | 9870 | HDFS management UI |
| datanode | 9864 | Data storage |
| resourcemanager | 8088 | YARN job management |
| nodemanager | 8042 | Node resource management |
| historyserver | 8188 | Job history |
| spark-master | 8080 | Spark UI |
| hive-server | 10000 | Hive query service |
| **pig** | - | Pig data processing |

## Verification Checklist

- [x] Pig Dockerfile created
- [x] Pig service added to docker-compose.yml
- [x] Makefile commands updated
- [x] Sample Pig script created
- [x] Documentation files created
- [x] Test script created and made executable

Everything is ready! Your Hadoop cluster now has Apache Pig fully integrated and documented.

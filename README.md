# Local Spark Development Setup

This guide walks you through setting up a local Spark development environment that matches our Databricks production setup.

## Setup Steps

1. **Clone and Prepare Repository**
   ```bash
   # Clone the repository
   git clone <repository-url>
   cd databricks-local-spark-build

   # Copy all entire repo to your 1phi/vinci repository
   cp -r Docker Dependencies test_spark /path/to/your/1phi/vinci/repo/
   cd /path/to/your/1phi/vinci/repo/
   ```



5. **Build the Container**
   ```bash
   # From your project root directory
   docker build -t spark-full -f Docker/spark-full.Dockerfile .
   ```

6. **Run the Container**
   ```bash
   docker run -it \
     -p 4040:4040 \
     -p 8080:8080 \
     -p 8081:8081 \
     -v "$(pwd):/home/spark/work" \
     --name spark-container \
     spark-full
   ```

7. **Start Spark Services**
   ```bash
   # In the container terminal
   start-master.sh

   # In a new terminal
   docker exec -it spark-container start-worker.sh spark://localhost:7077
   ```

8. **Run the Test Script**
   ```bash
   # From inside the container
   cd /home/spark/work/test_spark
   spark-submit spark_test.py
   ```

## Expected Output

If everything is working correctly, you should see:
```
+---+-----+
| id|value|
+---+-----+
|  1|test1|
|  2|test2|
|  3|test3|
+---+-----+
```

## Directory Structure

Your project should look like this:
```
.
├── spark-full.Dockerfile
├── Dependencies/
│   ├── spark_requirements.txt
│   ├── stage1_core_requirements.txt
│   ├── stage2a_requirements.txt
│   ├── stage2b_requirements.txt
│   ├── stage2c_requirements.txt
│   └── system_dependent_requirements.txt
└── test_spark/
    └── spark_test.py
└── rest-of-your-directory-structure
```

## Troubleshooting

### Common Issues

1. **Container Build Fails**
   - Check if all requirements files are present
   - Verify Docker is running
   - Solution: `docker system prune -a` and rebuild

2. **Port Conflicts**
   - Check if ports 4040, 8080, 8081 are in use
   - Solution: `lsof -i :4040` to find and kill processes

3. **Memory Issues**
   - Default: 4GB RAM recommended
   - Solution: Increase Docker Desktop memory limits

### Cleanup

To stop and remove everything:
```bash
# Stop Spark services
docker exec -it spark-container stop-worker.sh
docker exec -it spark-container stop-master.sh

# Stop and remove container
docker stop spark-container
docker rm spark-container

# Remove image (if needed)
docker rmi spark-full
```


## Version Info

- Spark: 3.5.0
- Python: 3.10
- Base Image: python:3.10-slim
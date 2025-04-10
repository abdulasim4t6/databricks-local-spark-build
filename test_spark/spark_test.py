from pyspark.sql import SparkSession

# Initialize Spark session
spark = SparkSession.builder \
    .appName("TestApp") \
    .getOrCreate()

# Create a simple test DataFrame
test_df = spark.createDataFrame([
    (1, "test1"),
    (2, "test2"),
    (3, "test3")
], ["id", "value"])

# Show the DataFrame
test_df.show()

# Stop the Spark session
spark.stop()

FROM python:3.10-slim

USER root

# Create spark user and set up directories
RUN groupadd -r spark && useradd -r -g spark spark
RUN mkdir -p /home/spark && chown -R spark:spark /home/spark

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    default-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Spark
ENV SPARK_VERSION=3.5.0
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
ENV PYSPARK_PYTHON=/usr/local/bin/python3
ENV PYSPARK_DRIVER_PYTHON=/usr/local/bin/python3

RUN wget -q https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && tar xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt \
    && mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} ${SPARK_HOME} \
    && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

# Copy requirements file
COPY Dependencies/spark_requirements.txt /tmp/requirements.txt

# Install Python packages
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Create work directory
RUN mkdir -p /home/spark/work && chown -R spark:spark /home/spark/work

# Switch to spark user
USER spark

WORKDIR /home/spark/work

# Set default command to bash for interactive use
CMD ["bash"] 
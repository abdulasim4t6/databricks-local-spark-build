FROM python:3.10-slim

USER root

# Create spark user and set up directories
RUN groupadd -r spark && useradd -r -g spark spark
RUN mkdir -p /home/spark && chown -R spark:spark /home/spark

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    default-jdk \
    wget \
    git \
    cmake \
    pkg-config \
    libdbus-1-dev \
    dbus \
    libglib2.0-dev \
    build-essential \
    libgtk-3-dev \
    python3-gi \
    gir1.2-gtk-3.0 \
    libcairo2-dev \
    libopenmpi-dev \
    libffi-dev \
    postgresql-server-dev-all \
    libpq-dev \
    gobject-introspection \
    libgirepository1.0-dev \
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

# Copy all requirements files
COPY Dependencies/spark_requirements.txt /tmp/spark_requirements.txt
COPY Dependencies/stage1_core_requirements.txt /tmp/stage1_requirements.txt
COPY Dependencies/stage2a_requirements.txt /tmp/stage2a_requirements.txt
COPY Dependencies/stage2b_requirements.txt /tmp/stage2b_requirements.txt
COPY Dependencies/stage2c_requirements.txt /tmp/stage2c_requirements.txt
COPY Dependencies/system_dependent_requirements.txt /tmp/system_requirements.txt

# Install Python packages in order with separate RUN commands for better error visibility
RUN pip3 install --no-cache-dir -r /tmp/system_requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/spark_requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/stage1_requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/stage2a_requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/stage2b_requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/stage2c_requirements.txt


# Create work directory
RUN mkdir -p /home/spark/work && chown -R spark:spark /home/spark/work

# Switch to spark user
USER spark

WORKDIR /home/spark/work

# Set default command to bash for interactive use
CMD ["bash"] 
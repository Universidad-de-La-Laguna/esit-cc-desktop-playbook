#!/bin/bash

# Application execution variables
: ${SPARK_APPLICATION_JAR_NAME:="spark-wordcount-example_2.11-0.0.1.jar"}
: ${SPARK_APPLICATION_MAIN_CLASS:="es.edu.ull.spark.scala.WordCount"}
: ${SPARK_APPLICATION_ARGS:="/opt/spark-data/ejemplo.txt /opt/spark-data/output"}

# System variables
: ${SPARK_APPS_DIR:="/opt/spark-apps"}
: ${SPARK_MASTER_URL:="spark://10.6.7.12:7077"}
: ${SPARK_SUBMIT_ARGS:="--conf spark.driver.extraJavaOptions='-Xss10m -XX:MaxPermSize=1024M ' --conf spark.executor.extraJavaOptions='-Xss10m -XX:MaxPermSize=512M '"}

# Check arguments
if [ -z "$1" ] 
then
    echo "No argument supplied. Using default..."
else
    if [[ $# -lt 3 ]] ; then
        echo "Usage: ./submitApp <jar> <mainClass> <args>"
        exit 1
    fi

    SPARK_APPLICATION_JAR_NAME=$1
    SPARK_APPLICATION_MAIN_CLASS=$2
    shift 2
    SPARK_APPLICATION_ARGS="$@"
fi

# Print arguments
echo "SPARK_APPLICATION_JAR_NAME=${SPARK_APPLICATION_JAR_NAME}"
echo "SPARK_APPLICATION_MAIN_CLASS=${SPARK_APPLICATION_MAIN_CLASS}"
echo "SPARK_APPLICATION_ARGS=${SPARK_APPLICATION_ARGS}"

# Launch spark application
echo "Launching app..."

docker run \
    --env SPARK_MASTER_URL=$SPARK_MASTER_URL \
    --env SPARK_APPLICATION_JAR_LOCATION=${SPARK_APPS_DIR}/${SPARK_APPLICATION_JAR_NAME} \
    --env SPARK_APPLICATION_MAIN_CLASS=$SPARK_APPLICATION_MAIN_CLASS \
    --env SPARK_APPLICATION_ARGS="$SPARK_APPLICATION_ARGS" \
    ccesitull/spark-submit:2.4.3

echo "DONE!"
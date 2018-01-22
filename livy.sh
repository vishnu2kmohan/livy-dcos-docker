#!/usr/bin/env bash

# Activate the "livy" conda environment, discover "SPARK_HOME" and start livy
bash -c 'source activate livy \
         && cd "${CONDA_PREFIX}/bin" \
         && source find-spark-home \
         && export LIVY_SERVER_JAVA_OPTS="-Xms512m -Xmx512m -XX:+UseG1GC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime -XX:+PrintPromotionFailure -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=10M -Xloggc:${MESOS_SANDBOX}/gc.log" \
         && env | sort \
         && ${HOME}/livy/bin/livy-server'

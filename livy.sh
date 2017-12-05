#!/usr/bin/env bash

# Activate the "livy" conda environment, discover "SPARK_HOME" and start livy
bash -c 'source activate livy \
         && cd $CONDA_PREFIX/bin \
         && source find-spark-home \
         && $HOME/livy/bin/livy-server'

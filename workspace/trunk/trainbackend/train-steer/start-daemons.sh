#!/bin/bash

pkill train-daemon.sh

TRAIN_STEER=$HOME/train-steer

cd $TRAIN_STEER
nohup ./train-daemon.sh --run-tests >> tests.log 2>&1 & 
nohup ./train-daemon.sh --generate-files >> generator.log 2>&1 &

#! /bin/bash

dataset=$1
cfgname=`echo ${dataset#/} | sed 's/\/AODSIM//g' | sed 's/\//_/g'`

./writeCfgs.sh $dataset
./submitCMS2Job.sh cfg/${cfgname}.sh


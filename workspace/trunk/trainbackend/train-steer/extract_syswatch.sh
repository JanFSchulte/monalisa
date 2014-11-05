#!/bin/bash

echo "Rewritting syswatch with old AliRoot"

source /home/alitrain/packages/env_aliroot.sh VO_ALICE@AliRoot::v5-03-57-AN
aliroot -b -q $TRAIN_STEER/rewrite_syswatch.C


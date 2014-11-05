#!/bin/bash

cd `dirname $0`

export PATH=$PATH:$HOME

./manage_alien_package.sh undefine $@ 2>&1 | tee -a bin/remove.log

#!/bin/bash

cd `dirname $0`

export PATH=$PATH:$HOME

./manage_alien_package.sh show_defined 2>&1

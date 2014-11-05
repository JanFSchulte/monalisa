#!/bin/bash

cd `dirname $0`

rm -rf sites.tmp &>/dev/null
mkdir sites.tmp &>/dev/null

/opt/alien/bin/alien -x packages.pl

for a in sites.tmp/*; do
    cat $a | grep VO_ALICE@ > $a.tmp
    mv $a.tmp $a
done

mv sites.tmp/ALL.packman sites.tmp/ALL.packman.tmp
for package in `cat sites.tmp/ALL.packman.tmp`; do
    echo $package | grep @
done > sites.tmp/ALL.packman

cat sites.tmp/* | sort -u > sites.tmp/ALL

rm -rf sites
mv sites.tmp sites

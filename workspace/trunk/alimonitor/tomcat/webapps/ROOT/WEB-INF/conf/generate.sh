#!/bin/bash

for a in SDSS ATLAS iVDgL CMS LIGO BTeV GRIDEX GADU GRASE; do 
	for b in rt hist1 hist2 hist3 hist4; do 
		cat vo_$b.properties | ~/MLrepository/bin/replace.sh SDSS "${a}" > ${a}_${b}.properties; 
	done; 
done

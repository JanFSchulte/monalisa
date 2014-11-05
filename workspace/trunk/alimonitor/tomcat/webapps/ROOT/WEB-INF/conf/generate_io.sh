#!/bin/bash

for a in CMS ATLAS SDSS LIGO iVDgL BTeV GRIDEX GRASE GADU; do
	for b in rt hist1 hist2; do
		cat vo_io_${b}.properties | ~/MLrepository/bin/replace.sh SDSS "${a}" VO_JOBS VO_IO > ${a}_io_${b}.properties
	done
done


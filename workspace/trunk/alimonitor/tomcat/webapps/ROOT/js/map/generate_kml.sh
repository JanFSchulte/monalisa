#!/bin/bash

i=0

(
echo '<?xml version="1.0" encoding="UTF-8"?>'
echo '<kml xmlns="http://earth.google.com/kml/2.1">'
echo '<Document>'
echo '  <name>ALICE Sites</name>'
echo '    <description><![CDATA[ALICE Sites highlighted]]></description>'

cat generate_kml.sources | while read URL; do
    i=$((i+1))

    wget -q "$URL" -O $i.kml
    
    cat $i.kml | grep http://maps.google.com | awk -F'[<>]' '{print $3}' | replace '&amp;' '&' | xargs wget -q -O $i-2.kml
    
    lines=`cat $i-2.kml | wc -l`
    
    cat $i-2.kml | tail -n $((lines-5)) | head -n $((lines-7)) | sed "s/style[0-9]*/&f$i/g"
    
    rm $i.kml $i-2.kml
done

echo '</Document>'
echo '</kml>'
) > google.kml

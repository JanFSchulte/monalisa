#!/bin/bash

cd `dirname "$0"`

#rm combined.js

#for jsfile in overlib/overlib.js overlib/overlib_crossframe.js dtree.js js/range.js js/timer.js  js/slider.js js/common.js calendar1.js js/window/prototype.js js/scriptaculous/scriptaculous.js \
#    js/ajax.js js/window/window.js js/window/windowutils.js  js/htmlsuite/dhtmlSuite-common.js js/htmlsuite/dhtmlSuite-calendar.js js/htmlsuite/dhtmlSuite-dragDropSimple.js js/sorttable.js; do
#    
#    (cat ../$jsfile; echo "") >> combined.js
#done

#rm combined.css

for cssfile in cooltree.css dtree.css map2D.css css/bluecurve/bluecurve.css style/style.css img/dynamic/style.css js/window/default.css js/window/mac_os_x.css js/htmlsuite/themes/light-cyan/css/calendar.css; do
#    (cat ../$cssfile; echo "") >> combined.css

    echo $cssfile
    grep AlphaImageLoader ../$cssfile

done

#!/bin/bash

cd `dirname "$0"`

NOW=`date +%s`

for jsfile in overlib/overlib.js overlib/overlib_crossframe.js dtree.js js/range.js js/timer.js  js/slider.js js/common.js calendar1.js js/window/prototype.js js/scriptaculous/scriptaculous.js \
    js/ajax.js js/window/window.js js/window/windowutils.js  js/htmlsuite/dhtmlSuite-common.js js/htmlsuite/dhtmlSuite-calendar.js js/htmlsuite/dhtmlSuite-dragDropSimple.js js/sorttable.js \
    js/window/effects.js js/htmlsuite/calendar.js js/tooltips.js js/menu.js \
    ; do
    
    (cat ../$jsfile; echo "") >> combined-$NOW.js
done

if ! diff combined-$NOW.js combined.js &>/dev/null; then
    echo "JS changed"
    
    /home/monalisa/MLrepository/bin/yui/yui.sh combined-$NOW.js -o combined-$NOW.yui.js
    
    cat ../WEB-INF/res/masterpage/masterpage.res | sed "s#/js/combined.*.js#/js/combined-$NOW.yui.js#g" > ../WEB-INF/res/masterpage/masterpage.res.new && mv ../WEB-INF/res/masterpage/masterpage.res.new ../WEB-INF/res/masterpage/masterpage.res
    
    cp combined-$NOW.js combined.js
else
    rm combined-$NOW.js
fi

for cssfile in cooltree.css dtree.css map2D.css css/bluecurve/bluecurve.css style/style.css img/dynamic/style.css js/window/default.css js/window/mac_os_x.css js/htmlsuite/themes/light-cyan/css/calendar.css; do
    (cat ../$cssfile; echo "") >> combined-$NOW.css
done

if ! diff combined-$NOW.css combined.css &>/dev/null; then
    echo "CSS changed"

    /home/monalisa/MLrepository/bin/yui/yui.sh combined-$NOW.css -o combined-$NOW.yui.css

    cat ../WEB-INF/res/masterpage/masterpage.res | sed "s#/js/combined.*.css#/js/combined-$NOW.yui.css#g" > ../WEB-INF/res/masterpage/masterpage.res.new && mv ../WEB-INF/res/masterpage/masterpage.res.new ../WEB-INF/res/masterpage/masterpage.res
    
    cp combined-$NOW.css combined.css
else
    rm combined-$NOW.css
fi

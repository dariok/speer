xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace xstring		= "https://github.com/dariok/XStringUtils"		at "/db/apps/edoc/data/repertorium/scripts/xquery/string-pack.xql";

let $coll := collection('/db/apps/edoc/data/repertorium/texts')

let $files := for $f in $coll
    return substring-after(base-uri($f), 'texts/')
    
for $r in $coll//tei:ref[contains(@target, 'html')]/@target
    let $frag := substring-after($r, '#')
    let $name := substring-before(xstring:substring-after-last($r, '/'), '.html')
    where $name||'.xml' = $files
    let $id := doc('/db/apps/edoc/data/repertorium/texts/'||$name||'.xml')/tei:TEI/@xml:id
    let $link := if($frag = '') then "view.html?id="||$id else "view.html?id="||$id||'#'||$frag
    return update value $r with $link
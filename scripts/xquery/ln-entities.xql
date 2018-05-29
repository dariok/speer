xquery version "3.1";

declare namespace meta ="https://github.com/dariok/wdbplus/wdbmeta";
declare namespace tei="http://www.tei-c.org/ns/1.0";

let $coll := collection('/db/apps/edoc/data/repertorium/texts')

let $meta := doc('/db/apps/edoc/data/repertorium/wdbmeta.xml')
let $links := doc('/db/apps/edoc/data/repertorium/register/rep_ent.xml')//tei:item[string-length(normalize-space()) > 5]

for $doc in $coll/tei:TEI
    where $doc//tei:pb[string-length(@facs) > 5 and not(starts-with(@facs, 'ln:'))]
    let $p1 := ($doc//tei:pb[string-length(@facs) > 5 and not(starts-with(@facs, 'ln:'))])[1]
    let $base := $links[string-length(substring-after($p1/@facs, .)) > 0]
    let $b := if (count($base) = 1) then $base
        else 
            let $t := for $b in $base
                order by string-length(substring-after($p1/@facs, $b)) 
                return $b
            return $t[1]
    
    for $pb in $doc//tei:pb[string-length(@facs) > 5 and not(starts-with(@facs, 'ln:'))]
        let $f := 'ln:' || $b/@xml:id || ',' || substring-before(substring-after($pb/@facs, $b), '.')
        return update replace $pb with <pb xmlns="http://www.tei-c.org/ns/1.0" n="{$pb/@n}" facs="{$f}" />
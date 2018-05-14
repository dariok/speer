xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace xstring = "https://github.com/dariok/XStringUtils" at "/db/apps/edoc/include/xstring/string-pack.xql";

let $vals := for $doc in collection('/db/apps/edoc/data/repertorium')//tei:persName[@ref != '']
    return distinct-values($doc/@ref)

let $items := for $v in $vals
    let $name := replace(xstring:substring-after-last($v, '/'), '_', ' ')
    let $idv := translate(xstring:substring-after((xstring:substring-after-last($v, '/')), '#'), ' ()%,&amp;?=+:', '_')
    let $id := if($idv castable as xs:integer) then 'i' || $idv else $idv
    
    return
        <tei:person xml:id="{$id}">
            <persName>{
                for $part at $pos in tokenize($name, ' ')
                    let $el := if ($pos = 1) then 'forename'
                        else if ($pos = count(tokenize($name, ' '))) then 'surname'
                        else if ($part = 'von') then 'nameLink'
                        else 'name'
                    
                    return element {$el} {$part}
            }</persName>
            {if (contains($v, '/'))
                then <tei:listBibl>
                    <tei:bibl>
                        <tei:ref>{normalize-space($v)}</tei:ref>
                    </tei:bibl>
                </tei:listBibl>
                else ()
            }
        </tei:person>
        
return xmldb:store('/db/apps/edoc/data', 'list-person.xml', <tei:listPerson>{$items}</tei:listPerson>)
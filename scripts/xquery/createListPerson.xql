xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace xstring = "https://github.com/dariok/XStringUtils" at "/db/apps/edoc/include/xstring/string-pack.xql";

let $vals := for $doc in collection('/db/apps/edoc/data/repertorium')//tei:persName[@ref != '']
    return distinct-values($doc/@ref)

let $items := for $v in $vals
    let $val := xmldb:decode($v)
    let $name := replace(xstring:substring-after-last($val, '/'), '_', ' ')
    let $idv := translate(xstring:substring-after(xstring:substring-after-last($val, '/'), '#'), ' ()%,&amp;?=+:"', '_')
    let $id := if($idv castable as xs:integer) then 'i' || $idv else $idv
    
    return if (contains($v, 'wikipedia')) then
        let $req := "https://www.wikidata.org/w/api.php?action=wbgetentities&amp;format=xml&amp;sites=enwiki|dewiki&amp;titles=" || $idv || "&amp;languages=de"
        let $data := doc($req)
        
        let $entry := if ($data/api/entities/entity/@id = '-1') then
                <person xml:id="{$id}" xmlns="http://www.tei-c.org/ns/1.0">
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
                                <tei:ref target="{$val}" />
                            </tei:bibl>
                        </tei:listBibl>
                        else ()
                    }
                </person>
            else
            let $bd := substring-after(substring-before($data[1]//*:mainsnak[@property='P569']/*:datavalue/*:value/@time, "Z"), '+')
            let $dd := substring-after(substring-before($data[1]//*:mainsnak[@property='P570']/*:datavalue/*:value/@time, "Z"), '+')
            
            return
            <person xmlns="http://www.tei-c.org/ns/1.0">
                <occupation>{normalize-space($data[1]//*:entity[1]/*:descriptions/*:description[@language='de']/@value)}</occupation>
                <idno type="URL" subtype="GND">{'http://d-nb.info/gnd/' || $data[1]//*:mainsnak[@property='P227']/*:datavalue/@value}</idno>
                <sex>{
                    let $reqP := "https://www.wikidata.org/w/api.php?action=wbgetentities&amp;format=xml&amp;sites=enwiki|dewiki&amp;ids=" || 
                            $data[1]//*:mainsnak[@property='P21']/*:datavalue/*:value/@id
                            || "&amp;languages=en"
                        
                        return substring(doc($reqP)//*:entity[1]/*:labels/*:label[1]/@value, 1, 1)
                }</sex>
                <birth when="{substring-before($bd, 'T')}">
                    {format-date(xs:dateTime($bd), "[D0]. [MNn] [Y]", "de", (), ())}
                    <placeName>{
                        let $reqP := "https://www.wikidata.org/w/api.php?action=wbgetentities&amp;format=xml&amp;sites=enwiki|dewiki&amp;ids=" || 
                            $data[1]//*:mainsnak[@property='P19']/*:datavalue/*:value/@id
                            || "&amp;languages=de"
                        
                        return (
                            attribute ref {'http://d-nb.info/gnd/' || doc($reqP)//*:entity[1]//*:mainsnak[@property='P227']/*:datavalue/@value},
                            xs:string(doc($reqP)//*:entity[1]/*:labels/*:label[1]/@value)
                        )
                    }</placeName>
                </birth>
                <death when="{substring-before($dd, 'T')}">
                    {format-date(xs:dateTime($dd), "[D0]. [MNn] [Y]", "de", (), ())}
                    <placeName>{
                        let $reqP := "https://www.wikidata.org/w/api.php?action=wbgetentities&amp;format=xml&amp;sites=enwiki|dewiki&amp;ids=" || 
                            $data[1]//*:mainsnak[@property='P20']/*:datavalue/*:value/@id
                            || "&amp;languages=de"
                        
                        return (
                            attribute ref {'http://d-nb.info/gnd/' || doc($reqP)//*:entity[1]//*:mainsnak[@property='P227']/*:datavalue/@value},
                            xs:string(doc($reqP)//*:entity[1]/*:labels/*:label[1]/@value)
                        )
                    }</placeName>
                </death>
            </person>
        
(:return xmldb:store('/db/apps/edoc/data', 'list-person.xml', <tei:listPerson>{$items}</tei:listPerson>):)
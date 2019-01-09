xquery version "3.0";

declare namespace tei		= "http://www.tei-c.org/ns/1.0";
declare namespace xlink	= "http://www.w3.org/1999/xlink";
declare namespace meta	= "https://github.com/dariok/wdbplus/wdbmeta";

let $filename := if (request:get-uploaded-file-name('file'))
		then request:get-uploaded-file-name('file')
		else if (request:get-parameter('filename', '')) then request:get-parameter('filename', '')
		else ''
			
	return if (request:is-multipart-content())
		then
			let $origFileData := string(request:get-uploaded-file-data('file'))
			let $origFileData := util:base64-decode($origFileData)
			(:let $origFileDataWithout := concat('<?xml', substring-after($origFileData, '<?xml'))
			(\: Das Problem der Entitäten muß erst einmal offen bleiben :\)
			let $oFDW := util:parse($origFileDataWithout):)
			let $ofdw := "<T" || substring-after($origFileData, '<T')
			let $d2 := replace($ofdw, "&amp;([^;]+);", "ln:$1,")
			let $d3 := replace($d2, 'ln:amp,', '&amp;amp;')
			let $data := replace($d2, 'ln:md,', '–')
			let $oFDW := util:parse($data)
			
			let $xslt := doc('/db/apps/edoc/data/repertorium/xslt/p4p5.xsl')
			
			let $params := <parameters>
					<param name="server" value="eXist"/>
					<param name="fileid" value="{substring-before($filename, '.xml')}"/>
				</parameters>
			(: ambiguous rule match soll nicht zum Abbruch führen :)
			let $attr := <attributes><attr name="http://saxon.sf.net/feature/recoveryPolicyName" value="recoverSilently" /></attributes>
			let $resultData := try {
				transform:transform($oFDW/*:TEI.2, $xslt, $params, $attr, "expand-xincludes=no")
			} catch * {
				let $err :=
					<error xmlns="https://github.com/dariok/wdbplus/debug" where="repertorium/scripts/convert/convert2.xql"
						when="{current-dateTime()}">
						<code>{$err:code}</code>
						<description>{$err:description}</description>
						<location>{$err:line-number}:{$err:column-number}</location>
						<additional>{$err:additional}</additional>
					</error>
				let $st := update insert $err into doc("/db/apps/edoc/repertorium/debug.xml")/*:errors
					
				return '<li> ' || $err:code || ": " || $err:description || '</li>' || "\n " || $err:line-number || ':' || $err:column-number || "\n a:" || $err:additional
			}
			
			let $storeData := if($resultData/tei:TEI)
				then $resultData/tei:TEI
				else $resultData
			
			let $store := try {
				let $login := xmldb:login('/db/apps/edoc/data/repertorium/texts', 'repertorium', 'repertorium')
				let $debugStore := xmldb:store('/db/apps/edoc/data/repertorium/texts', $filename, $storeData[self::tei:TEI])
				let $perm := sm:chown($debugStore, 'repertorium:repertorium')
				let $mod := sm:chmod($debugStore, 'rw-rw-r--')
				return $debugStore
			} catch * {
				let $err :=
							<error xmlns="https://github.com/dariok/wdbplus/debug" where="repertorium/scripts/convert/convert2.xql"
								when="{current-dateTime()}">
								<code>{$err:code}</code>
								<description>{$err:description}</description>
								<location>{$err:line-number}:{$err:column-number}</location>
								<additional>{$err:additional}</additional>
							</error>
				let $st := update insert $err into doc("/db/apps/edoc/repertorium/debug.xml")/*:errors
					
				return '<li> ' || $err:code || ": " || $err:description || '</li>' || "\n " || $err:line-number || ':' || $err:column-number || "\n a:" || $err:additional
			}
			
			let $id := $resultData/@xml:id
			let $title := if (contains($resultData//tei:title[1], '::'))
				then normalize-space(substring-before($resultData//tei:title[1], '::'))
				else normalize-space($resultData//tei:title[1])
			let $location := substring-after($store, 'texts/')
			
			(: Daten in die wdbmeta einfügen :)
			let $meta := doc('/db/apps/edoc/data/repertorium/wdbmeta.xml')
			let $file := <file xmlns="https://github.com/dariok/wdbplus/wdbmeta" path="{concat('texts/',$location)}"
				xml:id="{$id}"/>
			let $view := <view xmlns="https://github.com/dariok/wdbplus/wdbmeta" label="{$title}" file="{$id}"/>
			
			let $upd1 := if (not($meta//meta:file[@xml:id=$id]))
				then update insert $file into $meta//meta:files
				else ()
			let $upd2 := if ($meta//meta:view[@file = $id])
				then update replace $meta//meta:view[@file = $id]/@label with $title
				else update insert $view into $meta//meta:struct[@label = 'repertorium']
			let $target := concat('/exist/apps/edoc/view.html?id=', $id)
			return response:redirect-to($target)
		else 
			<h1>nee</h1>
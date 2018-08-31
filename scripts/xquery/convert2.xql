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
			let $origFileDataWithout := concat('<?xml', substring-after($origFileData, '<?xml'))
			(: Das Problem der Entitäten muß erst einmal offen bleiben :)
			let $oFDW := util:parse($origFileDataWithout)
			let $xslt := doc('/db/apps/edoc/data/repertorium/xslt/p4p5.xsl')
			
			let $params := <parameters>
					<param name="server" value="eXist"/>
					<param name="fileid" value="{substring-before($filename, '.xml')}"/>
				</parameters>
			(: ambiguous rule match soll nicht zum Abbruch führen :)
			let $attr := <attributes><attr name="http://saxon.sf.net/feature/recoveryPolicyName" value="recoverSilently" /></attributes>
			let $resultData := try {
				transform:transform($oFDW/*:TEI.2, $xslt, $params, $attr, "expand-xincludes=no") }
				catch * { '<ul><li> ' || $err:code || ": " || $err:description || '</li>' || "\n " || $err:line-number || ':' || $err:column-number || "\n a:" || $err:additional }
				
			let $login := xmldb:login('/db/apps/edoc/data/repertorium/texts', 'repertorium', 'repertorium')
			let $store := xmldb:store('/db/apps/edoc/data/repertorium/texts', $filename, $resultData)
			let $perm := sm:chown($store, 'repertorium:repertorium')
			let $id := $resultData/@xml:id
			let $title := if (contains($resultData//tei:title[1], '::'))
				then normalize-space(substring-before($resultData//tei:title[1], '::'))
				else normalize-space($resultData//tei:title[1])
			let $location := substring-after($store, 'texts/')
			
			(: Daten in die METS einfügen :)
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
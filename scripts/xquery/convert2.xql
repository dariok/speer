xquery version "3.0";

declare namespace tei		= "http://www.tei-c.org/ns/1.0";
declare namespace mets	= "http://www.loc.gov/METS/";
declare namespace xlink	= "http://www.w3.org/1999/xlink";

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
			let $xslt := doc('/db/edoc/ed000245/xslt/p4p5.xsl')
			
			let $params := <parameters>
					<param name="server" value="eXist"/>
					<param name="fileid" value="{substring-before($filename, '.xml')}"/>
				</parameters>
			(: ambiguous rule match soll nicht zum Abbruch führen :)
			let $attr := <attributes><attr name="http://saxon.sf.net/feature/recoveryPolicyName" value="recoverSilently" /></attributes>
			let $resultData := try {
				transform:transform($oFDW/*:TEI.2, $xslt, $params, $attr, "expand-xincludes=no") }
				catch * { '<ul><li> ' || $err:code || ": " || $err:description || '</li>' || "\n " || $err:line-number || ':' || $err:column-number || "\n a:" || $err:additional }
				
			let $login := xmldb:login('/db/edoc/ed000245/texts', 'guest', 'adf')
			let $store := xmldb:store('/db/edoc/ed000245/texts', $filename, $resultData)
			let $perm := sm:chown($store, 'guest:ed000245')
			let $id := $resultData/@xml:id
			let $title := if (contains($resultData//tei:title[1], '::'))
				then normalize-space(substring-before($resultData//tei:title[1], '::'))
				else normalize-space($resultData//tei:title[1])
			let $location := substring-after($store, '245/')
			
			(: Daten in die METS einfügen :)
			let $mets := doc('/db/edoc/ed000245/mets.xml')
			let $lastOrder := $mets//mets:div[@ORDER and position()=last()]/@ORDER
			let $order := format-number($lastOrder + 1, '000')
			let $metsFile :=
				<mets:file ID="{$id}" MIMETYPE="application/xml">
					<mets:FLocat LOCTYPE="URL" xlink:href="{$location}"/>
				</mets:file>
			let $metsDiv :=
				<mets:div LABEL="{$title}" ID="edoc_ed000245_{$order}" ORDER="{$order}">
					<mets:fptr FILEID="{$id}"/>
				</mets:div>
			let $upd1 := if (not($mets//mets:file[@ID=$id]))
				then update insert $metsFile into $mets//mets:fileGrp[@ID='transcript']
				else ()
			let $upd2 := if ($mets//mets:div[mets:fptr[@FILEID=$id]])
				then update replace $mets//mets:div[mets:fptr[@FILEID=$id]]/@LABEL with $title
				else update insert $metsDiv into $mets//mets:div[@ID='edoc_ed000245_dokumente']
			let $target := concat('/edoc/view.html?id=', $id)
			return response:redirect-to($target)
		else 
			<h1>nee</h1>
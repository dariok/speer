xquery version "3.0";

let $filename := if (request:get-uploaded-file-name('file'))
		then request:get-uploaded-file-name('file')
		else if (request:get-parameter('filename', '')) then request:get-parameter('filename', '')
		else ''
			
	return if (request:is-multipart-content())
		then
			let $origFileData := util:base64-decode(string(request:get-uploaded-file-data('file')))
			let $origFileDataWithout := substring-after($origFileData, '<?xml')
			let $oFDW := util:parse(concat('<?xml', $origFileDataWithout))
			let $xslt := doc('/db/edoc/ed000245/xslt/p4p5.xsl')
			
			let $params := <parameters><param name="server" value="eXist"/></parameters>
			(: ambiguous rule match soll nicht zum Abbruch führen :)
			let $attr := <attributes><attr name="http://saxon.sf.net/feature/recoveryPolicyName" value="recoverSilently" /></attributes>
			let $resultData := try {
				transform:transform($oFDW, $xslt, $params, $attr, "expand-xincludes=no") }
				catch * { '<ul><li> ' || $err:code || ": " || $err:description || '</li>' || "\n " || $err:line-number || ':' || $err:column-number || "\n a:" || $err:additional }
			
			return
				$resultData
		else 
			<h1>nee</h1>
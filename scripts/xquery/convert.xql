xquery version "3.0";

module namespace habq = "http://diglib.hab.de/ns/habq";

declare function habq:query() {
	let $collection := '/db/edoc/ed000245'
	return
		<div id="content">
			<form enctype="multipart/form-data" method="post" action="ed000245/scripts/xquery/convert2.xql">
				<fieldset>
					<legend>Upload von TEI-P4-Dateien:</legend>
					<input type="file" name="file"/>
					<input type="submit" value="Upload"/>
				</fieldset>
			</form>
		</div>
};

declare function habq:getTask() {
	let $bogus := <void/>
	return <h2>TEI-P4-Upload</h2>
};
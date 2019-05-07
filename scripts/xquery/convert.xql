xquery version "3.0";

module namespace wdbq = "https://github.com/dariok/wdbplus/wdbq";

declare function wdbq:query($map) {
	let $collection := '/db/apps/edoc/data/repertorium'
	return
		<div id="content">
			<form enctype="multipart/form-data" method="post" action="data/repertorium/scripts/xquery/convert2.xql">
				<fieldset>
					<legend>Upload von TEI-P4-Dateien:</legend>
					<input type="file" name="file"/>
					<input type="submit" value="Upload"/>
				</fieldset>
			</form>
		</div>
};

declare function wdbq:getTask() {
	let $bogus := <void/>
	return <h2>TEI-P4-Upload</h2>
};
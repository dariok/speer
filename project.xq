xquery version "3.1";

module namespace wdbPF	= "https://github.com/dariok/wdbplus/projectFiles";
declare namespace wdb	= "https://github.com/dariok/wdbplus/wdb";
declare namespace tei	= "http://www.tei-c.org/ns/1.0";

(:declare function wdbPF:getProjectFiles ( $model as map(*) ) as node()* {
    (
        <script src="{$wdb:edocBaseURL}/dat/repertorium/scripts/project.js" />
    )
};:)

(:declare function wdbPF:getHeader ( $model as map(*) ) as node()* {
	let $file := doc($model("fileLoc"))
	
	return (
		<h1>
			{$file/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'main']/text()}</h1>,
		<h2>{$file/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'num']/text()}</h2>,
		<span class="dispOpts">[<a href="javascript:anno()">annotieren</a>]</span>
	)
};:)
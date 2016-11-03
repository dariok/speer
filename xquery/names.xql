xquery version "3.0";

declare namespace tei		= "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace hab="http://diglib.hab.de/ns/hab" at "/db/edoc/modules/app.xql";

declare option output:method "html5";
declare option output:media-type "text/html";

let $ed := collection('/db/edoc/ed000245')
let $what := request:get-parameter('q', '')


return
<html data-template="hab:getEE">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><!-- Kurztitel als title; 2016-05-24 DK -->
		<meta data-template="hab:getEENr"/>
		<title data-template="hab:pageTitle"/>
		<link data-template="hab:getCSS"/>
		<script src="http://code.jquery.com/jquery-2.2.4.js" type="text/javascript"/>
		<script src="{$hab:edocBase}/resources/scripts/function.js" type="text/javascript"/>
		<!-- include project-specific functions -->
		<script data-template="hab:getJS" />
	</head>
	<body>
		<table>
			<tr>
				<th>Name</th>
				<th>Texte</th>
			</tr>
			
			{for $n in $ed//tei:name[@type=$what]
				let $name := normalize-space($n) 
				group by $name
				order by $name
				
				return
					<tr>
						<td>{$name[1]}</td>
						<td>{for $m in $n
							let $f := base-uri($m)
							group by $f
							let $id := $m/ancestor::tei:TEI/@xml:id
							
							return <a style="display: inline-block;" href="{concat($hab:edocBase, '/view.html?id=', $id)}">{$f}</a>
						}</td>
					</tr>
			}
		</table>
	</body>
</html>
xquery version "3.0";

declare namespace tei		= "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace hab="http://diglib.hab.de/ns/hab" at "/db/edoc/modules/app.xql";

declare option output:method "html5";
declare option output:media-type "text/html";

let $ed := collection('/db/edoc/ed000245')
let $what := request:get-parameter('q', '')


return
	<div>
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
	</div>
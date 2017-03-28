xquery version "3.0";

module namespace habq = "http://diglib.hab.de/ns/habq";

declare namespace tei				= "http://www.tei-c.org/ns/1.0";
import module namespace hab = "http://diglib.hab.de/ns/hab" at "/db/apps/wdb/modules/app.xql";


declare function habq:query() {
	let $ed := collection('/db/edoc/ed000245')
	let $what := request:get-parameter('q', '')
	
	return
		<div id="content">
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
};

declare function habq:getTask() {
	let $what := request:get-parameter('q', '')
	
	return <h2>{
		switch($what)
			case "place" return "Orte"
			case "person" return "Personen"
			case "org" return "Organisationen"
			default return "Register"
		}</h2>
};
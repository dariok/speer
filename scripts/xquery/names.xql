xquery version "3.0";

module namespace wdbq = "https://github.com/dariok/wdbplus/wdbq";

declare namespace tei				= "http://www.tei-c.org/ns/1.0";


declare function wdbq:query($map) {
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
								let $link := "view.html?id=" || $id
								
								return <a style="display: inline-block;" href="{$link}">{$f}</a>
							}</td>
						</tr>
				}
			</table>
		</div>
};

declare function wdbq:getTask() {
	let $what := request:get-parameter('q', '')
	
	return <h2>{
		switch($what)
			case "place" return "Orte"
			case "person" return "Personen"
			case "org" return "Organisationen"
			default return "Register"
		}</h2>
};
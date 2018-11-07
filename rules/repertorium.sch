<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
	xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
	<ns prefix="tei" uri="http://www.tei-c.org/ns/1.0" />
	
	<!--<pattern id="name-type">
		<rule context="tei:name/@type">
			<report test="not(. = ('person', 'place', 'org'))">
				Für name sind die Typen „person“, „place“ und „org“ vorgesehen. Möglichst durch tei:rs ersetzen.
			</report>
		</rule>
	</pattern>-->
	
	<pattern id="ref">
		<rule context="tei:ref[@target]">
			<assert test="starts-with(@target, 'ln:')
				or starts-with(@target, 'http')
				or matches(@target, '\.xml')
				or starts-with(@target, '#')">
				Fehler im ref. Muß mit „ln:“ beginnen (ehem. Entitäten), auf eine XML-Datei verweisen oder eine URL sein
			</assert>
		</rule>
	</pattern>
</schema>
<!-- Introduction-XSL für \\edoc\ed000216 Karlstadt-Edition -->
<xsl:stylesheet xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:mets="http://www.loc.gov/METS/" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://www.w3.org/1999/XSL/Transform http://www.w3.org/2007/schema-for-xslt20.xsd"
	exclude-result-prefixes="html tei mets xlink xsl exist xsi" version="2.0">
	
	<!-- erstellt für ed000245 basierend auf dem Skript aus ed000216; 2016-08-00 DK -->
	<!-- TODO weiter anpassen und ungenutzte empfehlen; 2016-11-02 DK -->
	
	<!-- Imports werden über tei-common abgewickelt; 2015/10/23 DK -->
	<xsl:import href="tei-common.xsl"/>
	<!-- für bei HTML und TeX gemeinsame Formatierungen; 2016-05-26 DK -->
	<xsl:import href="introduction-common.xsl"/>
	<!-- Ausgabe nach HTML5; mit passendem doctype auch 4.01 möglich. 2016-03-20 DK -->
	<!--<xsl:output encoding="UTF-8" indent="yes" method="html" doctype-public="-//W3C//DTD HTML 4.01//EN"
		doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>-->
	<xsl:output encoding="UTF-8" indent="no" method="html" doctype-system="about:legacy-compat"/>
	<!-- mehrere param nach common ausgelagert; 2016-05-27 DK -->
	<xsl:param name="footerXSL">
		<xsl:value-of select="concat($baseDir, '/tei-introduction.xsl')" disable-output-escaping="no"/>
	</xsl:param>
	<!-- Auflösung von absoluter URI via Katalog; 2016-06-24 DK -->
	<xsl:variable name="metsfile">
		<xsl:value-of select="concat($baseDir, '/mets.xml')" disable-output-escaping="no"/>
	</xsl:variable>
	
	<!-- neu mit mode="content" enthält nur noch den tatsächlichen Inhalt; das Gerüst wird über Templating bzw. in common erstellt; 2016-07-14 DK -->
	<xsl:template match="/" mode="content" as="item()*">
		<!-- navbar in den container verschoben; 2016-07-11 DK -->
		<!-- TODO navBar ausblendbar machen -->
		<!-- TODO navBar um Ansichtsoptionen und Link zu weiteren Ausgabevarianten erweitern -->
		<div id="navBar">
			<h1>
				<xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:fileDesc"/>
			</h1>
			<span class="dispOpts">[<a id="liSB" href="javascript:toggleSidebar();">Navigation einblenden</a>]</span>
			<hr/>
		</div>
		<div id="content">
			<p class="editors">Transkription <xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor"/>
			</p>
			<xsl:apply-templates select="tei:TEI/tei:text/tei:body"/>
			<xsl:call-template name="footnotes"/>
		</div>
		<!-- Creative Commons Hinweis (JB) -->
		<div class="ccsec">
			<!--<xsl:text>© </xsl:text>
		<xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author"/>
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="document($metsfile)//mets:rightsMD[@ID='rmd_edoc_ed000216_CC']/mets:mdRef/@xlink:href"/>
			</xsl:attribute>
			<img class="ccimg" src="http://diglib.hab.de/images/cc-by-sa.png" alt="image CC BY-SA licence"/>
		</a>-->
		</div>
	</xsl:template>
	
	<!-- neu 2016-09-23 DK -->
	<xsl:template match="tei:fileDesc">
		<xsl:apply-templates select="tei:titleStmt/tei:title"/>
		<h2><xsl:apply-templates select="tei:sourceDesc/tei:biblStruct"/></h2>
	</xsl:template>
	
	<xsl:template match="@n" as="item()*">
		<xsl:choose>
			<xsl:when test="starts-with(., '0')">
				<xsl:value-of select="substring-after(., '0')" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- neu 2016-09-23 DK -->
	<xsl:template match="tei:div[@xml:id = 'Editorial' or @xml:id = 'Text']">
		<div>
			<h3><xsl:apply-templates select="tei:head | tei:div[@n='1.0']/tei:head" mode="head" /></h3>
			<xsl:apply-templates select="tei:div | tei:p" />
		</div>
	</xsl:template>
	
	<xsl:template match="tei:head" />
	
	<xsl:template match="tei:div[not(@xml:id = 'Editorial' or @xml:id = 'Text')]" as="item()*">
		<xsl:variable name="id">
			<xsl:text disable-output-escaping="no">hd</xsl:text>
			<xsl:number level="any" format="1"/>
		</xsl:variable>
		<div>
			<xsl:attribute name="id">
				<xsl:choose>
					<xsl:when test="@xml:id">
						<xsl:value-of select="@xml:id"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$id"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="not(@n='1.0')">
				<h4>
					<xsl:apply-templates select="tei:head" mode="heading"/>
					<a href="#" class="upRef">↑</a>
				</h4>
			</xsl:if>
			<xsl:apply-templates select="child::node()"/>
		</div>
	</xsl:template>
	
	<!-- *** Pointer *** -->
	<!-- Change: ptr[@type='wdb'] ausgelagert nach tei-common, 2015/10/23 DK -->
	<xsl:template match="tei:cit/tei:ptr[@type = 'wdb'][@target]" as="item()*">
		<!-- angepaßt auf neues gemeinsames Template; 2016-05-23 DK -->
		<xsl:call-template name="footnoteLink">
			<xsl:with-param name="type">fn</xsl:with-param>
			<xsl:with-param name="position">t</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="tei:cit/tei:ptr/@target" as="item()*">
		<xsl:variable name="fileName">
			<xsl:choose>
				<xsl:when test="contains(., '#')">
					<xsl:value-of select="substring-before(., '#')" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="." disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="path">
			<xsl:value-of select="substring($fileName, 4)" disable-output-escaping="no"/>
		</xsl:variable>
		<xsl:variable name="fragment">
			<xsl:if test="contains(., '#')">
				<xsl:value-of select="concat('#', substring-after(., '#'))" disable-output-escaping="no"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="eeNumber">
			<xsl:value-of select="document($fileName, .)/tei:TEI/@n" disable-output-escaping="no"/>
		</xsl:variable>
		<xsl:variable name="type">
			<xsl:value-of select="substring-after(substring-before($path, '.'), '_')" disable-output-escaping="no"/>
		</xsl:variable>
		<!-- TODO wenn alles fertig ist, in endgültige Form bringen (mit Funktionsaufruf, PURL etc.)! -->
		<a href="http://diglib.hab.de/content.php?dir=edoc/ed000216&amp;distype=optional&amp;xml={$path}&amp;xsl=tei-{$type}.xsl{$fragment}">
			<xsl:text disable-output-escaping="no">KGK </xsl:text>
			<xsl:value-of select="$eeNumber" disable-output-escaping="no"/>
		</a>
	</xsl:template>
	<xsl:template match="tei:ptr[@type = 'link'][@target]" as="item()*">
		<xsl:text disable-output-escaping="no"> [</xsl:text>
		<a href="{@target}" target="_blank">Link</a>
		<xsl:text disable-output-escaping="no">]</xsl:text>
		<xsl:apply-templates select="child::node()"/>
	</xsl:template>
	<xsl:template match="tei:ptr[@type = 'digitalisat'][@target]" as="item()*">
		<xsl:text disable-output-escaping="no"> [</xsl:text>
		<a href="{@target}" target="_blank">Digitalisat</a>
		<xsl:text disable-output-escaping="no">]</xsl:text>
		<xsl:apply-templates select="child::node()"/>
	</xsl:template>
	<xsl:template match="tei:ptr[@type = 'gbv'][@cRef]" as="item()*">
		<xsl:variable name="gbv">
			<xsl:text disable-output-escaping="no">http://gso.gbv.de/DB=2.1/PPN?PPN=</xsl:text>
		</xsl:variable>
		<xsl:text disable-output-escaping="no"> [</xsl:text>
		<a href="{concat($gbv,@cRef)}" target="_blank">GBV</a>
		<xsl:text disable-output-escaping="no">]</xsl:text>
		<xsl:apply-templates select="child::node()"/>
	</xsl:template>
	<xsl:template match="tei:ptr[@type = 'opac'][@cRef]" as="item()*">
		<xsl:variable name="opac">
			<xsl:text disable-output-escaping="no">http://opac.lbs-braunschweig.gbv.de/DB=2/PPN?PPN=</xsl:text>
		</xsl:variable>
		<xsl:text disable-output-escaping="no"> [</xsl:text>
		<a href="{concat($opac,@cRef)}" target="_blank">OPAC</a>
		<xsl:text disable-output-escaping="no">]</xsl:text>
		<xsl:apply-templates select="child::node()"/>
	</xsl:template>
	<!-- template tei:ref[not(@type='isil' or @type='biblical')] gelöscht; 2016-05-26 DK -->
	<!-- aufgeräumt; 2016-05-26 DK -->
	<!-- mit transcript zusammengelegt in common; 2016-07-26 DK -->
	<!--<xsl:template match="tei:rs">
		<xsl:choose>
			<xsl:when test="@type='person'">
				<a href="javascript:show_annotation('{$dir}','http://diglib.hab.de/edoc/ed000216/personenregister.xml',
					'http://diglib.hab.de/edoc/ed000216/show-person.xsl','{substring(@ref,2)}',300,500)">
				<xsl:apply-templates/>
				</a>
			</xsl:when>
			<xsl:when test="@type='place'">
				<!-\- TODO show-place.xsl -\->
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>-->
	<!-- Sonderdarstellung -->
	<!-- template tei:bibl/tei:title gelöscht; 2016-05-26 DK -->
	<!-- template match="tei:ex" nach common ausgelagert; 2016-05-31 DK -->
	<!-- nicht für parent::tei:additions; DK 2015-12-14 -->
	<!-- p[@rend='blockquote'] gibt es nicht; 2016-05-26 DK -->
	<xsl:template match="tei:p[not(parent::tei:additions or parent::tei:physDesc)]" as="item()*">
		<p class="content">
			<xsl:apply-templates select="child::node()"/>
		</p>
	</xsl:template>
	
	<!-- neu 2016-11-02 DK -->
	<!-- TODO anpassen an weitere Varianten -->
	<xsl:template match="tei:pb">
		<a>
			<xsl:attribute name="href" select="@facs" />
			<xsl:value-of select="@n"/>
		</a>
	</xsl:template>
	
	<!-- template tei:anchor ausgelagert nach common; 2016-05-26 DK -->
	<!-- Angleichung an die Ausgabe der PDF; 2016-05-26 -->
	<xsl:template match="tei:monogr" as="item()*">
		<xsl:text>In: </xsl:text>
		<xsl:apply-templates select="tei:author" />
		<xsl:text>: </xsl:text>
		<xsl:apply-templates select="tei:title" />
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="tei:imprint/tei:pubPlace"/>
		<xsl:apply-templates select="tei:imprint/tei:publisher"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="tei:imprint/tei:date"/>
		<xsl:choose>
			<xsl:when test="tei:biblScope">
				<xsl:text>, </xsl:text>
				<xsl:apply-templates select="tei:biblScope"/>
				<xsl:if test="not(ends-with(tei:biblScope, '.'))">
					<xsl:text>.</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>.</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- template tei:extent nach introduction-common ausgelagert; 2016-05-26 DK -->
	<!-- wieder eingelagert, da offenkundig das <br> problematisch ist; 2016-08-01 DK -->
	<!-- Verwendung nicht einheitlich; idR sollten kein Punkt stehen. 2015-12-10 DK -->
	<xsl:template match="tei:extent" as="item()*">
		<br/>
		<xsl:apply-templates select="child::node()"/>
		<xsl:if test="not(substring(., string-length(.)) = '.')">
			<xsl:text disable-output-escaping="no">.</xsl:text>
		</xsl:if>
	</xsl:template>
	<!-- tei:head ausgeben, falls vorhanden; 2015-12-14 DK -->
	<!-- Angleichung an PDF; 2016-05-26 DK -->
	<xsl:template match="tei:msDesc[string-length(tei:msIdentifier) &gt; 0 or count(tei:msIdentifier/*) &gt; 0]" as="item()*">
		<xsl:apply-templates select="tei:msIdentifier/tei:repository"/>
		<xsl:text disable-output-escaping="no">, </xsl:text>
		<xsl:apply-templates select="tei:msIdentifier/tei:idno"/>
		<xsl:if test="tei:msContents/tei:msItem/tei:locus">
			<xsl:text disable-output-escaping="no">, </xsl:text>
			<xsl:apply-templates select="tei:msContents/tei:msItem/tei:locus"/>
		</xsl:if>
		<!-- note vor den Punkt, analog PDF; 2016-07-12 DK -->
		<xsl:apply-templates select="tei:msContents/tei:msItem/tei:note"/>
		<xsl:text disable-output-escaping="no">. </xsl:text>
		<!-- Anfang Anpassung Ausgabe nach Wünschen UB zu Nr. 16 (31.12.15); 2016-02-02 DK -->
		<!-- UB möchte jetzt keine Klammern mehr (Korr. an mich); 2016-04-25 DK -->
		<!-- UB möchte vielleicht doch Klammern (026); 2016-04-26 DK -->
		<xsl:if test="tei:physDesc/tei:handDesc/tei:handNote">
			<xsl:text disable-output-escaping="no">(</xsl:text>
			<xsl:apply-templates select="tei:physDesc/tei:handDesc/tei:handNote[1]"/>
			<xsl:text disable-output-escaping="no">)</xsl:text>
		</xsl:if>
		<xsl:if test="count(tei:physDesc/tei:handDesc/tei:handNote) &gt; 1">
			<br/>
			<xsl:apply-templates select="tei:physDesc/tei:handDesc/tei:handNote[position() &gt; 1]"/>
		</xsl:if>
		<xsl:if test="tei:physDesc/tei:additions">
			<br/>
			<xsl:apply-templates select="tei:physDesc/tei:additions"/>
		</xsl:if>
		<!-- Ende Anpassung Ausgabe nach Wünschen UB zu Nr. 16 (31.12.15); 2016-02-02 DK -->
	</xsl:template>
	<!-- bibliographische Liste listBibl -->
	<!-- Überschriften in Singular oder Plural je nach Anzahl der Angaben (JB) -->
	<!-- Verkürzt; 2015-12-14 DK -->
	<!-- angepaßt an PDF; 2016-05-26 DK -->
	<xsl:template match="tei:listBibl[@type = 'sigla']" as="item()*">
		<xsl:if test="count(parent::*/tei:listBibl[tei:msDesc]) &lt; 2">
			<h4>
				<xsl:choose>
					<!-- bei mehreren Mss (Beilagen) wird Überschrift nicht wiederholt (eigenes head) -->
					<xsl:when test="count(tei:msDesc) &gt; 1">
						<xsl:text disable-output-escaping="no">Handschriften:</xsl:text>
					</xsl:when>
					<xsl:when test="count(tei:msDesc) = 1">
						<xsl:text disable-output-escaping="no">Handschrift:</xsl:text>
					</xsl:when>
					<xsl:when test="count(tei:bibl) &gt; 1 or count(tei:biblStruct) &gt; 1">
						<xsl:text disable-output-escaping="no">Frühdrucke:</xsl:text>
					</xsl:when>
					<xsl:when test="count(tei:bibl) = 1 or count(tei:biblStruct) = 1">
						<xsl:text disable-output-escaping="no">Frühdruck:</xsl:text>
					</xsl:when>
				</xsl:choose>
			</h4>
		</xsl:if>
		<xsl:if test="tei:msDesc">
			<xsl:for-each select="tei:msDesc">
				<xsl:if test="tei:head">
					<h4>
						<xsl:apply-templates select="tei:head"/>
						<xsl:text disable-output-escaping="no">:</xsl:text>
					</h4>
				</xsl:if>
				<div class="exemplar">
					<span class="siglum">
						<xsl:if test="tei:msIdentifier/tei:altIdentifier[@type = 'siglum']/tei:idno[1]">
							<xsl:text disable-output-escaping="no">[</xsl:text>
							<xsl:apply-templates select="tei:msIdentifier/tei:altIdentifier[@type = 'siglum']/tei:idno[1]"/>
							<xsl:text disable-output-escaping="no">:]</xsl:text>
						</xsl:if>
					</span>
					<xsl:apply-templates select="."/>
					<xsl:if test="tei:physDesc/tei:p">
						<br/>
						<xsl:apply-templates select="tei:physDesc/tei:p"/>
					</xsl:if>
				</div>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="tei:bibl or tei:biblStruct">
			<xsl:for-each select="tei:bibl | tei:biblStruct">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<!-- angepaßt an PDF; 2016-05-26 DK -->
	<!-- Ausgabe nicht mehr als Liste auf Wunsch von HB. 2015-11-05 DK -->
	<xsl:template match="tei:listBibl[not(@type = 'sigla')]" as="item()*">
		<xsl:if test="preceding-sibling::*[1][self::tei:listBibl[not(@type = 'sigla')]]">
			<br/>
		</xsl:if>
		<xsl:if test="@type">
			<h5>
				<xsl:choose>
					<xsl:when test="@type = 'editions' and count(tei:bibl) &gt; 1">Editionen:</xsl:when>
					<xsl:when test="@type = 'editions' and count(tei:bibl) = 1">Edition:</xsl:when>
					<xsl:when test="@type = 'literatur'">Literatur:</xsl:when>
					<xsl:when test="@type = 'uebersetzung'">Übersetzung:</xsl:when>
					<xsl:when test="@type = 'regest'">Regest:</xsl:when>
				</xsl:choose>
				<xsl:text disable-output-escaping="no"> </xsl:text>
			</h5>
		</xsl:if>
		<ul class="lit">
			<xsl:for-each select="tei:msDesc | tei:bibl[@ref or text() or tei:ptr[@type = 'wdb']]">
				<li>
					<xsl:apply-templates select="."/>
					<xsl:if test="not(substring(., string-length(.)) = '.') and not(tei:ptr)">
						<xsl:text disable-output-escaping="no">.</xsl:text>
					</xsl:if>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>
	<!-- templates analytic, monogr gelöscht, Aufgaben übernimmt biblStruct[@type='imprint']; 2016-05-26 DK -->
	<!-- template tei:author[not(parent::tei:titleStmt)] | tei:editor[not(parent::tei:titleStmt)]> nach
		introduction-common ausgelagert; 2016-05-26 DK -->
	<!-- (named) template für tei:titleStmt/tei:author nach introduction-common ausgelagert; 2016-05-26 DK -->
	<!-- template tei:lb[ancestor::tei:biblStruct[1]] gelöscht; 2016-05-26 DK -->
	<!-- lb in langen quote wird als Umbruch ausgegeben; 2015-11-23 DK -->
	<xsl:template match="tei:lb[parent::tei:quote]" as="item()*">
		<br/>
	</xsl:template>
	
	<!--<xsl:template match="tei:imprint" as="item()*">
		<br/>
		<xsl:apply-templates select="tei:pubPlace"/>
		<xsl:apply-templates select="tei:publisher"/>
		<xsl:apply-templates select="tei:date"/>
		<xsl:choose>
			<xsl:when test="following-sibling::tei:biblScope">
				<xsl:text disable-output-escaping="no">, </xsl:text>
				<xsl:apply-templates select="following-sibling::tei:biblScope"/>
				<xsl:text disable-output-escaping="no">.</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="no">.</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>-->
	
	<!-- template match="tei:pubPlace" ausgelagert nach introduction-common; 2016-05-26 DK -->
	<!-- template match="tei:publisher"ausgelagert nach introduction-common; 2016-05-26 DK -->
	<!-- template match="tei:date | tei:placeName" ausgelagert nach introduction-common -->
	<xsl:template match="tei:idno[not(@type = 'siglum' or parent::tei:altIdentifier)]" as="item()*">
		<xsl:choose>
			<!-- VD-16-Link korrigiert; 2016-03-15 DK -->
			<!-- eckige Klammern entfernt; 2016-03-16 DK -->
			<xsl:when test="@type = 'vd16'">
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="concat($vd16, translate(., ' ', '+'))" disable-output-escaping="no"/>
					</xsl:attribute>
					<xsl:attribute name="target">_blank</xsl:attribute>
					<xsl:text disable-output-escaping="no">VD 16 </xsl:text>
					<xsl:value-of select="." disable-output-escaping="no"/>
				</a>
			</xsl:when>
			<!-- eckige Klammern entfernt; 2016-03-16 DK -->
			<xsl:when test="@type = 'vd17'">
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="$vd17" disable-output-escaping="no"/>
						<xsl:value-of select="." disable-output-escaping="no"/>
					</xsl:attribute>
					<xsl:attribute name="target">_blank</xsl:attribute>
					<xsl:text disable-output-escaping="no">VD17</xsl:text>
				</a>
			</xsl:when>
			<xsl:when test="@type = 'gbv'">
				<xsl:text disable-output-escaping="no"> [</xsl:text>
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="$gbv" disable-output-escaping="no"/>
						<xsl:value-of select="." disable-output-escaping="no"/>
					</xsl:attribute>
					<xsl:attribute name="target">_blank</xsl:attribute>
					<xsl:text disable-output-escaping="no">GBV</xsl:text>
				</a>
				<xsl:text disable-output-escaping="no">]</xsl:text>
			</xsl:when>
			<xsl:when test="@type = 'swb'">
				<xsl:text disable-output-escaping="no"> [</xsl:text>
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="$swb" disable-output-escaping="no"/>
						<xsl:value-of select="." disable-output-escaping="no"/>
					</xsl:attribute>
					<xsl:attribute name="target">_blank</xsl:attribute>
					<xsl:text disable-output-escaping="no">SWB</xsl:text>
				</a>
				<xsl:text disable-output-escaping="no">]</xsl:text>
			</xsl:when>
			<xsl:when test="@type = 'opac'">
				<xsl:text disable-output-escaping="no"> [</xsl:text>
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="$opac" disable-output-escaping="no"/>
						<xsl:value-of select="." disable-output-escaping="no"/>
					</xsl:attribute>
					<xsl:attribute name="target">_blank</xsl:attribute>
					<xsl:text disable-output-escaping="no">OPAC</xsl:text>
				</a>
				<xsl:text disable-output-escaping="no">]</xsl:text>
			</xsl:when>
			<xsl:when test="@type = 'signatur'">
				<xsl:apply-templates select="child::node()"/>
				<xsl:if test="following-sibling::tei:idno[@type = 'signatur']">
					<xsl:text disable-output-escaping="no"> und </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@type = 'siglum'">
				<!--nicht ausgeben, da schon vor dem Titel ausgegeben-->
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- Punkt am Ende hinzugefügt; 2015-11-09 DK -->
	<!-- Ausgabe kursiviert zwecks Angleichung an PDF; 2015-11-10 DK -->
	<xsl:template match="tei:list[ancestor::tei:note[@type = 'copies']]" as="item()*">
		<br/>
		<h5>Editionsvorlage: </h5>
		<xsl:apply-templates select="tei:item[@n = 'editionsvorlage']/tei:label"/>
		<xsl:text disable-output-escaping="no">, </xsl:text>
		<xsl:apply-templates select="tei:item[@n = 'editionsvorlage']/tei:idno"/>
		<xsl:if test="tei:item[@n = 'editionsvorlage']/tei:note">
			<xsl:text disable-output-escaping="no"> (</xsl:text>
			<xsl:apply-templates select="tei:item[@n = 'editionsvorlage']/tei:note"/>
			<xsl:text disable-output-escaping="no">)</xsl:text>
		</xsl:if>
		<xsl:text disable-output-escaping="no">.</xsl:text>
		<xsl:if test="child::tei:item[not(@n = 'editionsvorlage')]">
			<br/>
			<i>
				<xsl:text disable-output-escaping="no">Weitere Exemplare: </xsl:text>
			</i>
			<xsl:for-each select="tei:item[not(@n = 'editionsvorlage')]">
				<xsl:apply-templates select="tei:label"/>
				<xsl:text disable-output-escaping="no">, </xsl:text>
				<xsl:apply-templates select="tei:idno"/>
				<!-- Klammern hinzugefügt auf Wunsch HB; 2015-11-14 DK -->
				<!-- diese werden im Template berücksichtigt; 2016-07-12 DK -->
				<xsl:apply-templates select="tei:note"/>
				<xsl:if test="position() != last()">
					<!--<xsl:text>	– </xsl:text>-->
					<xsl:text disable-output-escaping="no">. — </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text disable-output-escaping="no">.</xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:template match="tei:note[@type = 'references']" as="item()*">
		<!-- Text entfernt zur gemeinsamen Ausgabe; 2016-05-17 DK -->
		<!-- Ausgabe mit Geviertstrich nach Festlegung Sitzung 2015-11-25 DK -->
		<xsl:for-each select="tei:listBibl/tei:bibl[@ref or text()]">
			<li>
				<xsl:apply-templates select="."/>
				<xsl:if test="not(substring(., string-length(.)) = '.')">
					<xsl:text disable-output-escaping="no">.</xsl:text>
				</xsl:if>
			</li>
		</xsl:for-each>
	</xsl:template>
	<!-- Listengenerierung angepaßt; 2016-05-26 DK -->
	<xsl:template match="tei:list[not(ancestor::tei:note[@type = 'copies'])]" as="item()*">
		<i>
			<xsl:value-of select="tei:head" disable-output-escaping="no"/>
		</i>
		<dl>
			<xsl:apply-templates select="child::node()"/>
		</dl>
	</xsl:template>
	<xsl:template match="tei:item[parent::tei:list and not(ancestor::tei:note[@type = 'copies'])]" as="item()*">
		<dd>
			<xsl:apply-templates select="child::node()"/>
		</dd>
	</xsl:template>
	<xsl:template match="tei:label[parent::tei:list and not(ancestor::tei:note[@type = 'copies'])]" as="item()*">
		<dt>
			<xsl:apply-templates select="child::node()"/>
		</dt>
	</xsl:template>
	<xsl:template match="tei:label[parent::tei:label]" as="item()*">
		<xsl:apply-templates select="child::node()"/>
		<xsl:text disable-output-escaping="no">, </xsl:text>
	</xsl:template>
	<xsl:template match="text()" mode="nospace" priority="1" as="item()*">
		<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
	</xsl:template>
	<xsl:template match="node() | @*" mode="nospace" as="item()*">
		<xsl:copy copy-namespaces="yes" inherit-namespaces="yes" use-attribute-sets="">
			<xsl:apply-templates select="node() | @*" mode="nospace"/>
		</xsl:copy>
	</xsl:template>
	<!-- Bibliographieabschnitt -->
	<!-- templates für alle möglichen bibl-Varianten gelöscht; 2016-05-26 DK -->
	<!-- template name="remove-leading-zeros" gelöscht; 2016-05-27 -->
	<!-- tei:hi ausgelagert nach common; 2016-05-27 DK -->
</xsl:stylesheet>
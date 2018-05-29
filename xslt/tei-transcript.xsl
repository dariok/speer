<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist"
	xmlns:mets="http://www.loc.gov/METS/" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xstring = "https://github.com/dariok/XStringUtils"
	exclude-result-prefixes="#all" version="3.0">
	
	<!-- Bearbeiter ab 2015/07/01 DK: Dario Kampkaspar, kampkaspar@hab.de -->
	<!-- Bearbeiter ab 2018/01/01 DK: Dario Kampkaspar, dario.kampkaspar@oeaw.ac.at -->
	<!-- Imports werden über tei-common abgewickelt; 2015/10/23 DK -->
	<xsl:import href="tei-common.xsl?6"/>
	
	<xsl:template match="/" mode="content">
		<div id="content"> <!-- Container für den restlichen Inhalt -->
			<p class="editors">Transkribiert von <xsl:apply-templates select="/tei:TEI/tei:teiHeader//tei:publisher/tei:ref"/></p>
			<!-- Haupttext -->
			<xsl:apply-templates select="tei:TEI/tei:text"/>
			<xsl:call-template name="apparatus"/>
			<xsl:call-template name="footnotes"/>
		</div><!-- end #content -->
	</xsl:template>
	
	<!-- Body-Elemente -->
	<!-- TODO closer, opener etc entsprechend PDF positionieren -->
	<xsl:template match="tei:closer[@rend and not(@rend='inline')]">
		<br/>
		<span class="closer" style="{@rend}">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<!-- a gelöscht; id in div übernommen; 2016-05-30 DK -->
	<!-- Sonderfälle wie in PDF berücksichtigt; 2016-05-30 DK -->
	<xsl:template match="tei:div[not(@type='footnotes' or @type='supplement')]">
		<div>
			<xsl:attribute name="id">
                <xsl:call-template name="makeID"/>
            </xsl:attribute>
			<xsl:choose>
				<xsl:when test="tei:*[1][self::tei:note] and tei:*[2][self::tei:head]">
					<xsl:apply-templates select="*[2]"/>
					<xsl:apply-templates select="*[position() &gt; 2]"/>
				</xsl:when>
				<xsl:when test="tei:*[1][self::tei:pb] and tei:*[2][self::tei:note] and tei:*[3][self::tei:head]">
					<xsl:apply-templates select="*[3]"/>
					<xsl:apply-templates select="*[position() &gt; 3]"/>
				</xsl:when>
				<xsl:when test="tei:*[1][self::tei:note] and tei:*[2][self::tei:note] and tei:*[3][self::tei:head]">
					<xsl:apply-templates select="*[3]"/>
					<xsl:apply-templates select="*[position() &gt; 3]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<!-- @type='supplement' entfernt wg. Konformität zu structMD; 2016-03-18 DK -->
	<!-- angepaßt an PDF; 2016-05-30 DK -->
	<xsl:template match="tei:div[starts-with(@xml:id, 'supp')]">
		<div class="supplement">
			<xsl:attribute name="id">
                <xsl:call-template name="makeID"/>
            </xsl:attribute>
			<h2>Beilage 
				<xsl:if test="count(//tei:div[@type = 'supplement']) &gt; 1">
					<xsl:number level="single" count="tei:div[@type = 'supplement']"/>
				</xsl:if>
			</h2>
			<xsl:if test="tei:head">
				<h3>
                    <xsl:value-of select="tei:head"/>
                </h3>
			</xsl:if>
		</div>
		<xsl:apply-templates select="tei:div"/>
	</xsl:template>
	
	<!-- Entscheidung vom 5.11.14: fw nicht mehr ausgeben (JB)-->
	<xsl:template match="tei:fw"/>	
	
	<!-- angepaßt an Ausgabe in intro und gemeinsames template für bei Arten von Überschrift (wegen Fußnote bei
		@rend='inline'; 2016-05-30 DK -->
	<xsl:template match="tei:head">
		<xsl:variable name="lev">
			<xsl:choose>
				<xsl:when test="@type='subheading'">5</xsl:when>
				<xsl:otherwise>4</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="h{$lev}">
			<xsl:attribute name="id">hd<xsl:number level="any"/>
            </xsl:attribute>
			<xsl:if test="(@rend = 'inline' or @place = 'margin') and (contains(., ' ') or contains(., '&#x9;'))">
				<xsl:call-template name="footnoteLink">
					<xsl:with-param name="type">crit</xsl:with-param>
					<xsl:with-param name="position">a</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="preceding-sibling::*[1][self::tei:pb]     or (preceding-sibling::*[1][self::tei:note[@place='margin']] and preceding-sibling::*[2][self::tei:pb])">
				<xsl:apply-templates select="preceding-sibling::tei:pb[1]" mode="head"/>
			</xsl:if>
			<xsl:apply-templates/>
			<xsl:apply-templates select="preceding-sibling::tei:note[@place = 'margin']"/>
			<xsl:if test="(@rend = 'inline' or @place = 'margin') and (contains(., ' ') or contains(., '&#x9;'))">
				<xsl:call-template name="footnoteLink">
					<xsl:with-param name="type">crit</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<a href="javascript:$('#wdbContent').scrollTop(0);" class="upRef">↑</a>
		</xsl:element>
	</xsl:template>
	
	<!-- tei:hi ausgelagert nach common; 2016-05-27 DK -->
	
	<!-- @style kommt nicht vor; 2016-05-30 DK -->
	<xsl:template match="tei:p[not(parent::tei:div[@type='colophon'])]">
		<p class="content">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<!-- Seitenumbrüche-->
	<xsl:template match="tei:pb">
		<span class="pagebreak">
			<a>
				<xsl:attribute name="href">
					<xsl:choose>
						<xsl:when test="starts-with(@facs, 'ln:')">
							<xsl:variable name="base" select="xstring:substring-before(substring-after(@facs, 'ln:'), ',')"/>
							<xsl:variable name="url" select="doc('https://repertorium-dev.eos.arz.oeaw.ac.at/exist/apps/edoc/data/repertorium/register/rep_ent.xml')/id($base)"/>
							<xsl:value-of select="$url || xstring:substring-after(@facs, ',')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@facs"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:value-of select="@n"/>
			</a>
		</span>
	</xsl:template>
	
	<!-- choice -->
	<xsl:template match="tei:choice">
		<xsl:apply-templates select="tei:reg"/>
		<xsl:apply-templates select="tei:ex"/>
		<xsl:apply-templates select="tei:expan"/>
		<xsl:apply-templates select="tei:corr"/>
	</xsl:template>
	
	<xsl:template match="tei:sic">
		<xsl:apply-templates/>
		<xsl:if test="not(parent::tei:choice)">
			<xsl:text> [!]</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<!-- neu für items mit mehreren Zählungen; 2016-07-18 DK -->
	<xsl:template match="tei:rdg" mode="fnLink">
		<xsl:call-template name="footnoteLink">
			<xsl:with-param name="type">crit</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- #### Pointer #### -->
	<!-- Change: @type='wdb' ausgelagert nach tei-common, 2015/10/23 DK -->
	<xsl:template match="tei:ptr[@type='link'][@target]">
		[<a href="{@target}" target="_blank">Link</a>]
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="tei:ptr[@type='digitalisat'][@target]">
		[<a href="{@target}" target="_blank">Digitalisat</a>
        <xsl:text>]</xsl:text>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="tei:ptr[@type='gbv'][@cRef]">
		<xsl:variable name="gbv">
            <xsl:text>http://gso.gbv.de/DB=2.1/PPN?PPN=</xsl:text>
        </xsl:variable>
		[<a href="{concat($gbv,@cRef)}" target="_blank">GBV</a>]
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="tei:ptr[@type='opac'][@cRef]">
		<xsl:variable name="opac">
            <xsl:text>http://opac.lbs-braunschweig.gbv.de/DB=2/PPN?PPN=</xsl:text>
        </xsl:variable>
		[<a href="{concat($opac,@cRef)}" target="_blank">OPAC</a>]
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- Listen -->
	<!-- überarbeitet 2016-05-31 DK -->
	<xsl:template match="tei:list[@rend='continuous_text']">
		<xsl:apply-templates select="tei:item" mode="ctext"/>
	</xsl:template>
	<xsl:template match="tei:list[not(@rend)]">
		<dl>
			<xsl:choose>
				<xsl:when test="contains(@type, 'flex')">
					<xsl:attribute name="class">flex</xsl:attribute>
				</xsl:when>
				<xsl:when test="contains(@type, 'long')">
					<xsl:attribute name="class">long</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">flex</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="tei:item | tei:pb | tei:anchor"/>
		</dl>
	</xsl:template>
	
	<!-- item bei @rend="continuous_text" als Fließtext ausgeben; Korrigendaliste: vor jedes corrigenda-<item> und nach
		jedem korrelierenden <add @corresp> einen Pfeil als Link zum Springen einfügen (JB 11.12.14) -->
	<!-- TODO prüfen; es gibt ggf. mehrere Ziele! 2016-05-31 DK -->
	<xsl:template match="tei:item" mode="ctext">
		<xsl:if test="@xml:id[starts-with(.,'corr')]">
			<!-- Überprüfen, ob im Dokument ein @corresp zur @xml:id vorhanden ist -->
			<!-- Prüfung ausgenommen; sollte idR immer vorhanden sein; 2016-06-01 DK -->
<!--			<xsl:if test="//tei:*[@corresp = substring(current()/@xml:id, 1)]">-->
				<a id="co{@xml:id}" href="#coa{@xml:id}">↑</a>
			<!--</xsl:if>-->
		</xsl:if>
		<xsl:apply-templates/>
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<!-- vollständige überarbeitet; Aussehen an PDF angepaßt; 2016-05-31 DK -->
	<xsl:template match="tei:item">
		<xsl:choose>
			<xsl:when test="preceding-sibling::tei:label">
				<dt>
					<xsl:if test="(preceding-sibling::tei:label)[1]/@xml:id">
						<xsl:attribute name="id">
                            <xsl:value-of select="(preceding-sibling::tei:label)[1]/@xml:id"/>
                        </xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="preceding-sibling::tei:label[1][@n] and not(parent::tei:list[contains(@type, 'consistent')])">
							<xsl:text>〈</xsl:text>
							<xsl:value-of select="preceding-sibling::tei:label[1]/@n"/>
							<xsl:text>〉 </xsl:text>
						</xsl:when>
						<xsl:when test="string-length(preceding-sibling::tei:label[1]/tei:app/tei:lem) &gt; 0">
							<xsl:value-of select="preceding-sibling::tei:label[1]/tei:app/tei:lem"/>
							<xsl:if test="not(substring(preceding-sibling::tei:label[1]/tei:app/tei:lem,         string-length(preceding-sibling::tei:label[1]/tei:app/tei:lem)-1) = '.')">
								<xsl:text>.</xsl:text>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="preceding-sibling::tei:label[1]"/>
						</xsl:otherwise>
					</xsl:choose>
				</dt>
			</xsl:when>
			<xsl:otherwise>
				<dt>&#160;</dt>
			</xsl:otherwise>
		</xsl:choose>
		<dd>
			<xsl:if test="preceding-sibling::tei:label[1]/tei:app">
				<xsl:if test="string-length(preceding-sibling::tei:label[1]/tei:app/tei:rdg[1]) &gt; 0">
					<xsl:text>(</xsl:text>
					<xsl:apply-templates select="preceding-sibling::tei:label[1]/tei:app/tei:rdg[1]"/>
					<xsl:text>)</xsl:text>
					<xsl:apply-templates select="preceding-sibling::tei:label[1]/tei:app/tei:note"/>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:if test="preceding-sibling::tei:label[1]/tei:app/tei:rdg[2]">
					<!-- neu 2016-07-18 DK -->
					<!-- TODO Ergebnis gegen PDF prüfen (kommt in 069 oder so vor) -->
					<xsl:apply-templates select="preceding-sibling::tei:label[1]/tei:app/tei:rdg[2]" mode="fnLink"/>
					<!-- TODO Ausgabe der Fußnote prüfen -->
					<!--<xsl:text>\footnotetextA{\textit{</xsl:text>
					<xsl:value-of select="substring-after(preceding-sibling::tei:label[1]/tei:app/tei:rdg[1]/@wit, '#')"/>
					<xsl:text>}; </xsl:text>
					<xsl:value-of select="preceding-sibling::tei:label[1]/tei:app/tei:rdg[2]"/>
					<xsl:text> \textit{</xsl:text>
					<xsl:value-of select="substring-after(preceding-sibling::tei:label[1]/tei:app/tei:rdg[2]/@wit, '#')"/>
					<xsl:text>}}</xsl:text>
					<xsl:text> </xsl:text>-->
				</xsl:if>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
		</dd>
	</xsl:template>
	
	<!-- template match="tei:listBibl" gelöscht, kommt nicht vor; 2016-05-31 DK -->
	<!-- index gelöscht; 2016-05-31 -->
	<!-- templates zu tei:anchor ausgelagert nach common; 2016-05-26 DK -->
	
	<!-- TODO Einrücken wie in PDF; 2016-05-31 DK -->
	<xsl:template match="tei:lg">
		<span>
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	<xsl:template match="tei:l">
		<xsl:apply-templates/>
		<br/>
	</xsl:template>
	
	<!-- ausgelagert nach common; 2016-07-26 DK -->
	<!--<!-\- enthaltenes tei:pb berücksichtigen; 2016-03-14 DK -\->
	<!-\- enthaltenes tei:note und tei:subst berücksichtigen; 2016-04-25 DK -\->
	<!-\- angepaßt für WDB Classic und eXist, verkürzt; 2016-07-18 DK -\->
	<xsl:template match="tei:rs">
		<xsl:variable name="xml">
			<xsl:choose>
				<xsl:when test="@type='person'">
					<xsl:text>/register/personenregister.xml</xsl:text>
				</xsl:when>
				<xsl:when test="@type='place'">
					<xsl:text>/register/ortsregister.xml</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="xsl">
			<xsl:choose>
				<xsl:when test="@type='person'">
					<xsl:text>/xslt/show-person.xsl</xsl:text>
				</xsl:when>
				<xsl:when test="@type='place'">
					<xsl:text>/xslt/show-place.xsl</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="link">
			<xsl:text>javascript:show_annotation('</xsl:text>
			<xsl:value-of select="$dir"/>
			<xsl:text>','</xsl:text>
			<xsl:value-of select="$baseDir" />
			<xsl:value-of select="$xml" />
			<xsl:text>','</xsl:text>
			<xsl:value-of select="$baseDir" />
			<xsl:value-of select="$xsl" />
			<xsl:text>','</xsl:text>
			<xsl:value-of select="substring-after(@ref, '#')" />
			<xsl:text>',300,500)</xsl:text>
		</xsl:variable>
		
		<!-\- The works -\->
		<!-\- pb kann auch innerhalb eines w stehen; 2016-06-19 DK -\->
		<xsl:choose>
			<xsl:when test="descendant::tei:pb">
				<a href="{$link}">
					<xsl:value-of select="text()[following-sibling::tei:w]"/>
					<xsl:value-of select="tei:w/text()[following-sibling::tei:pb]"/>
				</a>
				<xsl:apply-templates select="descendant::tei:pb[1]" />
				<a href="{$link}">
					<xsl:value-of select="tei:w/text()[preceding-sibling::tei:pb]"/>
					<xsl:value-of select="text()[preceding-sibling::tei:w]"/>
				</a>
			</xsl:when>
			<xsl:when test="tei:note">
				<!-\- XXX Offen: was passiert, wenn neben der note noch andere Sachen vorhanden sind? Bisher nicht der Fall... -\->
				<!-\- TODO @type='footnote' in eigenem when berücksichtigen, falls der Fall auftritt -\->
				<xsl:if test="node()[following-sibling::tei:note]">
					<a href="{$link}"><xsl:apply-templates select="node()[following-sibling::tei:note]"/></a>
				</xsl:if>
				<xsl:apply-templates select="tei:note" mode="fnLink">
					<xsl:with-param name="type">crit</xsl:with-param>
				</xsl:apply-templates>
				<xsl:if test="node()[preceding-sibling::tei:note]">
					<a href="{$link}"><xsl:apply-templates select="node()[preceding-sibling::tei:choice]"/></a>
				</xsl:if>
			</xsl:when>
			<!-\- angepaßt für a-a und unterbrochene Ausgabe; 2016-05-19 DK -\->
			<xsl:when test="tei:subst">
				<xsl:if test="node()[following-sibling::tei:subst]">
					<a href="{$link}">
						<xsl:apply-templates select="node()[following-sibling::tei:subst]"/>
					</a>
				</xsl:if>
				<xsl:if test="contains(tei:subst/tei:add, ' ')">
					<xsl:apply-templates select="tei:subst/tei:add" mode="fnLink">
						<xsl:with-param name="position">a</xsl:with-param>
						<xsl:with-param name="type">crit</xsl:with-param>
					</xsl:apply-templates>
				</xsl:if>
				<a href="{$link}"><xsl:apply-templates select="tei:subst/tei:add" /></a>
				<xsl:apply-templates select="tei:subst/tei:add" mode="fnLink">
					<xsl:with-param name="type">crit</xsl:with-param>
				</xsl:apply-templates>
				<xsl:if test="node()[preceding-sibling::tei:subst]">
					<a href="{$link}">
						<xsl:apply-templates select="node()[preceding-sibling::tei:subst]"/>
					</a>
				</xsl:if>
			</xsl:when>
			<!-\- neu 2016-05-18 DK -\->
			<xsl:when test="tei:choice">
				<xsl:if test="node()[following-sibling::tei:choice]">
					<a href="{$link}"><xsl:apply-templates select="node()[following-sibling::tei:choice]"/></a>
				</xsl:if>
				<xsl:if test="contains(tei:choice/tei:corr, ' ')">
					<xsl:apply-templates select="tei:choice" mode="fnLink">
						<xsl:with-param name="position">a</xsl:with-param>
						<xsl:with-param name="type">crit</xsl:with-param>
					</xsl:apply-templates>
				</xsl:if>
				<a href="{$link}">
					<xsl:apply-templates select="tei:choice/tei:corr" />
				</a>
				<xsl:apply-templates select="tei:choice" mode="fnLink">
					<xsl:with-param name="type">crit</xsl:with-param>
				</xsl:apply-templates>
				<xsl:if test="node()[preceding-sibling::tei:choice]">
					<a href="{$link}"><xsl:apply-templates select="node()[preceding-sibling::tei:choice]"/></a>
				</xsl:if>
			</xsl:when>
			<!-\- neu 2016-05-18 DK -\->
			<xsl:when test="tei:app">
				<xsl:if test="node()[following-sibling::tei:app]">
					<a href="{$link}"><xsl:apply-templates select="node()[following-sibling::tei:app]"/></a>
				</xsl:if>
				<xsl:if test="contains(tei:app/tei:lem, ' ')">
					<xsl:apply-templates select="tei:app" mode="fnLink">
						<xsl:with-param name="position">a</xsl:with-param>
						<xsl:with-param name="type">crit</xsl:with-param>
					</xsl:apply-templates>
				</xsl:if>
				<a href="{$link}">
					<xsl:apply-templates select="tei:app" />
				</a>
				<xsl:apply-templates select="tei:app" mode="fnLink">
					<xsl:with-param name="type">crit</xsl:with-param>
				</xsl:apply-templates>
				<xsl:if test="node()[preceding-sibling::tei:app]">
					<a href="{$link}"><xsl:apply-templates select="node()[preceding-sibling::tei:app]"/></a>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="a">
					<xsl:attribute name="href"><xsl:value-of select="$link"/></xsl:attribute>
					<xsl:apply-templates />
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		<!-\-<xsl:if test="not(following-sibling::tei:note)">
			<xsl:if test="following-sibling::node()[1] = following-sibling::*[1][not(self::tei:supplied)]">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:if>-\->
	</xsl:template>-->
	
	<!-- template match="tei:quote" in tei-common ausgelagert; 2016-05-31 DK -->
	<!-- tei:cit ausgelagert nach common; 2016-05-31 DK -->
	<!-- template match="tei:bibl/tei:title gelöscht; 2016-05-31 DK -->
	<!-- template match="tei:cb" gelöscht; 2016-05-31 DK -->
	
	<!-- Für die Sprache des Raumes (UB); 2016-02-23 DK -->
	<!-- Neu auch in tei:titlePage für Titelseiten; 2016-04-20 DK -->
	<!-- geändert auf docTitle, für nicht ausgerichtete/umgebrochene Stellen auf der Titelseite; 2016-05-11 DK -->
	<!-- Ausnahme für closer im Blocksatz hinzugefügt; 2016-05-17 DK -->
	<!-- übernommen aus PDF; 2016-05-31 DK -->
	<xsl:template match="tei:lb[ancestor::tei:closer or ancestor::tei:docTitle]">
		<xsl:if test="not(generate-id() = generate-id((ancestor::tei:titlePart//tei:lb)[1]))    and not(generate-id() = generate-id((ancestor::tei:closer//tei:lb)[1]))    and not(contains(ancestor::tei:closer/@rend, 'justified'))">
			<br/>
		</xsl:if>
	</xsl:template>
	
	<!-- TODO: prüfen, ob die Stelle in 044A ersetzt werden kann; 2016-05-31 DK -->
	<xsl:template match="tei:space">
		<!-- feste Whitespaces einfuegen -->
		<span style="white-space: pre-wrap;">
			<xsl:call-template name="createSpace">
				<xsl:with-param name="total">
					<xsl:value-of select="number(@quantity)"/>
				</xsl:with-param>
			</xsl:call-template>
		</span>
	</xsl:template>
	
	<!-- expan/ex nach common; 2016-05-31 DK -->
	<!-- xsl:template match="tei:unclear" nach tei-common; 2016-05-31 DK -->
	<!-- template match="tei:gap" ausgelagert nach tei-common; 2016-05-31 DK -->
	
	<xsl:template match="tei:titleStmt//tei:persName">
		<xsl:value-of select="tei:forename"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="tei:surname"/>
		<xsl:if test="following-sibling::tei:persName and (position() &lt; last()-1)">
			<xsl:text>, </xsl:text>
		</xsl:if>
		<xsl:if test="following-sibling::tei:persName and (position() = last()-1)">
			<xsl:text> und </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<!-- TODO nach common-common auslagern? 2016-05-31 DK -->
	<xsl:template match="tei:placeName">
		<xsl:if test="@cert">
			<xsl:text>[</xsl:text>
		</xsl:if>
		<xsl:apply-templates/>
		<xsl:if test="@cert">
			<xsl:text>]</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<!-- template match="tei:div[@type='colophon']/tei:p" gelöscht; Ausrichtung getrennt verarbeitet; 2016-05-31 DK -->
	<!-- template match="tei:back" gelöscht; tei:back wird ausgegeben; 2016-05-31 DK -->
	
	<!-- *** Marginalienfunktion *** -->
	<!-- Anzeige der Marginalien in separatem div -->
	<xsl:template name="marginaliaContainer">	
		<xsl:for-each select="//tei:note[@place='margin']">
			<span class="marginalia_text" id="text_{generate-id()}">
				<xsl:apply-templates/>
			</span>
		</xsl:for-each>
	</xsl:template>	
	<!-- template match="tei:span[@type='subheading']" gelöscht; 2016-05-31 DK -->
	
	<!-- für Anmerkungen über Elementgrenzen hinweg; 2016-05-31 DK -->
	<xsl:template match="tei:anchor[@type]">
		<xsl:variable name="myID">
            <xsl:value-of select="concat('#', @xml:id)"/>
        </xsl:variable>
		<xsl:variable name="num">
			<xsl:apply-templates select="preceding::tei:span[@from=$myID or @to=$myID]" mode="fnLink"/>
		</xsl:variable>
		<a id="{@xml:id}" class="anchorRef fn_number" href="#crit{$num}">
			<xsl:value-of select="$num"/>
		</a>
	</xsl:template>
	
	<!-- span im Text nicht ausgeben; 2016-05-31 DK -->
	<xsl:template match="tei:span"/>
	
	<!-- template match="tei:seg[@xml:id and not(@type)]" gelöscht; 2016-05-31 DK -->
	
	<!-- ergänzt um crit_app; 2016-05-31 DK -->
	<xsl:template match="tei:seg[@xml:id and @type]">
		<xsl:choose>
			<xsl:when test="@type='paraphrase'">
				<xsl:variable name="ref" select="concat('#', @xml:id)"/>
				<xsl:variable name="fn">
					<xsl:call-template name="fnumberFootnotes"/>
				</xsl:variable>
				<a id="tfn{$fn}" href="#fn{$fn}" class="fn_number">
					<xsl:call-template name="fnumberFootnotes"/>
				</a>
			</xsl:when>
			<xsl:when test="@type='crit_app'">
				<xsl:variable name="ref" select="concat('#', @xml:id)"/>
				<xsl:variable name="fn">
					<xsl:apply-templates select="following-sibling::tei:note[@corresp=$ref]" mode="fnLink">
						<xsl:with-param name="type">crit</xsl:with-param>
					</xsl:apply-templates>
				</xsl:variable>
				<a id="tcrit{$fn}" href="#crit{$fn}" class="fn_number anchorRef">
					<xsl:value-of select="$fn"/>
				</a>
			</xsl:when>
		</xsl:choose>
		<span id="{@xml:id}">
			<xsl:apply-templates/>
		</span>
		<!-- NB: das schließende FN-Zeichen bei crit_app erzeugt das template für note -->
	</xsl:template>
	
	<!-- Fussnoten und Zubehör -->
	<!-- Bestandteile im Fließtext -->
	<!-- a/@name → a/@id; Variable mit Link entfernt für Eindeutigkeit; 2016-03-18 DK -->
	<!-- angepaßt auf neue Variante rs; 2016-05-19 DK -->
	<xsl:template match="tei:add[not(parent::tei:rdg)]">
		<xsl:variable name="number">
			<xsl:call-template name="fnumberKrit"/>
		</xsl:variable>
		<xsl:if test="contains(., ' ') and not(ancestor::tei:rs)">
			<xsl:call-template name="footnoteLink">
				<xsl:with-param name="position">a</xsl:with-param>
				<xsl:with-param name="type">crit</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="child::tei:note[@type='comment']">
				<!--<xsl:value-of select="text()"/>-->
				<span id="tcrit{$number}">
                    <xsl:apply-templates select="node()[not(self::tei:note)]"/>
                </span>
			</xsl:when>
			<xsl:otherwise>
				<span id="tcrit{$number}">
                    <xsl:apply-templates/>
                </span>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="not(ancestor::tei:rs)">
			<xsl:call-template name="footnoteLink">
				<xsl:with-param name="type">crit</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="@corresp">
			<a id="coa{@corresp}{$number}" href="#co{@corresp}">↑</a>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="tei:app">
		<xsl:if test="tei:lem">
			<xsl:variable name="number">
				<xsl:call-template name="fnumberKrit"/>
			</xsl:variable>
			
			<xsl:if test="contains(tei:lem, ' ') and not(ancestor::tei:rs)">
				<!-- lokale Erstellung ersetzt; 2016-05-18 DK -->
				<xsl:call-template name="footnoteLink">
					<xsl:with-param name="position">a</xsl:with-param>
					<xsl:with-param name="type">crit</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<span id="tcrit{$number}">
                <xsl:apply-templates select="tei:lem"/>
            </span>
		</xsl:if>
		<!-- lokale Erstellung ersetzt; 2016-05-18 DK -->
		<xsl:if test="not(ancestor::tei:rs)">
			<xsl:call-template name="footnoteLink">
				<xsl:with-param name="type">crit</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- doppeltes FN-Zeichen nur, wenn der Text von corr selbst Spatien enthält; 2014-09-19 DK -->
	<!-- a/@name → a/@id; 2016-03-15 DK -->
	<!-- Link aus Variable ausgelagert wegen Eindeutigkeit der ID; 2016-03-17 DK -->
	<!-- überarbeitet für die Ausgabe von Links innerhalb rs; 2016-05-18 DK -->
	<xsl:template match="tei:corr[not(@type='corrigenda')]">
		<xsl:variable name="number">
			<xsl:call-template name="fnumberKrit"/>
		</xsl:variable>
		
		<xsl:if test="contains(text(), ' ') and not(ancestor::tei:rs)">
			<xsl:call-template name="footnoteLink">
				<xsl:with-param name="position">a</xsl:with-param>
				<xsl:with-param name="type">crit</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="@cert='low'">
			<xsl:text>〈</xsl:text>
		</xsl:if>
		<span id="tcrit{$number}">
            <xsl:apply-templates/>
        </span>
		<xsl:if test="@cert='low'">
			<xsl:text>〉</xsl:text>
		</xsl:if>
		<xsl:if test="not(ancestor::tei:rs)">
			<xsl:call-template name="footnoteLink">
				<xsl:with-param name="type">crit</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- a/@name → a/@id; 2016-03-15 DK -->
	<!-- überarbeitet für die Ausgabe von Links innerhalb rs; 2016-05-18 DK -->
	<xsl:template match="tei:del[not(parent::tei:subst)]">
		<xsl:variable name="number">
			<xsl:call-template name="fnumberKrit"/>
		</xsl:variable>
		<xsl:if test="contains(., ' ') and not(ancestor::tei:rs)">
			<xsl:call-template name="footnoteLink">
				<xsl:with-param name="position">a</xsl:with-param>
				<xsl:with-param name="type">crit</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<span id="tcrit{$number}">
            <xsl:apply-templates/>
        </span>
		<xsl:if test="not(ancestor::tei:rs)">
			<xsl:call-template name="footnoteLink">
				<xsl:with-param name="type">crit</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- Bei <subst> im Haupttext nur <add> ausgeben, nicht <del> -->
	<xsl:template match="tei:subst">
		<xsl:apply-templates select="tei:add"/>
	</xsl:template>
	
	<!-- Paragraphenzeichen, mit <g> kodiert, vorerst nicht ausgeben. -->
	<xsl:template match="tei:g"/>
	
	<!-- Marginalien -->
	<!-- Alle Marginalien haben @place=margin; Marginalien werden ueber named template ausgegeben. (DK)  -->
	<xsl:template match="tei:note[@place='margin']">
		<xsl:element name="a">
			<xsl:attribute name="class">mref</xsl:attribute>
			<xsl:attribute name="id">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
		</xsl:element>
	</xsl:template>
	
	<!-- Kritische Fußnoten -->
	<!-- angepaßt für neue Ausgabe rs; 2016-05-19 DK -->
	<xsl:template match="tei:note[@type='crit_app']">
		<xsl:if test="not(ancestor::tei:rs)">
			<xsl:choose>
				<xsl:when test="preceding-sibling::tei:seg[@type='crit_app']">
					<xsl:call-template name="footnoteLink">
						<xsl:with-param name="type">crit</xsl:with-param>
						<xsl:with-param name="position">e</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="footnoteLink">
						<xsl:with-param name="type">crit</xsl:with-param>
						<xsl:with-param name="position">t</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<!-- neu 2016-07-11 DK -->
	<xsl:template match="tei:note[@type='crit_app']" mode="fn">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="tei:note[@type='comment']"/>
	
	<!-- note[@type='footnote'] nach common ausgelagert; 2016-05-23 DK -->
	
	<!-- Bei <note> innerhalb von <add> etc. keine Fußnote in der Fußnote erzeugen (JB) -->
	<xsl:template match="tei:note" mode="no_count"/>
	
	<!-- fnumber-Templates nach common ausgelagert; 2016-05-18 DK --> 
	
	<!-- template name="grcApp" gelöscht, da kein Bedarf mehr; 2016-05-31 DK -->
	
	<!-- Kritischer Apparat am Fuß -->
	<!-- Kritische Fußnoten nicht mehr automatisch mit einem Punkt beenden (eingerichtet JB 10.09.14)
		doppeltes FN-Zeichen nur, wenn der Textknoten Spatien enthält, nicht jedoch wenn die Spatien nur in Kindern stehen
		(DK 19/09/14) -->
	<!-- Anpassung für app/rdg in Thesenreihen; 2015/11/03 DK -->
	<!-- inline- und marginales Head hinzugefügt, Link angepaßt; 2016-05-30 DK -->
	<!-- span[@type='crit_app'] hinzugefügt; 2016-05-31 DK -->
	<xsl:template name="apparatus">
		<div id="kritApp">
			<!-- überflüssiges a und xsl:if gelöscht; 2016-05-31 DK -->
			<hr class="fnRule"/>
			<xsl:for-each select="/tei:TEI/tei:text//tei:choice[not(tei:corr[@cert='low'])]     | /tei:TEI/tei:text//tei:app[not(ancestor::tei:choice)      and not(parent::tei:label[not(@rend)] and ancestor::tei:div[@type='thesen'] and count(tei:rdg) = 1)]     | /tei:TEI/tei:text//tei:subst     | /tei:TEI/tei:text//tei:add[not(parent::tei:subst | parent::tei:rdg  | parent::tei:lem)]     | /tei:TEI/tei:text//tei:del[not(parent::tei:subst | parent::tei:rdg)]     | /tei:TEI/tei:text//tei:note[@type='crit_app']     | /tei:TEI/tei:text//tei:head[@rend='inline' or @place='margin']     | /tei:TEI/tei:text//tei:span[@type='crit_app']">
				<xsl:variable name="text">
					<xsl:value-of select="translate(translate(./@wit,' ',','),'#',' ')"/>
				</xsl:variable>
				<xsl:variable name="number">
					<xsl:call-template name="fnumberKrit"/>
				</xsl:variable>
				<!-- neu wegen Link auf Überschrift; 2016-05-30 DK -->
				<!-- um span ergänzt; 2016-05-31 DK -->
				<xsl:variable name="target">
					<xsl:choose>
						<xsl:when test="name()='head'">hd<xsl:number level="any"/>
                        </xsl:when>
						<xsl:when test="name()='span'">
                            <xsl:value-of select="substring-after(@from, '#')"/>
                        </xsl:when>
						<xsl:otherwise>tcrit<xsl:call-template name="fnumberKrit"/>
                        </xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- div/@name → div/@id; 2016-03-15 DK -->
				<!-- head neu aufgenommen; 2016-07-11 DK -->
				<div class="footnotes" id="crit{$number}">
					<a href="#{$target}" class="fn_number_app">
						<xsl:if test="contains(tei:lem, ' ') or contains(tei:add, ' ') or contains(tei:corr/text(), ' ')         or (name() = 'add' and contains(., ' ')) or (name() = 'head' and contains(., ' '))">
							<xsl:value-of select="$number"/>
                            <xsl:text>–</xsl:text>
						</xsl:if>
						<xsl:value-of select="$number"/>
						<xsl:text> </xsl:text>
					</a>
					<span class="footnoteText">
						<xsl:choose>
							<xsl:when test="name()='add'">
								<xsl:apply-templates select="." mode="fn"/>
							</xsl:when>
							<xsl:when test="name()='del'">
								<i>
									<!-- TODO sobald nutzbares XSLT bereitsteht, hier ändern -->
									<xsl:if test="substring(., string-length(.)-1) = ' '">
										<xsl:text>davor </xsl:text>
									</xsl:if>
									<xsl:if test="substring(., 1, 1) = ' '">
										<xsl:text>danach </xsl:text>
									</xsl:if>
									<xsl:if test="@type = 'corrigenda'">
										<xsl:text>gemäß Korrekturverzeichnis </xsl:text>
									</xsl:if>
									<xsl:text>gestrichen: </xsl:text>
								</i>
								<xsl:apply-templates select="." mode="fn"/>
							</xsl:when>
							<xsl:when test="name()='note'">
								<i>
                                    <xsl:apply-templates select="." mode="fn"/>
                                </i>
							</xsl:when>
							<xsl:when test="name()='subst'">
								<xsl:apply-templates select="tei:add" mode="fn"/>
								<i>
                                    <xsl:text> verbessert für: </xsl:text>
                                </i>
								<!-- Abgrenzung zu "vom Editor verbesser" nicht nötig, da in Kombination mit "Im
									Korrekturverzeichnis..:" <i><xsl:text> von Karlstadt verbessert für: </xsl:text></i>-->
								<xsl:apply-templates select="tei:del" mode="fn"/>
							</xsl:when>
							<xsl:when test="name()='app'">
								<xsl:if test="not(ancestor::tei:choice)">
									<xsl:apply-templates select="." mode="fn"/>
								</xsl:if>
								<xsl:if test="child::tei:note[@type='comment']">
									<xsl:text>. – </xsl:text>
									<i>
                                        <xsl:apply-templates select="tei:note[@type='comment']" mode="fn"/>
                                    </i>
								</xsl:if>
							</xsl:when>
							<xsl:when test="name()='choice'">
								<xsl:choose>
									<xsl:when test="@resp">
										<i>von <xsl:value-of select="@resp"/> verbessert für: </i>
									</xsl:when>
									<xsl:otherwise>
										<i>vom Editor verbessert für: </i>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="tei:sic/tei:app">
										<xsl:apply-templates select="tei:sic/tei:app" mode="fn"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="tei:sic" mode="fn"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="tei:corr/tei:note[@type='comment']">
									<xsl:text>. </xsl:text>
									<i>
                                        <xsl:apply-templates select="tei:corr/tei:note[@type='comment']" mode="fn"/>
                                    </i>
								</xsl:if>
								<xsl:if test="tei:sic/tei:app/tei:note[@type='comment']">
									<xsl:text>. </xsl:text>
									<i>
                                        <xsl:apply-templates select="tei:sic/tei:app/tei:note[@type='comment']" mode="fn"/>
                                    </i>
								</xsl:if>
							</xsl:when>
							<xsl:when test="name()='head'">
								<i>
									<xsl:text>Im Original </xsl:text>
									<xsl:choose>
										<xsl:when test="@rend='inline'">
											<xsl:text>im fortlaufenden Text</xsl:text>
										</xsl:when>
										<xsl:when test="@place='margin'">
											<xsl:text>am Rand</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>woanders</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</i>
								<xsl:text>.</xsl:text>
							</xsl:when>
							<xsl:when test="name()='span'">
								<xsl:apply-templates/>
							</xsl:when>
						</xsl:choose>
					</span>
				</div>
			</xsl:for-each>
		</div>
	</xsl:template>

	<xsl:template match="tei:add" mode="fn">
		<!-- TODO hier weitere Fälle (wieder gestrichen) wie in -tex einfügen! -->
		<i>
			<xsl:choose>
				<xsl:when test="@place='margin'">am Rand </xsl:when>
				<xsl:when test="@place='supralinear'">über der Zeile </xsl:when>
				<xsl:when test="@type='corrigenda'">im Korrekturverzeichnis </xsl:when>
				<!-- hinzugefügt 2016-06-09 DK -->
				<xsl:when test="@place = 'end'">am Zeilenende </xsl:when>
				<xsl:when test="@resp">von <xsl:value-of select="substring-after(@resp, '#')"/>
                    <xsl:text> </xsl:text>
                </xsl:when>
			</xsl:choose>
			<xsl:if test="not(parent::tei:subst)">hinzugefügt</xsl:if>
		</i>
		<xsl:if test="child::tei:note[@type='comment']">
			<i>
                <xsl:text>. </xsl:text>
                <xsl:apply-templates select="tei:note[@type='comment']" mode="fn"/>
            </i>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="tei:app" mode="fn">
		<xsl:variable name="witness">
			<xsl:value-of select="translate(tei:lem/@wit, ' #', ', ')"/>
		</xsl:variable>
		<xsl:if test="tei:lem and not(substring-after(tei:lem/@wit, '#')     = //tei:listWit[not(@type='other')][1]/tei:witness/@xml:id)">
			<i>
                <xsl:value-of select="$witness"/>; </i>
		</xsl:if>
		<xsl:for-each select="tei:rdg">
			<xsl:if test="not(position()=1)">
                <xsl:text>, </xsl:text>
            </xsl:if>
			<xsl:choose>
				<!-- wenn <rdg> entweder leer ist, oder nur aus einem Element (nicht <del>) besteht (betrifft bisher nur
						<expan>, <unclear>) statt Text und Elementen (JB 11.12.14); Alternativ: bei jedem leeren <lem> automatisch
						ein "fehlt Sigle Editionsvorlage" anhängen mit: not(text()) and not(child::tei:w|add|expan)(!) -->
				<xsl:when test="not(text()) and not(child::tei:expan | child::tei:unclear)">
					<i>fehlt</i>
				</xsl:when>
				<xsl:when test="@rend='margin'">
					<xsl:apply-templates/>
					<i> am Rand</i>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<!-- normale Ausgabe: "fehlt Sigle", bei rdg/del: "fehlt Sigle:...", bei del[@rend='om'] den Inhalt von rdg
						nicht nochmal ausgeben (Sonderfall in 066.2, JB 10.12.14)-->
				<xsl:when test="descendant::tei:del">
					<i>
						<xsl:text> </xsl:text>
						<xsl:value-of select="translate(@wit, ' #', ', ')"/>:
						<xsl:apply-templates select="tei:del" mode="fn"/>
					</i>
				</xsl:when>
				<xsl:otherwise>
					<i>
						<xsl:text> </xsl:text>
						<xsl:value-of select="translate(@wit, ' #', ', ')"/>
					</i>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	<!-- Funktion space -->
	<xsl:template name="createSpace">
		<xsl:param name="index" select="1"/>
		<xsl:param name="total" select="2"/>
		<xsl:text> </xsl:text>
		<xsl:if test="not($index = $total)">
			<xsl:call-template name="createSpace">
				<xsl:with-param name="index" select="$index + 1"/>
				<xsl:with-param name="total">
					<xsl:value-of select="$total"/>
				</xsl:with-param>
		</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
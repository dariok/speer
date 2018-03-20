<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:mets="http://www.loc.gov/METS/" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xsl tei mets xlink exist xsi html" version="2.0" xsi:schemaLocation="http://www.w3.org/1999/XSL/Transform http://www.w3.org/2007/schema-for-xslt20.xsd">
	
	<!-- erstellt 2015/10/23 DK: Dario Kampkaspar, kampkaspar@hab.de -->
	<!-- angepaßt nach ed000216; 2016-11-02 DK -->
	
	<xsl:output method="html"/>
	
	<!-- neu 2016-07-14 DK -->
	<xsl:param name="server"/>
	
	<!-- damit nicht bei jedem bibl neu geladen werden muß; 2016-06-01 DK -->
<!--	<xsl:variable name="biblFile" select="document('../register/bibliography.xml')"/>-->
	
	<!-- Name und Inhalt angepaßt für Verwendung auf WDB Classic und eXist; 2016-07-14 DK -->
	<xsl:variable name="viewURL">
		<xsl:text>http://dev2.hab.de/edoc/view.html</xsl:text>
	</xsl:variable>
	
	<!-- angepaßt für Verwendung auf WDB Classic und eXist; 2016-07-14 DK -->
	<xsl:variable name="baseDir">
		<xsl:text>http://repertorium-dev.eos.arz.oeaw.ac.at/exist/apps/edoc/data/repertorium/texts</xsl:text>
	</xsl:variable>
	
	<xsl:param name="footerXML">
		<xsl:call-template name="resolveXML">
			<xsl:with-param name="metsID">
				<xsl:value-of select="/tei:TEI/@xml:id"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:param>
	
	<!-- neu für die Verwendung mit WDB Classic und eXist; 2016-07-14 DK -->
	<xsl:template match="/">
		<xsl:apply-templates select="." mode="content"/>
	</xsl:template>
	
	<xsl:template match="tei:abbr">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- ausgelagert nach common; 2016-01-18 DK -->
	<xsl:template match="tei:bibl[@ref]">
		<xsl:if test="parent::tei:cit">
            <br/>
        </xsl:if>
		<a>
			<xsl:variable name="refs">
				<xsl:value-of select="substring-after(@ref, '#')"/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="@type='ebd'">ebd.</xsl:when>
				<xsl:when test="@type='Ebd'">Ebd.</xsl:when>  <!-- Für Großschreibung am Anfang von Fußnoten -->
				<!--<xsl:otherwise>
					<xsl:apply-templates select="$biblFile//tei:bibl[@xml:id=$refs]/tei:abbr"/>
				</xsl:otherwise>-->
			</xsl:choose>
		</a>
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- Ausgabe detaillierter gewünscht; 2016-05-17 DK -->
	<!-- noch detaillierter; 2016-07-11 DK -->
	<xsl:template match="tei:bibl/tei:abbr">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- nur der eigentliche Titel von Quellen(-editionen) soll kursiv stehen; 2016-07-11 DK -->
	<xsl:template match="tei:listBibl[@type='primary']//tei:abbr/tei:title">
		<i>
            <xsl:apply-templates/>
        </i>
	</xsl:template>
	
	<!-- Autoren von Sekundärliteratur in kleinen Kapitälchen, analog PDF; 2016-07-11 DK -->
	<xsl:template match="tei:name[parent::tei:abbr]">
		<xsl:choose>
			<xsl:when test="ancestor::tei:listBibl[not(@type='primary')]">
				<span class="nameSC">
                    <xsl:apply-templates/>
                </span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Inhalt ausgelagert wegen Anchor innerhalb einer Liste; 2016-05-19 DK -->
	<xsl:template match="tei:anchor[not(parent::tei:list)]">
		<xsl:apply-templates select="." mode="long"/>
	</xsl:template>
	<!-- neu 2016-05-19 DK -->
	<xsl:template match="tei:anchor[not(@type)]" mode="long">
		<a id="{@xml:id}" class="anchorRef"/>
	</xsl:template>
	
	<!-- apply-templates aufgetrennt (verhindern von Leerzeichen); 2015-11-23 DK -->
	<!-- verschoben aus intro nach common (Augustinkommentar); 2015-11-27 DK -->
	<xsl:template match="tei:cit">
		<span class="blockquote">
			<xsl:apply-templates select="tei:quote"/>
			<xsl:apply-templates select="tei:ptr | tei:note | tei:bibl"/>
		</span>
	</xsl:template>
	
	<xsl:template match="tei:ex">
		<xsl:text>'</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>'</xsl:text>
	</xsl:template>
	
	<!-- TODO nach common-common? -->
	<!-- neue Regelung nach Treffen 2016-02-10: tr immer spitz, intro und FN eckig, außer wenn @reason; 2016-02-12 DK -->
	<!-- @resp für z.B. Texterklärungen hinzugefügt; 2016-06-09 DK -->
	<!-- Test vereinfacht; 2016-07-12 DK -->
	<xsl:template match="tei:gap">
		<xsl:choose>
			<xsl:when test="@reason">
				<xsl:text>〈…〉</xsl:text>
			</xsl:when>
			<xsl:when test="@resp">
				<xsl:text>[</xsl:text>
				<xsl:apply-templates/>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:when test="contains(/tei:TEI/@xml:id, 'introduction')">
				<xsl:text>[…]</xsl:text>
			</xsl:when>
			<xsl:when test="contains(/tei:TEI/@xml:id, 'transcript') and not(ancestor::tei:note[@type='footnote'])">
				<xsl:text>〈…〉</xsl:text>
			</xsl:when>
			<xsl:when test="contains(/tei:TEI/@xml:id, 'transcript') and ancestor::tei:note[@type='footnote']">
				<xsl:text>[…]</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:hi [not(parent::tei:head)]">
		<xsl:choose>
<!--			<xsl:when test="@rend='large'">
				<span style="font-size:larger;"><xsl:apply-templates/></span>
			</xsl:when>
			<xsl:when test="@rend='italics'">
				<span style="font-style:italic;"><xsl:apply-templates/></span>
			</xsl:when>
			<xsl:when test="@rend='normal'">
				<span style="font-style:normal;"><xsl:apply-templates/></span>
			</xsl:when>-->
			<xsl:when test="@rend='super'">
				<span class="superscript">
                    <xsl:apply-templates/>
                </span>
			</xsl:when>
			<xsl:when test="@rend='sub'">
				<span class="subscript">
                    <xsl:apply-templates/>
                </span>
			</xsl:when>
			<xsl:otherwise>
				<span style="font-style:smallCaps">
                    <xsl:apply-templates/>
                </span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Sachkommentar-Fußnoten -->
	<!-- a/@name → a/id; 2016-03-15 DK -->
	<!-- grundsätzlich alle Fußnoten ausgeben; 2016-03-18 DK -->
	<!-- umgestellt auf template footnoteLink; 2016-05-19 DK -->
	<!-- ausgelagert nach common; 2016-05-23 DK -->
	<xsl:template match="tei:note[@type='footnote']">
		<xsl:call-template name="footnoteLink">
			<xsl:with-param name="type">fn</xsl:with-param>
			<xsl:with-param name="position">t</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- neu zur Angleichung an PDF; 2016-07-11 DK -->
	<xsl:template match="tei:orig">
		<span class="orig">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<!-- FIXME !important! allgemeiner machen!! -->
	<!-- TODO insgesamt besser machen. Allgemeine Funktion zum Verlinken finden -->
	<!-- Überlegung: Wenn der Link mit http:// beginnt, dann ist es Link auf andere Edition. In dem Fall als Linktext das
		Kürzel oder den Titel aus der METS der Zieledition entnehmen -->
	<xsl:template match="tei:ptr[@type = 'wdb' and @target and not(parent::tei:cit)]">
		<xsl:variable name="target">
			<xsl:call-template name="makeLink">
				<xsl:with-param name="refXML">
					<xsl:value-of select="@target"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="file">
			<!-- Test auf Texte der 2. Phase; 2016-07-14 DK -->
			<xsl:choose>
				<xsl:when test="not(contains(@target, 'ed000240'))">
					<xsl:variable name="uri">
						<xsl:choose>
							<xsl:when test="contains(@target, '../') and contains(@target, '#')">
								<xsl:value-of select="substring-after(substring-before(@target, '#'), '../')"/>
							</xsl:when>
							<xsl:when test="contains(@target, '../')">
								<xsl:value-of select="substring-after(@target, '../')"/>
							</xsl:when>
							<xsl:when test="contains(@target, '#')">
								<!--<xsl:value-of select="concat(substring-before(@target, '_'), '/', substring-before(@target, '#'))"/>-->
								<xsl:value-of select="substring-before(@target, '#')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select=" @target"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:value-of select="concat($baseDir, '/texte/', $uri)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@target"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<a href="{$target}">
			<xsl:choose>
				<xsl:when test="contains(@target, '/') and not(contains(@target, '#'))">
					<xsl:text>KGK </xsl:text>
					<!-- neu für Links auf spätere EE; 2016-07-12 DK -->
					<xsl:variable name="nr">
						<xsl:value-of select="document($file)/tei:TEI/@n"/>
					</xsl:variable>
					<xsl:choose>
						<!-- direkt @target testen; 2016-07-14 DK -->
						<xsl:when test="not(contains(@target, 'ed000240'))">
							<xsl:value-of select="$nr"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>II</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- TODO prüfen, ob Links mit Fragment Identifier korrekt erstellt werden!-->
				<!-- Link auf eine Fußnote (target="#n..."); ergibt Verweis mit S. und FN-Nummber-->
				<xsl:when test="contains(@target, '#n')">
					<!-- in choose um in der eigenen Datei die Nummer ausgeben zu können; 2016-07-11 DK -->
					<xsl:choose>
						<!-- test geändert: wenn / enthalten, dann Link in andere Datei; 2016-07-12 DK -->
						<xsl:when test="contains(@target, '/')">
							<xsl:text>KGK </xsl:text>
							<!-- neu für Links auf spätere EE; 2016-07-12 DK -->
							<xsl:variable name="nr">
								<xsl:value-of select="document($file)/tei:TEI/@n"/>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="string-length($nr) &gt; 0">
									<xsl:value-of select="$nr"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>Ⅱ</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>FN </xsl:text>
							<!--TODO Nummer der Zielfußnote ermitteln!-->
							<!-- Versuch über fnumberFootnotes; 2016-07-11 DK -->
							<xsl:call-template name="fnumberFootnotes">
								<xsl:with-param name="context" select="id(substring-after(@target, '#'))"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!--Link auf den Text einer Transkription an eine beliebige Stelle -->
				<!-- darf nicht mit # anfangen, da sonst gleiche Datei; 2016-07-12 DK -->
				<!-- test geändert: wenn / enthalten, dann Link in andere Datei; 2016-07-12 DK -->
				<xsl:when test="(contains(@target, '#q') or contains(@target, '#s')) and contains(@target, '/')">
					<xsl:text>KGK </xsl:text>
					<xsl:value-of select="document($file)/tei:TEI/@n"/>
				</xsl:when>
				<!-- neu 2016-07-12 DK -->
				<xsl:when test="contains(@target, '#q') or contains(@target, '#s')">
					<xsl:text>Textstelle</xsl:text>
				</xsl:when>
			</xsl:choose>
		</a>
		<!-- aus den einzelnen Fällen ausgelagert; 2016-07-11 DK -->
		<!-- neue Ausnahme Semikolon; 2016-07-12 DK -->
		<!-- und Doppelpunkt; 2016-07-12 DK -->
		<xsl:if test="following-sibling::node()[1][self::text()] and not(starts-with(following::text()[1], ')')    or starts-with(following::text()[1], ',') or starts-with(following::text()[1], '.')    or starts-with(following::text()[1], ';') or starts-with(following::text()[1], ':'))">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<!-- abgekürzt und Vergabe der Anführungszeichen an CSS abgegeben; 2016-05-27 DK -->
	<xsl:template match="tei:quote">
		<q>
			<xsl:if test="@xml:id">
				<xsl:attribute name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
				<xsl:attribute name="class">anchorRef</xsl:attribute>
			</xsl:if>
			<xsl:if test="@xml:lang">
				<xsl:choose>
					<xsl:when test="@xml:lang='grc-Grek'"> 
						<xsl:attribute name="lang">grc</xsl:attribute>
					</xsl:when>
					<xsl:when test="@xml:lang='heb-Hebr'"> 
						<!-- angepaßt auf he nach 639-1; 2016-05-23 DK -->
						<xsl:attribute name="lang">he</xsl:attribute>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			<xsl:apply-templates/>
		</q>
	</xsl:template>
	
	<!-- in common zusammengefaßt; nur noch wenn @xml:lang; 2016-03-18 DK -->
	<xsl:template match="tei:seg[@xml:lang]">
		<xsl:choose>
			<!-- aufgeteilt je Sprache; Ausgabe der Sprache in HTML-Attribut @lang; 2016-05-20 DK -->
			<xsl:when test="@xml:lang='grc-Grek'"> 
				<span lang="grc">
                    <xsl:apply-templates/>
                </span>
			</xsl:when>
			<xsl:when test="@xml:lang='heb-Hebr'">
				<!-- angepaßt auf he nach 639-1; 2016-05-23 DK -->
				<span lang="he">
                    <xsl:apply-templates/>
                </span>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- in common zusammengefaßt; 2016-01-18 DK -->
	<!-- neue Regelung nach Treffen 2016-02-10: tr immer spitz, intro und FN eckig, außer wenn @reason; 2016-02-12 DK -->
	<xsl:template match="tei:supplied">
		<xsl:choose>
			<xsl:when test="@reason">
				<xsl:text>⟨</xsl:text>
				<xsl:apply-templates/>
				<xsl:text>⟩</xsl:text>
			</xsl:when>
			<xsl:when test="contains(/tei:TEI/@xml:id, 'introduction')">
				<xsl:text>[</xsl:text>
				<xsl:apply-templates/>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:when test="contains(/tei:TEI/@xml:id, 'transcript') and not(ancestor::tei:note[@type='footnote'])">
				<xsl:text>⟨</xsl:text>
				<xsl:apply-templates/>
				<xsl:text>⟩</xsl:text>
			</xsl:when>
			<xsl:when test="contains(/tei:TEI/@xml:id, 'transcript') and ancestor::tei:note[@type='footnote']">
				<xsl:text>[</xsl:text>
				<xsl:apply-templates/>
				<xsl:text>]</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- Ausgabe von erwähnten allg. Werktiteln und Begrifflichkeiten in Anführungszeichen / kursiv -->
	<xsl:template match="tei:term">
		<xsl:choose>
			<xsl:when test="@type='term'">
				<xsl:element name="i">
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:when>
			<!-- Ausgabe Quellentitel kursiv, nach Festlegung TK; 2016-05-09 DK -->
			<xsl:when test="@type='title' and not(tei:quote) and not(parent::tei:quote)">
				<i>
                    <xsl:apply-templates/>
                </i>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:title[parent::tei:p or parent::tei:note]">
		<i>
            <xsl:apply-templates/>
        </i>
	</xsl:template>
	<!-- neu 2016-05-24 DK -->
	<xsl:template match="tei:titleStmt/tei:title">
		<xsl:apply-templates select="node()[not(self::tei:date or self::tei:placeName)]"/>
		<br/>
		<xsl:apply-templates select="tei:placeName"/>
		<xsl:if test="tei:date and tei:placeName">
			<xsl:text>, </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="tei:date"/>
		<xsl:if test="contains((/tei:TEI/tei:text/tei:body/tei:div[1]//tei:objectDesc)[1]/@form, 'lost')">
			<br/>
            <span>(verschollen)</span>
		</xsl:if>
		<xsl:if test="contains((/tei:TEI//tei:text/tei:body/tei:div[1]//tei:objectDesc)[1]/@form, 'fragment')">
			<br/>
            <span>(Fragment)</span>
		</xsl:if>
	</xsl:template>
	
	<!-- Tabellen -->
	<xsl:template match="tei:table">
		<table>
			<xsl:if test="@rend='noborder'">
				<xsl:attribute name="class">noborder</xsl:attribute>
			</xsl:if>
			<xsl:if test="tei:row[1]/tei:cell[1][@role='label']">
				<xsl:attribute name="class">firstColumnLabel</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</table>
	</xsl:template>
	
	<!-- TODO das hier nach "common-common"? 2016-05-31 DK -->
	<xsl:template match="tei:unclear">
		<xsl:apply-templates/>
		<xsl:text>〈?〉</xsl:text>
	</xsl:template>
	
	<xsl:template match="tei:head[parent::tei:table]">
		<caption>
            <xsl:apply-templates/>
        </caption>
	</xsl:template>
	
	<xsl:template match="tei:row">
		<tr>
			<xsl:apply-templates select="tei:cell"/>
		</tr>
	</xsl:template>
	
	<!-- übernommen aus transcript; 2016-07-26 DK -->
	<!-- enthaltenes tei:pb berücksichtigen; 2016-03-14 DK -->
	<!-- enthaltenes tei:note und tei:subst berücksichtigen; 2016-04-25 DK -->
	<!-- angepaßt für WDB Classic und eXist, verkürzt; 2016-07-18 DK -->
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
<!--			<xsl:value-of select="$dir"/>-->
			<xsl:text>','</xsl:text>
			<xsl:value-of select="$baseDir"/>
			<xsl:value-of select="$xml"/>
			<xsl:text>','</xsl:text>
			<xsl:value-of select="$baseDir"/>
			<xsl:value-of select="$xsl"/>
			<xsl:text>','</xsl:text>
			<xsl:value-of select="substring-after(@ref, '#')"/>
			<xsl:text>',300,500)</xsl:text>
		</xsl:variable>
		
		<!-- The works -->
		<!-- pb kann auch innerhalb eines w stehen; 2016-06-19 DK -->
		<xsl:choose>
			<xsl:when test="descendant::tei:pb">
				<a href="{$link}">
					<xsl:value-of select="text()[following-sibling::tei:w]"/>
					<xsl:value-of select="tei:w/text()[following-sibling::tei:pb]"/>
				</a>
				<xsl:apply-templates select="descendant::tei:pb[1]"/>
				<a href="{$link}">
					<xsl:value-of select="tei:w/text()[preceding-sibling::tei:pb]"/>
					<xsl:value-of select="text()[preceding-sibling::tei:w]"/>
				</a>
			</xsl:when>
			<xsl:when test="tei:note">
				<!-- XXX Offen: was passiert, wenn neben der note noch andere Sachen vorhanden sind? Bisher nicht der Fall... -->
				<!-- TODO @type='footnote' in eigenem when berücksichtigen, falls der Fall auftritt -->
				<xsl:if test="node()[following-sibling::tei:note]">
					<a href="{$link}">
                        <xsl:apply-templates select="node()[following-sibling::tei:note]"/>
                    </a>
				</xsl:if>
				<xsl:apply-templates select="tei:note" mode="fnLink">
					<xsl:with-param name="type">crit</xsl:with-param>
				</xsl:apply-templates>
				<xsl:if test="node()[preceding-sibling::tei:note]">
					<a href="{$link}">
                        <xsl:apply-templates select="node()[preceding-sibling::tei:choice]"/>
                    </a>
				</xsl:if>
			</xsl:when>
			<!-- angepaßt für a-a und unterbrochene Ausgabe; 2016-05-19 DK -->
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
				<a href="{$link}">
                    <xsl:apply-templates select="tei:subst/tei:add"/>
                </a>
				<xsl:apply-templates select="tei:subst/tei:add" mode="fnLink">
					<xsl:with-param name="type">crit</xsl:with-param>
				</xsl:apply-templates>
				<xsl:if test="node()[preceding-sibling::tei:subst]">
					<a href="{$link}">
						<xsl:apply-templates select="node()[preceding-sibling::tei:subst]"/>
					</a>
				</xsl:if>
			</xsl:when>
			<!-- neu 2016-05-18 DK -->
			<xsl:when test="tei:choice">
				<xsl:if test="node()[following-sibling::tei:choice]">
					<a href="{$link}">
                        <xsl:apply-templates select="node()[following-sibling::tei:choice]"/>
                    </a>
				</xsl:if>
				<xsl:if test="contains(tei:choice/tei:corr, ' ')">
					<xsl:apply-templates select="tei:choice" mode="fnLink">
						<xsl:with-param name="position">a</xsl:with-param>
						<xsl:with-param name="type">crit</xsl:with-param>
					</xsl:apply-templates>
				</xsl:if>
				<a href="{$link}">
					<xsl:apply-templates select="tei:choice/tei:corr"/>
				</a>
				<xsl:apply-templates select="tei:choice" mode="fnLink">
					<xsl:with-param name="type">crit</xsl:with-param>
				</xsl:apply-templates>
				<xsl:if test="node()[preceding-sibling::tei:choice]">
					<a href="{$link}">
                        <xsl:apply-templates select="node()[preceding-sibling::tei:choice]"/>
                    </a>
				</xsl:if>
			</xsl:when>
			<!-- neu 2016-05-18 DK -->
			<xsl:when test="tei:app">
				<xsl:if test="node()[following-sibling::tei:app]">
					<a href="{$link}">
                        <xsl:apply-templates select="node()[following-sibling::tei:app]"/>
                    </a>
				</xsl:if>
				<xsl:if test="contains(tei:app/tei:lem, ' ')">
					<xsl:apply-templates select="tei:app" mode="fnLink">
						<xsl:with-param name="position">a</xsl:with-param>
						<xsl:with-param name="type">crit</xsl:with-param>
					</xsl:apply-templates>
				</xsl:if>
				<a href="{$link}">
					<xsl:apply-templates select="tei:app"/>
				</a>
				<xsl:apply-templates select="tei:app" mode="fnLink">
					<xsl:with-param name="type">crit</xsl:with-param>
				</xsl:apply-templates>
				<xsl:if test="node()[preceding-sibling::tei:app]">
					<a href="{$link}">
                        <xsl:apply-templates select="node()[preceding-sibling::tei:app]"/>
                    </a>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="a">
					<xsl:attribute name="href">
                        <xsl:value-of select="$link"/>
                    </xsl:attribute>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		<!--<xsl:if test="not(following-sibling::tei:note)">
			<xsl:if test="following-sibling::node()[1] = following-sibling::*[1][not(self::tei:supplied)]">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:if>-->
	</xsl:template>
	
	<!-- ersetzt bisherige Ausagben; 2016-05-27 DK -->
	<!-- Anmerkung: rowspan kann vorerst nicht übernommen werden, da es zu falscher Zellenzahl kommt -->
	<xsl:template match="tei:cell[parent::tei:row[@role='label']]">
		<th>
            <xsl:apply-templates/>
        </th>
	</xsl:template>
	<xsl:template match="tei:cell[parent::tei:row[not(@role)]]">
		<xsl:variable name="pos" select="position()"/>
		<xsl:if test="text() or tei:* or not(parent::tei:row/preceding-sibling::tei:row/tei:cell[$pos][@rows])">
			<td>
				<xsl:if test="@rows">
					<xsl:attribute name="rowspan">
                        <xsl:value-of select="@rows"/>
                    </xsl:attribute>
				</xsl:if>
				<xsl:apply-templates/>
			</td>
		</xsl:if>
	</xsl:template>
	
	<!-- neu 2017-03-28 DK -->
	<xsl:template match="tei:ref[not(@type)]">
		<a href="{@target}" target="_blank">
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	
	<xsl:template name="makeLink">
		<xsl:param name="refXML"/>
		<xsl:variable name="xsl">
			<xsl:value-of select="concat('tei-', substring-after(substring-before($refXML, '.xml'), '_'), '.xsl')"/>
		</xsl:variable>
		<!-- neu 2016-07-11 DK -->
		<xsl:variable name="tXML">
			<xsl:choose>
				<xsl:when test="contains($refXML, '#')">
					<xsl:value-of select="substring-before($refXML, '#')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$refXML"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- neu 2016-07-11 DK -->
		<xsl:variable name="fragment">
			<xsl:if test="contains($refXML, '#')">
				<xsl:value-of select="concat('#', substring-after($refXML, '#'))"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="xml">
			<xsl:choose>
				<xsl:when test="starts-with($refXML, '../')">
					<xsl:value-of select="concat('texte/', substring-after($tXML, '../'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$refXML"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- neu wegen Links auf spätere EE; 2016-07-12 DK -->
		<!-- TODO verallgemeinern entsprechend Überlegungen oben zu ref -->
		<xsl:variable name="tdir">
			<xsl:value-of select="$baseDir"/>
		</xsl:variable>
		<!-- neu im choose; 2016-07-11 DK -->
		<!-- TODO ist es (wegen Zitierbarkeit) besser, auch bei einem lokalen Verweis einen vollen Link zu generieren? -->
		<xsl:choose>
			<xsl:when test="starts-with($refXML, '#')">
				<xsl:value-of select="$refXML"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- neu für Verwendbarkeit mit WDB Classic und eXist; 2016-07-14 DK -->
				<!-- vergessenes otherwise eingefügt; 2016-07-18 DK -->
				<xsl:choose>
					<xsl:when test="$server='eXist'">
						<!-- Link korrigiert; 2016-08-17 DK -->
						<xsl:value-of select="concat($viewURL, '?file=', $tdir, '/', $xml, $fragment)"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- $fragment hinzugefügt 2016-07-11 DK -->
						<!-- Link korrigiert; 2016-08-17 DK -->
						<xsl:value-of select="concat($viewURL, $tdir, '&amp;xml=', $xml, '&amp;xsl=', $xsl, $fragment)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="resolveXML">
		<xsl:param name="metsID"/>
		
		<xsl:value-of select="document('../mets.xml')//mets:file[@ID=$metsID]/mets:FLocat/@xlink:href"/>
	</xsl:template>
	
	<!-- FN-Nummer um eins erhöhen, falls innherhalb einer Paraphrase; 2016-04-19 DK -->
	<!-- tei:cit/tei:ptr hinzugefügt; 2016-05-31 DK -->
	<xsl:template name="fnumberFootnotes">
		<xsl:param name="context" select="current()"/>
		
		<xsl:variable name="fn">
			<xsl:choose>
				<xsl:when test="$context/ancestor::tei:seg[@type='paraphrase']">
					<xsl:value-of select="count($context/preceding::tei:note[@type='footnote']       | $context/preceding::tei:seg[@type='paraphrase']       | $context/preceding::tei:ptr[parent::tei:cit])+2"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count($context/preceding::tei:note[@type='footnote']       | $context/preceding::tei:seg[@type='paraphrase']       | $context/preceding::tei:ptr[parent::tei:cit])+1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:value-of select="$fn"/>
	</xsl:template>
	
	<!-- aus transcript ausgelagert; 2016-05-18 DK -->
	<!-- Templates zum Generieren der Fußnotennummern -->
	<!-- [not(tei:corr[@cert='low'])] von tei:choice entfernt, da jetzt nur noch da, wo auch wirklich nötig; 2016-05-18 DK -->
	<xsl:template name="fnumberKrit">
		<xsl:number level="any" format="a" count="tei:choice     | tei:app[not(ancestor::tei:choice)     and not(parent::tei:label[not(@rend)] and ancestor::tei:div[@type='thesen'] and count(tei:rdg) = 1)     or tei:lem/tei:gap]     | tei:subst     | tei:add[not(parent::tei:subst | parent::tei:lem | parent::tei:rdg)]     | tei:del[not(parent::tei:subst | parent::tei:lem | parent::tei:rdg)]     | tei:note[@type='crit_app']    | tei:head[@rend='inline' or @place='margin']    | tei:span[@type='crit_app']"/>
	</xsl:template>
	
	<xsl:template name="fnumberGreek">
		<xsl:number level="any" format="α" count="tei:seg[@xml:id[starts-with(.,'start')]]"/>
	</xsl:template>
	
	<!-- neu 2016-05-18 DK -->
	<xsl:template name="makeID">
		<xsl:param name="targetElement"/>
		<xsl:param name="id"/>
		
		<xsl:choose>
			<xsl:when test="$targetElement">
				<xsl:choose>
					<xsl:when test="$targetElement/@xml:id">
						<xsl:value-of select="$targetElement/@xml:id"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="generate-id($targetElement)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$id">
				<xsl:value-of select="$id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="generate-id()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- neu für die Ausgabe aller Links auf die Fußnoten; 2016-05-18 DK -->
	<xsl:template match="tei:*" mode="fnLink">
		<xsl:param name="type"/>
		<xsl:param name="position">s</xsl:param>
		<xsl:call-template name="footnoteLink">
			<xsl:with-param name="type" select="$type"/>
			<xsl:with-param name="position" select="$position"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- neu für allgemeine Verarbeitung geschachtelter Link-Ausgaben; 2016-05-18 DK -->
	<xsl:template name="footnoteLink">
		<xsl:param name="position">s</xsl:param>
		<xsl:param name="type"/>
		<xsl:variable name="number">
			<xsl:choose>
				<xsl:when test="$type='crit'">
					<xsl:call-template name="fnumberKrit"/>
				</xsl:when>
				<xsl:when test="$type='fn'">
					<xsl:call-template name="fnumberFootnotes"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="fnumberGreek"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<a id="{$position}{$type}{$number}" href="#{$type}{$number}" class="fn_number">
			<xsl:value-of select="$number"/>
		</a>
	</xsl:template>
	
	<!-- ausgelagert nach common (ersetzt alte intro); 2016-05-23 DK -->
	<!-- change: Apparat immer ausgeben; 2016-04-25 DK -->
	<!-- angepaßt auf Template footnoteLink; 2016-05-19 DK -->
	<xsl:template name="footnotes">
		<div id="FußnotenApparat">
			<!-- überflüssiges a gelöscht; 2016-05-31 DK -->
			<hr class="fnRule"/>
			<xsl:for-each select="/tei:TEI/tei:text//tei:note[@type='footnote']     | /tei:TEI/tei:text//tei:seg[@type='paraphrase'] | /tei:TEI/tei:text//tei:cit/tei:ptr">
				<xsl:variable name="number">
					<xsl:call-template name="fnumberFootnotes"/>
				</xsl:variable>
				<div class="footnotes" id="fn{$number}">
					<a href="#tfn{$number}" class="fn_number_app">
						<xsl:value-of select="$number"/>
						<xsl:text> </xsl:text>
					</a>
					<span class="footnoteText">
						<!-- damit man auch zu referenzierten FN springen kann; 2016-07-11 DK -->
						<xsl:if test="@xml:id">
							<xsl:attribute name="id">
								<xsl:value-of select="@xml:id"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="name()='seg'">
								<xsl:text>Im Folgenden Zitatpassagen und Paraphrasen bis </xsl:text>
								<xsl:variable name="nr">
									<xsl:call-template name="fnumberFootnotes">
										<xsl:with-param name="context" select="following-sibling::tei:note[1]"/>
									</xsl:call-template>
								</xsl:variable>
								<a href="#fn{$nr}">Anm. <xsl:value-of select="$nr"/>
                                </a>
								<xsl:text>. Quellenangaben s. dort.</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="." mode="fnText"/>
							</xsl:otherwise>
						</xsl:choose>
					</span>
				</div>
			</xsl:for-each>
		</div>
	</xsl:template>
	
	<!-- neu 2016-07-012 DK -->
	<xsl:template match="tei:note" mode="fnText">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="tei:ptr" mode="fnText">
		<xsl:apply-templates select="@target"/>
	</xsl:template>
</xsl:stylesheet>
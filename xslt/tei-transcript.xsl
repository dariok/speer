<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist"
	xmlns:mets="http://www.loc.gov/METS/" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xstring = "https://github.com/dariok/XStringUtils"
	xmlns:acdh="https://www.acdh.oeaw.ac.at"
	exclude-result-prefixes="#all" version="3.0">
	
	<!-- Bearbeiter ab 2018/01/01 DK: Dario Kampkaspar, dario.kampkaspar@oeaw.ac.at -->
	
	<xsl:import href="string-pack.xsl" />
	
	<xsl:output method="html"/>
	
	<xsl:variable name="viewURL">
		<xsl:text>https://repertorium.acdh-dev.oeaw.ac.at/exist/apps/edoc/view.html</xsl:text>
	</xsl:variable>
	<xsl:variable name="baseDir">
		<xsl:text>https://repertorium.acdh-dev.oeaw.ac.at/exist/apps/edoc/data/repertorium</xsl:text>
	</xsl:variable>
	
	<xsl:template match="/">
		<div id="content">
			<p class="editors">Transkribiert von <xsl:apply-templates select="/tei:TEI/tei:teiHeader//tei:publisher/tei:ref"/></p>
			<!-- Haupttext -->
			<xsl:apply-templates select="tei:TEI/tei:text"/>
			<div id="FußnotenApparat">
				<hr class="fnRule"/>
				<xsl:apply-templates select="/tei:TEI/tei:text//tei:note[@type='footnote' or not(@type)]" mode="fn" />
			</div>
			<xsl:call-template name="apparatus" />
		</div>
	</xsl:template>
	
	<xsl:template match="tei:titleStmt/tei:title">
		<xsl:apply-templates select="node()[not(self::tei:date or self::tei:placeName)]"/>
		<br/>
		<xsl:apply-templates select="tei:placeName"/>
		<xsl:if test="tei:date and tei:placeName">
			<xsl:text>, </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="tei:date"/>
	</xsl:template>
	
	<xsl:template match="tei:div">
		<div>
			<xsl:attribute name="id">
				<xsl:choose>
					<xsl:when test="@xml:id"><xsl:value-of select="@xml:id" /></xsl:when>
					<xsl:otherwise>d<xsl:number level="any" /></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates />
		</div>
	</xsl:template>
	
	<xsl:template match="tei:fw"/>	
	
	<xsl:template match="tei:gap">
		<xsl:choose>
			<xsl:when test="@reason">
				<xsl:text>〈…〉</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>[…]</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:head">
		<xsl:variable name="lev">
			<xsl:value-of select="count(ancestor::tei:div)"/>
		</xsl:variable>
		<xsl:element name="h{$lev}">
			<xsl:attribute name="id">hd<xsl:number level="any"/></xsl:attribute>
			<xsl:if test="preceding-sibling::*[1][self::tei:pb]">
				<xsl:apply-templates select="preceding-sibling::tei:pb[1]" mode="head"/>
			</xsl:if>
			<xsl:apply-templates/>	
			<a href="javascript:$('#wdbContent').scrollTop(0);" class="upRef">↑</a>
		</xsl:element>
	</xsl:template>

	<xsl:template match="tei:hi">
		<xsl:choose>
			<xsl:when test="@rend='strong'">
				<b><xsl:apply-templates/></b>
			</xsl:when>
			<xsl:when test="@rend='ita'">
				<i><xsl:apply-templates/></i>
			</xsl:when>
			<xsl:when test="@rend='center'">
				<span style="display:inline-block; width:100%; text-align:center;"><xsl:apply-templates/></span>
			</xsl:when>
			<xsl:when test="@rend='sup'">
				<span class="superscript">
					<xsl:apply-templates/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:p">
		<p class="content">
			<xsl:apply-templates/>
		</p>
	</xsl:template>
	
	<xsl:template match="tei:pb">
		<a class="pagebreak">
			<xsl:attribute name="href">
				<xsl:choose>
					<xsl:when test="starts-with(@facs, 'ln:')">
						<xsl:variable name="base" select="xstring:substring-before(substring-after(@facs, 'ln:'), ',')"/>
						<xsl:variable name="url" select="doc($baseDir || '/register/rep_ent.xml')/id($base)"/>
						<xsl:value-of select="$url || xstring:substring-after(@facs, ',')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@facs"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates select="@n | @xml:id" />
		</a>
	</xsl:template>
	
	<xsl:template match="tei:choice">
		<xsl:variable name="number">
			<xsl:call-template name="fnumberKrit"/>
		</xsl:variable>
		
		<xsl:if test="contains(tei:corr, ' ')">
			<xsl:call-template name="footnoteLink">
				<xsl:with-param name="position">a</xsl:with-param>
				<xsl:with-param name="type">crit</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<span id="tcrit{$number}">
			<xsl:apply-templates select="tei:corr/node()"/>
		</span>
		<xsl:call-template name="footnoteLink">
			<xsl:with-param name="type">crit</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="tei:list">
		<ul>
			<xsl:apply-templates select="tei:item | tei:pb"/>
		</ul>
	</xsl:template>
	
	<xsl:template match="tei:item">
		<li>
			<xsl:apply-templates select="node()"/>
		</li>
	</xsl:template>
	
	<xsl:template match="tei:ref[@target]">
		<a target="_blank">
			<xsl:attribute name="href">
				<xsl:choose>
					<xsl:when test="starts-with(@target, 'ln:')">
						<xsl:variable name="base" select="xstring:substring-before(substring-after(@target, 'ln:'), ',')"/>
						<xsl:variable name="url" select="doc($baseDir || '/register/rep_ent.xml')/id($base)"/>
						<xsl:value-of select="$url || substring-after(@target, ',')"/>
					</xsl:when>
					<xsl:when test="starts-with(@target, '#')">
						<xsl:value-of select="@target"/>
					</xsl:when>
					<xsl:when test="starts-with(@target, 'http') or starts-with(@target, 'view.html')">
						<xsl:value-of select="@target"/>
					</xsl:when>
					<xsl:when test="doc-available(@target)">
						<xsl:variable name="id" select="doc(@target)/tei:TEI/@xml:id"/>
						<xsl:value-of select="'view.html?id=' || $id"/>
					</xsl:when>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	<xsl:template match="tei:ref[not(@type or @target)]">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="tei:rs">
		<xsl:variable name="xml">
			<xsl:choose>
				<xsl:when test="@type='person'">
					<xsl:text>/db/apps/edoc/data/repertorium/register/personenregister.xml</xsl:text>
				</xsl:when>
				<xsl:when test="@type='place'">
					<xsl:text>../register/ortsregister.xml</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="xsl">
			<xsl:choose>
				<xsl:when test="@type='person'">
					<xsl:text>../xslt/show-person.xsl</xsl:text>
				</xsl:when>
				<xsl:when test="@type='place'">
					<xsl:text>../xslt/show-place.xsl</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="link">
			<!-- TODO anpassen -->
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
			<xsl:otherwise>
				<xsl:element name="a">
					<xsl:attribute name="href">
						<xsl:value-of select="$link"/>
					</xsl:attribute>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:table">
		<table>
			<xsl:choose>
				<xsl:when test="not(@rend) or @rend='noborder'">
					<xsl:attribute name="class">noborder</xsl:attribute>
				</xsl:when>
				<xsl:when test="contains(@rend, 'border')" />
			</xsl:choose>
			<xsl:if test="tei:row[1]/tei:cell[1][@role='label']">
				<xsl:attribute name="class">firstColumnLabel</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</table>
	</xsl:template>
	<xsl:template match="tei:row">
		<tr>
			<xsl:apply-templates select="tei:cell"/>
		</tr>
	</xsl:template>
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

	<xsl:template match="tei:term">
		<i><xsl:apply-templates /></i>
	</xsl:template>

	<xsl:template match="tei:note[@type='crit_app']">
		<xsl:call-template name="footnoteLink">
			<xsl:with-param name="type">crit</xsl:with-param>
			<xsl:with-param name="position">t</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="tei:note[@type='footnote' or not(@type)]">
		<xsl:call-template name="footnoteLink">
			<xsl:with-param name="type">fn</xsl:with-param>
			<xsl:with-param name="position">t</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="tei:note[@type='footnote' or not(@type)]" mode="fn">
		<xsl:variable name="number" select="acdh:fnumberFootnotes(.)" />
		<div class="footnotes" id="fn{$number}">
			<a href="#tfn{$number}" class="fn_number_app">
				<xsl:value-of select="$number"/>
			</a>
			<span class="footnoteText">
				<!-- damit man auch zu referenzierten FN springen kann; 2016-07-11 DK -->
				<xsl:choose>
					<xsl:when test="@xml:id">
						<xsl:apply-templates select="@xml:id" />
					</xsl:when>
					<xsl:when test="@n">
						<xsl:attribute name="id" select="@n" />
					</xsl:when>
				</xsl:choose>
				<xsl:apply-templates />
			</span>
		</div>
	</xsl:template>
	
	<xsl:template match="tei:anchor">
		<a id="{@xml:id}" class="anchorRef"/>
	</xsl:template>
	
	<xsl:template match="tei:*" mode="fnLink">
		<xsl:param name="type"/>
		<xsl:param name="position">s</xsl:param>
		<xsl:call-template name="footnoteLink">
			<xsl:with-param name="type" select="$type"/>
			<xsl:with-param name="position" select="$position"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="apparatus">
		<div id="kritApp">
			<hr class="fnRule"/>
			<xsl:for-each select="//tei:choice
				| //tei:note[@type='crit_app']">
				<xsl:variable name="text">
					<xsl:value-of select="translate(./@wit,' #',', ')"/>
				</xsl:variable>
				<xsl:variable name="number">
					<xsl:call-template name="fnumberKrit"/>
				</xsl:variable>
				<xsl:variable name="target">
					<xsl:text>tcrit</xsl:text><xsl:call-template name="fnumberKrit"/>
				</xsl:variable>
				
				<div class="footnotes" id="crit{$number}">
					<a href="#{$target}" class="fn_number_app">
						<xsl:if test="contains(tei:corr/text(), ' ')">
							<xsl:value-of select="$number"/>
							<xsl:text>–</xsl:text>
						</xsl:if>
						<xsl:value-of select="$number"/>
					</a>
					<span class="footnoteText">
						<xsl:choose>
							<xsl:when test="self::tei:note">
								<i>
									<xsl:apply-templates select="node()" />
								</i>
							</xsl:when>
							<xsl:when test="self::tei:choice">
								<i>vom Editor verbessert für: </i>
								<xsl:apply-templates select="tei:sic/node()" />
							</xsl:when>
							<xsl:otherwise>
								<i><xsl:apply-templates select="node()"/></i>
							</xsl:otherwise>
						</xsl:choose>
					</span>
				</div>
			</xsl:for-each>
		</div>
	</xsl:template>
	
	<!-- globales -->
	<xsl:template name="footnoteLink">
		<xsl:param name="position">s</xsl:param>
		<xsl:param name="type"/>
		<xsl:variable name="number">
			<xsl:choose>
				<xsl:when test="$type='crit'">
					<xsl:call-template name="fnumberKrit"/>
				</xsl:when>
				<xsl:when test="$type='fn'">
					<xsl:value-of select="acdh:fnumberFootnotes(.)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<a id="{$position}{$type}{$number}" href="#{$type}{$number}" class="fn_number">
			<xsl:value-of select="$number"/>
		</a>
	</xsl:template>
	
	
	
	<xsl:function name="acdh:fnumberFootnotes">
		<xsl:param name="context" />
		
		<xsl:choose>
			<xsl:when test="$context/@n">
				<xsl:value-of select="$context/@n"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="count($context/preceding::tei:note[@type='footnote' or not(@type)])+1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:template name="fnumberKrit">
		<xsl:number level="any" format="a" count="tei:choice | tei:note[@type='crit_app'] | tei:corr"/>
	</xsl:template>
	
	<xsl:template match="@xml:id">
		<xsl:attribute name="id" select="normalize-space()" />
	</xsl:template>
	
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
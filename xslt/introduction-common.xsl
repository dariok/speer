<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.0">
	<!-- erstellt 2016-05-26 DK -->
	
	<xsl:template match="tei:titleStmt/tei:author">
		<xsl:value-of select="tei:forename"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="tei:surname"/>
		<xsl:if test="following-sibling::tei:author and (position() &lt; last()-1)">
			<xsl:text>, </xsl:text>
		</xsl:if>
		<xsl:if test="following-sibling::tei:author and (position() = last()-1)">
			<xsl:text> und </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<!-- neu 2015-11-09; vorher über seg[@type]; 2015-11-09 DK -->
	<xsl:template match="tei:date | tei:placeName">
		<xsl:if test="@cert">
			<xsl:text>[</xsl:text>
		</xsl:if>
		<xsl:apply-templates/>
		<xsl:if test="@cert">
			<xsl:text>]</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="tei:note[@type='copies']">
		<xsl:apply-templates select="tei:list"/>
	</xsl:template>
	
	<!-- ausgegliedert aus tei:item zur gleichen Behandlung; 2015-12-11 DK -->
	<!-- TODO ggfs. noch handNote hier einbringen! -->
	<!-- angepaßt auf runde Klammern gem. Beschluß; 2016-01-14 DK -->
	<xsl:template match="tei:note[not(@type) and (parent::tei:bibl or parent::tei:item or parent::tei:msItem)]">
		<xsl:text> (</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>)</xsl:text>
	</xsl:template>
	
	<xsl:template match="tei:pubPlace">
		<xsl:if test="current()[position() &gt; 1]">
			<xsl:text>, </xsl:text>
		</xsl:if>
		<xsl:if test="@cert">
			<xsl:text>[</xsl:text>
		</xsl:if>
		<xsl:apply-templates/>
		<xsl:if test="@cert">
			<xsl:text>]</xsl:text>
		</xsl:if>
		<xsl:if test="following-sibling::tei:publisher">
			<xsl:text>: </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="tei:publisher">
		<xsl:if test="current()[position() &gt; 1]">
			<xsl:text>, </xsl:text>
		</xsl:if>
		<xsl:if test="@cert">
			<xsl:text>[</xsl:text>
		</xsl:if>
		<xsl:apply-templates/>
		<xsl:if test="@cert">
			<xsl:text>]</xsl:text>
		</xsl:if>
		<xsl:text>, </xsl:text>
	</xsl:template>
</xsl:stylesheet>
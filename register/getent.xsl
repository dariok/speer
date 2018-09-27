<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template name="start">
        <xsl:variable name="entries" select="doc('http://repertorium.acdh-dev.oeaw.ac.at/exist/apps/edoc/data/repertorium/register/rep_ent.xml')//*:item"/>
        
        <items action="replace">
            <xsl:apply-templates select="$entries">
                <xsl:sort select="@xml:id" />
            </xsl:apply-templates>
        </items>
    </xsl:template>
    
    <xsl:template match="*:item">
        <item value="ln:{@xml:id}" annotation="{normalize-space()}" />
    </xsl:template>
</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


    <xsl:template match="node() | @*" mode="copyExceptPrefix">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="copy"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node() | @*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="copy"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node()[position()=1][self::text()]" mode="copyExceptPrefix">
        <xsl:param name="prefix" select="''"/>
        <xsl:value-of select="substring-after(., $prefix)"/>
    </xsl:template>

    <xsl:template match="node() | @*" mode="fixLinks">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="fixLinks"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node()[self::text()]" mode="fixLinks">
        <xsl:analyze-string select="." regex="\[.*\]\(.*\)">
            <xsl:matching-substring>
                <xsl:element name="xref">
                    <xsl:attribute name="format">html</xsl:attribute>
                    <xsl:attribute name="scope">external</xsl:attribute>
                    <xsl:attribute name="href" select="substring-before(substring-after(., '('), ')')"/>
                    <xsl:value-of select="substring-before(substring-after(., '['), ']')"/>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="fixInlineCode">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="fixInlineCode"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node()[self::text()]" mode="fixInlineCode">
        <xsl:analyze-string select="." regex="`..*`">
            <xsl:matching-substring>
                <xsl:element name="codeph">
                    <xsl:value-of select="substring-before(substring-after(., '`'), '`')"/>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    

    <sch:pattern>
        <sch:rule context="p">
            <sch:let name="this" value="."/>
            <sch:let name="text" value="node()[1][self::text()]/normalize-space()"/>
            <sch:let name="prefix" value="substring($text, 1, 2)"/>
            
            <!-- Convert Markdown list items to DITA unordered list items -->
            <sch:report test="(starts-with($text, '* ') or starts-with($text, '- '))
                and not(preceding-sibling::*[1][self::p[starts-with(., $prefix)]])" role="info" 
                sqf:fix="createListFromParagraph addItemToList">
                List items should be marked with a list item (li) element and added to a list (ul) element.
            </sch:report>
            <sqf:fix id="createListFromParagraph" use-when="not(preceding-sibling::*[1][self::ul])">
                <sqf:description>
                    <sqf:title>Create a list</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <ul>
                        <xsl:for-each-group select="$this|following-sibling::*" group-adjacent="self::p and starts-with(., $prefix)">
                            <xsl:if test="current-group()=$this">
                                <xsl:for-each select="current-group()">
                                    <li>
                                        <xsl:apply-templates mode="copyExceptPrefix">
                                            <xsl:with-param name="prefix" select="$prefix"/>
                                        </xsl:apply-templates>
                                    </li>
                                </xsl:for-each>
                            </xsl:if>
                        </xsl:for-each-group>
                    </ul>
                </sqf:add>
                <sqf:delete match="following-sibling::p[starts-with(., $prefix)][
                    preceding-sibling::*[not(starts-with(., $prefix))][1]/following-sibling::*=$this
                    or not(preceding-sibling::*[not(starts-with(., $prefix))][1])
                    ]"/>
                <sqf:delete/>
            </sqf:fix>
            <sqf:fix id="addItemToList" use-when="preceding-sibling::*[1][self::ul]">
                <sqf:description>
                    <sqf:title>Add this as an item to the preceding list</sqf:title>
                </sqf:description>
                
                <sqf:add match="preceding-sibling::*[1][self::ul]" position="last-child">
                    <li>
                    <xsl:apply-templates mode="copyExceptPrefix" select="following-sibling::*[1]/node()">
                        <xsl:with-param name="prefix" select="$prefix"/>
                    </xsl:apply-templates>
                    </li>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
            
            <!-- Convert a Markdown numbered list item to a DITA ordered list with one item -->
            <sch:report test="matches($text, '^\d(\d)*\.') and not(preceding-sibling::*[1][self::p[matches(., '^\d(\d)*\.')]])" role="info" sqf:fix="createOrderedListFromParagraph">
                Ordered list items should be marked with a list item (li) element and added to an ordered list (ol) element.
            </sch:report>
            <sqf:fix id="createOrderedListFromParagraph">
                <sqf:description>
                    <sqf:title>Transform this into an item in a new ordered list</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <ol>
                        <xsl:for-each select=". | following-sibling::p[matches(., '^\d(\d)*\.')][
                                preceding-sibling::*[not(matches(., '^\d(\d)*\.'))][1]/following-sibling::*=$this
                                or not(preceding-sibling::*[not(matches(., '^\d(\d)*\.'))])
                                ]">
                            <li>
                                <xsl:apply-templates mode="copyExceptPrefix">
                                    <xsl:with-param name="prefix" select="concat(substring-before(., '.'), '.')"/>
                                </xsl:apply-templates>
                            </li>
                        </xsl:for-each>
                    </ol>
                </sqf:add>
                <sqf:delete match="following-sibling::p[matches(., '^\d(\d)*\.')][
                    preceding-sibling::*[not(matches(., '^\d(\d)*\.'))][1]/following-sibling::*=$this
                    or not(preceding-sibling::*[not(matches(., '^\d(\d)*\.'))])
                    ]"/>
                <sqf:delete/>
            </sqf:fix>
            
            <!-- Comvert Markdown code to DITA codeblocks -->
            <sch:report test="starts-with($text, '```')" role="info" sqf:fix="createCodeblockFromParagraph"
                sqf:default-fix="createCodeblockFromParagraph">
                Code fragments should be placed within a "codeblock" element.
            </sch:report>
            <sqf:fix id="createCodeblockFromParagraph">
                <sqf:description>
                    <sqf:title>Transform this into a code block</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <codeblock>
                        <xsl:apply-templates mode="copyExceptPrefix">
                            <xsl:with-param name="prefix" select="'```'"/>
                        </xsl:apply-templates>
                    </codeblock>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
            
            <!-- Convert Markdown quotes to DITA long quotes -->
            <sch:report test="starts-with($text, '> ') and not(preceding-sibling::*[1][self::p[starts-with(., '> ')]])" role="info" 
                sqf:fix="createQuoteFromParagraph">
                Quotes should be marked with a long quote (lq) element.
            </sch:report>
            <sqf:fix id="createQuoteFromParagraph">
                <sqf:description>
                    <sqf:title>Transform this into a quote</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <lq>
                        <xsl:for-each-group select="$this|following-sibling::*" group-adjacent="self::p and starts-with(., '>')">
                            <xsl:if test="current-group()=$this">
                                <xsl:for-each select="current-group()">
                                    <p>
                                        <xsl:apply-templates mode="copyExceptPrefix">
                                            <xsl:with-param name="prefix" select="$prefix"/>
                                        </xsl:apply-templates>
                                    </p>
                                </xsl:for-each>
                            </xsl:if>
                        </xsl:for-each-group>
                    </lq>
                </sqf:add>
                <sqf:delete match="following-sibling::p[starts-with(., '> ')][
                    preceding-sibling::*[not(starts-with(., '> '))][1]/following-sibling::*=$this
                    or not(preceding-sibling::*[not(starts-with(., '> '))][1])
                    ]"/>
                <sqf:delete/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>

    <sch:pattern>
        <sch:rule context="p|li[not(descendant-or-self::p)]">
            <!-- Convert Markdown links to DITA cross referernces -->
            <sch:report test="matches(., '\[.*\]\(.*\)')" role="info" sqf:fix="convertMarkdownLinks2XReferences">
                Paragraph contains links in Markdown format! These should be converted to 
                DITA cross references.
            </sch:report>
            <sqf:fix id="convertMarkdownLinks2XReferences">
                <sqf:description>
                    <sqf:title>Transform Markdown links to DITA cross references</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <xsl:apply-templates mode="fixLinks" select="."/>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
            <!-- Convert inline code to codeph -->
            <sch:report test="matches(., '`..*`')" role="info" sqf:fix="convertMarkdowncode2Codeph">
                Paragraph contains inline code fragments! These should be converted to 
                DITA code phase (codeph) elements.
            </sch:report>
            <sqf:fix id="convertMarkdowncode2Codeph">
                <sqf:description>
                    <sqf:title>Transform Markdown inline code to DITA code phrases</sqf:title>
                </sqf:description>
                <sqf:add position="after">
                    <xsl:apply-templates mode="fixInlineCode" select="."/>
                </sqf:add>
                <sqf:delete/>
            </sqf:fix>
            
        </sch:rule>
    </sch:pattern>

</sch:schema>

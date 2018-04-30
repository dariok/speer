xquery version "3.0";

(: ~
 : This module provides additional functions to deal with string operations more easily
 : 
 : @author Dario Kampkaspar
 : @version 0.1
 :)
module namespace xstring = "https://github.com/dariok/XStringUtils";


(:
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:wdb="https://github.com/dariok/wdbplus
:)

	(:~
		: Returns the substring after a given test string
		:
		: @param $s The string to be checked</xd:p
		: @param $c The text to be searched for in the string value of <pre>$s<pre>.
		: @return If <pre>$c<pre> is found within the given string, the return value is the same as a call to 
		:		<pre>fn:substring-after($s, $c)</pre>; if <pre>$c</pre> cannot be found, <pre>$s</pre> is
		:		returned unaltered.
	:)
	declare function xstring:substring-after($s as xs:string, $c as xs:string) as xs:string {
		if (contains($s, $c)) then substring-after($s, $c) else $s
	};
	
	(:~
		: Returns the substring before a given test string
		:
		: @param $s The string to be checked
		: @param $c The text to be searched for in the string value of <pre>$s</pre>.
		: @return If <pre>$c</pre> is found within the given string, the return value is the same as a call to 
		:		<pre>fn:substring-before($s, $c)</pre>; if <pre>$c</pre> cannot be found, <pre>$s</pre>
		:		is returned unaltered.
		:)
	declare function xstring:substring-before($s as xs:string, $c as xs:string) as xs:string {
		if (contains($s, $c)) then substring-before($s, $c) else $s
	};
	
	(:~
		: Returns the substring before a given test string if it ends with this test string.
		:
		: @param $s The string to be checked
		: @param $c The text to be searched for in the string value of <pre>$s</pre>.
		: @return If <pre>$c</pre> is found within the given string, the portion of <pre>$s</pre> before this
		:		string (in final position) is returned; if <pre>$c</pre> cannot be found, <pre>$s</pre>
		:		is returned unaltered.
		:)
	declare function xstring:substring-before-if-ends($s as xs:string, $c as xs:string) as xs:string {
		let $l := string-length($s)
		
		return if(ends-with($s, $c)) then substring($s, 1, $l - 1) else $s
	};
	
	(:~
		: Returns the substring after a given test string if it starts with this test string.
		:
		: @param $s The string to be checked
		: @param $c The text to be searched for in the string value of <pre>$s</pre>.
		: @return If <pre>$c</pre> is found within the given string, the portion of <pre>$s</pre> after this
		:		string (in initial position) is returned; if <pre>$c</pre> cannot be found, or is not in the initial
		:		position, <pre>$s</pre> is returned unaltered.
		:)
	declare function xstring:substring-after-if-starts($s as xs:string, $c as xs:string) as xs:string {
		if(starts-with($s, $c)) then substring-after($s, $c) else $s
	};
	
	(:~
		: Returns the substring before the last occurrence of the search string.
		:
		: @param $s The string to be checked
		: @param $c The text to be searched for in the string value of <pre>$s</pre>.
		: @return The substring of $s before the last occurrence of $c; if $c does not occur, $s is returned unaltered.
		:)
	declare function xstring:substring-before-last($s as xs:string, $c as xs:string) as xs:string {
		let $string := string-join(tokenize(normalize-space($s), $c)[not(position() = last())], $c)
		
		return if (starts-with($s, $c))
				then concat($c, $string)
				else $string
	};
	
	(:~
		: Returns the substring after the last occurrence of the search string.
		:
		: @param $s The string to be checked
		: @param $c The text to be searched for in the string value of <pre>$s</pre>.
		: @return The substring of $s after the last occurrence of $c; if $c does not occur, $s is returned unaltered.
		:)
	declare function xstring:substring-after-last($s as xs:string, $c as xs:string) as xs:string {
		tokenize(normalize-space($s), $c)[last()]
	};
# DITA Markdown framework

An extension of the oXygen XML Editor DITA framework that adds support for 
recognizing and converting Markdown structures written in DITA paragraphs to 
the corresponding DITA markup.

This project shows how we can help people that know Markdown to transition to DITA. 
You can write Markdown fragments in DITA paragraphs and these will be recognized, 
you will be notified and offered to replace the Markdown fragment with the 
corresponding DITA markup.

Examples of the Markdown fragments that are recognized and converted to DITA are 
described below.

## Lists
  
Something like 

```
* item 1
* item 2
* item 3  
```  

will be converted to  

```xml
<ol>
  <li>item 1</li>
  <li>item 2</li>
  <li>item 3</li>
</ol>  
```

rendered as

  * item 1
  
  * item 2
  
  * item 3
  
You can also use `-` instead of `*` to start unordered list items.
  
Something like

```
  1. item 1
  2. item 2
  3. item 3  
```

will be converted to 

```xml
<ol>
  <li>item 1</li>
  <li>item 2</li>
  <li>item 3</li>  
</ol>
```

rendered as
    
1. item 1
2. item 2
3. item 3  

## Quotes

Something like

```
> quote text
> quote text
> quote text
```

is converted to

```xml
<lq>
  <p>quote text</p>
  <p>quote text</p>
  <p>quote text</p>
</lq>  
```

that renders as

> quote text
> quote text
> quote text

## Code blocks 

Something 

``` 
  ``` 
  1+1=2 
  ``` 
```

results into a `codeblock` element

```xml
<codeblock>
  1+1=2
</codeblock>
```

rendered as

``` 
  1+1=2 
```


## Inline code

Something like

```
This is a `test` for inline code. 
```

is converted to 

```xml
This is a <codeph>test</codeph> for inline quotes. 
```

rendered as 

This is a `test` for inline code.

## Links

Links are also detected and converted to cross references. 

```
See the [oXygen website](http://www.oxygenxml.com) 
for more details.
```

is converted to

```xml
See the <xref format="html" href="http://www.oxygenxml.com" scope="external">oXygen website</xref> 
for more details.
```

rendered as
See the [oXygen website](http://www.oxygenxml.com) for more details.

Or we can have quick links like

```
<http://www.oxygenxml.com> 
```

and these also can be converted to DITA cross references

```xml
<xref format="html" href="http://www.oxygenxml.com" scope="external"/>
```

rendered as

<http://www.oxygenxml.com>


## Images

An image using Markdown format will be converted to a `figure` or `image` element, 
depending whether there is a title or not.

```
In this case we have a title, so we should get a figure 
![oXygen logo](https://www.oxygenxml.com/img/resources/oxygen190x62.png "One of the oXygen logos") 
which is a block!
```

results in

```xml
In this case we have a title, so we should get a figure 
<fig>
  <title>One of the oXygen logos</title>
  <image href="https://www.oxygenxml.com/img/resources/oxygen190x62.png">
    <alt>oXygen logo</alt>
  </image>
</fig> which is a block!
```

rendered as

In this case we have a title, so we should get a figure ![oXygen logo](https://www.oxygenxml.com/img/resources/oxygen190x62.png "One of the oXygen logos") which is a block!

If we do not have a title then an inline `image` element is generated 

```
In this case we obtain only an image ![oXygen logo](https://www.oxygenxml.com/img/resources/oxygen190x62.png) which is rendered inline.
```

generates

```xml
In this case we obtain only an image <image href="https://www.oxygenxml.com/img/resources/oxygen190x62.png">
<alt>oXygen logo</alt></image> which is rendered inline.
```

rendered as

In this case we obtain only an image ![oXygen logo](https://www.oxygenxml.com/img/resources/oxygen190x62.png) which is rendered inline.

## Tables

We can convert tables with header row:

```
|test|table|conversion|
|-|-|-|
|1|2|3|
|1|2|3|
```

converted to something like 

```xml
<table id="table_ub4_44j_rx">
    <tgroup cols="3">
        <colspec colname="col1"/>
        <colspec colname="col2"/>
        <colspec colname="col3"/>
        <thead>
            <row>
                <entry>test</entry>
                <entry>table</entry>
                <entry>conversion</entry>
            </row>
        </thead>
        <tbody>
            <row>
                <entry>1</entry>
                <entry>2</entry>
                <entry>3</entry>
            </row>
            <row>
                <entry>1</entry>
                <entry>2</entry>
                <entry>3</entry>
            </row>
        </tbody>
    </tgroup>
</table>
```

rendered as

|test|table|conversion|
|-|-|-|
|1|2|3|
|1|2|3|

We can similarly convert tables without a header row:

```
|-|-|-|
|1|2|3|
|1|2|3|
```

to 

```xml
<table id="table_a1k_lnk_rx">
    <tgroup cols="3">
        <colspec colname="col1"/>
        <colspec colname="col2"/>
        <colspec colname="col3"/>
        <tbody>
            <row>
                <entry>1</entry>
                <entry>2</entry>
                <entry>3</entry>
            </row>
            <row>
                <entry>1</entry>
                <entry>2</entry>
                <entry>3</entry>
            </row>
        </tbody>
    </tgroup>
</table>
```

|-|-|-|
|1|2|3|
|1|2|3|


## Sections

Sections can be easily created by using ## to mark their title.

```
## New section
```

results in something like

```xml
<section id="section_i5l_nnk_rx">
    <title>New section</title>
    <p/>
</section>
```        


##  Inner and sibling topics

On the last paragraph you can use # to mark an inner or sibling topic title

```
# New topic
```

This will result in something like:

```xml
<topic id="topic_201610210051370300">
    <title>New topic</title>
    <body>
        <p/>
    </body>
</topic>
```    
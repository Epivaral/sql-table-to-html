# SQL table to HTML
### Convert any table or select query to a html table format

**FROM:** [www.sqlguatemala.com](http://www.sqlguatemala.com/p/free-tools.html)

**SP:** sp_TabletoHTML

**Version:** 1.0

**AUTHOR:** Eduardo Pivaral [sqlguatemala.com](www.sqlguatemala.com)

**MIT License**

This stored procedure converts a table or select query to a HTML table format, 
with some customization options.

I have taken as a base, a script [Carlos Robles](https://twitter.com/dbamastery) ([dbamastery.com](http://dbamastery.com/))
provided me for a static table, so i modified it to accept any table and apply different
or no styles, also you can output or not the column names to the table.

### NOTES:
----------	 
* This SP works with dynamic queries, also data is not validated,
so it is vulnerable to SQL injection attacks, so always validate your queries first.

* Null values are not converted on this initial release, so before using it,
remove null values from your data.

* Some special datatypes like geography, timestamp, xml, image are not supported,
if you try to use them, an error will raise, remove these columns before using it.

* This tool is not designed to handle huge amounts of data, so, for massive information
you can split them in various executions.		
-----------

### PARAMETERS:
-----------
- **@stTable:** input table or SELECT query, a schema.object or SELECT query format
- **@RawTableStyle:** OUTPUT variable, to use in another process or programatically
- **@includeColumnName:**  0=does not include column names | 1=include column names (DEFAULT)
- **@TableStyle:** 0=no style | 1=black borders (DEFAULT) | 2=grey style | 3=lightblue style
-----------


### SAMPLE EXECUTION:
-----------------

**Most basic usage, table name and all defaults to query window**
```SQL
EXEC sp_TabletoHTML @stTable = 'sys.dm_os_windows_info'
```
Output:

 ![table output ](/images/1.JPG)

**SELECT QUERY, all defaults**
```SQL
SET @SQLSentence = 'SELECT name,state_desc ,create_date,collation_name FROM sys.databases'

EXEC sp_TabletoHTML @stTable = @SQLSentence,
	@RawTableStyle = @st OUTPUT
```
Output:

 ![table output ](/images/2.JPG)

**Remove column name**
```SQL
SET @SQLSentence = 'SELECT name,state_desc ,create_date,collation_name FROM sys.databases'

EXEC sp_TabletoHTML @stTable = @SQLSentence,
	@includeColumnName = 0,
	@RawTableStyle = @st OUTPUT
```
Output:

 ![table output ](/images/3.JPG)

**Gray style with columns**
```SQL
SET @SQLSentence = 'SELECT name,state_desc ,create_date,collation_name FROM sys.databases'

EXEC sp_TabletoHTML @stTable = @SQLSentence,
	@TableStyle = 2,
	@RawTableStyle = @st OUTPUT
```
Output:

 ![table output ](/images/4.JPG)

**Lightblue with columns**
```SQL
SET @SQLSentence = 'SELECT name,state_desc ,create_date,collation_name FROM sys.databases'

EXEC sp_TabletoHTML @stTable = @SQLSentence,
	@TableStyle = 3,
	@RawTableStyle = @st OUTPUT
```
Output:

 ![table output ](/images/5.JPG)

**Remove style and columns**
```SQL
SET @SQLSentence = 'SELECT name,state_desc ,create_date,collation_name FROM sys.databases'

EXEC sp_TabletoHTML @stTable = @SQLSentence,
	@TableStyle = 0,
	@includeColumnName = 0,
	@RawTableStyle = @st OUTPUT
```
Output:

 ![table output ](/images/6.JPG)
-----------------

IF OBJECT_ID('dbo.sp_TabletoHTML') IS NULL
	EXEC ('CREATE PROCEDURE dbo.sp_TabletoHTML AS SELECT 1;');
GO

ALTER PROCEDURE [dbo].[sp_TabletoHTML] 
	@stTable AS NVARCHAR(max),
	@RawTableStyle AS NVARCHAR(max) = '' OUTPUT,
	@includeColumnName AS BIT = 1, 
	@TableStyle AS TINYINT = 1 
AS
BEGIN
	/*******************************************************************************
	Convert any table or select query to a html <table> format
	FROM: https://github.com/Epivaral/sql-table-to-html

	SP: sp_TabletoHTML
	Version: 1.0
	AUTHOR: Eduardo Pivaral (www.sqlguatemala.com)
	MIT License
	
	This stored procedure converts a table or select query to a HTML table format, 
	with some customization options.

	I have taken as a base, a script Carlos Robles (http://dbamastery.com/) 
	provided me for a static table, so i modified it to accept any table and apply different
	or no styles, also you can output or not the column names to the table.

	NOTES:
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

	PARAMETERS:
	-----------
	@stTable: input table or SELECT query, a schema.object or SELECT query format
	@RawTableStyle: OUTPUT variable, to use in another process or programatically
	@includeColumnName:  0=does not include column names | 1=include column names (DEFAULT)
	@TableStyle: 0=no style | 1=black borders (DEFAULT) | 2=grey style | 3=lightblue style
	-----------


	SAMPLE EXECUTION:
	-----------------
	Most basic execution with all defaults:

	EXEC sp_TabletoHTML @stTable = 'sys.dm_os_sys_info'

	more execution examples at: https://github.com/Epivaral/sql-table-to-html
	-----------------
	*******************************************************************************/

	SET NOCOUNT ON;
	
	IF EXISTS (
			SELECT *
			FROM tempdb.INFORMATION_SCHEMA.TABLES
			WHERE TABLE_NAME = '##rowstablePreHTML'
			)
	BEGIN
		DROP TABLE ##rowstablePreHTML
	END
	

	/*** BASIC SQL Injection detection, always make your own validations before input any code */
	IF (
			(CHARINDEX('DELETE ', @stTable) > 0)
			OR (CHARINDEX('INSERT ', @stTable) > 0)
			OR (CHARINDEX('UPDATE ', @stTable) > 0)
			OR (CHARINDEX('INTO ', @stTable) > 0)
			OR (CHARINDEX('DROP ', @stTable) > 0)
			OR (CHARINDEX('TRUNCATE ', @stTable) > 0)
			OR (CHARINDEX('MERGE ', @stTable) > 0)
			OR (CHARINDEX('EXEC ', @stTable) > 0)
			OR (CHARINDEX('EXECUTE ', @stTable) > 0)
			OR (CHARINDEX('--', @stTable) > 0)
			OR (CHARINDEX(';', @stTable) > 0)
			OR (CHARINDEX('XP_', @stTable) > 0)
			OR (CHARINDEX('KILL ', @stTable) > 0)
			)
	BEGIN
		THROW 50000,'Only Select statements or schema.object names are allowed as an input',1;
		RETURN;
	END
	/********************************************************************************************/

	/************** INTERNAL PARAMETERS **************/
	DECLARE @ColumnST AS NVARCHAR(max) = ''
	DECLARE @newSelect AS NVARCHAR(max) = ''
	DECLARE @ColumnNamesHTML AS NVARCHAR(max) = ''
	DECLARE @CSSTableStyle AS NVARCHAR(max) = ''
	DECLARE @SelectStatement as NVARCHAR(max) = ''
	/************* END INTERNAL PARAMETERS *************/
			
	IF(CHARINDEX('SELECT',@stTable)>0)
	BEGIN
		SET @SelectStatement = 'SELECT tbl1.* into ##rowstablePreHTML FROM (' + @stTable+') tbl1'
	END
	ELSE
	BEGIN
		 SET @SelectStatement= 'SELECT tbl1.* into ##rowstablePreHTML FROM ' + @stTable + ' tbl1'
	END
	
	BEGIN TRY
		EXEC sp_executesql	@SelectStatement --Loading table contents on temp table
	END TRY  
	BEGIN CATCH
		THROW 50000,'Syntax related issue with your input, use "<schema>.<table>" or "SELECT <columns> FROM <TABLE>" format',1;
		RETURN;
	END CATCH; 


	SET @ColumnST = (
			SELECT '[' + COLUMN_NAME + ']' AS 'TH'
			FROM tempdb.INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME LIKE '##rowstablePreHTML'
			FOR XML raw('TR'),
				elements	
			) -- Obtain columns for the table 

	-- performing cleanup task for columns
	SET @ColumnST = REPLACE(@ColumnST, '<TR>', '')
	SET @ColumnST = REPLACE(@ColumnST, '</TR>', '')

	SET @ColumnNamesHTML = '<TR>' + @ColumnST + '</TR>' --Obtaining column names, we will use this later to append to the table

	-- Removing [] we put before on the columns
	SET @ColumnNamesHTML = REPLACE(@ColumnNamesHTML, '[', '')
	SET @ColumnNamesHTML = REPLACE(@ColumnNamesHTML, ']', '')

	-- we continue cleanup tasks for columns before creating or dynamic Select
	SET @ColumnST = REPLACE(@ColumnST, '<TH>', '')
	SET @ColumnST = REPLACE(@ColumnST, '</TH>', 'as TD,') --creating all column names with the same name 
	SET @ColumnST = LEFT(@ColumnST, LEN(@ColumnST) - 1) -- Removing last comma

	-- generating select statement on an HTML friendly format
	SET @newSelect = 'SELECT @RawTableStyleOUT =(SELECT ' + isnull(@ColumnST, '') + ' FROM ##rowstablePreHTML For XML RAW(''TR''), ELEMENTS)'

	EXEC sp_executesql @newSelect,
		N' @RawTableStyleOUT as nvarchar(max) OUTPUT',
		@RawTableStyleOUT = @RawTableStyle OUTPUT

	IF (@TableStyle = 0) -- no Style
	BEGIN
		SET @CSSTableStyle = '' 
	END

	IF (@TableStyle = 1) -- black borders
	BEGIN
		SET @CSSTableStyle = '<style type="text/css">
	table, th, td {border: 1px solid; border-collapse: collapse;}
	</style>'
	END

	IF (@TableStyle = 2) -- Grey style
	BEGIN
		SET @CSSTableStyle = '<style type="text/css">
	table, td, tr {border: 1px solid #dddddd; padding: 3px; color: #555555; border-collapse: collapse;}
	th {background-color: #dddddd;}
	</style>'
	END

	IF (@TableStyle = 3) -- lightblue borders
	BEGIN
		SET @CSSTableStyle = '<style type="text/css">
	table, td, tr {border: 1px solid #DCDCDC; padding: 2px; color: #808080; border-collapse: collapse;}
	th {border: 1px solid #DCDCDC;background-color: #1E90FF;color:#FFFFFF;}
	</style>'
	END

	IF(@includeColumnName =1) --IF Column names must be included
	BEGIN
		SET @RawTableStyle = @ColumnNamesHTML + @RawTableStyle
	END
	
	SET @RawTableStyle = @CSSTableStyle + '<TABLE>' + isnull(@RawTableStyle,'') + '</TABLE>'

	SELECT @RawTableStyle

END
GO


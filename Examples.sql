/*various execution examples*/

DECLARE	@st NVARCHAR(max)
		,@SQLSentence NVARCHAR(max)

SET @SQLSentence = 'SELECT name,state_desc ,create_date,collation_name FROM sys.databases'

-- most basic usage, table name and all defaults to query window
EXEC sp_TabletoHTML @stTable = 'sys.dm_os_windows_info'

--Using output parameter:

-- SELECT QUERY, all defaults
EXEC sp_TabletoHTML @stTable = @SQLSentence,
	@RawTableStyle = @st OUTPUT


-- Remove column name
EXEC sp_TabletoHTML @stTable = @SQLSentence,
	@includeColumnName = 0,
	@RawTableStyle = @st OUTPUT


-- Gray style with columns
EXEC sp_TabletoHTML @stTable = @SQLSentence,
	@TableStyle = 2,
	@RawTableStyle = @st OUTPUT


-- lightblue with columns
EXEC sp_TabletoHTML @stTable = @SQLSentence,
	@TableStyle = 3,
	@RawTableStyle = @st OUTPUT



-- remove style and columns
EXEC sp_TabletoHTML @stTable = @SQLSentence,
	@TableStyle = 0,
	@includeColumnName = 0,
	@RawTableStyle = @st OUTPUT






USE [QQQun]
GO

/****** Object:  StoredProcedure [dbo].[insertIntoSingleTable]    Script Date: 03/09/2018 14:34:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	此存储过程为整合多库多表数据进入单库单表存储过程，请勿运行
-- =============================================
CREATE PROCEDURE [dbo].[insertIntoSingleTable] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    -- 下面两句会清空数据库
	--truncate table dbo.Member
	--truncate table dbo.Qun

	--获取全部表与数据库关系
	declare @allTables table ([serverName] nvarchar(1000), [databaseName] nvarchar(1000), [schemaName] nvarchar(1000), [tableName] nvarchar(1000))
	insert into 
		@allTables ([serverName], [databaseName], [schemaName], [tableName])
	exec sp_msforeachdb '
		select
			@@SERVERNAME,
			''?'',
			s.name,
			t.name
		from
			[?].sys.tables t
			inner join
			sys.schemas s
		on
			t.schema_id = s.schema_id
	'

	declare @task table (id int primary key identity(1, 1), cmd nvarchar(1000), msg nvarchar(50))
	declare @tbName nvarchar(50)

	--插入群信息任务
	set @tbName = 'QunList'
	insert into
		@task
	select
		'
			insert into
				QQQun.dbo.Qun (QunNum, MastQQ, CreateDate, Title, Class, QunText)
			select
				a.QunNum,
				a.MastQQ,
				a.CreateDate,
				a.Title,
				a.Class,
				a.QunText
			from
				' + a.databaseName + '.dbo.' + a.tableName + ' a
		' as cmd,
		'insert ' + a.databaseName + '.' + a.tableName as msg
	from
		@allTables a
	where
		a.databaseName != 'QQQun' and
		a.tableName like @tbName + '%'
	order by
		CONVERT(int, SUBSTRING(a.tableName, LEN(@tbName) + 1, LEN(a.tableName) - LEN(@tbName)))

	--插入群成员数据任务
	set @tbName = 'Group'
	insert into
		@task
	select
		'
			insert into
				QQQun.dbo.Member (QQNum, Nick, Age, Gender, Auth, QunNum)
			select
				a.QQNum,
				a.Nick,
				a.Age,
				a.Gender,
				a.Auth,
				a.QunNum
			from
				' + a.databaseName + '.dbo.' + a.tableName + ' a
		' as cmd,
		'insert ' + a.databaseName + '.' + a.tableName as msg
	from
		@allTables a
	where
		a.databaseName != 'QQQun' and
		a.tableName like @tbName + '%'
	order by
		CONVERT(int, SUBSTRING(a.tableName, LEN(@tbName) + 1, LEN(a.tableName) - LEN(@tbName)))


	declare @i int
	set @i = 1
	declare @count int
	select
		@count = MAX(a.id)
	from
		@task a
	declare @cmd nvarchar(1000)
	declare @msg nvarchar(50)
	declare @outinfo nvarchar(100)
	while @i <= @count
		begin
			select
				@cmd = a.cmd,
				@msg = a.msg
			from
				@task a
			where
				a.id = @i
			set @outinfo = (LTRIM(STR(@i)) + '-->' + LTRIM(STR(@count)) + '  ' + @msg + '...')
			RAISERROR (@outinfo, 10, 1) WITH NOWAIT
			exec(@cmd)
			set @i = @i + 1
		end
		
	SET NOCOUNT OFF
END

GO


USE [QQQun]
GO

/****** Object:  StoredProcedure [dbo].[queryByQQNum]    Script Date: 03/09/2018 14:33:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[queryByQQNum]
	-- Add the parameters for the stored procedure here
	@QQNum int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    --生成基础数据表
	select
		a.QQNum as 'dstQQNum',
		a.Nick as 'dstNick',
		a.Age as 'dstAge',
		a.Gender as 'dstGender',
		a.Auth as 'qunAuth',
		a.QunNum as 'qunNum',
		
		b.Title as 'qunTitle',
		b.QunText as 'qunText',
		b.MastQQ as 'qunMastQQ',
		b.Class as 'qunClass',
		b.CreateDate as 'qunCreateDate',
		
		c.QQNum as 'qunMemberQQNum',
		c.Nick as 'qunMemberNick',
		c.Age as 'qunMemberAge',
		c.Gender as 'qunMemberGender',
		c.Auth as 'qunMemberAuth'
	into
		#basetable
	from
		Member a
		left join
		Qun b
	on
		a.QunNum = b.QunNum
		left join
		Member c
	on
		a.QunNum = c.QunNum
	where
		a.QQNum = @QQNum
	--生成目标QQ信息	
	select top 1
		a.dstQQNum as 'QQNum',
		a.dstNick as 'Nick',
		a.dstAge as 'Age',
		a.dstGender as 'Gender'
	into
		#dstQQTable
	from
		#basetable a
	group by
		a.dstQQNum,
		a.dstNick,
		a.dstAge,
		a.dstGender
	order by
		COUNT(1)
	desc
	--生成目标QQ加群信息
	select
		a.qunNum as 'GroupNum',
		a.dstQQNum as 'QQNum',
		a.qunAuth as 'Auth',
		a.qunTitle as 'GroupTitle',
		a.qunText as 'GroupText',
		a.qunMastQQ as 'GroupMastQQ',
		a.qunClass as 'GroupClass',
		a.qunCreateDate as 'GroupCreateDate'
	into
		#joinGroupTable
	from
		#basetable a
	group by
		a.dstQQNum,
		a.qunAuth,
		a.qunNum,
		a.qunTitle,
		a.qunText,
		a.qunMastQQ,
		a.qunClass,
		a.qunCreateDate
	--生成群成员信息	
	select
		a.qunNum as 'GroupNum',
		a.qunMemberQQNum as 'QQNum',
		a.qunMemberAuth as 'Auth',
		a.qunMemberNick as 'Nick',
		a.qunMemberAge as 'Age',
		a.qunMemberGender as 'Gender'
	into
		#groupMemberTable
	from
		#basetable a
	group by
		a.qunNum,
		a.qunMemberQQNum,
		a.qunMemberNick,
		a.qunMemberAge,
		a.qunMemberGender,
		a.qunMemberAuth
		
	--输出QQ节点
	select distinct
		a.QQNum as 'ID',
		case a.QQNum when @QQNum then 1 else 0 end as 'IsDst',
		'Member' as 'Type'
	from
		#groupMemberTable a
	order by
		case a.QQNum when @QQNum then 1 else 0 end
	desc
	--输出群节点
	select
		a.GroupNum as 'ID',
		a.GroupTitle,
		a.GroupText,
		a.GroupMastQQ,
		a.GroupClass,
		a.GroupCreateDate,
		'Group' as 'Type'
	from
		#joinGroupTable a
	--输出加群关系信息
	select
		a.GroupNum,
		a.QQNum,
		a.Auth,
		a.Nick,
		a.Age,
		a.Gender
	from
		#groupMemberTable a
END

GO


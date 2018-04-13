USE [QQQun]
GO

/****** Object:  StoredProcedure [dbo].[queryByQunNum]    Script Date: 03/09/2018 14:33:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[queryByQunNum]
	-- Add the parameters for the stored procedure here
	@QunNum int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    --生成基础数据表
	select
		a.QunNum as 'dstQunNum',
		a.Title as 'dstTitle',
		a.QunText as 'dstQunText',
		a.MastQQ as 'dstMastQQ',
		a.Class as 'dstClass',
		a.CreateDate as 'dstCreateDate',
		
		b.QQNum as 'memberQQNum',
		b.Nick as 'memberNick',
		b.Age as 'memberAge',
		b.Gender as 'memberGender',
		b.Auth as 'memberAuth',
		
		c.QunNum as 'joinQunNum',
		c.Nick as 'joinNick',
		c.Age as 'joinAge',
		c.Gender as 'joinGender',
		c.Auth as 'joinAuth',
		
		d.Title as 'joinQunTitle',
		d.QunText as 'joinQunText',
		d.MastQQ as 'joinQunMastQQ',
		d.Class as 'joinQunClass',
		d.CreateDate as 'joinQunCreateDate'
	into
		#basetable
	from
		Qun a
		left join
		Member b
	on
		a.QunNum = b.QunNum
		left join
		Member c
	on
		b.QQNum = c.QQNum
		left join
		Qun d
	on
		c.QunNum = d.QunNum
	where
		a.QunNum = @QunNum
	--生成目标群信息	
	select
		a.dstQunNum as 'GroupNum',
		a.dstTitle as 'GroupTitle',
		a.dstQunText as 'GroupText',
		a.dstMastQQ as 'GroupMastQQ',
		a.dstClass as 'GroupClass',
		a.dstCreateDate as 'GroupCreateDate'
	into
		#dstGroupTable
	from
		#basetable a
	group by
		a.dstQunNum,
		a.dstTitle,
		a.dstQunText,
		a.dstMastQQ,
		a.dstClass,
		a.dstCreateDate
	--生成目标群员信息	
	select
		a.dstQunNum as 'GroupNum',
		a.memberQQNum as 'QQNum',
		a.memberAuth as 'Auth',
		a.memberNick as 'Nick',
		a.memberAge as 'Age',
		a.memberGender as 'Gender'
	into
		#dstGroupMemberTable
	from
		#basetable a
	group by
		a.dstQunNum,
		a.memberQQNum,
		a.memberNick,
		a.memberAge,
		a.memberGender,
		a.memberAuth
	--生成群员加群信息
	select
		a.joinQunNum as 'GroupNum',
		a.memberQQNum as 'QQNum',
		a.joinAuth as 'Auth',
		a.joinQunTitle as 'GroupTitle',
		a.joinQunText as 'GroupText',
		a.joinQunMastQQ as 'GroupMastQQ',
		a.joinQunClass as 'GroupClass',
		a.joinQunCreateDate as 'GroupCreateDate',
		a.joinNick as 'Nick',
		a.joinAge as 'Age',
		a.joinGender as 'Gender'
	into
		#joinGroupTable
	from
		#basetable a
	group by
		a.memberQQNum,
		a.joinNick,
		a.joinAge,
		a.joinGender,
		a.joinAuth,
		a.joinQunNum,
		a.joinQunTitle,
		a.joinQunText,
		a.joinQunMastQQ,
		a.joinQunClass,
		a.joinQunCreateDate
		
	--输出QQ节点
	select
		a.QQNum
	from
		#dstGroupMemberTable a
	--输出群节点
	select distinct
		a.GroupNum,
		a.GroupTitle,
		a.GroupText,
		a.GroupMastQQ,
		a.GroupClass,
		a.GroupCreateDate,
		case a.GroupNum when @QunNum then 1 else 0 end as 'IsDst'
	from
		#joinGroupTable a
	order by
		case a.GroupNum when @QunNum then 1 else 0 end
	desc
	--输出连接关系
	select
		a.GroupNum,
		a.QQNum,
		a.Auth,
		a.Nick,
		a.Age,
		a.Gender
	from
		#joinGroupTable a
END

GO


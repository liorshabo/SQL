--//שאלה 1
--סעיף א
select email, nickName, year(registrationDate) as registrationYear,
G.gameName, D.downloadDate,datediff(day,registrationDate,downloadDate) as NumOfDayToDownload
from tblGamer GR inner join tblDownload D on GR.UserNo = D.userNo inner join tblGame G on D.gameNo=G.gameNo
where (year(registrationDate))> 2015 
order by  registrationYear desc , NumOfDayToDownload

--סעיף ב
select distinct email, nickName, year(registrationDate) as registrationYear,
G.gameName, D.downloadDate,datediff(day,registrationDate,downloadDate) as NumOfDayToDownload
from tblGamer GR inner join tblDownload D on GR.UserNo = D.userNo inner join tblGame G on D.gameNo=G.gameNo
inner join tblPlaysIn PL on ((D.userNo = PL.userNo) and (D.gameNo=PL.gameNo))
where year(registrationDate) > 2015 and levelRank>3
order by  registrationYear desc , NumOfDayToDownload 

--סעיף ג
select distinct email, nickName, year(registrationDate) as registrationYear,
G.gameName, D.downloadDate,datediff(day,registrationDate,downloadDate) as NumOfDayToDownload
from tblGamer GR inner join tblDownload D on GR.UserNo = D.userNo inner join tblGame G on D.gameNo=G.gameNo
inner join tblPlaysIn PL on ((D.userNo = PL.userNo) and (D.gameNo=PL.gameNo)) 
inner join tblPurchase PS on PS.userNo = D.userNo
where year(registrationDate) > 2015 and levelRank>3
and amount = 30 and purchaseType = 'C'
order by  registrationYear desc , NumOfDayToDownload

--סעיף ד 
select distinct email, nickName, year(registrationDate) as registrationYear,
G.gameName, D.downloadDate,datediff(day,registrationDate,downloadDate) as NumOfDayToDownload
from tblGamer GR inner join tblDownload D on GR.UserNo = D.userNo inner join tblGame G on D.gameNo=G.gameNo
inner join tblPlaysIn PL on ((D.userNo = PL.userNo) and (D.gameNo=PL.gameNo)) 
inner join tblPurchase PS on PS.userNo = D.userNo
where year(registrationDate) > 2015 and levelRank>3
and amount = 30 and purchaseType = 'C'
order by  registrationYear desc , NumOfDayToDownload
union




--//שאלה 2
select G.gameNo, gameName, typeName ,L.levelNo, userNo,
datediff(year,arrivalDate,GETDATE()) as seniority, levelRank
from tblGame G inner join tblLevel L on G.gameNo=L.gameNo inner join tblGoalType GT on GT.typeNo=L.typeNo
 LEFT join tblPlaysIn PI on L.levelNo=PI.levelNo and  L.gameNo=PI.gameNo
 order by  G.gameNo, gameName, L.levelNo


 --//שאלה 3
 select G.gameNo,gameName,gameDescription
 from tblGame G inner join tblDownload D on G.gameNo=D.gameNo
 where year(downloadDate) = year(getdate())
 except
 select G.gameNo,gameName,gameDescription
 from tblGame G inner join tblDownload D on G.gameNo=D.gameNo
 inner join tblRequest R on D.gameNo = R.gameNo
 inner join tblRequestType RT on R.requestTypeNo = RT.requestTypeNo
 where year(downloadDate) = year(getdate()) and requastName='game invitation'


  
 --//שאלה 4
 SELECT G.*, GR.* 
FROM (
	SELECT P.userNo, P.gameNo --, COUNT(P.levelNo), Q.levelsPlayed
	FROM tblPlaysIn P
		inner join tblLevel L ON L.gameNo = P.gameNo AND L.levelNo = P.levelNo
		left join (SELECT userNo, P.gameNo, COUNT(P.levelNo) levelsPlayed
					FROM tblPlaysIn P
					GROUP BY userNo, P.gameNo) Q ON Q.userNo = P.userNo AND Q.gameNo = P.gameNo
	WHERE P.highScore >= L.pointsForStar3
	GROUP BY P.userNo, P.gameNo
	, Q.levelsPlayed
	HAVING COUNT(P.levelNo) = Q.levelsPlayed
) Q
left join tblGame G on G.gameNo = Q.gameNo
left join tblGamer Gr on Gr.UserNo = Q.userNo



 --//שאלה 5
 select gameName, L.levelNo,typeName, count(PI.userNo) NumOfPlayers,
 avg(1.0*PI.highScore) AVGscore, max(highScore) MAXscore,
 min(highScore) MINscore, avg(levelRank) AVGRank
 from tblLevel L inner join tblGame G on L.gameNo = G.gameNo 
 inner join tblGoalType GT on GT.typeNo =L.typeNo
 left join tblPlaysIn PI on PI.gameNo = L.gameNo and PI.levelNo =L.levelNo
 group by gameName, L.levelNo,typeName
 order by gameName,L.levelNo



  
 --//שאלה 6
 declare @X int
 set @X = 1
 select GR.UserNo, nickName, G.gameNo, gameName, COUNT(R.requestNo), COUNT(posterNo)
 from tblGamer GR inner join tblDownload D on GR.UserNo = D.userNo
 inner join tblGame G on G.gameNo=D.gameNo
 inner join tblRequest R on R.gameNo=G.gameNo 
 inner join tblRequestType RT on R.requestTypeNo=RT.requestTypeNo
 where requastName ='game invitation' AND downloadDate=NULL
 group by GR.UserNo, nickName, G.gameNo, gameName
 having COUNT(R.requestNo) >= @X



  
 --//שאלה 7
 select DISTINCT nickName, G.UserNo
 from tblGamer G inner join tblPurchase P on G.UserNo = P.userNo
 where purchaseType = 'C'and year(PurchaseDate) = year(getdate()) and amount >=10
 intersect
 select nickName, G.UserNo
 from tblGamer G inner join tblPurchase P on G.UserNo = P.userNo
 where purchaseType = 'C' and year(getdate())-1=year(PurchaseDate)
 group by G.userNo, nickName
 having SUM(P.amount) >= 360



 --//שאלה 8

  declare @y int
  set @y = 1
  select nickName, G.UserNo, sum(highScore) as sum_of_points
  from tblGamer G inner join tblPlaysIn PY on G.UserNo = PY.userNo 
  where PY.gameNo=@y
  group by nickName, G.UserNo
  having sum(highScore) > ALL (
                             select sum(highScore)
							from (select userNo2 as [user] from tblFriendOf F1 where (userNo1 = G.userNo)
								union
								select userNo1 from tblFriendOf where userNo2 =G.userNo) as temp inner join tblPlaysIn as PY2 on temp.[user]=PY2.userNo
								where gameNo=@y
								group by [user])




 --//שאלה 9
select  G.gameNo, gameName, [year] ,num_of_new_gamers,
 isnull(sum_of_coins_Purchase,0) sum_of_coins_Purchase
 from tblGame G inner join 
              ( select DATEPART(year, arrivalDate) as [year] , count(*) as num_of_new_gamers,gameNo
                from tblPlaysIn
                group by DATEPART(year, arrivalDate),gameNo)
		        P ON G.gameNo=P.gameNo
left join     (select isnull(sum(amount),0) as sum_of_coins_Purchase,
                gameNo, DATEPART(year, PurchaseDate) Purchaseyaer
               from tblPurchase 
               where purchaseType = 'C'
			   group by gameNo, DATEPART(year, PurchaseDate)) PS1 ON PS1.Purchaseyaer=p.[year] 
			   and PS1.gameNo=P.gameNo
	where [year] in
	             (select distinct DATEPART(year, PurchaseDate) a
                 from tblPurchase )
	order by [year], G.gameName                		 
--צריך לצמצם את החיפוש - נציג את הרשומים החדשים בכל שנה שבהכרח ביצעו רכישות
--שנה של רכישה = שנה של הרשמה בהכרח (תנאי
--להציג אנשים שבהכרח נרשמו בשנה מסויימת ובאותה שנה גם רכשו
--הפלט צריך להצטצמצם לשנים בהם היו רכישות מבין כל שנות ההרשמה באופן כללי
--אם הם רכשו אז הם בטח נרשמו. אבל אם הם נרשמו הם לא בהכרח רכשו ולכן צריך לחפש מי רכש מבין כל מי שנרשם 



			 select sum(amount) sum_of_Purchase, gameNo
             from tblPurchase 
             where purchaseType = 'M'
			 group by gameNo
			 union
			 select sum(amount) sum_of_Purchase, gameNo
              from tblPurchase 
             where purchaseType = 'L'
			 group by gameNo
			 union
             select sum(amount) sum_of_Purchase, gameNo
             from tblPurchase 
             where purchaseType = 'B'
			 group by gameNo
									    

         




select DATEPART(year, arrivalDate) as year , count(*) as num_of_new_gamers, gameNo
from tblPlaysIn
group by DATEPART(year, arrivalDate),gameNo





  --//שאלה א10
   CREATE TRIGGER tblFriendOf
   on [tblFriendOf]
   AFTER insert as 
   begin 
   DECLARE
   @UserNo1 INT, @UserNo2 INT
   select @UserNo1=inserted.[userNo1], @UserNo2=inserted.[userNo2]
   from inserted 
   IF exists  
	   ((select userNo1 from tblFriendOf where userNo1=@UserNo1)
       union
       (select userNo2 from tblFriendOf where userNo2=@UserNo2))
   rollback
   else begin
   insert tblFriendOf
   set userNo1 = @UserNo1, userNo2 = @UserNo2
   end
   





 --//שאלת בונוס
 select G.UserNo, nickName, registrationDate, COUNT(PI.gameNo),sum(PI.levelNo),
 case when datediff(month, registrationDate, GETDATE())< 6 then N'שחקן חדש'
 when (datediff(month, registrationDate, GETDATE())-6) between 6 and 12--חצי שנה קודמת לזו
  and (datediff(month, registrationDate, GETDATE())< 6 and arrivalDate is not null) then N'שחקן פעיל'
  when datediff(month, registrationDate, GETDATE()) between 6 and 12 and arrivalDate is not null
  and (datediff(month, registrationDate, GETDATE())< 6 and arrivalDate is null) then N'שחקן מאותת נטישה'
  when ((datediff(year, downloadDate, GETDATE()) < 1) and  arrivalDate is null)
       and (((datediff(year, downloadDate, GETDATE())-1) < 1) and  arrivalDate is not null) then N'שחקן נוטש'
  when  datediff(month, registrationDate, GETDATE())< 6 and
   (datediff(month, registrationDate, GETDATE())-6) < 12 then N'שחקן מתעורר'
  else N'לא רלוונטי'
  end as Category
  from tblGamer G left join tblPlaysIn PI on G.UserNo = PI.UserNo
  left join tblDownload D on D.UserNo = PI.UserNo and D.gameNo = PI.gameNo
  group by G.UserNo, nickName, registrationDate
  




  ---שאלה 9 דן

select distinct [year] ,g.gameNo, g.gameName,
(select count(*) from tblDownload where gameNo=g.gameNo and year(downloadDate)=d.[year]) as num_of_new_gamers,
(select ISNULL(sum(amount),0) from tblPurchase where purchaseType='C' and year(PurchaseDate)=d.[year] and gameNo=g.gameNo) as num_of_C,
(select ISNULL(sum(amount),0) from tblPurchase where purchaseType='M' and year(PurchaseDate)=d.[year] and gameNo=g.gameNo) as num_of_M,
(select ISNULL(sum(amount),0) from tblPurchase where purchaseType='L' and year(PurchaseDate)=d.[year] and gameNo=g.gameNo) as num_of_L,
(select ISNULL(sum(amount),0) from tblPurchase where purchaseType='B' and year(PurchaseDate)=d.[year] and gameNo=g.gameNo) as num_of_B
from (SELECT year(PurchaseDate) as [year], gameNo
from tblPurchase
Union
select year(downloadDate) as [year] ,gameNo from tblDownload) as d inner join tblGame as g on d.gameNo=g.gameNo
order by d.[year],g.gameName
                


------התחלה של 10ב דן
declare
@u int,
@g int

set
@g=3
set @u=1

select * from
(select userNo2 as [user] from tblFriendOf F1 where (userNo1 = @u)
								union
								select userNo1 from tblFriendOf where userNo2 =@u) as temp
								where not exists(select * from tblDownload where temp.[user]=userNo and gameNo=@g)






								---בודק על שאילתה מסויימת האם החזירה שורה אחת לפחות, אם היא החזירה אז אמת וא זאם כן אז תציג מה שיש בסלקט
								--- נוט - אם השאילתה הפנימית מתקיימת ויש נוט אקססיט אז האקזיסט יחזיר אמת והנוט יהפוך לפולס ואז יציג בסלקט את משלים של הנכון

--עוד ניסיון ל10ב
   CREATE TRIGGER FriendOf
   on [tblFriendOf]
   before insert as 
   begin 
   DECLARE
   @UserNo1 INT, @UserNo2 INT
   select @UserNo1=inserted.[userNo1], @UserNo2=inserted.[userNo2]
   from inserted 
   IFת
(select userNo2 as [user] from tblFriendOf F1 where (userNo1 = @u)
								union
								select userNo1 from tblFriendOf where userNo2 =@u) as temp
								where not exists(select * from tblDownload where temp.[user]=userNo and gameNo=@g)                                                              
   rollback
   else 
        begin
        update tblFriendOf
        set userNo1 = @UserNo1, userNo2 = @UserNo2
		end
   end


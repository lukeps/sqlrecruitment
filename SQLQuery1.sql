
CREATE TABLE A(
[Dimension_1] nvarchar,
[Dimension_2] nvarchar,
[Dimension_3] nvarchar,
[Measure_1] int
)

CREATE TABLE B(
[Dimension_1] nvarchar,
[Dimension_2] nvarchar,
[Measure_2] int
)

CREATE TABLE MAP(
[Dimension_1] nvarchar,
[Correct_Dimension_2] nvarchar
)


INSERT INTO dbo.A VALUES('a','I','K',1)
INSERT INTO dbo.A VALUES('a','J','L',7)
INSERT INTO dbo.A VALUES('b','I','M',2)
INSERT INTO dbo.A VALUES('c','J','N',5)

INSERT INTO dbo.MAP VALUES('a','W')
INSERT INTO dbo.MAP VALUES('a','W')
INSERT INTO dbo.MAP VALUES('b','X')
INSERT INTO dbo.MAP VALUES('c','Y')
INSERT INTO dbo.MAP VALUES('b','X')
INSERT INTO dbo.MAP VALUES('d','Z')

INSERT INTO dbo.B VALUES('a','J',7)
INSERT INTO dbo.B VALUES('b','J',10)
INSERT INTO dbo.B VALUES('d','J',4)

SELECT * from dbo.A
Select * from dbo.B
select * from dbo.MAP

-- without summing distinct pairs from A and B tables together
SELECT ac.Dimension_1,ac.Correct_Dimension_2 as Dimension_2,
(CASE WHEN a.A_Measure_1 IS NULL THEN '0' ELSE a.A_Measure_1 END) as Measure_1,
(CASE WHEN b.B_Measure_2 IS NULL THEN '0' ELSE b.B_Measure_2 END) as Measure_2 FROM(
SELECT ab.Dimension_1,ab.Correct_Dimension_2 FROM(
SELECT aa.Dimension_1,aa.Correct_Dimension_2 FROM(SELECT a.Dimension_1,map.Correct_Dimension_2,a.Measure_1 FROM SQL.dbo.A a JOIN( SELECT DISTINCT * FROM SQL.dbo.MAP) map on a.Dimension_1 = map.Dimension_1) aa
GROUP BY aa.Dimension_1,aa.Correct_Dimension_2
UNION ALL
SELECT bb.Dimension_1,bb.Correct_Dimension_2 FROM(SELECT b.Dimension_1,map.Correct_Dimension_2,b.Measure_2 FROM SQL.dbo.B b JOIN( SELECT DISTINCT * FROM SQL.dbo.MAP) map on b.Dimension_1 = map.Dimension_1) bb
GROUP BY bb.Dimension_1,bb.Correct_Dimension_2
)ab
GROUP BY ab.Dimension_1,ab.Correct_Dimension_2) ac
LEFT JOIN (SELECT Dimension_1,SUM(Measure_1) as A_Measure_1 FROM SQL.dbo.A GROUP BY  Dimension_1) a on ac.Dimension_1 = a.Dimension_1
LEFT JOIN (SELECT Dimension_1,SUM(Measure_2) as B_Measure_2 FROM SQL.dbo.B GROUP BY  Dimension_1) b on ac.Dimension_1 = b.Dimension_1



--with grouping A and B pairs together with additional collumn Summed_A_M1_B_M2
SELECT ab.Dimension_1,ab.Dimension_2,(CASE WHEN a.A_Measure_1 IS NULL THEN 0 ELSE a.A_Measure_1 END) as A_Measure_1,(CASE WHEN b.B_Measure_2 IS NULL THEN 0 ELSE b.B_Measure_2 END) as B_Measure_2,ab.Summed_A_M1_B_M2 FROM(
SELECT x.Dimension_1,x.Correct_Dimension_2 as Dimension_2,SUM(x.Measure_1) as Summed_A_M1_B_M2 FROM(
SELECT * FROM(SELECT a.Dimension_1,map.Correct_Dimension_2,a.Measure_1 FROM SQL.dbo.A a JOIN( SELECT DISTINCT * FROM SQL.dbo.MAP) map on a.Dimension_1 = map.Dimension_1) aa
UNION ALL
SELECT bb.Dimension_1,bb.Correct_Dimension_2,bb.Measure_2 FROM(SELECT b.Dimension_1,map.Correct_Dimension_2,b.Measure_2 FROM SQL.dbo.B b JOIN( SELECT DISTINCT * FROM SQL.dbo.MAP) map on b.Dimension_1 = map.Dimension_1) bb
) x
GROUP BY x.Dimension_1,x.Correct_Dimension_2
) ab
LEFT JOIN (SELECT Dimension_1,SUM(Measure_1) as A_Measure_1 FROM SQL.dbo.A GROUP BY  Dimension_1) a on ab.Dimension_1 = a.Dimension_1
LEFT JOIN (SELECT Dimension_1,SUM(Measure_2) as B_Measure_2 FROM SQL.dbo.B GROUP BY  Dimension_1) b on ab.Dimension_1 = b.Dimension_1










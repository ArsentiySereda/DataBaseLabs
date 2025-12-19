
----Задание 2 
--Пункт 2
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--BEGIN TRANSACTION;

--SELECT * FROM Client WHERE id = 10;

--UPDATE Client SET company = 'ООО "СбытЭнерго"' 
--WHERE company = 'ООО "ЭнергоСбыт"';

--WAITFOR DELAY '00:00:10';

--COMMIT TRANSACTION;

--SELECT * FROM Client WHERE id = 10;
--GO

--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--BEGIN TRANSACTION;

--SELECT * FROM Client WHERE id = 6; 

--UPDATE Client SET company = '"ОАО "Строй Дом"' WHERE id = 6;

--WAITFOR DELAY '00:00:10';

--ROLLBACK;

--SELECT * FROM Client WHERE id = 6;
--GO


----Пункт 4
--SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

--BEGIN TRANSACTION;

--SELECT * FROM Client WHERE id = 7;

--UPDATE Client 
--SET company = 'ООО "Новое название"', 
--    contact_person = 'Новое имя'
--WHERE id = 7;

--WAITFOR DELAY '00:00:10';

--ROLLBACK;

--SELECT * FROM Client WHERE id = 7;
--GO


--SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

--BEGIN TRANSACTION;

--SELECT rate, title, max_amount FROM [Credit product] WHERE id = 3;

--WAITFOR DELAY '00:00:07';

--SELECT rate, title, max_amount FROM [Credit product] WHERE id = 3;

--COMMIT TRANSACTION;
--GO


----Пункт 6
--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

--BEGIN TRANSACTION;

--SELECT * FROM Client WHERE id = 2;

--WAITFOR DELAY '00:00:07';

--SELECT * FROM Client WHERE id = 2;

--COMMIT TRANSACTION;
--GO

--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

--BEGIN TRANSACTION;

--SELECT * FROM Client WHERE company LIKE '%ООО%'

--WAITFOR DELAY '00:00:07';

--SELECT * FROM Client WHERE company LIKE '%ООО%'

--COMMIT TRANSACTION;
--GO

----Пункт 8
--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

--BEGIN TRANSACTION;

--SELECT * FROM Client WHERE company LIKE '%ООО%'

--WAITFOR DELAY '00:00:07';

--SELECT * FROM Client WHERE company LIKE '%ООО%'

--COMMIT TRANSACTION;

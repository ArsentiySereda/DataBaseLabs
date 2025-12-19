----Задание 1
BEGIN TRANSACTION;

SELECT * FROM Client WHERE id > 8 ORDER BY id ASC;

INSERT INTO Client (phone_number, contact_person, company, address)
VALUES ('+79160001111', 'Смирнова Анна', 'ООО "СтройГрад"', 'Москва, Строителей 15');

SELECT * FROM Client WHERE id > 8 ORDER BY id ASC;

ROLLBACK TRANSACTION;

SELECT * FROM Client WHERE id > 8 ORDER BY id ASC;
GO

BEGIN TRANSACTION;

INSERT INTO Client (phone_number, contact_person, company, address)
VALUES ('+79262223344', 'Ковалев Георгий', 'ЗАО "ТехноПрофи"', 'Санкт-Петербург, Техническая 25');

SELECT * FROM Client WHERE id > 8 ORDER BY id ASC;

SAVE TRANSACTION Savepoint1;

INSERT INTO Client (phone_number, contact_person, company, address)
VALUES ('+79035556677', 'Петрова Анна', 'ИП Петрова', 'Екатеринбург, Торговая 30');

SELECT * FROM Client WHERE id > 8 ORDER BY id ASC;

ROLLBACK TRANSACTION Savepoint1;

SELECT * FROM Client WHERE id > 8 ORDER BY id ASC;

COMMIT TRANSACTION;

SELECT * FROM Client WHERE id > 8 ORDER BY id ASC;
GO


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;

SELECT * FROM Client WHERE id = 10;

UPDATE Client SET contact_person = 'Сидоров Алексей' 
WHERE id = 10;

COMMIT TRANSACTION;

SELECT * FROM Client WHERE company = 'ООО "СбытЭнерго"';
GO


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WAITFOR DELAY '00:00:05';

BEGIN TRANSACTION;

SELECT * FROM Client WHERE id = 6;

WAITFOR DELAY '00:00:10';
COMMIT;

SELECT * FROM Client WHERE id = 6;
GO


SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

WAITFOR DELAY '00:00:05';

BEGIN TRANSACTION;

SELECT * FROM Client WHERE id = 7;

WAITFOR DELAY '00:00:10';

COMMIT;

SELECT * FROM Client WHERE id = 7;
GO


SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

UPDATE [Credit product] 
SET rate = 8,  
    max_amount = 25000000.00, 
    title = 'Лизинг оборудования оптом'
WHERE id = 3;

COMMIT TRANSACTION;

SELECT rate, title, max_amount FROM [Credit product] WHERE id = 3;
GO



SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRANSACTION;

UPDATE Client 
SET company = 'ООО "Бетономешалка"',
    contact_person = 'Сергей Аннов'
WHERE id = 2;

COMMIT TRANSACTION;

SELECT * FROM Client WHERE id = 2;
GO


SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRANSACTION;

INSERT INTO Client (phone_number, contact_person, company, address)
VALUES ('+79168889900', 'Фантом Фантомыч', 'ООО "Ghostbusters"', 'Ярославль, Союзная 144');

COMMIT TRANSACTION;

SELECT * FROM Client WHERE company LIKE '%ООО%'
GO


SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;

INSERT INTO Client (phone_number, contact_person, company, address)
VALUES ('+79168889900', 'Фантом Фантомыч', 'ООО "Ghostbusters"', 'Ярославль, Союзная 144');

COMMIT TRANSACTION;

SELECT * FROM Client WHERE company LIKE '%ООО%'
GO
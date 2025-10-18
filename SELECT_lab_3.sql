drop VIEW if exists ClientProductInterests;
drop VIEW if exists ClientPenaltyAnalysis;


1.1 Выбрать из произвольной таблицы данные и отсортировать их по двум  
произвольным имеющимся в таблице признакам (разные направления сортировки).

Все клиенты банка упорядоченные по имени контактного человека по алфавиту
SELECT 
	*
FROM
	Client
ORDER BY
	contact_person

Все клиенты банка упорядоченные по компании в обратном порядке
SELECT 
	*
FROM 
	Client
ORDER BY 
	company DESC

1.2 Выбрать из произвольной таблицы те записи, которые удовлетворяют
условию отбора (where). Привести 2-3 запроса.

Все записи кредитной истории наших клиентов, которые сотрудничали со Сбербанком
SELECT
	*
FROM
	[Credit history]
WHERE
	bank = 'Сбербанк'

Все кредитные продукты минимальный оъбем которых 50000, а максимальный срок не более 50 месяцев
SELECT
	*
FROM
	[Credit product]
WHERE
	min_amount > 50000 AND max_period < 50

Штрафы наложенные за 2024 год в размере больше 7000
SELECT
	*
FROM
	Penalty
WHERE
	(accrual_date BETWEEN '2024-01-01' AND '2024-12-31') AND amount > 7000 


1.3 Привести примеры 2-3 запросов с использованием агрегатных функций
(count, max, sum и др.) с группировкой и без группировки.

Сколько записей в кредитной истории принадежит каждому из банков
SELECT
	bank,
	COUNT(*) as clients
FROM
	[Credit history]
GROUP BY 
	bank

Наибольший размер штрафа для каждой из причин его получения
SELECT
	reason,
	MAX(amount) as amount
FROM
	Penalty
GROUP BY 
	reason

Общая сумма кредитов взятых в банке
SELECT
	SUM(amount) as amount
FROM
	Deal


1.4  Привести примеры подведения подытога с использованием GROUP BY [ALL] [ CUBE | ROLLUP](2-3 запроса). 
В ROLLUP и CUBE использовать не менее 2-х столбцов

Статистика штрафов с агрегацией по годам и типам нарушений
SELECT
	CASE 
		WHEN GROUPING(YEAR(accrual_date)) = 1 THEN 'Все года'
		ELSE CAST(YEAR(accrual_date) AS NVARCHAR(10))
		END AS year,
	CASE 
		WHEN GROUPING(reason) = 1 THEN 'Все причины'
      ELSE reason
		END AS reason,
  SUM(amount) AS total_amount
FROM 
	Penalty
GROUP BY 
	ROLLUP(YEAR(accrual_date), reason)
ORDER BY 
	GROUPING(YEAR(accrual_date)),
  YEAR(accrual_date),
  GROUPING(reason),
  reason;

Сводка кредитной активности по всем срезам: банки, годы, платежная дисциплина
SELECT
	CASE 
		WHEN GROUPING(bank) = 1 THEN 'Все банки'
		ELSE bank
		END AS bank,
	CASE 
		WHEN GROUPING(YEAR(repayment_date)) = 1 THEN 'Все года'
		ELSE CAST(YEAR(repayment_date) AS NVARCHAR(10))
		END AS repayment_date,
	CASE 
		WHEN GROUPING(is_penal) = 1 THEN 'Все уплаты/неуплаты'
		ELSE CAST(is_penal AS NVARCHAR(2))
		END AS is_penal,
	SUM(amount) as amount
FROM 
	[Credit history]
GROUP BY 
	CUBE(bank, YEAR(repayment_date), is_penal)
ORDER BY
	GROUPING(bank),
	bank,
	GROUPING(YEAR(repayment_date)),
	repayment_date,
	GROUPING(is_penal),
	is_penal;
	

1.5 Выбрать из таблиц информацию об объектах, 
в названиях которых нет заданной последовательности букв (LIKE).

Клиенты фамилии контактных лиц которых заканчиваются не на "ров", "рова", "ев" или "ева"
SELECT 
	*
FROM
	Client
WHERE
	contact_person NOT LIKE('%ров %') AND contact_person NOT LIKE ('%ев %') AND
	contact_person NOT LIKE('%рова %') AND contact_person NOT LIKE ('%ева %')

Клиенты названия компаний которых не являются "ЗАО" или "ИП"
SELECT
	*
FROM
	Client
WHERE
	company NOT LIKE('ЗАО "%') AND company NOT LIKE ('ИП "%')


2.1 Вывести информацию подчиненной (дочерней) таблицы, заменяя коды
(значения внешних ключей) соответствующими символьными значениями из
родительских таблиц. Привести 2-3 запроса с использованием классического
подхода соединения таблиц (where).

Краткий вывод кредитной истории клиентов с именами кредиторов
SELECT 
	c.contact_person, cr.bank, cr.amount 
FROM 
	Client c, [Credit history] cr 
WHERE 
	c.id = cr.client_id;

Вывод существующих сделок с указанием названия выбранног кредитного продукта
Ы
SELECT 
	d.amount, cp.title 
FROM 
	Deal d, [Credit product] cp 
WHERE 
	d.product_id = cp.id;

Вывод размера сделок с поступившими на них платежами
SELECT 
	p.deal_id, d.rest, p.amount, p.accrual_date 
FROM 
	Payment p, Deal d 
WHERE 
	p.deal_id = d.id;


2.2. Реализовать запросы пункта 2.1 через внутреннее соединение inner join. 

Краткий вывод кредитной истории клиентов с названиями кредиторов
SELECT 
	c.company, cr.bank, cr.amount 
FROM 
	Client c INNER JOIN [Credit history] cr ON c.id=cr.client_id

Вывод существующих сделок с указанием названия выбранного кредитного продукта
SELECT 
	d.amount, cp.title 
FROM 
	Deal d INNER JOIN [Credit product] cp ON d.product_id = cp.id;

Вывод размера сделок с поступившими на них платежами
SELECT 
	p.deal_id, d.rest, p.amount, p.accrual_date 
FROM 
	Payment p INNER JOIN  Deal d ON p.deal_id = d.id;

2.3. Левое внешнее соединение left join. Привести 2-3 запроса.
Краткий вывод кредитной истории клиентов с названиями кредиторов
SELECT 
    c.company,
    cr.bank, 
    cr.amount
FROM 
    Client c LEFT JOIN [Credit history] cr 
        ON c.id = cr.client_id
WHERE
    cr.amount IS NOT NULL
ORDER BY 
    cr.amount DESC;

Все сделки и платежи по ним
SELECT 
	d.id as deal_id,
  d.amount as deal_amount,
  d.deal_start,
  pm.amount as payment_amount,
  pm.accrual_date as payment_date
FROM 
  Deal d LEFT JOIN Payment pm 
		ON d.id = pm.deal_id
ORDER BY 
  d.deal_start ;


2.4. Правое внешнее соединение right join. Привести 2-3 запроса 

Записи в кредитной истории вида: Банк, клиент, долг
SELECT 
  ch.bank,
  c.company,
  ch.amount
FROM 
  Client c
RIGHT JOIN [Credit history] ch ON c.id = ch.client_id;

Кредитные продукты и клиенты которые их взяли
SELECT 
	cpr.title,
	c.contact_person,
	c.company
FROM 
	Client c RIGHT JOIN Client_product cp 
	ON c.id = cp.client_id
	RIGHT JOIN [Credit product] cpr ON cp.product_id = cpr.id;

 Все штрафы и соответствующие платежи 
SELECT 
    pn.reason,
    pn.amount as penalty_amount,
    pm.amount as payment_amount
FROM 
    Payment pm RIGHT JOIN Penalty pn 
        ON pm.penalty_id = pn.id;


2.5. Привести примеры 2-3 запросов с использованием агрегатных функций
и группировки.
 Статистика использования кредитных продуктов
SELECT 
    cp.title,
    COUNT(d.id) as deal_count,
    SUM(d.amount) as total_deal_amount
FROM 
    [Credit product] cp
        LEFT JOIN Deal d ON cp.id = d.product_id
GROUP BY 
    cp.title, cp.id;

 Анализ штрафов по клиентам
SELECT 
    c.contact_person,
    COUNT(pn.id) as penalty_count,
    SUM(pn.amount) as total_penalties,
    SUM(CASE WHEN pn.is_paid = 1 THEN pn.amount ELSE 0 END) as paid_penalties
FROM 
    Client c
    LEFT JOIN [Credit history] ch ON c.id = ch.client_id
    LEFT JOIN Penalty pn ON ch.id = pn.id
GROUP BY 
    c.id, c.contact_person;

Суммарная статистика кредитов по банкам
SELECT 
    c.company,
    ch.bank,
    SUM(amount) as total_amount
FROM 
    [Credit history] ch LEFT JOIN Client c
    ON ch.client_id = c.id
GROUP BY 
    c.company,
    ch.bank;


2.6. Привести примеры 2-3 запросов с использованием группировки и условия отбора групп (Having).
 Клиенты с общей суммой кредитов более 1 млн
SELECT 
    c.contact_person,
    SUM(ch.amount) as total_credit
FROM 
    Client c JOIN [Credit history] ch 
        ON c.id = ch.client_id
GROUP BY 
    c.id, c.contact_person
HAVING 
    SUM(ch.amount) > 1000000;
Банки из кредитной истории общая сумма взятых кредитов клиентами у которых больше 500000
SELECT 
    bank,
    AVG(amount) as avg_credit_amount,
    COUNT(*) as credit_count
FROM 
    [Credit history]
GROUP BY 
    bank
HAVING 
    AVG(amount) > 500000;


2.7. Привести примеры 3-4 вложенных (соотнесенных, c использованием IN, EXISTS) запросов.

 Сделки, которые больше средней по своему продукту
SELECT 
    d.id,
    d.amount,
    cp.title
FROM 
    Deal d
JOIN [Credit product] cp ON d.product_id = cp.id
WHERE 
    EXISTS (
        SELECT 1
        FROM Deal avg_deal
        WHERE avg_deal.product_id = cp.id
        HAVING d.amount > AVG(avg_deal.amount)
    );

 Клиенты, у которых есть неоплаченные штрафы
SELECT 
    c.contact_person,
    c.company,
    c.address
FROM 
    Client c
WHERE 
    EXISTS (
        SELECT 1 
        FROM [Credit history] ch
        JOIN Penalty p ON ch.id = p.id
        WHERE ch.client_id = c.id 
          AND p.is_paid = 0
    );

 Кредитные продукты, по которым не заключено ни одной сделки
SELECT 
    title
FROM 
    [Credit product]
WHERE 
	id NOT IN 
		(SELECT DISTINCT 
			product_id 
		FROM 
			Deal 
		WHERE 
			product_id IS NOT NULL);

Клиенты, которые вносили платежи
SELECT 
    contact_person
FROM 
    Client c
WHERE 
    EXISTS (
        SELECT 
            1 
        FROM 
            Deal d
            JOIN Payment p ON d.id = p.deal_id
        WHERE 
            d.client_id = c.id
    );


3.1  На основе любых запросов из п. 2 создать два представления (VIEW).

Кредитные продукты и клиенты которые их взяли
GO
CREATE VIEW ClientProductInterests AS
SELECT 
    cpr.title,
    c.contact_person,
    c.company
FROM 
    Client c 
RIGHT JOIN Client_product cp ON c.id = cp.client_id
RIGHT JOIN [Credit product] cpr ON cp.product_id = cpr.id;
GO
SELECT * FROM ClientProductInterests

Анализ штрафов по клиентам
GO
CREATE VIEW ClientPenaltyAnalysis AS
SELECT 
    c.contact_person,
    COUNT(pn.id) as penalty_count,
    SUM(pn.amount) as total_penalties,
    SUM(CASE WHEN pn.is_paid = 1 THEN pn.amount ELSE 0 END) as paid_penalties
FROM 
    Client c
    LEFT JOIN [Credit history] ch ON c.id = ch.client_id
    LEFT JOIN Penalty pn ON ch.id = pn.id
GROUP BY 
    c.id, c.contact_person;
GO
SELECT * FROM ClientPenaltyAnalysis


3.2  Привести примеры использования общетабличных выражений (СТЕ) (2-3 запроса)
 Банки со средним кредитом более 500000
WITH HighAvgBanks AS (
    SELECT 
        bank,
        AVG(amount) as avg_credit_amount,
        COUNT(*) as credit_count
    FROM 
        [Credit history]
    GROUP BY 
        bank
    HAVING 
        AVG(amount) > 500000
)
SELECT *
FROM HighAvgBanks;

Записи в кредитной истории вида: Банк, клиент, долг
WITH BankClientDebts AS (
    SELECT 
        ch.bank,
        c.company,
        ch.amount
    FROM 
        Client c
    RIGHT JOIN [Credit history] ch ON c.id = ch.client_id
)
SELECT *
FROM BankClientDebts;


4. Функции ранжирования
4.1 Привести примеры 3-4 запросов с использованием ROW_NUMBER, RANK, DENSE_RANK (c  PARTITION BY и без)

Нумерация записей клиентов в крединой истории по банкам и величине взятых кредитов
SELECT 
    LEFT(ch.bank,15) AS bank,
    LEFT(c.contact_person,20) AS contact_person,
    LEFT(ch.amount, 15) AS amount,
    RANK() OVER (PARTITION BY ch.bank ORDER BY ch.amount DESC) as rank_in_bank
FROM 
    Client c
JOIN [Credit history] ch ON c.id = ch.client_id;

Нумерация кредитных продуктов по процентной ставке внутри каждой категории (с рассрочкой/без рассрочки)
SELECT 
    LEFT(title,20) AS title,
    LEFT(rate,10) AS rate,
    DENSE_RANK() OVER (PARTITION BY in_parts ORDER BY rate DESC) as dense_rank_by_parts
FROM [Credit product];

Нумерация сделок по времени кредитования и размеру кредита
SELECT 
    LEFT(c.contact_person,20) AS contact_person,
    LEFT(d.amount,15) AS amount,
    LEFT(d.period_, 10) AS _period,
    ROW_NUMBER() OVER (
        PARTITION BY d.client_id 
        ORDER BY d.amount DESC, d.period_ ASC
    ) as deal_rank
FROM 
    Deal d
JOIN Client c ON d.client_id = c.id; 


5.1 Привести примеры 3-4 запросов с использованием UNION / UNION ALL, EXCEPT, INTERSECT. 
Данные  в одном из запросов отсортируйте по произвольному признаку.
Клиенты которые либо заключали сделки либо имеют записи в кредитной истории
SELECT 
	contact_person FROM Client
WHERE 
	id IN (SELECT client_id FROM [Credit history])
UNION
SELECT 
	contact_person 
FROM 
	Client  
WHERE 
	id IN (SELECT client_id FROM Deal);

Объединение продуктов со временем кредитования не менее 24мес и свозможностью оплаты по частям с дублями
SELECT
	title, rate, in_parts, min_period, max_period, min_amount, max_amount
FROM
	[Credit product]
WHERE
	in_parts = 1
UNION ALL
SELECT
	title, rate, in_parts, min_period, max_period, min_amount, max_amount
FROM
	[Credit product]
WHERE 
	min_period > 24
ORDER BY 
	title

 Клиенты у которых есть активные сделки, но нет кредитной истории
SELECT 
	contact_person FROM Client
WHERE 
	id IN (SELECT client_id FROM Deal WHERE rest > 0)
EXCEPT
SELECT 
	contact_person FROM Client
WHERE 
	id IN (SELECT client_id FROM [Credit history]);

 Клиенты которые и брали кредиты и заключали сделки
SELECT 
	contact_person FROM Client
WHERE 
	id IN (SELECT client_id FROM [Credit history])
INTERSECT  
SELECT 
	contact_person FROM Client
WHERE 
	id IN (SELECT client_id FROM Deal);


6.1 Привести примеры получения сводных (итоговых) таблиц с использованием CASE
Классификация клиентов по общей сумме кредитов
SELECT 
    contact_person,
    company,
    (SELECT SUM(amount) FROM Deal d WHERE client_id = c.id) as total_credit,
    CASE 
        WHEN (SELECT SUM(amount) FROM Deal WHERE client_id = c.id) > 8000000 THEN 'Заслуженный кредитор'
        WHEN (SELECT SUM(amount) FROM Deal WHERE client_id = c.id) > 5000000 THEN 'Бывалый должник'
        WHEN (SELECT SUM(amount) FROM Deal WHERE client_id = c.id) > 0 THEN 'Новичок'
        ELSE 'Зашел не в ту дверь'
    END as client_category
FROM Client c
ORDER BY c.contact_person;

--Подсчет колличества сделок по категориям их продолжительнсти
SELECT 
    CASE 
        WHEN period_ <= 12 THEN 'Краткосрочные (до 1 года)'
        WHEN period_ <= 36 THEN 'Среднесрочные (1-3 года)'
        ELSE 'Долгосрочные (более 3 лет)'
    END as period_category,
    COUNT(*) as deal_count,
    AVG(amount) as avg_amount,
    SUM(amount) as total_amount
FROM Deal
GROUP BY 
    CASE 
        WHEN period_ <= 12 THEN 'Краткосрочные (до 1 года)'
        WHEN period_ <= 36 THEN 'Среднесрочные (1-3 года)'
        ELSE 'Долгосрочные (более 3 лет)'
    END;

6.2 Привести примеры получения сводных (итоговых) таблиц с использованием PIVOT и UNPIVOT.
Количество клиентов по типам компаний
SELECT *
FROM (
    SELECT 
        contact_person,
        CASE 
            WHEN company LIKE 'ООО %' THEN 'ООО'
            WHEN company LIKE 'АО %' THEN 'АО'
            WHEN company LIKE 'ЗАО %' THEN 'АО'
            ELSE 'Другие'
        END as company_type
    FROM Client
) AS SourceTable
PIVOT (
    COUNT(contact_person)
    FOR company_type IN ([ООО], [АО], [Другие])
) AS pvt;


Развернутые с UNPIVOT данные о кредитных продуктах
SELECT product_id, parameter_name, parameter_value
FROM (
    SELECT 
        id as product_id,
        CAST(min_amount AS NVARCHAR(20)) as min_amount,
        CAST(max_amount AS NVARCHAR(20)) as max_amount,
        CAST(rate AS NVARCHAR(20)) as interest_rate
    FROM [Credit product]
) AS SourceTable
UNPIVOT (
    parameter_value FOR parameter_name IN (min_amount, max_amount, interest_rate)
) AS upvt;

Развернутые с UNPIVOT данные о клиентах вида
SELECT client_id, condition_type, condition_value
FROM (
    SELECT 
        id as client_id,
        CAST(LEN(contact_person) AS NVARCHAR(10)) as name_length,
        CAST(LEN(company) AS NVARCHAR(10)) as company_name_length,
        CAST(
            CASE 
                WHEN phone_number LIKE '+7%' THEN '1' 
                ELSE '0'
            END AS NVARCHAR(10)
        ) as phone_format_numeric
    FROM Client
) AS SourceTable
UNPIVOT (
    condition_value FOR condition_type IN (name_length, company_name_length, phone_format_numeric)
) AS upvt;


ЧАСТЬ 2
a)  Для каждого клиента вывести количество взятых им кредитов и их общую сумму
SELECT 
    c.contact_person,
    c.company,
    COUNT(ch.id) as credit_count,
    SUM(ch.amount) as total_amount
FROM 
    Client c
LEFT JOIN [Credit history] ch ON c.id = ch.client_id
GROUP BY 
    c.id, c.contact_person, c.company;

b) Самые выгодные кредиты
SELECT 
    title,
    rate,
    min_amount,
    max_amount
FROM 
    [Credit product]
WHERE 
    in_parts = 1  
    AND rate = (SELECT MIN(rate) FROM [Credit product] WHERE in_parts = 1);

c) Количество сделок по дням текущего месяца
SELECT 
    deal_start,
    COUNT(*) as deal_count
FROM 
    Deal
WHERE 
    deal_start >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
GROUP BY 
    deal_start
ORDER BY 
    deal_start;

d) Непопулярные виды кредитов
SELECT 
    title
FROM 
    [Credit product]
WHERE 
	id NOT IN 
		(SELECT DISTINCT 
			product_id 
		FROM 
			Deal 
		WHERE 
			product_id IS NOT NULL);

e) Клиенты с наибольшим количеством кредитов и плохой историей
SELECT 
    c.contact_person,
    c.company,
    COUNT(ch.id) as credit_count,
    SUM(CASE WHEN ch.is_penal = 1 THEN 1 ELSE 0 END) as penal_credits
FROM 
    Client c
JOIN [Credit history] ch ON c.id = ch.client_id
GROUP BY 
    c.id, c.contact_person, c.company
HAVING 
    COUNT(ch.id) = (
        SELECT MAX(credit_count) 
        FROM (
            SELECT COUNT(id) as credit_count
            FROM [Credit history]
            GROUP BY client_id
        ) as counts
    )
    AND SUM(CASE WHEN ch.is_penal = 1 THEN 1 ELSE 0 END) > 0;

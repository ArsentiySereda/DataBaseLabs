
drop table if exists Client;
drop table if exists [Credit record];
drop table if exists [Credit product];
drop table if exists Client_product;
drop table if exists Penalty;
drop table if exists Deal;
drop table if exists Payment;

CREATE TABLE Client(
	id INT PRIMARY KEY IDENTITY,
	phone_number VARCHAR(20) DEFAULT('+79998887766'),
	contact_person NVARCHAR(100) NOT NULL,
	company NVARCHAR(200) NOT NULL,
	adress NVARCHAR(250) NOT NULL
);

CREATE TABLE [Credit record](
	id INT PRIMARY KEY IDENTITY,
	client_id INT NOT NULL,
	bank VARCHAR(200) NOT NULL,
	number INT DEFAULT(100),
	amount DECIMAL(20,2) NOT NULL CHECK(amount > 0),
	repayment_date DATE DEFAULT(GETDATE()),
	is_penal TINYINT DEFAULT(1),
	FOREIGN KEY (client_id) REFERENCES Client(id)
);

CREATE TABLE [Credit product](
    id INT PRIMARY KEY IDENTITY,
    title VARCHAR(100) UNIQUE NOT NULL,
    rate DECIMAL(4,2) DEFAULT(17.0),
    in_parts TINYINT DEFAULT(1),
    min_period DATE NOT NULL CHECK(min_period > '1900-01-01'),
    max_period DATE NOT NULL,
    min_amount DECIMAL(20,2) NOT NULL CHECK (min_amount > 0),
    max_amount DECIMAL(20,2) NOT NULL,
    condition1 DECIMAL(20,2) NOT NULL CHECK (condition1 > 0),
    condition2 NVARCHAR(500),
    
    CONSTRAINT check_max_period CHECK (max_period > min_period),
    CONSTRAINT check_max_amount CHECK (max_amount > min_amount)
);

CREATE TABLE Client_product(
	client_id INT NOT NULL,
	product_id INT NOT NULL,
	PRIMARY KEY(client_id, product_id),
	FOREIGN KEY (client_id) REFERENCES Client(id),
	FOREIGN KEY (product_id) REFERENCES [Credit product](id)
)

CREATE TABLE Deal(
    id INT PRIMARY KEY IDENTITY,
    client_id INT NOT NULL,
    product_id INT NOT NULL,
    deal_start DATE NOT NULL,
    amount DECIMAL(20,2) NOT NULL CHECK (amount > 0),
    period_ INT NOT NULL,
    rate DECIMAL(4,2) NOT NULL,
    monthly_payment AS amount * (rate/100/12) * 
                 POWER(1 + (rate/100/12), period_) / 
                 (POWER(1 + (rate/100/12), period_) - 1),
	rest AS amount,
    FOREIGN KEY (product_id) REFERENCES [Credit product](id),
	FOREIGN KEY (client_id) REFERENCES Client(id)
);

CREATE TABLE Penalty(
	id INT PRIMARY KEY IDENTITY,
    accrual_date DATE NOT NULL,
    reason VARCHAR(200) NOT NULL,
    amount DECIMAL(20,2) NOT NULL CHECK (amount > 0),
    is_paid BIT DEFAULT 0
);

CREATE TABLE Payment(
	id INT PRIMARY KEY IDENTITY,
	penalty_id INT NOT NULL,
	deal_id INT NOT NULL,
	amount DECIMAL(20,2) NOT NULL CHECK(amount > 0),
	accural_date DATE NOT NULL,
	pay_off_before AS DATEADD(month,1,accural_date),
	actual_payment_date DATE,
	in_main_debt DECIMAL(20,2) CHECK(in_main_debt > 0),
	in_early_repayment DECIMAL(20,2), 
	FOREIGN KEY (penalty_id) REFERENCES Penalty(id),
	FOREIGN KEY (deal_id) REFERENCES Deal(id),
);

INSERT INTO Client (phone_number, contact_person, company, adress) VALUES
	('+79161234567', '������ ����', '��� "�����"', '������, ������ 1'),
	('+79269876543', '������� ����', '��� "������"', '���, ������� 50'),
	('+79031112233', '������� �������', '�� �������', '������������, �������� 25'),
	('+79557778899', '������� �����', '��� "�����"', '�����������, ������� 100'),
	('+79991234567', '������� �������', '�� "��������"', '������, ������� 15'),
	('+79105556677', '�������� ���������', '��� "���� �������"', '������-��-����, ������� 10'),
	('+79224448899', '�������� �����', '�� ��������', '�����������, ����������� 5'),
	('+79058889900', '������ ��������', '��� "�������"', '������ ��������, �������������� 8'),
	('+79651112233', '�������� �����', '��� "����������"', '������, ��������� 30'),
	(DEFAULT, '��������� �����', '�� "������"', '���������, ������� 20');

INSERT INTO [Credit record] (client_id, bank, number, amount, repayment_date, is_penal) VALUES
	(1, '��������', 275712, 500000.00, '2024-03-15', 0),
	(2, '���', 28563, 1500000.00, '2024-01-20', 1),
	(3, '�����-����', 385763, 750000.50, '2024-02-10', 0),
	(1, '��������', 38573, 300000.00, '2024-04-05', 0),
	(4, '�����������', 23475, 2000000.00, '2023-12-25', 1),
	(5, '��������', 23079, 1000000.00, '2024-03-01', 0),
	(2, '��������', 2135673, 800000.75, '2024-02-28', 1),
	(6, '���', 4349873, 1200000.00, '2024-01-15', 0),
	(7, '����������', 1238572, 900000.00, '2024-03-20', 0),
	(8, '��������', 1234567, 1750000.25, '2024-04-10', 1);

INSERT INTO [Credit product] (title, rate, in_parts, min_period, max_period, min_amount, max_amount, condition1, condition2) VALUES
	('��������� �������', 12.5, 1, '2024-01-01', '2025-01-01', 500000.00, 10000000.00, 10000.00, '������������� ����������'),
	('�������������� ������', 9.0, 1, '2024-01-01', '2030-01-01', 1000000.00, 50000000.00, 50000.00, '������-����'),
	('������ ������������', 11.0, 1, '2024-01-01', '2027-01-01', 300000.00, 20000000.00, 15000.00, '������� �����-�������'),
	('�������� ��������������', 10.5, 1, '2024-01-01', '2026-01-01', 1000000.00, 30000000.00, 20000.00, ''),
	('��������� ��������� �������', 13.0, 1, '2024-01-01', '2028-01-01', 2000000.00, 10000000.00, 30000.00, ''),
	('���������', 15.0, 0, '2024-01-01', '2025-01-01', 100000.00, 5000000.00, 5000.00, '����������� �������������'),
	('��������� ������', 17.0, 1, '2024-01-01', '2025-01-01', 50000.00, 5000000.00, 2500.00, '��������������� ��������'),
	('����������������', 8.5, 1, '2024-01-01', '2029-01-01', 5000000.00, 50000000.00, 75000.00, '����������� �������'),
	('�������� ������', 14.0, 1, '2024-01-01', '2025-06-01', 300000.00, 10000000.00, 12000.00, '���������� �������'),
	('��������� ��������������', 7.5, 1, '2024-01-01', '2032-01-01', 5000000.00, 200000000.00, 100000.00, '����� � �������� ���������');

INSERT INTO Deal (client_id, product_id, deal_start, amount, period_, rate) VALUES
	(1, 1, '2024-01-15', 5000000.00, 24, 12.5),
	(1, 3, '2024-02-01', 3000000.00, 36, 11.0),
	(2, 2, '2024-01-20', 10000000.00, 48, 9.0),
	(3, 1, '2024-03-05', 2000000.00, 24, 12.5),
	(3, 5, '2024-02-10', 5000000.00, 48, 13.0),
	(4, 4, '2024-01-25', 8000000.00, 36, 10.5),
	(5, 6, '2024-03-15', 1500000.00, 12, 15.0),
	(6, 7, '2024-02-20', 3000000.00, 18, 17.0),
	(7, 8, '2024-01-30', 10000000.00, 72, 8.5),
	(8, 9, '2024-03-01', 4000000.00, 18, 14.0);

INSERT INTO Penalty (accrual_date, reason, amount, is_paid) VALUES
	('2022-05-10', '��������� �������', 5000.00, 1),
	('2022-11-20', '��������� �������', 7500.00, 1),
	('2023-03-15', '��������� �������', 10000.00, 0),
	('2023-08-05', '��������� �������', 6000.00, 1),
	('2023-12-12', '��������� �������', 8000.00, 0),
	('2024-01-25', '��������� �������', 12000.00, 0),
	('2024-02-18', '��������� �������', 9000.00, 0),
	('2024-03-08', '��������� �������', 7000.00, 0),
	('2024-04-02', '��������� �������', 15000.00, 0),
	('2024-05-20', '��������� �������', 11000.00, 0);

INSERT INTO Client_product (client_id, product_id) VALUES
	(1, 1), (1, 3), (2, 2), (3, 1), (3, 5), (4, 4), (5, 6), (6, 7), (7, 8), (8, 9), (9, 10), (2, 4), (4, 2), (6, 1);  

INSERT INTO Payment (penalty_id, deal_id, amount, accural_date, actual_payment_date, in_main_debt, in_early_repayment) VALUES
	(1, 1, 50000.00, '2024-01-01', '2024-01-15', 45000.00, 5000.00),
	(2, 2, 75000.00, '2024-02-01', '2024-02-05', 70000.00, 5000.00),
	(3, 3, 100000.00, '2024-03-01', '2024-03-10', 95000.00, 5000.00),
	(4, 4, 30000.00, '2024-04-01', '2024-04-12', 28000.00, 2000.00),
	(5, 5, 60000.00, '2024-05-01', '2024-05-20', 55000.00, 5000.00),
	(6, 6, 80000.00, '2024-06-01', NULL, 75000.00, 5000.00),
	(7, 7, 120000.00, '2024-07-01', '2024-07-08', 115000.00, 5000.00),
	(8, 8, 25000.00, '2024-08-01', NULL, 23000.00, 2000.00),
	(9, 9, 150000.00, '2024-09-01', '2024-09-25', 145000.00, 5000.00),
	(10, 10, 45000.00, '2024-10-01', '2024-10-18', 42000.00, 3000.00);


SELECT * FROM Client;
SELECT * FROM [Credit record];	
SELECT * FROM Payment;
SELECT * FROM Client_product;
SELECT * FROM Deal;
SELECT * FROM Penalty;
SELECT * FROM [Credit product];

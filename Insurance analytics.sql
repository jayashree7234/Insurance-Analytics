Create database Insurance;
use insurance;

CREATE TABLE customer_information (
    customer_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(20),
    age INT,
    occupation VARCHAR(100),
    marital_status VARCHAR(50),
    address VARCHAR(255)
);

Desc Customer_information;
Select *from Customer_information;

CREATE TABLE policy_details (
    Policy_ID VARCHAR(20) PRIMARY KEY,
    Policy_Type VARCHAR(50),
    Coverage_Amount DECIMAL(12,2),
    Premium_Amount DECIMAL(10,2),
    Policy_Start_Date DATE,
    Policy_End_Date DATE,
    Payment_Frequency VARCHAR(30),
    Status VARCHAR(30),
    Customer_ID VARCHAR(20),
    FOREIGN KEY (Customer_ID)
    REFERENCES customer_information(Customer_ID)
);

desc policy_details;
Select * from Policy_details;

CREATE TABLE claims (
    Claim_ID VARCHAR(20) PRIMARY KEY,
    Date_of_Claim DATE,
    Claim_Amount DECIMAL(12,2),
    Claim_Status VARCHAR(30),
    Reason_for_Claim VARCHAR(100),
    Settlement_Date DATE,
    Policy_ID VARCHAR(20),
    FOREIGN KEY (Policy_ID)
    REFERENCES policy_details(Policy_ID)
);

desc claims;
SELECT * FROM claims;

CREATE TABLE payment_history (
    Payment_ID VARCHAR(20) PRIMARY KEY,
    Payment_Date DATE,
    Payment_Amount DECIMAL(12,2),
    Payment_Method VARCHAR(50),
    Payment_Status VARCHAR(30),
    Policy_ID VARCHAR(20),
    FOREIGN KEY (Policy_ID)
    REFERENCES policy_details(Policy_ID)
);

desc payment_history;
Select * from Payment_history;

CREATE TABLE Additional_details(
    Agent_ID VARCHAR(20),
    Renewal_Status VARCHAR(30),
    Policy_Discounts DECIMAL(10,2),
    Risk_Score INT,
    Policy_ID VARCHAR(20),
    FOREIGN KEY (Policy_ID)
    REFERENCES policy_details(Policy_ID)
);

desc Additional_details;
Select * from Additional_details;

-- 1.Total Policy
SELECT COUNT(*) AS Total_Policies
FROM policy_details;

-- 2.Total Customers
SELECT COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM policy_details;

-- 3.Age Bucket Wise Policy Count
SELECT 
    CASE 
        WHEN c.Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN c.Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN c.Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN c.Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS Age_Bucket,
    COUNT(p.Policy_ID) AS Policy_Count
FROM policy_details p
JOIN customer_information c
ON p.Customer_ID = c.Customer_ID
GROUP BY Age_Bucket
ORDER BY Policy_Count;

-- 4.Gender Wise Policy Count
SELECT 
    c.Gender,
    COUNT(p.Policy_ID) AS Policy_Count
FROM policy_details p
JOIN customer_information c
ON p.Customer_ID = c.Customer_ID
GROUP BY c.Gender;

-- 5.Policy Type Wise Policy Count
SELECT 
    Policy_Type,
    COUNT(*) AS Policy_Count
FROM policy_details
GROUP BY Policy_Type;

-- 6.Policy Expire This Year
SELECT COUNT(*) AS Expiring_This_Year
FROM policy_details
WHERE YEAR(Policy_End_Date) = YEAR(CURDATE());

SELECT 
    YEAR(Policy_End_Date) AS Expiry_Year,
    COUNT(*) AS Expiring_Policies
FROM policy_details
GROUP BY YEAR(Policy_End_Date)
ORDER BY Expiry_Year;

-- 7.Premium Growth Rate
SELECT 
    Year,
    Total_Premium,
    CONCAT(ROUND(((Total_Premium - Previous_Year_Premium) / Previous_Year_Premium) * 100, 2), '%') AS Growth_Percentage
FROM (
		SELECT 
        Year,
        Total_Premium,
        LAG(Total_Premium) OVER (ORDER BY Year) AS Previous_Year_Premium
    FROM (
        SELECT 
            YEAR(Policy_Start_Date) AS Year,
            SUM(Premium_Amount) AS Total_Premium
        FROM policy_details
        GROUP BY YEAR(Policy_Start_Date)
    ) yearly
) t;

-- 8.Claim Status Wise Policy Count
SELECT 
    Claim_Status,
    COUNT(DISTINCT Policy_ID) AS Policy_Count
FROM claims
GROUP BY Claim_Status;

-- 9.Payment Status Wise Policy Count
SELECT 
    Payment_Status,
    COUNT(Policy_ID) AS Policy_Count
FROM payment_history
GROUP BY Payment_Status;

-- 10.Total Claim Amount
SELECT format(SUM(Claim_Amount),2) AS Total_Claim_Amount
FROM claims
WHERE Claim_Status = "Approved";

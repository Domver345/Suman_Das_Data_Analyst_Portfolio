-- 49. Display the invoice number and day on which customers were issued movies.
SELECT inv_no, DAYNAME(issue_date) AS issue_day FROM invoice;

-- 50. Display the month (in alphabets) in which customers are supposed to return the movies.
SELECT inv_no, MONTHNAME(return_date) AS return_month FROM invoice;

-- 51. Display the issue-date in the format 'dd-month-yy'. For example: 12-February-93
SELECT inv_no, DATE_FORMAT(issue_date, '%d-%M-%y') AS formatted_issue_date FROM invoice;

-- 52. Find the date, 15 days after the current date.
SELECT CURDATE() AS today, DATE_ADD(CURDATE(), INTERVAL 15 DAY) AS future_date;

-- 53. Find the number of days elapsed between the current date and the return date of the movie for all customers.
SELECT inv_no, DATEDIFF(CURDATE(), return_date) AS days_elapsed FROM invoice;

-- 54. Change the telephone number of 'pranada' to 466389.
UPDATE cust SET phone = 466389 WHERE fname = 'pranada';

-- 55. Change the issue-date of cust-id 'A01' to '1993-07-24'.
UPDATE invoice SET issue_date = '1993-07-24' WHERE cust_id = 'A01';

-- 56. Change the price of 'gone with the wind' to Rs. 250.00
UPDATE movie SET price = 250.00 WHERE title = 'gone with the wind';

-- 57. Delete the record with invoice number 'I08' from the invoice table.
DELETE FROM invoice WHERE inv_no = 'I08';

-- 58. Delete all the records having return date before '1993-07-10'.
DELETE FROM invoice WHERE return_date < '1993-07-10';

-- 59. Change the area of cust-id 'A05' to 'vs'.
UPDATE cust SET area = 'vs' WHERE cust_id = 'A05';

-- 60. Change the return date of invoice number 'I09' to '1993-08-16'.
UPDATE invoice SET return_date = '1993-08-16' WHERE inv_no = 'I09';

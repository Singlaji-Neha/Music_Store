-- Q1- Who is most senior employee based on job title?

select * from employee;

select * from employee 
ORDER BY levels desc
	limit 1;
	

-- Q2 which countries have the most invoices?

select * from invoice;

select count(*) as c, billing_country
	from invoice
	GROUP BY billing_country
	order by c desc;

-- Q3 what are top 3 values of total invoices?

select total from invoice 
	order by total desc
	limit 3;


-- Q4 which city have the best customers? 
-- we would have to promotional music festival in the city we made the most money.
-- write query that returns on ecity that has the highest of invoices and 
-- return both the city name and sum of all invoices totals

select sum(total) as total_invoices, billing_city 
from invoice
group by billing_city 
order by total_invoices desc;



-- Q5 who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- 	Write a query that returns the person who has spent the most money. 

select customer.customer_id, customer.first_name, customer.last_name , sum(invoice.total) as total
	from customer
JOIN invoice ON customer.customer_id = invoice.customer_id 
group by customer.customer_id
order by total desc 
limit 1

-- MODERATE LEVEL
	
-- Q6 Write a query to return email, first name, last name & genre of all rock music listeneres. 
-- 	return your list ordered alphabetically by email starting with A


	
select  email, first_name,last_name 
	from customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE Track_id  IN (
	select track_id from track
	JOIN genre ON Track.Genre_id = Genre.Genre_id
	where genre.name LIKE 'Rock'
)
order by email;


-- Q7 Let's invite the artists who have wriiten the most rock music in our dataset.
	-- write a query that returns the artist name and total track count of the top 10 rock bands.


select artist.artist_id,  artist.name, count(artist.artist_id) as Num_of_songs
	from track
JOIN album on album.album_id = track.album_id
JOIN artist on artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
	group by artist.artist_id
order by Num_of_songs DESC
	limit 10;


-- Q8 Return all the track names that have a song length longer than the average song length.
--  Return  the name and milliseconds for each track. Order by the song length with the longer songs listed first.


select name, milliseconds 
	from track
	WHERE milliseconds > (
	select avg(milliseconds) as avg_track_length
	from track
	)
order by milliseconds desc


-- ADVANCE LEVEL

-- Q9 Find how much amount spent by each customer on artists?
-- write a query to return customer name, artist name and total spent

-- Using CTE(Common Table Expression)

with best_selling_artist as (
	select artist.artist_id as artist_id , artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.Quantity) as total_sales
	from invoice_line
	join track on invoice_line.track_id = track.track_id
	join album on track.album_id = album.album_id
	join artist on album.artist_id = artist.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name , bsa.artist_name , 
	sum(il.unit_price*il.Quantity) as amount_spent
from invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il on i.invoice_id = il.invoice_id
JOIN Track t On il.track_id = t.track_id
JOIN album as alb on t.album_id = alb.album_id 
join best_selling_artist bsa on alb.artist_id = bsa.artist_id
group by 1,2,3,4
order by 5 desc;


-- Q10 we want to find out the most popular music Genre from each country. 
-- we determine the most popular genre as the genre with the highest amount of purchases
-- write a query that returns each country along with top genre.
-- for countries where the maximum number of purchases is shared return all gneres.


-- METHOD 1 : Using CTE

WITH popular_genre as (
	select COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) as RowNo
	from invoice_line
	JOIN invoice on invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * from popular_genre WHERE RowNo <=1;



-- METHOD 2 :Using Recursive


WITH RECURSIVE 
		sales_per_country AS (
	SELECT COUNT(*) as purchases_per_genre, customer.country, genre.name, genre.genre_id
	from invoice_line
	JOIN invoice on invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2
  ),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
	from sales_per_country
	GROUP BY 2
	ORDER BY 2)

SELECT sales_per_country.*
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;



 -- Q11: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount. 

-- METHOD 1 : Using CTE

WITH customer_with_country AS (
	SELECT customer.customer_id, first_name, last_name,billing_country, SUm(total) as total_spending,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP bY 1,2,3,4
	ORDER BY 4 ASc, 5 DESC)
	SELECT * FROM customer_with_country WHERE RowNo <=1 



-- METHOD 2 : RECURSIVE

WITH RECURSIVE 
		customer_with_country AS (
	SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending
	from invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 2,3 DESC),

country_max_spending AS (
	SELECT billing_country , max(total_spending) as max_spending
	from customer_with_country
	GROUP BY billing_country
)

select cc.billing_country, cc.total_Spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;

















Create database testsql;

use testsql;

CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks (
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists (artist_id, name, country, birth_year) VALUES
(1, 'Vincent van Gogh', 'Netherlands', 1853),
(2, 'Pablo Picasso', 'Spain', 1881),
(3, 'Leonardo da Vinci', 'Italy', 1452),
(4, 'Claude Monet', 'France', 1840),
(5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks (artwork_id, title, artist_id, genre, price) VALUES
(1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
(2, 'Guernica', 2, 'Cubism', 2000000.00),
(3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
(4, 'Water Lilies', 4, 'Impressionism', 500000.00),
(5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales (sale_id, artwork_id, sale_date, quantity, total_amount) VALUES
(1, 1, '2024-01-15', 1, 1000000.00),
(2, 2, '2024-02-10', 1, 2000000.00),
(3, 3, '2024-03-05', 1, 3000000.00),
(4, 4, '2024-04-20', 2, 1000000.00);



--Section 1: 1 mark each
-- Q1-Write a query to calculate the price of 'Starry Night' plus 10% tax.

select 
		title , 
		price,
		(price+(price*(10/100))) as After_Tax 
from artworks 
where title='Starry Night'

--Q 2 Write a query to display the artist names in uppercase.

select 
	artist_id,
	upper(name) as Name
from 
artists

--Write a query to extract the year from the sale date of 'Guernica'.

select 
		title,
		year(sale_date) as Year_of_sale
from sales
inner join
artworks
		on artworks.artwork_id=sales.artwork_id
		where title='Guernica'

-- Q 3 Write a query to find the total amount of sales for the artwork 'Mona Lisa'.

select 
		title,
		sum(total_amount) as total_sales_amount
from sales
inner join
artworks
		on artworks.artwork_id=sales.artwork_id
		where title='Mona Lisa'
		group by artworks.artwork_id,title;




--Section 2: 2 marks each
--Q1 Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.


select 
		artist_id,
		sum(quantity) as total_sales_quantity
from sales
inner join
artworks
		on artworks.artwork_id=sales.artwork_id
		group by artist_id
		having sum(quantity)>
		(select 
		avg(quantity) as total_sales_quantity
		from sales
		inner join
		artworks
		on artworks.artwork_id=sales.artwork_id);


-- Q2 Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.
Select *,
			year(birth_year) as Avg_Year_country
			from artists A
		where birth_year<
		(Select 
			avg(birth_year) as Year_Avg
			from artists B
		where A.country=B.country
		group by B.country);
		
--Q3 Write a query to create a non-clustered index on the sales table to improve query performance for queries filtering by artwork_id.

Create NonClustered index IX_sales_artwork_id
  on sales (artwork_id);

-- Q4 Write a query to display artists who have artworks in multiple genres.

select 
		artists.artist_id
		,name,
		count(distinct genre) as Count_genre
from artists
inner join
artworks
		on artists.artist_id=artworks.artist_id
		group by artists.artist_id,name
		having count(distinct genre)>1;


-- Q5 Write a query to rank artists by their total sales amount and display the top 3 artists.

with Ranking as(
select 
        rank() over (order by sum(total_amount) desc) as Rank_,
		artists.artist_id
		,name,
		sum(total_amount) as Count_Total
from artists
inner join
artworks
		on artists.artist_id=artworks.artist_id
inner join
sales 
        on artworks.artwork_id=sales.artwork_id
	group by artists.artist_id,name)

		select * from Ranking
		where Rank_<4;

-- Q6 Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.
select 
		artists.artist_id
		,name
		,count( distinct genre) as Genre_count
from artists
inner join
artworks
		on artists.artist_id=artworks.artist_id
		where genre='Cubism' or  genre='Surrealism'
		group by artists.artist_id,name
		having count( distinct genre)=2;


--Q7 Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.

select * from
		(select top 2 * from artworks
		order by price desc) as TOP_table
inner join
			(select 
			sales.artwork_id,
			title,
			sum(quantity) as total_quantity
			from artworks
			inner join
			sales 
			on sales.artwork_id=artworks.artwork_id
			group by sales.artwork_id,title) as Quantity_table
	on Quantity_table.artwork_id=TOP_table.artwork_id

--Q8 Write a query to find the average price of artworks for each artist.
select 
			artists.artist_id
			,name
			,avg(price) as avg_price
from artworks
inner join
artists
		on artists.artist_id=artworks.artist_id
		group by artists.artist_id,name

--Q9 Write a query to find the artworks that have the highest sale total for each genre.
 
 with Ranking as
 (select artworks.artwork_id,genre,
  rank() over (partition by genre   order by Count_Total desc) as Rank_
 from 
(select 
		sales.artwork_id,
			title,
		sum(total_amount) as Count_Total
from 
artworks
inner join
sales 
        on artworks.artwork_id=sales.artwork_id
	group by sales.artwork_id,title) as Total_sale
inner join 
artworks 
on artworks.artwork_id=Total_sale.artwork_id)
select * from Ranking
where Rank_=1


-- Q10 Write a query to find the artworks that have been sold in both January and February 2024.
select artworks.artwork_id,title from 
artworks
inner join
sales 
        on artworks.artwork_id=sales.artwork_id
		where year(sale_date)=2024 and month(sale_date)=01
intersect
select  artworks.artwork_id,title from 
artworks
inner join
sales 
        on artworks.artwork_id=sales.artwork_id
		where year(sale_date)=2024 and month(sale_date)=02

--Q 11 Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.
select 
	artist_id,
	avg(price) as avg_ from artworks
	group by artist_id
having avg(price)> all
  (select price from artworks where genre='Renaissance')



--Section 5: 5 Marks Questions
--Q1 Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre 
--and use it in a query to display the results.
go
create Function dbo.totalquantitysoldforeachgenre()
Returns @sold table
 ( gene varchar(50)
,quantity int)
as
begin
		insert @sold
		 select genre , sum(quantity) as SOLd 
		 from sales
		 inner join
		 artworks
		 on artworks.artwork_id=sales.artwork_id
		 group by genre
return
end
go
select * from dbo.totalquantitysoldforeachgenre()


--Q2 Create a scalar function to calculate the average sales amount for artworks in a given genre 
--and write a query to use this function for 'Impressionism'.
go
Create function dbo.the_average_sales_amount_genre (@genre varchar(50))
returns DECIMAL(10, 2)
as
begin
declare @amount  DECIMAL(10, 2)
set @amount=
(
select  avg(total_amount) as SOLd 
		 from sales
		 inner join
		 artworks
		 on artworks.artwork_id=sales.artwork_id
		 where genre=@genre
		 group by genre)
	return @amount
end
go

select *,dbo.the_average_sales_amount_genre('Impressionism') as AVG_sales_amount
from artworks
where genre='Impressionism'
--Q3 Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.
go
select artworks.artwork_id,
NTILE(4) over (order by sum(total_amount)) as TOT
 from sales
		 inner join
		 artworks
		 on artworks.artwork_id=sales.artwork_id
		 group by artworks.artwork_id
--Q4 Create a trigger to log changes to the artworks table into an artworks_log table, 
--capturing the artwork_id, title, and a change description.
create table artworks_log (artwork_id int , title varchar(50), descp varchar(50))

go
create trigger log_changes
on artworks
after update
as 
begin
insert into artworks_log
   select artwork_id,title,'changing the artworks table' 
   from inserted
   end
--Q5 Create a stored procedure to add a new sale and update the total sales for the artwork.
--Ensure the quantity is positive, and use transactions to maintain data integrity.

go
create proc Update_total_sales 
		@sale_id int , 
		@artwork_id int , 
		@sale_date varchar(50),
		@quantity int, 
		@total_amount DECIMAL(10, 2)
as
	begin
	begin try
		begin transaction;
		if @quantity<0 
		    throw 50001,'The qunatity must be postive',1;

			INSERT INTO sales values(@sale_id  , 
		@artwork_id  , 
		@sale_date ,
		@quantity , 
		@total_amount )

		print 'Updated sales are'
		
		select artworks.artwork_id , sum(quantity) as SOLd 
		 from sales
		 inner join
		 artworks
		 on artworks.artwork_id=sales.artwork_id
		 where artworks.artwork_id=@artwork_id
		 group by artworks.artwork_id

		commit transaction;
		end try

		begin catch
		rollback transaction;
		print concat('Error_message:',Error_message())
		print concat('Error_number:',Error_number())
		end catch
	end

exec Update_total_sales 6, 4, '2024-05-20', 10, 4000000.00


--Section 4: 4 Marks Questions
--Q1 Write a query to export the artists and their artworks into XML format.
select artist_id, name,
(
select 
	artwork_id, 
	title,
	genre, 
	price
from artworks b
where A.artist_id=b.artist_id
for xml path, type)
from artists A
for xml path, root('artists')

--Q2 Write a query to convert the artists and their artworks into JSON format.

select artist_id, name,
json_query((
select 
	artwork_id, 
	title,
	genre, 
	price
from artworks b
where A.artist_id=b.artist_id
for json path)) as ARt
from artists A
for json path, root('artists')


 

--Section 3: 3 Marks Questions
--Q1 Write a query to create a view that shows artists who have created artworks in multiple genres.
go
create view shows_artists_multiple_genres
as
select 
		artists.artist_id, 
		name ,
		count(distinct genre) as Count_ofGenres
from artists 
inner join
artworks
		on artists.artist_id=artworks.artist_id
		group by artists.artist_id, name
		having count(distinct genre)>1
go

select * from shows_artists_multiple_genres
--Q2 Write a query to find artworks that have a higher price than the average price of artworks by the same artist.
select * from 
artworks A
	where price >
		(select avg(price) as Avg from artworks B
		where A.artist_id=B.artist_id
		group by artist_id)

--Q3 Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is
--higher than the overall average artwork price.
Select artist_id,avg(price) as Avg from artworks 
		group by artist_id
		having avg(price)>(Select avg(price) as Avg from artworks )


--section 5 
CREATE TABLE [Customers table] (
  C_id  int primary key,
  [customer_name] Varchar(20) not null,
  [customer_email] Varchar(20) unique ,);

  CREATE TABLE [Products] (
  [P_id] Int,
  [product_name] Varchar(20) unique,
  [product_price] int not null,
  [product_category] Varchar(20) ,
  PRIMARY KEY ([P_id])
);

CREATE TABLE [Orders] (
  [o_id] Int,
  [order_date] varchar(20),
  [order_quantity] varchar(20) not null,
  [order_total_amount] varchar(20),
  PRIMARY KEY ([o_id])

);

CREATE TABLE [Salestable] (
  [id] Int,
  [C_id] Int not null,
  [P_id] Int  not null,
  [o_id] Int not null ,
  PRIMARY KEY ([id]),
   FOREIGN KEY ([C_id]) REFERENCES [Customers table](id),
    FOREIGN KEY ([P_id]) REFERENCES [Products]([P_id]),
	FOREIGN KEY ([o_id]) REFERENCES [Orders]([o_id])


);




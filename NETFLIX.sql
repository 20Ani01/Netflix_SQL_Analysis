CREATE TABLE netflix
(
	show_id VARCHAR(8),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description varchar(250)
)

SELECT * FROM netflix;

SELECT 
	COUNT(*) AS TOTAL_CONTENT 
FROM netflix;

SELECT 
	DISTINCT type
FROM netflix;

-- 15 Business Problems
-- 1. Count the number of Movies vs TV Shows
select 
	type,
	count(*) as total_content
from netflix
group by 1;

--2. Find the most common rating for Movie & TV Show
select
	type,
	rating
from 
	(select
		type,
		rating,
		rank() over(partition by type order by count(*) desc) as ranking
	from netflix
	group by 1,2) as t1
where ranking = 1;

-- 3. List all the movies released in 2020
select
	*
from netflix
where 
	type = 'Movie'
	and
	release_year = 2020;

-- 4. Find top 5 countries with most content on netflix
select
	unnest(string_to_array(country, ',')) as new_country,
	count(show_id) as total_count
from netflix
group by 1
order  by 2 desc
limit 5;

--5. Identify the longest movie
select
	*
from netflix
where
	type = 'Movie'
	and
	duration = (select max(duration) from netflix);

-- 6. Find the contents added in last 5 years
select
	*
from netflix
where
	to_date(date_added, 'month, dd, yyyy') >= current_date - interval '5 years';

-- 7. Find all the movie/shows directed by 'Rajiv Chilaka'
select 
	*
from netflix
where
	director ilike '%Rajiv Chilaka%';

-- 8. List all TV Shows more than 5 seasons
select
	*
from netflix
where
	type = 'TV Show'
	and
	split_part(duration, ' ', 1)::numeric > 5
order by 
	split_part(duration, ' ', 1)::numeric desc;

-- 9. Count the number of times each Genre
select
	unnest(string_to_array(listed_in, ',')) as new_genre,
	count(show_id) as total_content
from netflix
group by 1;

/*10. Find each year and the average number of content released by India on
netflix and return top 5 year with highest average content*/
select
	extract(year from to_date(date_added, 'month, dd, yyyy')) as year,
	count(*) as yearly_content,
	Round(count(show_id)::numeric/(select count(*) 
	from netflix where country = 'India')::numeric * 100, 2) 
	as avg_content_per_year
from netflix
where
	country = 'India'
group by 1
order by 3 desc
limit 5;

-- 11. List all the movies that are documentaries
select
	*
from netflix
where
	type = 'Movie'
	and
	listed_in ilike '%Documentaries%';

-- 12. Find all the content without a director
select
	*
from netflix
where
	director is null;

--- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years\
select
	*
from netflix
where
	type = 'Movie'
	and
	casts ilike '%Salman Khan%'
	and 
	release_year > extract(year from current_date) - 10;

/* 14. Find top 10 actors who have appeared in the highest number of movies 
		produced in india*/
select
	unnest(string_to_array(casts, ',')) as new_casts,
	count(*) as total_count
from netflix
where
	type = 'Movie'
	and
	country ilike '%India%'
group by 1
order by 2 desc
limit 10;

/* 15. Categorise the content based on the presence of the keywords 'Kill'
and 'violence' in the description field. Label content containing these keywords
as 'Bad' and all othe content as 'Good'. Count howmany items fall into each category*/
with new_table
as
(select
	*,
	case
		when
			description ilike '%kill%'
			or
			description ilike '%violence%' then 'Bad_Content'
		else 'Good_Content'
	end category
from netflix
)
select 
	category,
	count(*) as total_content
from new_table
group by 1;

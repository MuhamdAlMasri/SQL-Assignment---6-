1)
WITH CTE_filmrentalcounts AS (
    SELECT
        f.film_id,
        f.title,
        COUNT(r.rental_id) AS rental_count
    FROM
        film AS f
    LEFT JOIN
        inventory AS i ON f.film_id = i.film_id
    LEFT JOIN
        rental AS r ON i.inventory_id = r.inventory_id
    GROUP BY
        f.film_id, f.title
)
SELECT
    frc.film_id,
    frc.title,
    frc.rental_count,
    (SELECT AVG(rental_count) FROM CTE_filmrentalcounts) AS avg_rental_count,
    CASE
        WHEN frc.rental_count > (SELECT AVG(rental_count) FROM CTE_filmrentalcounts) THEN 'Above Average'
        WHEN frc.rental_count < (SELECT AVG(rental_count) FROM CTE_filmrentalcounts) THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS rental_status
FROM
    CTE_filmrentalcounts AS frc;


2)
WITH CTE_TOP3_CATEGORIES AS
(
    SELECT 
        se_rental.customer_id,
        se_category.name AS category_name,
        ROW_NUMBER() OVER (PARTITION BY se_rental.customer_id ORDER BY COUNT(se_rental.rental_id) DESC) AS category_rank
    FROM public.rental AS se_rental
    INNER JOIN public.inventory AS se_inventory
    ON se_inventory.inventory_id = se_rental.inventory_id
    INNER JOIN public.film AS se_film
    ON se_film.film_id = se_inventory.film_id
    INNER JOIN public.film_category AS se_film_category
    ON se_film_category.film_id = se_film.film_id
    INNER JOIN public.category AS se_category
    ON se_category.category_id = se_film_category.category_id
    GROUP BY
        se_rental.customer_id,
        se_category.name
)
SELECT
    customer_id,
    MAX(CASE WHEN category_rank = 1 THEN category_name END) AS top1,
    MAX(CASE WHEN category_rank = 2 THEN category_name END) AS top2,
    MAX(CASE WHEN category_rank = 3 THEN category_name END) AS top3
FROM CTE_TOP3_CATEGORIES
WHERE category_rank <= 3
GROUP BY customer_id;

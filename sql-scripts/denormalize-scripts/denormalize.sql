CREATE TABLE denormalized_table AS
WITH FilmActors AS (
    SELECT
        f.film_id,
        STRING_AGG(a.first_name || ' ' || a.last_name, ', ' ORDER BY a.first_name) AS actors_list
    FROM film f
    JOIN film_actor fa ON f.film_id = fa.film_id
    JOIN actor a ON fa.actor_id = a.actor_id
    GROUP BY f.film_id
),
FilmFirstCategory AS (
    SELECT DISTINCT ON (film_id) film_id, category_id
    FROM film_category
    ORDER BY film_id, category_id
),
RentalPayments AS (
    SELECT
        rental_id,
        SUM(amount) AS payment_amount,
        MAX(payment_date) AS payment_date
    FROM payment
    GROUP BY rental_id
)
SELECT
    r.inventory_id,
    r.customer_id,
    r.rental_date,
    f.title AS film_title,
    cat.name AS film_category,
    f.rating AS film_rating,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    c.email AS customer_email,
    addr.address AS customer_address,
    city.city AS customer_city,
    co.country AS customer_country, 
    r.return_date,
    p.payment_amount,
    p.payment_date,
    s.first_name || ' ' || s.last_name AS staff_member,
    fa.actors_list,
    f.special_features

FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
JOIN address addr ON c.address_id = addr.address_id
JOIN city ON addr.city_id = city.city_id
JOIN country co ON city.country_id = co.country_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN staff s ON r.staff_id = s.staff_id
JOIN FilmFirstCategory ffc ON f.film_id = ffc.film_id
JOIN category cat ON ffc.category_id = cat.category_id
LEFT JOIN RentalPayments p ON r.rental_id = p.rental_id
LEFT JOIN FilmActors fa ON f.film_id = fa.film_id;

ALTER TABLE denormalized_table
ADD PRIMARY KEY (inventory_id, customer_id, rental_date);
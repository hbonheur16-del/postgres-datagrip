-- Exemples d’optimisation des JOIN (INNER, OUTER, CROSS)

-- 1) INNER JOIN classique, avec prédicats les plus sélectifs dans le WHERE
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i       ON i.customer_id = c.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
WHERE i.invoice_date >= DATE '2010-01-01'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- 2) LEFT JOIN : garder tous les clients, même sans facture
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COALESCE(SUM(il.unit_price * il.quantity), 0) AS total_spent
FROM customer c
LEFT JOIN invoice i       ON i.customer_id = c.customer_id
LEFT JOIN invoice_line il ON il.invoice_id = i.invoice_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- 3) CROSS JOIN : produit cartésien contrôlé
-- Exemple pédagogique : nombre de clients par pays croisé avec une liste de seuils
WITH nb_clients_pays AS (
    SELECT country, COUNT(*) AS nb_clients
    FROM customer
    GROUP BY country
), seuils AS (
    SELECT 10 AS seuil
    UNION ALL SELECT 20
    UNION ALL SELECT 50
)
SELECT
    n.country,
    n.nb_clients,
    s.seuil,
    (n.nb_clients >= s.seuil) AS au_moins_seuil
FROM nb_clients_pays n
CROSS JOIN seuils s
ORDER BY n.country, s.seuil;
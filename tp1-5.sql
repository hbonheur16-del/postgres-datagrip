BEGIN;

-- 0. Nettoyage : on supprime la table partitionnée si elle existe déjà
DROP TABLE IF EXISTS invoice_part CASCADE;

-- 1. Création de la table partitionnée basée sur invoice,
--    partitionnée par année sur purchase_date
CREATE TABLE invoice_part
(
    LIKE invoice INCLUDING DEFAULTS
) PARTITION BY RANGE (purchase_date);

-- 2. Création automatique des partitions annuelles pour chaque année présente dans invoice
DO $$
DECLARE
    r RECORD;
    year_start date;
    year_end   date;
    part_name  text;
BEGIN
    FOR r IN
        SELECT DISTINCT
               date_trunc('year', purchase_date)::date                    AS year_start,
               (date_trunc('year', purchase_date) + INTERVAL '1 year')::date AS year_end
        FROM invoice
        WHERE purchase_date IS NOT NULL
        ORDER BY 1
    LOOP
        year_start := r.year_start;
        year_end   := r.year_end;
        part_name  := format('invoice_%s', to_char(year_start, 'YYYY'));

        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS %I PARTITION OF invoice_part
             FOR VALUES FROM (%L) TO (%L);',
            part_name,
            year_start,
            year_end
        );
    END LOOP;
END$$;

-- 3. Index sur la colonne de partitionnement
CREATE INDEX IF NOT EXISTS idx_invoice_part_purchase_date
    ON invoice_part (purchase_date);

-- (optionnel) index sur customer_id pour les recherches par client
CREATE INDEX IF NOT EXISTS idx_invoice_part_customer
    ON invoice_part (customer_id);

-- 4. Insertion des données de l'ancienne table vers la table partitionnée
INSERT INTO invoice_part
SELECT *
FROM invoice
WHERE purchase_date IS NOT NULL;

COMMIT;

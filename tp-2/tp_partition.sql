- auto-generated definition


create table invoice_partitioned
(
    invoice_id          integer generated always as identity,
    customer_id         integer        not null
        references customer,
    invoice_date        timestamp      not null,
    billing_address     varchar(70),
    billing_city        varchar(40),
    billing_state       varchar(40),
    billing_country     varchar(40),
    billing_postal_code varchar(10),
    total               numeric(10, 2) not null,
    purchase_date       date,
    PRIMARY KEY (invoice_id,purchase_date)
) PARTITION BY RANGE (purchase_date);


CREATE TABLE invoice_2018 PARTITION OF invoice_partitioned
    FOR VALUES FROM ('2018-01-01') TO ('2019-01-01');


CREATE TABLE invoice_2019 PARTITION OF invoice_partitioned
    FOR VALUES FROM ('2019-01-01') TO ('2020-01-01');

CREATE TABLE invoice_2020 PARTITION OF invoice_partitioned
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');

CREATE TABLE invoice_2021 PARTITION OF invoice_partitioned
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');

CREATE TABLE invoice_2022 PARTITION OF invoice_partitioned
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');


SELECT * FROM invoice_partitioned
WHERE purchase_date BETWEEN '2018-01-01' AND '2019-01-01';


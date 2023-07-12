SET SEED = 0.1234567890;
DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO customers (full_name)
VALUES
    ('John Smith'),
    ('Jane Doe'),
    ('Michael Johnson'),
    ('Emily Davis'),
    ('David Anderson'),
    ('Sarah Wilson'),
    ('Robert Brown'),
    ('Jennifer Taylor'),
    ('Daniel Martinez'),
    ('Laura Thompson');

DROP TABLE IF EXISTS products CASCADE;
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (description, price)
VALUES
    ('T-Shirt', 19.99),
    ('Jeans', 49.99),
    ('Sneakers', 79.99),
    ('Watch', 149.99),
    ('Backpack', 39.99);

DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers (id)
);

DROP TABLE IF EXISTS order_items CASCADE;
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders (id),
    FOREIGN KEY (product_id) REFERENCES products (id)
);

-- Create 20 orders
INSERT INTO orders (order_date, customer_id)
SELECT
    CURRENT_DATE - (random() * 365)::integer,  -- Random order dates within the past year
    (SELECT id FROM customers where s = s ORDER BY random() LIMIT 1)  -- Random customer_id from the customers table
FROM generate_series(1, 20) as s;

-- Create order_items for each order
INSERT INTO order_items (order_id, product_id, quantity, amount)
with
cross_joined as (
	SELECT
	    o.id AS order_id,
	    p.id AS product_id,
	    p.price,
	    (random() * 5 + 1)::integer as quantity,
	    row_number() over (partition by o.id order by random()) as row_num
	FROM orders o
	CROSS JOIN products as p
)

,with_amount as (
	select
		order_id,
		product_id,
		quantity,
		quantity * price as amount
	from cross_joined
	where
		row_num = 1
		or random() < 0.25
)

select *
from with_amount;

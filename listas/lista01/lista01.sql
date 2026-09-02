DROP TABLE IF EXISTS orders_products CASCADE;
DROP TABLE IF EXISTS orders     CASCADE;
DROP TABLE IF EXISTS products   CASCADE;
DROP TABLE IF EXISTS users      CASCADE;

CREATE TABLE users (
    id serial PRIMARY KEY,
    name text NOT NULL,
    email text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE products (
    id serial PRIMARY KEY,
    name text NOT NULL,
    price numeric(10,2) NOT NULL CHECK (price >= 0),
    stock integer NOT NULL DEFAULT 0 CHECK (stock >= 0),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE orders (
    id serial PRIMARY KEY,
    user_id integer NOT NULL REFERENCES users(id),
    order_date timestamptz NOT NULL DEFAULT now(),
    status text NOT NULL DEFAULT 'pending'
           CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'canceled')),
    total numeric(12,2) NOT NULL DEFAULT 0 CHECK (total >= 0)
);

CREATE TABLE orders_products (
    id serial PRIMARY KEY,
    order_id integer NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id integer NOT NULL REFERENCES products(id),
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(10,2) NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO users (name, email) VALUES
    ('Ana Souza',    'ana@tads.ifrn'),
    ('Bruno Lima',   'bruno@tads.ifrn'),
    ('Carla Alves',  'carla@tads.ifrn'),
    ('Diego Santos', 'diego@tads.ifrn'),
    ('Elisa Prado',  'elisa@tads.ifrn'),
    ('Felipe Silva', 'felipe@tads.ifrn');

INSERT INTO products (name, price, stock) VALUES
    ('Notebook Dell Inspiron',            4500.00, 10),
    ('Mouse Logitech MX',                 89.90, 50),
    ('Teclado Mecânico Logitech',         349.90, 30),
    ('Monitor 27" Dell',                  1899.00, 12),
    ('Webcam HD Logitech',                259.00, 40),
    ('Headset Gamer Logitech',            499.90, 25),
    ('Cadeira Ergonômica Flexform',       1299.00,  8),
    ('SSD 1TB Kingston',                  459.00, 20),
    ('Notebook Apple Macbook Pro M5',     19999.00, 8);

-- interval - second, minute, hour, day, month, year
INSERT INTO orders (user_id, order_date, status, total) VALUES
    (1, now() - interval '2 days',  'delivered', 4589.90),
    (2, now() - interval '5 days',  'shipped',    349.90),
    (3, now() - interval '10 days', 'paid',       618.90),
    (1, now() - interval '15 days', 'delivered', 1299.00),
    (4, now() - interval '20 days', 'paid',       459.00),
    (5, now() - interval '25 days', 'pending',    259.00),
    (2, now() - interval '40 days', 'delivered', 1899.00),
    (3, now() - interval '50 days', 'canceled',   499.90),
    (4, now() - interval '60 days', 'delivered',  349.90),
    (5, now() - interval '90 days', 'delivered', 4500.00);

INSERT INTO orders_products (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 4500.00),
    (1, 2, 1,   89.90),
    (2, 3, 1,  349.90),
    (3, 5, 1,  259.00),
    (3, 3, 1,  349.90),
    (3, 2, 1,   89.90),
    (4, 7, 1, 1299.00),
    (5, 8, 1,  459.00),
    (6, 5, 1,  259.00),
    (7, 4, 1, 1899.00),
    (8, 6, 1,  499.90),
    (9, 3, 1,  349.90),
    (10, 1, 1, 4500.00);


-- 1. Liste os produtos com preço superior a R$ 1000.

select name, price from products
where price>1000;

-- 2. Liste os produtos ordenados pelo preço, do maior para o menor.

select name, price from products
order by price desc;

-- 3. Aumente o preço de todos os produtos da Dell em 10%.

update products
set price = price * 1.10
where name like '%Dell%';

-- 4. Exclua todos os produtos que sejam do tipo Macbook.

delete from products
where name like '%Macbook%';

-- 5. Exclua um produto que não possua pedidos associados. 

select name, price from products
where not exists (
    select *
    from orders_products
    where orders_products.product_id = products.id
    
);
-- 6. Liste todos os pedidos realizados nos últimos 30 dias.

select name, created_at
from products
where created_at >= '2026-07-31';

-- 7. Liste os pedidos e os respectivos nomes de usuário.

select 
    o.id as pedido_id,
    o.order_date as data_pedido,
    o.status as status_pedido,
    o.total as valor_total,
    u.name as nome_usuario
from orders o
inner join users u on o.user_id = u.id;

-- 8. Liste todos os usuários e seus pedidos, inclusive usuários sem pedidos.

select 
    u.id as usuario_id,
    u.name as nome_usuario,
    o.id as pedido_id
from users u
left join orders o on u.id = o.user_id;

-- 9. Liste todos os usuários (id, nome e email) que realizaram pelo menos um pedido.

select 
    u.id as usuario_id,
    u.name as nome_usuario,
    u.email,
    o.id as pedido_id
from users u
inner join orders o on u.id = o.user_id;

-- 10. Liste produtos que nunca foram vendidos.

select id, name, price, stock 
from products p
where not exists (
    select * 
    from orders_products op 
    where op.product_id = p.id
);

-- 11. Liste usuários que nunca realizaram pedidos.

select id, name 
from users u
where not exists(
    select *
    from orders o
    where o.user_id = u.id
);

-- 12. Liste os produtos com preço acima da média em ordem decrescente.

select name, price 
from products
where price > (select avg(price) from products)
order by price desc;

-- 13. Liste a quantidade de pedidos realizados por cada usuário.

select
    u.id as usuario_id,
    u.name as nome_usuario,
    count(o.id) as total_de_pedidos
from users u
left join orders o on u.id = o.user_id
group by u.id, u.name
order by total_de_pedidos desc, u.name asc;

-- 14. Listar os três produtos mais vendidos.

select 
    p.id as produto_id,
    p.name as nome_produto,
    sum(op.quantity) as total_unidades_vendidas
from products p
inner join orders_products op on p.id = op.product_id
group by p.id, p.name
order by total_unidades_vendidas desc
limit 3;

-- 15. Gerar um relatório com: usuários, quantidade de pedidos e valor total comprado.

select
    u.id as usuario_id,
    u.name as nome_usuario,
    count(o.id) as quantidade_de_pedidos,
    coalesce(sum(o.total),0.00) as valor_total_comprado
from users u
left join orders o on u.id = o.user_id
group by u.id, u.name
order by valor_total_comprado desc, quantidade_de_pedidos desc;


-- select id, order_date at time zone 'America/Fortaleza' from orders order by order_date;
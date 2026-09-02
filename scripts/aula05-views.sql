-- VIEWS

-- No psql: \dv - visualizar as views existentes
-- No psql: \d+ v_users_orders - visualizar detalhes da view

-- 1. Resumo de pedidos por usuário (id, usuario, qtd_pedidos, total_gasto)
drop view if exists v_users_orders;
create view v_users_orders as
select 
    u.id id,
    u.name usuario,
    count(o.id) qtd_pedidos,
    coalesce(sum(o.total), 0) total_gasto
from users u
left join orders o on o.user_id = u.id
group by u.id, u.name;

-- select * from v_users_orders order by id;

-- 2. Relatório de vendas de produtos (id, produto, qtd_vendida, total_vendido)
drop view if exists v_products_sales;
create view v_products_sales as
select 
    p.id id,
    p.name produto,
    sum(op.quantity) qtd_vendida,
    sum(op.quantity * op.unit_price) total_vendido
from products p
join orders_products op on op.product_id = p.id
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name;

-- select * from v_products_sales order by id;

-- 3. Relatório detalhado de pedidos
drop view if exists v_orders_details;
create view v_orders_details as
select
    o.id id,
    u.name usuario,
    u.email email,
    o.order_date,
    o.status,
    p.name produto,
    op.quantity qtd,
    op.unit_price valor_unitario,
    op.unit_price * op.quantity valor_total
from orders o
join users u on u.id = o.user_id
join orders_products op on op.order_id = o.id
join products p on p.id = op.product_id;

-- select * from v_orders_details order by id;

-- 4. Relatório de itens em estoque
drop view if exists v_products_in_stock;
create view v_products_in_stock as
select
    id,
    name produto,
    price valor,
    stock estoque
from products
where stock > 0
WITH CHECK OPTION;

-- select * from v_products_in_stock;

-- update products
-- set stock = 10
-- where id = 1;

update v_products_in_stock
set estoque = 0
where id = 1
returning id, produto, estoque;

insert into v_products_in_stock (produto, valor, estoque)
values ('Produto qualquer', 99, 0);


-- explain analyze select * from v_top_produtcs order by total_vendido desc limit 3;


-- view

drop view if exists v_top_products;
create view v_top_products as
select 
    p.id id,
    p.name produto,
    sum(op.quantity) unid_vendidas,
    sum(op.quantity * op.unit_price) total_vendidos
from products p
join orders_products op on op.product_id = p.id
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name;

-- ver v e mc \dmv

--Materialezed views

-- explain analyze select * from mv_top_produtcs order by total_vendido desc limit 3;


drop view if exists mv_top_products;
create materialized view mv_top_products as
select 
    p.id id,
    p.name produto,
    sum(op.quantity) unid_vendidas,
    sum(op.quantity * op.unit_price) total_vendidos
from products p
join orders_products op on op.product_id = p.id
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name
with data;
--with NO data;

-- 6. MV para mostrar o total vendido por mês

drop materialized view if exists mv_monthly_sales;
create materialized view mv_monthly_sales as
select
    to_char(date_trunc('month', o.order_date), 'YYYY-MM') mes,
    sum(o.total) total_vendido
from orders o
where o.status <> 'canceled'
group by mes
with data;

-- select * from mv_monthly_sales order by mes desc;

-- Recarregando MV

refresh materialized view mv_monthly_sales;

-- Recarregando MV (bloqueada durante o refresh)

create unique index index_monthly_sales_month
on mv_monthly_sales(mes);

refresh materialized view concurrently mv_monthly_sales


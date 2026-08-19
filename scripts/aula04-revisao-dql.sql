select * from funcionario;

select pnome, unome, numero_departamento from funcionario;

select pnome || ' ' || unome as "Nome completo", numero_departamento as "Dep" from funcionario;
select pnome || ' ' || unome nome, numero_departamento dep from funcionario;


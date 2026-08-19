/*-- Insert
insert into funcionario 
values
('12345878999', 'raissa', 'placido', 'raissa@gmail.com','Natal-RN', '9990', '2000-01-27', 'M', null, null),
('12245678899', 'laura', 'nubia', 'laura@gmail.com','Fortaleza-CE', '9000', '1918-12-15', 'M', null, null),
('12335677899', 'joaquim', 'otelo', 'joaquim@gmail.com','Recife-PE', '6490', '1990-03-22', 'M', null, null);

insert into funcionario(cpf, pnome, unome, email, salario, data_nasc, sexo) values ('12345227899', 'Alice', 'Tomaz','alice@gmail.com', 6690, '2002-03-03', 'M');

-- Atualizar

update funcionario 
set sexo='F'
where  cpf='12345678999'
returning cpf, pnome, unome, sexo;

-- Remover

delete from funcionario
where cpf='12345678899'
returning cpf, pnome, unome;
*/
insert into departamento values
(1, 'TI', '11122233344', current_date),
(2, 'Financeiro', '11122233345', current_date - interval '3 days'),
(3, 'RH', '11122233346', current_date - interval '5 days');


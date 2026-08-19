drop table if exists funcionario cascade;
drop table if exists departamento cascade;


create table funcionario(
    cpf char(11) primary key, 
    pnome varchar (50) not null,
    unome varchar (50) not null,
    email varchar (50) unique,
    endereco varchar(100),
    salario numeric(7,2),
    data_nasc date,
    sexo char(1),
    cpf_supervisor char(11),
    numero_departamento smallint,

    constraint funcionario_salario_check 
    check (salario >= 2000 and salario <= 15000),

    constraint funcionario_sexo_check 
    check (lower(sexo) in ('m', 'f', 'o'))
);


create table departamento(
    numero smallint primary key,
    nome varchar(50) unique,
    cpf_gerente char(11),
    data_ini date not null
        
    );

/*
-- adicionar um novo atributo
--alter table departamento
--add column data_ini date;

-- alterar um atributo para not nul
--alter table departamento
--alter column data_ini set not null;

-- excluir um atributo

--alter table departamento
--drop column data_ini;

-- adicionar uma restrição padrão
alter table funcionario
alter column endereco set default 'Macau-RN';

-- excluir um valor padrão default
--alter table funcionario
--alter column endereco drop default;

-- adicionar restrição (constraint) CHECK
--alter table funcionario
--add constraint funcionario_sexo_check]
--check (lower(sexo) in ('m', 'f', 'o'));
-- or (sexo in ('m', 'f', 'o', 'M', 'F', 'O'));

-- excluir restrição
--alter table funcionario
--drop constraint if exists funcionario_sexo_check;

-- adicionar restrição FOREIGN KEY
alter table funcionario 
add constraint funcionario_num_dep_fk
foreign key (numero_departamento)
references departamento(numero)
--no action, set null, set default, restrict, cascade
on delete no action
on update cascade;

-- TO DO: adicionar restrições FK para cpf_supervisor e cpf_gerente.

-- 1. Restrição para o Supervisor (Tabela Funcionario aponta para ela mesma)
alter table funcionario 
add constraint funcionario_cpf_sup_fk
foreign key (cpf_supervisor)
references funcionario(cpf)
on delete set null
on update cascade;

-- 2. Restrição para o Gerente (Tabela Departamento aponta para Funcionario)
alter table departamento
add constraint departamento_cpf_gerente_fk
foreign key (cpf_gerente)
references funcionario(cpf)
on delete no action
on update cascade;
*/
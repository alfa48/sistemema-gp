#Manuel André
#Damiao de Oliveira
 use sistema_prisional_db;

INSERT INTO `cela` (`numero`, `capacidade`, `status_ocupacao`, `num_detentos`) VALUES
(1, 8, 0, 0),
(2, 8, 0, 0),
(3, 8, 0, 0),
(4, 8, 0, 0),
(5, 8, 0, 0),
(6, 8, 0, 0);

select * from cela;

INSERT INTO `detento` (`nome`, `data_nascimento`, `num_detento`, `data_entrada`, `data_saida`, `cela_id`) VALUES
('João Silva', '1985-01-15', 1, '2024-06-01', '2025-06-01', 1),
('Maria Souza', '1990-03-22', 2, '2024-06-02', '2025-06-02', 2),
('Carlos Pereira', '1978-07-09', 3, '2024-06-03', '2025-06-03', 3),
('Ana Costa', '1982-11-30', 4, '2024-06-04', '2025-06-04', 4),
('Pedro Oliveira', '1995-05-18', 5, '2024-06-05', '2025-06-05', 5),
('Lucas Martins', '1988-09-25', 6, '2024-06-06', '2025-06-06', 6);

-- nota que para a cela o status e numero de detento alterou de forma autonoma;
-- assim que se add detento nas celas
select * from cela;
select * from detento;

-- add mais 6 detentos no na cela 2
INSERT INTO `detento` (`nome`, `data_nascimento`, `num_detento`, `data_entrada`, `data_saida`, `cela_id`) VALUES
('José Lima', '1983-02-14', 7, '2024-06-07', '2025-06-07', 2),
('Clara Mendes', '1992-04-21', 8, '2024-06-08', '2025-06-08', 2),
('Miguel Alves', '1987-10-30', 9, '2024-06-09', '2025-06-09', 2),
('Beatriz Rocha', '1993-08-12', 10, '2024-06-10', '2025-06-10', 2),
('Rafael Nunes', '1981-12-05', 11, '2024-06-11', '2025-06-11', 2),
('Fernanda Silva', '1989-09-23', 12, '2024-06-12', '2025-06-12', 2);
INSERT INTO detento (nome, data_nascimento, num_detento, data_entrada, data_saida, cela_id)
VALUES ('João Silva', '1990-01-15', 12345, '2023-03-10', '2024-06-19', 1);

select * from cela;

-- nota que ja temos 7 detentos na cela 2 com mais 2 excederá o limite permitido que é 8
INSERT INTO `detento` (`nome`, `data_nascimento`, `num_detento`, `data_entrada`, `data_saida`, `cela_id`) VALUES
-- ('Paulo Santos', '1984-03-10', 13, '2024-06-13', '2025-06-13', 2),
('Juliana Ferreira', '1991-07-19', 14, '2024-06-14', '2025-06-14', 2);
select * from cela;

-- visitante para o detento 3
INSERT INTO `visitante` (`nome`, `relacao_detento`, `data_entrada`, `id_detento`)
VALUES
('Visitante 1', 'Amigo', '2024-06-20', 3),
('Visitante 2', 'Familiar', '2024-06-20', 3),
('Visitante 3', 'Colega', '2024-06-20', 3),
-- ('Visitante 4', 'Parente', '2024-06-20', 3),
('Visitante 5', 'Conhecido', '2024-06-20', 3);
select * from visitante;

-- add funcionario

-- Inserir funcionário com cargo de gestão
INSERT INTO `funcionario` (`nome`, `cargo`, `salario`, `data_contrat`)
VALUES ('Funcionário Gestão', 'gestao', 5000.00, current_date()),
-- Inserir funcionário com cargo de guarda
	('Funcionário Guarda 1', 'guarda', 3000.00, current_date()),
-- Inserir funcionário com cargo de guarda
	('Funcionário Guarda 2', 'guarda', 3000.00, current_date()),
-- Inserir funcionário com cargo de médico
	('Funcionário Médico', 'medico', 6000.00, current_date());
    
    select * from funcionario;
-- registro
-- Supondo que o id do Funcionário gestao faça um registro
 INSERT INTO `registro` (`data`, `destino`, `tipo_resgistro`, `id_detento`, `id_funcionario`)
VALUES (current_date(), 1, 'transferencia', 2, 1);

-- 13 Supondo que o id do Funcionário gestao faça um registro de soltura
 INSERT INTO `registro` (`data`, `destino`, `tipo_resgistro`, `id_detento`, `id_funcionario`)
VALUES (current_date(), null, 'soltura', 13, 1);

select * from detento;
select * from cela;
select * from registro;
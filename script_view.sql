#Manuel André
#Damiao de Oliveira
 use sistema_prisional_db;
 
--
-- view no MySQL que mostra todos os detentos de uma cela específica,
-- 
CREATE VIEW view_detentos_cela AS
SELECT d.id AS detento_id, d.nome AS nome_detento, d.data_nascimento, d.num_detento, d.data_entrada, d.data_saida, c.numero AS numero_cela
FROM detento d
JOIN cela c ON d.cela_id = c.id;


--
-- view que mostra todos os vistantes de um detento
--
CREATE VIEW view_visitantes_detento AS
SELECT v.id AS id_visitante, v.nome AS nome_visitante, v.relacao_detento, v.data_entrada,
       d.id AS id_detento, d.nome AS nome_detento
FROM visitante v
JOIN detento d ON v.id_detento = d.id;

#Manuel André
#Damiao de Oliveira
 use sistema_prisional_db;
 
-- Consulta na View para a Cela 
SELECT *
FROM view_detentos_cela
WHERE numero_cela = 2;
 
-- Consulta na view para a visitas
SELECT *
FROM view_visitantes_detento
WHERE id_detento = 3;

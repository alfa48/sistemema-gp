#Manuel André
#Damiao de Oliveira
 use sistema_prisional_db;

-- trigger para contar e nao permitir adicionar detento numa cela lotada
DELIMITER $$

CREATE TRIGGER `before_detento_insert`
BEFORE INSERT ON `detento`
FOR EACH ROW
BEGIN
  DECLARE v_capacidade INT;
  DECLARE v_num_detentos INT;
  
  -- Obtém a capacidade e o número atual de detentos da cela especificada
  SELECT capacidade, num_detentos INTO v_capacidade, v_num_detentos
  FROM cela
  WHERE id = NEW.cela_id;
  
  -- Verifica se a capacidade foi atingida
  IF v_num_detentos < v_capacidade THEN
    -- Incrementa o número de detentos na cela
    UPDATE cela
    SET num_detentos = num_detentos + 1
    WHERE id = NEW.cela_id;

    -- Atualiza o status de ocupação da cela, se necessário
    IF v_num_detentos + 1 = 1 THEN
      UPDATE cela
      SET status_ocupacao = 1
      WHERE id = NEW.cela_id;
    END IF;

  ELSE
    -- Impede a inserção se a capacidade da cela for atingida
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'A capacidade da cela foi atingida. Não é possível adicionar mais detentos.';
  END IF;
END$$

DELIMITER ;

-- trigger para permitir visitas apenas nas quintas e sexta e o número máximo de visitas é 4 por dia
DELIMITER //

CREATE TRIGGER limite_visitas
BEFORE INSERT ON visitante
FOR EACH ROW
BEGIN
    DECLARE total_visitas INT;
    DECLARE dia_semana VARCHAR(20);

    -- Obtém o dia da semana da data de entrada do visitante
    SET dia_semana = UPPER(DATE_FORMAT(NEW.data_entrada, '%W'));

    -- Conta quantas visitas já existem na data de entrada do novo visitante
    SELECT COUNT(*)
    INTO total_visitas
    FROM visitante
    WHERE DATE(data_entrada) = DATE(NEW.data_entrada);

    -- Verifica se é quinta ou sexta-feira e se o número de visitas é menor que 4
    IF (dia_semana = 'THURSDAY' OR dia_semana = 'FRIDAY') AND total_visitas >= 4 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Limite de 4 visitas por dia excedido para quintas e sextas-feiras.';
    END IF;
END //

DELIMITER ;

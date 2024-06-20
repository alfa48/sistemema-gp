#Manuel André
#Damiao de Oliveira
 use sistema_prisional_db;

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

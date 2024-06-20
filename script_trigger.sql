#Manuel André
#Damiao de Oliveira
 use sistema_prisional_db;


/*
Para criar um trigger que preencha automaticamente o campo origem com o ID da
cela atual do detento sempre que um registro for criado na tabela registro,
*/
DELIMITER //

CREATE TRIGGER before_insert_registro_fill_origem
BEFORE INSERT ON registro
FOR EACH ROW
BEGIN
    DECLARE cela_atual INT;

    -- Obtém a cela atual do detento
    SET cela_atual = (SELECT cela_id FROM detento WHERE id = NEW.id_detento);

    -- Verifica se cela_atual é NULL
    IF cela_atual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Detento não encontrado ou cela_id é NULL';
    ELSE
        -- Executa a lógica se o tipo_registro for 'transferencia' e presidio for NULL, ou se o tipo_registro for 'soltura'
        IF NEW.tipo_resgistro = 'transferencia' AND NEW.presidio IS NULL THEN
            SET NEW.origem = cela_atual;
        ELSEIF NEW.tipo_resgistro = 'soltura' THEN
            SET NEW.origem = cela_atual;
        END IF;
    END IF;
END;
//

DELIMITER ;




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


-- 
-- trigger para garantir que apenas funcionários com o cargo de 'gestão' possam criar registros na tabela registro, 
--
DELIMITER //

CREATE TRIGGER before_insert_registro
BEFORE INSERT ON registro
FOR EACH ROW
BEGIN
    DECLARE cargo_funcionario VARCHAR(25);

    -- Obtém o cargo do funcionário que está inserindo o registro
    SELECT cargo
    INTO cargo_funcionario
    FROM funcionario
    WHERE id = NEW.id_funcionario;

    -- Verifica se o cargo do funcionário é 'gestao'
    IF cargo_funcionario != 'gestao' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Apenas funcionários com cargo de gestão podem criar registros.';
    END IF;
END //

DELIMITER ;

-- 
-- criar um trigger que ao criar um registro se o tipo_registro for trasferencia e presidio for null, nao permita que origem e destino sejam nulls nem que sejam iguais 
-- decrementar 1 no num_detentos da cela do detento e incrementar 1 no num_detentos da cela de destino
--
DELIMITER //

CREATE TRIGGER before_insert_registro_tras
BEFORE INSERT ON registro
FOR EACH ROW
BEGIN
    DECLARE detento_cela_atual INT;
    
    IF NEW.tipo_resgistro = 'transferencia' AND NEW.presidio IS NULL THEN
        -- Verificar se destino não é nulo e é diferente da cela atual do detento
        IF NEW.destino IS NULL OR NEW.destino = (SELECT cela_id FROM detento WHERE id = NEW.id_detento) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O destino da transferência não pode ser nulo ou igual à cela atual do detento.';
        END IF;
        
        -- Decrementar num_detentos na cela de origem
        SET detento_cela_atual = (SELECT cela_id FROM detento WHERE id = NEW.id_detento);
        UPDATE cela SET num_detentos = num_detentos - 1 WHERE id = detento_cela_atual;
        
        -- Incrementar num_detentos na cela de destino
        UPDATE cela SET num_detentos = num_detentos + 1 WHERE id = NEW.destino;
        
        -- Atualizar cela_id do detento para o destino da transferência
        UPDATE detento SET cela_id = NEW.destino WHERE id = NEW.id_detento;
        
    END IF;
END;
//

DELIMITER ;


-- 
/* Transferência com presídio não nulo: Decrementar num_detentos do detento e alterar cela_id para NULL.
Entrada: Incrementar num_detentos na cela de destino.
Soltura: Decrementar num_detentos do detento e alterar cela_id para NULL. 
*/
DELIMITER //

CREATE TRIGGER before_insert_registro_soltura_entrada_tras_pra_out_presidio
BEFORE INSERT ON registro
FOR EACH ROW
BEGIN
    DECLARE detento_data_saida DATE;
    
    IF NEW.tipo_resgistro = 'transferencia' AND NEW.presidio IS NOT NULL THEN
        -- Transferência para outro presídio
        UPDATE detento SET cela_id = NULL WHERE id = NEW.id_detento;
    ELSEIF NEW.tipo_resgistro = 'transferencia' THEN
        -- Transferência para outra cela dentro do mesmo presídio
        UPDATE detento SET cela_id = NEW.destino WHERE id = NEW.id_detento;
        
    ELSEIF NEW.tipo_resgistro = 'entrada' THEN
        -- Entrada em uma cela
        IF NEW.destino IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O destino da entrada não pode ser nulo.';
        ELSE
            UPDATE detento SET cela_id = NEW.destino WHERE id = NEW.id_detento;
        END IF;
        
    ELSEIF NEW.tipo_resgistro = 'soltura' THEN
        -- Soltura do detento
        SET detento_data_saida = (SELECT data_saida FROM detento WHERE id = NEW.id_detento);
        
        IF detento_data_saida IS NOT NULL AND detento_data_saida <= CURRENT_DATE() THEN
            UPDATE detento SET cela_id = NULL WHERE id = NEW.id_detento;
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A pena do detento não foi cumprida.';
        END IF;
    END IF;
END;
//

DELIMITER ;


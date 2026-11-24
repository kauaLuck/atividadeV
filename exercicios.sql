DELIMITER //
CREATE PROCEDURE atualizar_preco_categoria(
    IN p_id_categoria INT,
    IN p_percentual DECIMAL(5,2),
    OUT p_quantidade INT,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_categoria INT;
    SET p_quantidade = 0;
    -- Verifica se os dados foram informados
    IF p_id_categoria IS NULL OR p_percentual IS NULL THEN
        SET p_mensagem = 'Erro: informe todos os dados.';
    -- Valida o desconto máximo
    ELSEIF p_percentual < -50 THEN
        SET p_mensagem = 'Erro: desconto máximo permitido é de 50%.';
    -- Valida o aumento máximo
    ELSEIF p_percentual > 100 THEN
        SET p_mensagem = 'Erro: aumento máximo permitido é de 100%.';
    ELSE
        -- Verifica se a categoria existe
        SELECT COUNT(*)
        INTO v_categoria
        FROM categorias
        WHERE id_categoria = p_id_categoria;
        IF v_categoria = 0 THEN
            SET p_mensagem = 'Erro: categoria não encontrada.';
        -- Verifica se o percentual é zero
        ELSEIF p_percentual = 0 THEN
            SET p_mensagem = 'Nenhum ajuste realizado: percentual igual a zero.';
        ELSE
            -- Atualiza os preços dos produtos ativos
            UPDATE produtos
            SET preco = preco * (1 + p_percentual / 100)
            WHERE id_categoria = p_id_categoria
              AND ativo = TRUE;
            -- Guarda a quantidade de produtos alterados
            SET p_quantidade = ROW_COUNT();
            SET p_mensagem = CONCAT(
                'Sucesso! ',
                p_quantidade,
                ' produto(s) tiveram seus preços atualizados.'
            );
        END IF;
    END IF;
    -- Registra a operação no log
    INSERT INTO log_operacoes (
        tabela_afetada,
        operacao,
        descricao
    )
    VALUES (
        'produtos',
        'UPDATE',
        CONCAT(
            'Categoria: ', p_id_categoria,
            ' | Percentual: ', p_percentual,
            '% | ', p_mensagem
        )
    );
END //
DELIMITER ;

CALL atualizar_preco_categoria(
    1,
    10,
    @quantidade,
    @mensagem
);
SELECT @quantidade AS produtos_alterados,
       @mensagem AS resultado;


CALL atualizar_preco_categoria(
    1,
    -20,
    @quantidade,
    @mensagem
);
SELECT @quantidade AS produtos_alterados,
       @mensagem AS resultado;
       
CALL atualizar_preco_categoria(
    1,
    -60,
    @quantidade,
    @mensagem
);
SELECT @quantidade, @mensagem;

SELECT * FROM log_operacoes;



-- exercicio 2
DELIMITER //
CREATE PROCEDURE consultar_extrato_cliente(
    IN p_id_cliente INT
)
BEGIN
    DECLARE v_cliente INT;
    SELECT COUNT(*)
    INTO v_cliente
    FROM clientes
    WHERE id_cliente = p_id_cliente;
    IF v_cliente = 0 THEN
        SELECT 'Erro: cliente não encontrado!' AS mensagem;
    ELSE
        -- RESULTADO 1: Dados do cliente
        SELECT
            nome,
            email,
            telefone,
            criado_em AS data_cadastro
        FROM clientes
        WHERE id_cliente = p_id_cliente;
        -- RESULTADO 2: Pedidos do cliente
        SELECT
            id_pedido AS numero_pedido,
            data_pedido,
            status,
            valor_total
        FROM pedidos
        WHERE id_cliente = p_id_cliente
        ORDER BY data_pedido DESC;
        -- RESULTADO 3: Resumo dos pedidos
        SELECT
            COUNT(id_pedido) AS total_pedidos,
            IFNULL(SUM(valor_total), 0) AS valor_total_gasto,
            IFNULL(AVG(valor_total), 0) AS ticket_medio,
            MAX(data_pedido) AS ultimo_pedido
        FROM pedidos
        WHERE id_cliente = p_id_cliente;
    END IF;
END //
DELIMITER ;

CALL consultar_extrato_cliente(1);
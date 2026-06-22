CREATE INDEX CONCURRENTLY idx_pedidos_cliente_id
    ON pedidos(cliente_id);

CREATE INDEX CONCURRENTLY idx_produtos_categoria_preco
    ON produtos(categoria_id, preco);

CREATE INDEX CONCURRENTLY idx_pedidos_criado_em
    ON pedidos(criado_em);

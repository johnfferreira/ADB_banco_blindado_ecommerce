-- ============================================================
-- OPERAÇÃO BANCO BLINDADO
-- Arquivo: 004_create_indexes.sql
-- Descrição: Optimização de performance (Tuning)
-- Universidade de Luanda · Administração de BD · 4º Ano
-- ============================================================

-- ── QUERY LENTA #1: Busca de pedidos por cliente ─────────────
-- Problema: Sequential Scan em toda a tabela pedidos → ~850ms
-- Solução: Índice em cliente_id
-- Resultado: Index Scan → ~2ms
--
-- EXPLAIN ANALYZE
-- SELECT p.*, c.nome FROM pedidos p
-- JOIN clientes c ON c.id = p.cliente_id
-- WHERE p.cliente_id = 42;

CREATE INDEX CONCURRENTLY idx_pedidos_cliente_id
    ON pedidos(cliente_id);


-- ── QUERY LENTA #2: Filtro de produtos por categoria e preço ─
-- Problema: Seq Scan com dois filtros simultâneos → ~400ms
-- Solução: Índice composto (categoria_id + preco)
-- Resultado: Bitmap Index Scan → ~5ms
--
-- EXPLAIN ANALYZE
-- SELECT * FROM produtos
-- WHERE categoria_id = 3 AND preco < 5000;

CREATE INDEX CONCURRENTLY idx_produtos_categoria_preco
    ON produtos(categoria_id, preco);


-- ── QUERY LENTA #3: Relatório mensal de receita ──────────────
-- Problema: Scan em coluna timestamp sem índice → ~1200ms
-- Solução: Índice em criado_em
-- Resultado: Index Scan → ~8ms
--
-- EXPLAIN ANALYZE
-- SELECT DATE_TRUNC('month', criado_em) AS mes, SUM(total) AS receita
-- FROM pedidos
-- WHERE criado_em BETWEEN '2024-01-01' AND '2024-12-31'
-- GROUP BY mes ORDER BY mes;

CREATE INDEX CONCURRENTLY idx_pedidos_criado_em
    ON pedidos(criado_em);


-- ── Verificar todos os índices criados ───────────────────────
-- SELECT indexname, tablename, indexdef
-- FROM pg_indexes
-- WHERE schemaname = 'public'
-- ORDER BY tablename;

-- NOTA: CONCURRENTLY cria o índice sem bloquear a tabela.
-- Essencial em produção para não travar as queries em curso.
-- Não pode ser usado dentro de uma transacção (BEGIN/COMMIT).

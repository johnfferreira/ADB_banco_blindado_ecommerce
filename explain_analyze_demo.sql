-- ============================================================
-- OPERAÇÃO BANCO BLINDADO
-- Arquivo: explain_analyze_demo.sql
-- Descrição: Demonstração do EXPLAIN ANALYZE no projecto
-- Universidade de Luanda · Administração de BD · 4º Ano
--
-- Como usar:
--   docker exec -it banco-blindado psql -U postgres -d ecommerce_db
--   \i /docker-entrypoint-initdb.d/explain_analyze_demo.sql
--
-- Ou copiar e colar cada bloco directamente no psql.
-- ============================================================


-- ════════════════════════════════════════════════════════════
-- O QUE É O EXPLAIN ANALYZE?
-- ════════════════════════════════════════════════════════════
--
--  EXPLAIN          → mostra o PLANO de execução (estimativas)
--  EXPLAIN ANALYZE  → executa a query e mostra tempos REAIS
--
--  Principais termos do output:
--  ┌─────────────────────────────────────────────────────────┐
--  │ Seq Scan       → lê a tabela INTEIRA linha a linha      │
--  │                  (lento em tabelas grandes)             │
--  │ Index Scan     → vai directo ao registo via índice      │
--  │                  (rápido, mesmo em milhões de linhas)   │
--  │ cost=X..Y      │ X = custo de arranque                  │
--  │                │ Y = custo total estimado               │
--  │ actual time    → tempo real em milissegundos            │
--  │ rows           → linhas retornadas                      │
--  │ Planning Time  → tempo para gerar o plano               │
--  │ Execution Time → tempo real de execução                 │
--  └─────────────────────────────────────────────────────────┘


-- ════════════════════════════════════════════════════════════
-- DEMO 1: Seq Scan vs Index Scan (pedidos por cliente)
-- ════════════════════════════════════════════════════════════

-- ANTES do índice: Seq Scan (lê todos os pedidos para encontrar 1)
-- (desactiva temporariamente os índices para simular ausência)
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;

EXPLAIN ANALYZE
SELECT p.id, p.status, p.total, c.nome AS cliente
FROM pedidos p
JOIN clientes c ON c.id = p.cliente_id
WHERE p.cliente_id = 1;

-- Resultado esperado:
--   Seq Scan on pedidos  (cost=... rows=... width=...)
--   actual time=...  rows=2

-- DEPOIS do índice: Index Scan (vai directo ao registo)
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
SELECT p.id, p.status, p.total, c.nome AS cliente
FROM pedidos p
JOIN clientes c ON c.id = p.cliente_id
WHERE p.cliente_id = 1;

-- Resultado esperado:
--   Index Scan using idx_pedidos_cliente_id on pedidos
--   actual time=...  rows=2


-- ════════════════════════════════════════════════════════════
-- DEMO 2: Filtro de produtos por categoria e preço
-- ════════════════════════════════════════════════════════════

EXPLAIN ANALYZE
SELECT id, nome, preco, stock
FROM produtos
WHERE categoria_id = 1
  AND preco < 50000.00;

-- Deve usar: idx_produtos_categoria_preco (índice composto)
-- Nota: com poucos dados o planner pode preferir Seq Scan
--       porque o overhead do índice só compensa com +1000 linhas.


-- ════════════════════════════════════════════════════════════
-- DEMO 3: Relatório de receita mensal (índice em criado_em)
-- ════════════════════════════════════════════════════════════

EXPLAIN ANALYZE
SELECT
    DATE_TRUNC('month', criado_em) AS mes,
    COUNT(*)                       AS total_pedidos,
    SUM(total)                     AS receita_total
FROM pedidos
WHERE criado_em BETWEEN '2024-01-01' AND '2026-12-31'
GROUP BY mes
ORDER BY mes;

-- Deve usar: idx_pedidos_criado_em


-- ════════════════════════════════════════════════════════════
-- DEMO 4: JOIN complexo — relatório completo de pedidos
-- ════════════════════════════════════════════════════════════

EXPLAIN ANALYZE
SELECT
    p.id           AS pedido_id,
    c.nome         AS cliente,
    pr.nome        AS produto,
    ip.quantidade,
    ip.preco_unitario,
    (ip.quantidade * ip.preco_unitario) AS subtotal,
    p.status
FROM pedidos p
JOIN clientes       c  ON c.id  = p.cliente_id
JOIN itens_pedido   ip ON ip.pedido_id = p.id
JOIN produtos       pr ON pr.id = ip.produto_id
WHERE p.status = 'pago'
ORDER BY p.id, pr.nome;

-- Observa o plano de JOIN: Hash Join, Nested Loop, ou Merge Join
-- O planner escolhe automaticamente o mais eficiente


-- ════════════════════════════════════════════════════════════
-- DEMO 5: Busca de cliente por email (coluna UNIQUE)
-- ════════════════════════════════════════════════════════════

EXPLAIN ANALYZE
SELECT id, nome, email
FROM clientes
WHERE email = 'joao@email.com';

-- UNIQUE cria automaticamente um índice → Index Scan garantido
-- Resultado: custo mínimo, 1 linha retornada


-- ════════════════════════════════════════════════════════════
-- CONSULTAR OS ÍNDICES ACTIVOS NO BANCO
-- ════════════════════════════════════════════════════════════

SELECT
    tablename                           AS tabela,
    indexname                           AS indice,
    indexdef                            AS definicao
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

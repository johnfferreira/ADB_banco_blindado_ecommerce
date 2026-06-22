-- ============================================================
-- OPERAÇÃO BANCO BLINDADO
-- Arquivo: 005_import_csv.sql
-- Descrição: Importação de clientes a partir de ficheiro CSV
-- Universidade de Luanda · Administração de BD · 4º Ano
--
-- O comando COPY do PostgreSQL importa dados directamente de um
-- ficheiro CSV para a tabela, sem precisar de INSERT linha por linha.
-- É muito mais eficiente para grandes volumes de dados.
-- ============================================================

-- TRUNCATE TABLE itens_pedido, pedidos, clientes RESTART IDENTITY CASCADE;

COPY clientes (nome, email, telefone)
FROM '/tmp/clientes.csv'
DELIMITER ','
CSV HEADER;

SELECT
    COUNT(*)                    AS total_importado,
    MIN(criado_em)::date        AS primeiro_registo,
    MAX(criado_em)::date        AS ultimo_registo
FROM clientes;

-- ============================================================
-- OPERAÇÃO BANCO BLINDADO
-- Arquivo: 003_create_roles.sql
-- Descrição: Controlo de acessos (RBAC)
-- Universidade de Luanda · Administração de BD · 4º Ano
-- ============================================================

-- ── ROLE: ESTAGIÁRIO (só pode ler) ───────────────────────────
CREATE ROLE role_estagiario;

GRANT CONNECT ON DATABASE ecommerce_db TO role_estagiario;
GRANT USAGE ON SCHEMA public TO role_estagiario;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO role_estagiario;

CREATE USER estagiario_carlos WITH PASSWORD 'Est@2024!';
GRANT role_estagiario TO estagiario_carlos;


-- ── ROLE: SISTEMA / APP (só pode inserir) ────────────────────
-- Utilizado pelo backend da aplicação
-- Não pode ler dados sensíveis nem apagar nada
CREATE ROLE role_sistema;

GRANT CONNECT ON DATABASE ecommerce_db TO role_sistema;
GRANT USAGE ON SCHEMA public TO role_sistema;
GRANT INSERT ON pedidos, itens_pedido, clientes TO role_sistema;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO role_sistema;

CREATE USER app_backend WITH PASSWORD 'Sys#2024!';
GRANT role_sistema TO app_backend;


-- ── ROLE: GERENTE (lê e edita, mas NÃO apaga clientes) ───────
-- Responde à pergunta: "Como evitar que alguém apague clientes
-- acidentalmente em produção?"
CREATE ROLE role_gerente;

GRANT CONNECT ON DATABASE ecommerce_db TO role_gerente;
GRANT USAGE ON SCHEMA public TO role_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO role_gerente;

-- Revogar DELETE especificamente na tabela clientes
-- Mesmo o gerente não consegue apagar clientes
REVOKE DELETE ON clientes FROM role_gerente;

CREATE USER gerente_ana WITH PASSWORD 'Ger@2024!';
GRANT role_gerente TO gerente_ana;

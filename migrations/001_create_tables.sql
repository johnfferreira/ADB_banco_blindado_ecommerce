-- ============================================================
-- OPERAÇÃO BANCO BLINDADO
-- Arquivo: 001_create_tables.sql
-- Descrição: Criação do schema normalizado (3FN)
-- Universidade de Luanda · Administração de BD · 4º Ano
-- ============================================================

-- Tabela de categorias (separada de produtos → 3FN)
CREATE TABLE categorias (
    id    SERIAL PRIMARY KEY,
    nome  VARCHAR(80) NOT NULL UNIQUE
);

-- Tabela de clientes
CREATE TABLE clientes (
    id          SERIAL PRIMARY KEY,
    nome        VARCHAR(100)  NOT NULL,
    email       VARCHAR(150)  NOT NULL UNIQUE,
    telefone    VARCHAR(20),
    -- Senha guardada como hash bcrypt (nunca em texto claro)
    senha_hash  TEXT,
    criado_em   TIMESTAMP     DEFAULT NOW()
);

-- Tabela de produtos
-- DECIMAL(10,2) e não FLOAT → precisão exacta para valores monetários
-- FLOAT usa representação binária: 0.1 + 0.2 ≠ 0.3 (erro de arredondamento)
CREATE TABLE produtos (
    id            SERIAL PRIMARY KEY,
    nome          VARCHAR(150)  NOT NULL,
    preco         DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    stock         INTEGER       NOT NULL DEFAULT 0,
    categoria_id  INTEGER       REFERENCES categorias(id),
    criado_em     TIMESTAMP     DEFAULT NOW()
);

-- Tabela de pedidos
CREATE TABLE pedidos (
    id          SERIAL PRIMARY KEY,
    cliente_id  INTEGER       NOT NULL REFERENCES clientes(id),
    status      VARCHAR(20)   DEFAULT 'pendente'
                CHECK (status IN ('pendente', 'pago', 'cancelado')),
    total       DECIMAL(12,2),
    criado_em   TIMESTAMP     DEFAULT NOW()
);

-- Tabela de itens do pedido (relação N:N entre pedidos e produtos)
CREATE TABLE itens_pedido (
    id             SERIAL PRIMARY KEY,
    pedido_id      INTEGER       NOT NULL REFERENCES pedidos(id),
    produto_id     INTEGER       NOT NULL REFERENCES produtos(id),
    quantidade     INTEGER       NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL
);

-- Extensão para encriptação de senhas com bcrypt
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Tabela de utilizadores do sistema (funcionários)
-- Separada de clientes: um cliente compra, um utilizador opera o sistema
CREATE TABLE utilizadores (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    senha_hash TEXT         NOT NULL, -- bcrypt via pgcrypto
    papel      VARCHAR(20)  NOT NULL DEFAULT 'estagiario'
               CHECK (papel IN ('estagiario', 'gerente', 'sistema')),
    criado_em  TIMESTAMP    DEFAULT NOW()
);

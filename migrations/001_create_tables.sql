CREATE TABLE categorias (
    id    SERIAL PRIMARY KEY,
    nome  VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE clientes (
    id          SERIAL PRIMARY KEY,
    nome        VARCHAR(100)  NOT NULL,
    email       VARCHAR(150)  NOT NULL UNIQUE,
    telefone    VARCHAR(20),
    senha_hash  TEXT,
    criado_em   TIMESTAMP     DEFAULT NOW()
);

CREATE TABLE produtos (
    id            SERIAL PRIMARY KEY,
    nome          VARCHAR(150)  NOT NULL,
    preco         DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    stock         INTEGER       NOT NULL DEFAULT 0,
    categoria_id  INTEGER       REFERENCES categorias(id),
    criado_em     TIMESTAMP     DEFAULT NOW()
);

CREATE TABLE pedidos (
    id          SERIAL PRIMARY KEY,
    cliente_id  INTEGER       NOT NULL REFERENCES clientes(id),
    status      VARCHAR(20)   DEFAULT 'pendente'
                CHECK (status IN ('pendente', 'pago', 'cancelado')),
    total       DECIMAL(12,2),
    criado_em   TIMESTAMP     DEFAULT NOW()
);

CREATE TABLE itens_pedido (
    id             SERIAL PRIMARY KEY,
    pedido_id      INTEGER       NOT NULL REFERENCES pedidos(id),
    produto_id     INTEGER       NOT NULL REFERENCES produtos(id),
    quantidade     INTEGER       NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL
);

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE utilizadores (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    senha_hash TEXT         NOT NULL,
    papel      VARCHAR(20)  NOT NULL DEFAULT 'estagiario'
               CHECK (papel IN ('estagiario', 'gerente', 'sistema')),
    criado_em  TIMESTAMP    DEFAULT NOW()
);

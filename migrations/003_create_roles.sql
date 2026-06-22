CREATE ROLE role_estagiario;

GRANT CONNECT ON DATABASE ecommerce_db TO role_estagiario;
GRANT USAGE ON SCHEMA public TO role_estagiario;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO role_estagiario;

CREATE USER estagiario_carlos WITH PASSWORD 'Est@2024!';
GRANT role_estagiario TO estagiario_carlos;


CREATE ROLE role_sistema;

GRANT CONNECT ON DATABASE ecommerce_db TO role_sistema;
GRANT USAGE ON SCHEMA public TO role_sistema;
GRANT INSERT ON pedidos, itens_pedido, clientes TO role_sistema;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO role_sistema;

CREATE USER app_backend WITH PASSWORD 'Sys#2024!';
GRANT role_sistema TO app_backend;


CREATE ROLE role_gerente;

GRANT CONNECT ON DATABASE ecommerce_db TO role_gerente;
GRANT USAGE ON SCHEMA public TO role_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO role_gerente;

REVOKE DELETE ON clientes FROM role_gerente;

CREATE USER gerente_ana WITH PASSWORD 'Ger@2024!';
GRANT role_gerente TO gerente_ana;

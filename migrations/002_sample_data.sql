-- ============================================================
-- OPERAÇÃO BANCO BLINDADO
-- Arquivo: 002_sample_data.sql
-- Descrição: Dados de teste para simular o e-commerce
-- Universidade de Luanda · Administração de BD · 4º Ano
-- ============================================================

-- Utilizadores do sistema (funcionários que operam o e-commerce)
-- Separados dos clientes: cliente compra, utilizador opera o sistema
INSERT INTO utilizadores (nome, email, senha_hash, papel) VALUES
    ('Carlos Estagiário', 'carlos@ecommerce.ao', crypt('Est@2024!', gen_salt('bf')), 'estagiario'),
    ('Ana Gerente',       'ana@ecommerce.ao',    crypt('Ger@2024!', gen_salt('bf')), 'gerente'),
    ('App Backend',       'app@ecommerce.ao',    crypt('Sys@2024!', gen_salt('bf')), 'sistema');

-- Categorias
INSERT INTO categorias (nome) VALUES
    ('Electrónica'),
    ('Roupas'),
    ('Alimentação'),
    ('Informática'),
    ('Electrodomésticos');

-- Clientes (senha guardada com hash bcrypt via pgcrypto)
INSERT INTO clientes (nome, email, telefone, senha_hash) VALUES
    ('João Silva Junior',   'joao.junior@email.com',  '+244 923 000 001', crypt('senha123', gen_salt('bf'))),
    ('Maria Costa Junior',  'maria.junior@email.com', '+244 923 000 002', crypt('senha456', gen_salt('bf'))),
    ('Pedro Lopes Junior',  'pedro.junior@email.com', '+244 923 000 003', crypt('senha789', gen_salt('bf'))),
    ('Ana Ferreira Junior', 'ana.junior@email.com',   '+244 923 000 004', crypt('senhaAna', gen_salt('bf'))),
    ('Carlos Matos Junior', 'carlos.junior@email.com','+244 923 000 005', crypt('senhaCar', gen_salt('bf')));

-- Produtos
INSERT INTO produtos (nome, preco, stock, categoria_id) VALUES
    ('Smartphone Samsung A15',  45000.00, 30, 1),
    ('Auriculares Bluetooth',    8500.00, 50, 1),
    ('Camisa Social Branca',     3200.00, 100, 2),
    ('Calças Jeans',             5500.00, 80, 2),
    ('Arroz 5kg',                1800.00, 200, 3),
    ('Azeite 1L',                2400.00, 150, 3),
    ('Laptop Lenovo',           150000.00, 15, 4),
    ('Rato sem fio',             4500.00, 60, 4),
    ('Frigorífico 300L',        120000.00, 10, 5),
    ('Microondas 20L',           35000.00, 25, 5);

-- Pedidos
INSERT INTO pedidos (cliente_id, status, total) VALUES
    (1, 'pago',      53500.00),
    (2, 'pago',      5500.00),
    (3, 'pendente',  154500.00),
    (1, 'cancelado', 8500.00),
    (4, 'pago',      5000.00);

-- Itens dos pedidos
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
    (1, 1, 1, 45000.00),   -- João comprou Samsung
    (1, 2, 1,  8500.00),   -- João comprou auriculares
    (2, 4, 1,  5500.00),   -- Maria comprou calças
    (3, 7, 1, 150000.00),  -- Pedro comprou laptop
    (3, 8, 1,   4500.00),  -- Pedro comprou rato
    (4, 2, 1,   8500.00),  -- João (cancelado)
    (5, 3, 1,   3200.00),  -- Ana comprou camisa
    (5, 5, 1,   1800.00);  -- Ana comprou arroz

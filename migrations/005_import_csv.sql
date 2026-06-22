COPY clientes (nome, email, telefone)
FROM '/tmp/clientes.csv'
DELIMITER ','
CSV HEADER;

DO $$
DECLARE
    r RECORD;
    senha_temp TEXT;
BEGIN
    FOR r IN
        SELECT id, email
        FROM clientes
        WHERE senha_hash IS NULL
    LOOP
        senha_temp := split_part(r.email, '@', 1) || '@Temp2024!';

        UPDATE clientes
        SET senha_hash = crypt(senha_temp, gen_salt('bf'))
        WHERE id = r.id;

        RAISE NOTICE 'Cliente id=% → senha temporária gerada: %', r.id, senha_temp;
    END LOOP;
END $$;

SELECT
    id,
    nome,
    email,
    CASE
        WHEN senha_hash IS NOT NULL THEN '✓ hash gerado'
        ELSE '✗ sem senha'
    END                         AS senha_estado,
    COUNT(*) OVER ()            AS total_importado
FROM clientes
ORDER BY id;

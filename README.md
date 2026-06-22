# Operação Banco Blindado
**Administração de Banco de Dados**  
Universidade de Luanda · INSTIC · 4º Ano

---

## Cenário

E-commerce angolano com crescimento acelerado. Sistema legado sem backup automatizado, sem controlo de acessos e com performance degradada em horários de pico. Missão: reestruturar o ambiente completamente.

---

## Estrutura do Projecto

```
operacao-banco-blindado/
├── migrations/
│   ├── 001_create_tables.sql   → Schema normalizado em 3FN
│   ├── 002_sample_data.sql     → Dados de teste
│   ├── 003_create_roles.sql    → Controlo de acessos (RBAC)
│   ├── 004_create_indexes.sql  → Índices para optimização
│   └── 005_import_csv.sql      → Importação de clientes via CSV (COPY)
├── backup/
│   ├── backup.sh               → Script de backup automático
│   └── restore.sh              → Script de restauro
├── clientes.csv                → Dados brutos de clientes para importação
├── explain_analyze_demo.sql    → Demonstração de análise de performance
├── docker-compose.yml          → Ambiente local com PostgreSQL 16
└── README.md
```

---

## EXPLAIN ANALYZE — Análise de Performance

O `EXPLAIN ANALYZE` executa a query e mostra o plano real de execução, com tempos e número de linhas.

```bash
# Entrar no psql
docker exec -it banco-blindado psql -U postgres -d ecommerce_db
```

```sql
-- Seq Scan (sem índice): lê a tabela inteira
EXPLAIN ANALYZE
SELECT * FROM pedidos WHERE cliente_id = 1;

-- Index Scan (com índice): vai directo ao registo
-- (após criar o índice em 004_create_indexes.sql)
EXPLAIN ANALYZE
SELECT p.*, c.nome FROM pedidos p
JOIN clientes c ON c.id = p.cliente_id
WHERE p.cliente_id = 1;
```

Ver o ficheiro [explain_analyze_demo.sql](./explain_analyze_demo.sql) para 5 demos completos com todos os índices do projecto.

---

## Como Executar

### 1. Subir o banco com Docker

```bash
docker compose up -d
```

O Docker vai criar o banco `ecommerce_db` e executar automaticamente todos os ficheiros de `migrations/` por ordem alfabética.
OBS: O postgrelSQL vai rodar na porta 5432, caso tenha um outro servico a rodar nessa porta, troca a porta ou mate o processo demomento

### 2. Verificar se as tabelas foram criadas

```bash
docker exec -it banco-blindado psql -U postgres -d ecommerce_db
\dt
```

### 3. Importar dados do CSV manualmente

Se o container já estava a correr antes de adicionar o ficheiro CSV, podes importar manualmente:

```bash
# Entrar no container
docker exec -it banco-blindado psql -U postgres -d ecommerce_db

# Dentro do psql, executar:
\COPY clientes (nome, email, telefone) FROM '/tmp/clientes.csv' DELIMITER ',' CSV HEADER;

# Verificar os registos importados
SELECT id, nome, email, telefone FROM clientes;
```

> **Nota:** O `\COPY` (com barra invertida) é o comando do cliente psql e lê o ficheiro do lado do *cliente*. O `COPY` (sem barra) lê do lado do *servidor* — ambos funcionam aqui porque o volume mapeia o ficheiro directamente.

---

### 4. Fazer backup manual (com Docker)

```bash
docker exec banco-blindado pg_dump -U postgres ecommerce_db \
  | gzip > ./backup/backups/backup_manual.sql.gz
```

### 4. Restaurar backup

```bash
cd backup
./restore.sh backups/backup_manual.sql.gz
```

---

## Decisões Técnicas

| Decisão | Escolha | Motivo |
|---|---|---|
| Tipo para preços | `DECIMAL(10,2)` | FLOAT tem erros de arredondamento binário. Em contexto financeiro, 0.1 + 0.2 ≠ 0.3 |
| Hash de senhas | `bcrypt (pgcrypto)` | Irreversível. Mesmo com dump completo, senhas não são expostas |
| Índices | `CONCURRENTLY` | Não bloqueia a tabela durante criação. Seguro em produção |
| Controlo de acesso | `RBAC com REVOKE` | Estagiário só lê, sistema só insere, gerente não apaga clientes |
| Backup | `pg_dump + gzip` | Dump comprimido com verificação de integridade via `gzip -t` |

---

## Perguntas da Defesa

**Como evitas que um developer apague clientes em produção?**  
RBAC com `REVOKE DELETE ON clientes FROM role_gerente`. Só o superuser DBA pode apagar.

**Qual é o RTO?**  
Menos de 10 minutos. Backup diário às 02h00. Restore via `restore.sh`.

**Como verificas que o backup não está corrompido?**  
O script executa `gzip -t` após cada dump e regista o resultado no log.

**Por que DECIMAL e não FLOAT?**  
FLOAT é representação binária — imprecisa para valores monetários. DECIMAL é exacto.

**Quais foram as 3 queries mais lentas?**  
"Com os dados de teste o tempo foi 0.683ms porque temos poucos registos. O problema real aparece em produção com volume alto, o Seq Scan lê a tabela inteira linha a linha, enquanto o Index Scan vai directo ao registo. Criei o índice para garantir essa escalabilidade.`cliente_id`, `(categoria_id, preco)` e `criado_em`.

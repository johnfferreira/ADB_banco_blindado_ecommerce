#!/bin/bash
# ============================================================
# OPERAÇÃO BANCO BLINDADO
# Arquivo: backup/restore.sh
# Descrição: Restaurar banco a partir de um backup
# Universidade de Luanda · Administração de BD · 4º Ano
#
# Uso: ./restore.sh backups/backup_2024-01-15_0200.sql.gz
# ============================================================

DB_NAME="ecommerce_db"
DB_USER="postgres"
BACKUP_FILE=$1
BD_REF=banco-blindado
# Verificar se o ficheiro foi passado como argumento
if [ -z "$BACKUP_FILE" ]; then
    echo "✗ Erro: indica o ficheiro de backup."
    echo "  Uso: ./restore.sh backups/backup_YYYY-MM-DD_HHMM.sql.gz"
    exit 1
fi

# Verificar se o ficheiro existe
if [ ! -f "$BACKUP_FILE" ]; then
    echo "✗ Erro: ficheiro '$BACKUP_FILE' não encontrado."
    exit 1
fi

echo "→ Iniciando restauro a partir de: $BACKUP_FILE"
echo "→ Atenção: o banco '$DB_NAME' será recriado do zero."
read -p "   Confirmas? (s/N): " CONFIRM

if [ "$CONFIRM" != "s" ]; then
    echo "Operação cancelada."
    exit 0
fi

# 1. Apagar o banco actual
echo "→ Removendo banco existente..."
# psql -U "$DB_USER" -c "DROP DATABASE IF EXISTS $DB_NAME;"
docker exec "$BD_REF" psql -U "$DB_USER" -c "DROP DATABASE IF EXISTS $DB_NAME;"

# 2. Recriar o banco vazio
echo "→ Criando banco vazio..."
# psql -U "$DB_USER" -c "CREATE DATABASE $DB_NAME;"
docker exec "$BD_REF" psql -U "$DB_USER" -c "CREATE DATABASE $DB_NAME;"

# 3. Descomprimir e restaurar
echo "→ Restaurando dados..."
# gunzip -c "$BACKUP_FILE" | psql -U "$DB_USER" -d "$DB_NAME"
gunzip -c "$BACKUP_FILE" | docker exec -i banco-blindado psql -U "$DB_USER" -d "$DB_NAME"

if [ $? -eq 0 ]; then
    echo "✓ Restauro concluído com sucesso!"
    echo "  RTO atingido — banco operacional."
else
    echo "✗ Erro durante o restauro. Verifica o ficheiro de backup."
    exit 1
fi

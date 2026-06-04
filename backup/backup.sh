#!/bin/bash
# ============================================================
# OPERAÇÃO BANCO BLINDADO
# Arquivo: backup/backup.sh
# Descrição: Backup automático diário do PostgreSQL
# Universidade de Luanda · Administração de BD · 4º Ano
#
# Agendar via cron (todos os dias às 02:00):
#   crontab -e
#   0 2 * * * /bin/bash /caminho/backup/backup.sh
# ============================================================

# ── Configuração ─────────────────────────────────────────────
DB_NAME="ecommerce_db"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"
BACKUP_DIR="./backups"
DATE=$(date +"%Y-%m-%d_%H%M")
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql.gz"
LOG_FILE="$BACKUP_DIR/backup.log"
RETENTION_DAYS=7
BD_REF=banco-blindado

# ── Criar directório se não existir ──────────────────────────
mkdir -p "$BACKUP_DIR"

echo "[$DATE] Iniciando backup do banco '$DB_NAME'..." >> "$LOG_FILE"

# pg_dump -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" \
#     | gzip > "$BACKUP_FILE"

docker exec "$BD_REF" pg_dump -U "$DB_USER" -d "$DB_NAME" \
     | gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
    echo "[$DATE] ✓ Backup criado: $BACKUP_FILE ($SIZE)" >> "$LOG_FILE"

    gzip -t "$BACKUP_FILE"
    if [ $? -eq 0 ]; then
        echo "[$DATE] ✓ Integridade verificada com sucesso" >> "$LOG_FILE"
    else
        echo "[$DATE] ✗ ERRO: ficheiro de backup corrompido!" >> "$LOG_FILE"
        exit 1
    fi
else
    echo "[$DATE] ✗ ERRO: falha ao criar o backup!" >> "$LOG_FILE"
    exit 1
fi

find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
echo "[$DATE] Backups com mais de $RETENTION_DAYS dias removidos." >> "$LOG_FILE"

echo "[$DATE] Backup concluído." >> "$LOG_FILE"

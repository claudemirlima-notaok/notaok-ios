#!/bin/bash
BACKUP_DIR="$HOME/.notaok_backups"
PROJECT_DIR="$HOME/Downloads/notaok-ios"
LOG_FILE="$BACKUP_DIR/change_log.txt"
mkdir -p "$BACKUP_DIR"

create_backup() {
    local file_path="$1"
    local description="$2"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local filename=$(basename "$file_path")
    local backup_name="${filename}_${timestamp}.backup"
    cp "$file_path" "$BACKUP_DIR/$backup_name"
    echo "════════════════════════════════════════" >> "$LOG_FILE"
    echo "🕒 $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "📁 $file_path" >> "$LOG_FILE"
    echo "💾 $backup_name" >> "$LOG_FILE"
    echo "📝 $description" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "✅ Backup: $backup_name"
}

verify_file() {
    local file_path="$1"
    echo "🔍 VERIFICANDO: $file_path"
    local lines=$(wc -l < "$file_path")
    local open=$(grep -o '{' "$file_path" | wc -l)
    local close=$(grep -o '}' "$file_path" | wc -l)
    echo "📏 Linhas: $lines | 🔓 {: $open | 🔒 }: $close"
    [ $open -eq $close ] && echo "✅ Chaves OK!" || echo "❌ ERRO: Desbalanceado!"
}

export -f create_backup verify_file
echo "✅ Sistema carregado!"

#!/bin/bash

# 🔧 SCRIPT DE CORREÇÃO AUTOMÁTICA - Google Login
# Configura URL Scheme e verifica GoogleService-Info.plist

echo "🔧 CONFIGURAÇÃO AUTOMÁTICA - GOOGLE LOGIN"
echo "=========================================="
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variáveis
PROJECT_PATH="$HOME/Downloads/notaok-ios"
GOOGLE_SERVICE_FILE="$PROJECT_PATH/ios/Runner/GoogleService-Info.plist"
INFO_PLIST="$PROJECT_PATH/ios/Runner/Info.plist"

# Verificar se projeto existe
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}❌ Projeto não encontrado em: $PROJECT_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Projeto encontrado${NC}"
echo ""

# ============================================
# 1. VERIFICAR GoogleService-Info.plist
# ============================================
echo "1️⃣  Verificando GoogleService-Info.plist..."
echo ""

if [ ! -f "$GOOGLE_SERVICE_FILE" ]; then
    echo -e "${RED}❌ GoogleService-Info.plist não encontrado${NC}"
    echo ""
    echo "🔧 AÇÃO NECESSÁRIA:"
    echo "   1. Abrir Firebase Console:"
    echo "      https://console.firebase.google.com/project/notaok-4d791"
    echo "   2. Project Settings → Your apps → iOS app"
    echo "   3. Clicar em 'GoogleService-Info.plist' para baixar"
    echo "   4. Mover arquivo para: $PROJECT_PATH/ios/Runner/"
    echo ""
    echo "Após fazer isso, execute este script novamente."
    exit 1
fi

echo -e "${GREEN}✅ GoogleService-Info.plist encontrado${NC}"
echo ""

# Extrair REVERSED_CLIENT_ID
REVERSED_CLIENT_ID=$(grep -A 1 "REVERSED_CLIENT_ID" "$GOOGLE_SERVICE_FILE" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>/\1/')

if [ -z "$REVERSED_CLIENT_ID" ]; then
    echo -e "${RED}❌ REVERSED_CLIENT_ID não encontrado no GoogleService-Info.plist${NC}"
    exit 1
fi

echo "📋 REVERSED_CLIENT_ID encontrado:"
echo "   $REVERSED_CLIENT_ID"
echo ""

# ============================================
# 2. VERIFICAR SE URL SCHEME JÁ EXISTE
# ============================================
echo "2️⃣  Verificando URL Scheme no Info.plist..."
echo ""

if grep -q "$REVERSED_CLIENT_ID" "$INFO_PLIST"; then
    echo -e "${GREEN}✅ URL Scheme já está configurado corretamente!${NC}"
    echo ""
    echo "🎉 GOOGLE LOGIN JÁ ESTÁ CONFIGURADO!"
    echo ""
    echo "Você pode testar agora:"
    echo "1. Build & Run no Xcode (Cmd + R)"
    echo "2. Clicar em 'Continuar com Google'"
    echo "3. Deve abrir tela de seleção de conta Google"
    echo ""
    exit 0
fi

echo -e "${YELLOW}⚠️  URL Scheme não encontrado no Info.plist${NC}"
echo ""

# ============================================
# 3. FAZER BACKUP DO Info.plist
# ============================================
echo "3️⃣  Criando backup do Info.plist..."
echo ""

BACKUP_FILE="$INFO_PLIST.backup.$(date +%Y%m%d_%H%M%S)"
cp "$INFO_PLIST" "$BACKUP_FILE"
echo -e "${GREEN}✅ Backup criado: $(basename $BACKUP_FILE)${NC}"
echo ""

# ============================================
# 4. ADICIONAR URL SCHEME AO Info.plist
# ============================================
echo "4️⃣  Adicionando URL Scheme ao Info.plist..."
echo ""

# Verificar se CFBundleURLTypes já existe
if grep -q "CFBundleURLTypes" "$INFO_PLIST"; then
    echo -e "${YELLOW}⚠️  CFBundleURLTypes já existe${NC}"
    echo ""
    echo "🔧 AÇÃO MANUAL NECESSÁRIA:"
    echo "   1. Abrir Xcode"
    echo "   2. Selecionar Runner → Target Runner → Info"
    echo "   3. Expandir 'URL Types'"
    echo "   4. Clicar no '+' para adicionar novo"
    echo "   5. URL Schemes: $REVERSED_CLIENT_ID"
    echo "   6. Identifier: com.googleusercontent.apps"
    echo ""
    echo "Ou editar manualmente o arquivo:"
    echo "   $INFO_PLIST"
    echo ""
    echo "Adicionar dentro de <dict>:"
    echo "   <key>CFBundleURLSchemes</key>"
    echo "   <array>"
    echo "     <string>$REVERSED_CLIENT_ID</string>"
    echo "   </array>"
    exit 1
fi

# Adicionar CFBundleURLTypes antes da tag </dict> final
echo "   Adicionando CFBundleURLTypes..."

# Criar XML para inserir
URL_TYPES_XML="	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>$REVERSED_CLIENT_ID</string>
			</array>
		</dict>
	</array>"

# Inserir antes da última linha (</dict>)
# Usar perl para fazer a inserção
perl -i -pe "s|</dict>\s*\n</plist>|$URL_TYPES_XML\n</dict>\n</plist>|" "$INFO_PLIST"

if grep -q "$REVERSED_CLIENT_ID" "$INFO_PLIST"; then
    echo -e "${GREEN}✅ URL Scheme adicionado com sucesso!${NC}"
else
    echo -e "${RED}❌ Falha ao adicionar URL Scheme${NC}"
    echo ""
    echo "Restaurando backup..."
    cp "$BACKUP_FILE" "$INFO_PLIST"
    echo ""
    echo "🔧 AÇÃO MANUAL NECESSÁRIA:"
    echo "   Adicione manualmente no Xcode conforme instruções acima."
    exit 1
fi

echo ""

# ============================================
# 5. VERIFICAR RESULTADO
# ============================================
echo "5️⃣  Verificando configuração..."
echo ""

if grep -q "$REVERSED_CLIENT_ID" "$INFO_PLIST" && grep -q "CFBundleURLTypes" "$INFO_PLIST"; then
    echo -e "${GREEN}✅ CONFIGURAÇÃO CONCLUÍDA COM SUCESSO!${NC}"
    echo ""
    echo "🎉 Google Login está configurado!"
    echo ""
    echo "📋 PRÓXIMOS PASSOS:"
    echo "   1. Abrir Xcode"
    echo "   2. Clean Build Folder (Shift + Cmd + K)"
    echo "   3. Build & Run (Cmd + R)"
    echo "   4. Testar botão 'Continuar com Google'"
    echo ""
    echo "Backup do arquivo original salvo em:"
    echo "   $(basename $BACKUP_FILE)"
    echo ""
else
    echo -e "${RED}❌ Algo deu errado${NC}"
    echo ""
    echo "Restaurando backup..."
    cp "$BACKUP_FILE" "$INFO_PLIST"
    echo ""
    echo "Execute o diagnóstico novamente:"
    echo "   bash diagnostico_firebase_ios.sh"
    exit 1
fi

echo "✅ Script concluído!"
echo ""

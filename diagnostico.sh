#!/bin/bash

# 🔍 SCRIPT DE DIAGNÓSTICO COMPLETO - NotaOK iOS
# Verifica configuração Firebase, OAuth clients, e identifica problemas

echo "🔍 DIAGNÓSTICO COMPLETO DO PROJETO NotaOK iOS"
echo "=============================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variáveis
PROJECT_PATH="$HOME/Downloads/notaok-ios"
GOOGLE_SERVICE_FILE="$PROJECT_PATH/ios/Runner/GoogleService-Info.plist"
INFO_PLIST="$PROJECT_PATH/ios/Runner/Info.plist"
ENTITLEMENTS="$PROJECT_PATH/ios/Runner/Runner.entitlements"

echo "📁 Verificando estrutura do projeto..."
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
echo "-------------------------------------------"

if [ ! -f "$GOOGLE_SERVICE_FILE" ]; then
    echo -e "${RED}❌ GoogleService-Info.plist NÃO ENCONTRADO${NC}"
    echo "   Localização esperada: $GOOGLE_SERVICE_FILE"
    exit 1
else
    echo -e "${GREEN}✅ GoogleService-Info.plist encontrado${NC}"
fi

# Extrair informações importantes
echo ""
echo "📊 Informações do arquivo:"

PROJECT_ID=$(grep -A 1 "PROJECT_ID" "$GOOGLE_SERVICE_FILE" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>/\1/')
BUNDLE_ID=$(grep -A 1 "BUNDLE_ID" "$GOOGLE_SERVICE_FILE" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>/\1/')
REVERSED_CLIENT_ID=$(grep -A 1 "REVERSED_CLIENT_ID" "$GOOGLE_SERVICE_FILE" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>/\1/')
CLIENT_ID=$(grep -A 1 "CLIENT_ID" "$GOOGLE_SERVICE_FILE" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>/\1/')

echo "   Project ID: $PROJECT_ID"
echo "   Bundle ID: $BUNDLE_ID"
echo "   Client ID: ${CLIENT_ID:0:30}..."
echo "   Reversed Client ID: $REVERSED_CLIENT_ID"
echo ""

# ============================================
# 2. VERIFICAR URL SCHEMES (Google Login)
# ============================================
echo "2️⃣  Verificando URL Schemes para Google Login..."
echo "------------------------------------------------"

if grep -q "$REVERSED_CLIENT_ID" "$INFO_PLIST"; then
    echo -e "${GREEN}✅ URL Scheme configurado corretamente${NC}"
    echo "   Scheme: $REVERSED_CLIENT_ID"
else
    echo -e "${YELLOW}⚠️  URL Scheme NÃO configurado${NC}"
    echo ""
    echo "🔧 CORREÇÃO NECESSÁRIA:"
    echo "   Adicionar ao Info.plist:"
    echo "   <key>CFBundleURLTypes</key>"
    echo "   <array>"
    echo "     <dict>"
    echo "       <key>CFBundleURLSchemes</key>"
    echo "       <array>"
    echo "         <string>$REVERSED_CLIENT_ID</string>"
    echo "       </array>"
    echo "     </dict>"
    echo "   </array>"
fi
echo ""

# ============================================
# 3. VERIFICAR SIGN IN WITH APPLE
# ============================================
echo "3️⃣  Verificando Sign in with Apple..."
echo "--------------------------------------"

if [ -f "$ENTITLEMENTS" ]; then
    echo -e "${GREEN}✅ Runner.entitlements encontrado${NC}"
    
    if grep -q "com.apple.developer.applesignin" "$ENTITLEMENTS"; then
        echo -e "${GREEN}✅ Sign in with Apple capability configurado${NC}"
    else
        echo -e "${YELLOW}⚠️  Sign in with Apple NÃO configurado no entitlements${NC}"
        echo ""
        echo "🔧 CORREÇÃO NECESSÁRIA:"
        echo "   No Xcode:"
        echo "   1. Selecionar Target 'Runner'"
        echo "   2. Aba 'Signing & Capabilities'"
        echo "   3. Clicar no '+' e adicionar 'Sign In with Apple'"
    fi
else
    echo -e "${YELLOW}⚠️  Runner.entitlements NÃO ENCONTRADO${NC}"
    echo "   Isso indica que Sign in with Apple não está configurado"
    echo ""
    echo "🔧 CORREÇÃO NECESSÁRIA:"
    echo "   No Xcode:"
    echo "   1. Selecionar Target 'Runner'"
    echo "   2. Aba 'Signing & Capabilities'"
    echo "   3. Clicar no '+' e adicionar 'Sign In with Apple'"
fi
echo ""

# ============================================
# 4. VERIFICAR FIREBASE AUTH CONFIGURADO
# ============================================
echo "4️⃣  Verificando configuração Firebase no código..."
echo "---------------------------------------------------"

MAIN_DART="$PROJECT_PATH/lib/main.dart"
AUTH_SERVICE="$PROJECT_PATH/lib/services/auth_service.dart"
LOGIN_SCREEN="$PROJECT_PATH/lib/screens/login_screen.dart"

# Verificar flag de inicialização
if grep -q "_firebaseInitialized" "$MAIN_DART"; then
    echo -e "${GREEN}✅ Proteção contra inicialização duplicada implementada${NC}"
else
    echo -e "${RED}❌ Flag _firebaseInitialized NÃO encontrada${NC}"
fi

# Verificar botão visitante removido
if grep -q "signInAnonymously" "$LOGIN_SCREEN"; then
    echo -e "${RED}❌ Botão 'Entrar como Visitante' ainda existe${NC}"
else
    echo -e "${GREEN}✅ Botão 'Entrar como Visitante' removido${NC}"
fi

# Verificar recuperação de senha
if grep -q "mostrarDialogRecuperarSenha" "$LOGIN_SCREEN"; then
    echo -e "${GREEN}✅ Recuperação de senha implementada${NC}"
else
    echo -e "${RED}❌ Recuperação de senha NÃO implementada${NC}"
fi
echo ""

# ============================================
# 5. VERIFICAR DEPENDÊNCIAS
# ============================================
echo "5️⃣  Verificando dependências do pubspec.yaml..."
echo "------------------------------------------------"

PUBSPEC="$PROJECT_PATH/pubspec.yaml"

check_dependency() {
    local dep=$1
    if grep -q "^  $dep:" "$PUBSPEC"; then
        local version=$(grep "^  $dep:" "$PUBSPEC" | awk '{print $2}')
        echo -e "${GREEN}✅ $dep: $version${NC}"
    else
        echo -e "${RED}❌ $dep não encontrado${NC}"
    fi
}

check_dependency "firebase_core"
check_dependency "firebase_auth"
check_dependency "google_sign_in"
check_dependency "sign_in_with_apple"
check_dependency "cloud_firestore"
echo ""

# ============================================
# 6. GERAR RELATÓRIO DE PROBLEMAS
# ============================================
echo "6️⃣  Gerando relatório de problemas..."
echo "--------------------------------------"

PROBLEMS=0

echo "" > /tmp/notaok_problems.txt

# Verificar OAuth client type
if [[ "$CLIENT_ID" == *".apps.googleusercontent.com" ]]; then
    if [[ "$CLIENT_ID" == *"web"* ]] || [[ "$CLIENT_ID" == *"WEB"* ]]; then
        echo -e "${RED}❌ PROBLEMA: OAuth Client Type é WEB (deveria ser iOS)${NC}"
        echo "PROBLEMA: OAuth Client Type é WEB (deveria ser iOS)" >> /tmp/notaok_problems.txt
        echo "SOLUÇÃO: Baixar novo GoogleService-Info.plist do Firebase Console" >> /tmp/notaok_problems.txt
        PROBLEMS=$((PROBLEMS+1))
    else
        echo -e "${GREEN}✅ OAuth Client Type parece correto (iOS)${NC}"
    fi
fi

# Verificar URL Scheme
if ! grep -q "$REVERSED_CLIENT_ID" "$INFO_PLIST"; then
    echo -e "${RED}❌ PROBLEMA: URL Scheme não configurado para Google Login${NC}"
    echo "PROBLEMA: URL Scheme não configurado" >> /tmp/notaok_problems.txt
    echo "SOLUÇÃO: Adicionar $REVERSED_CLIENT_ID ao Info.plist" >> /tmp/notaok_problems.txt
    PROBLEMS=$((PROBLEMS+1))
fi

# Verificar Apple Sign In
if [ ! -f "$ENTITLEMENTS" ] || ! grep -q "com.apple.developer.applesignin" "$ENTITLEMENTS"; then
    echo -e "${RED}❌ PROBLEMA: Sign in with Apple não configurado${NC}"
    echo "PROBLEMA: Sign in with Apple não configurado" >> /tmp/notaok_problems.txt
    echo "SOLUÇÃO: Adicionar capability no Xcode" >> /tmp/notaok_problems.txt
    PROBLEMS=$((PROBLEMS+1))
fi

echo ""

# ============================================
# 7. RESUMO FINAL
# ============================================
echo "================================"
echo "📊 RESUMO DO DIAGNÓSTICO"
echo "================================"
echo ""

if [ $PROBLEMS -eq 0 ]; then
    echo -e "${GREEN}🎉 NENHUM PROBLEMA CRÍTICO ENCONTRADO!${NC}"
    echo ""
    echo "✅ Configuração parece estar correta"
    echo "✅ Você pode testar Google e Apple login"
else
    echo -e "${YELLOW}⚠️  $PROBLEMS PROBLEMA(S) ENCONTRADO(S)${NC}"
    echo ""
    echo "📋 Relatório de problemas salvo em: /tmp/notaok_problems.txt"
    echo ""
    echo "Conteúdo:"
    cat /tmp/notaok_problems.txt
fi

echo ""
echo "================================"
echo "🔗 LINKS ÚTEIS"
echo "================================"
echo ""
echo "Firebase Console:"
echo "https://console.firebase.google.com/project/$PROJECT_ID"
echo ""
echo "Firebase Authentication:"
echo "https://console.firebase.google.com/project/$PROJECT_ID/authentication"
echo ""
echo "Apple Developer:"
echo "https://developer.apple.com/account/"
echo ""

echo "✅ Diagnóstico concluído!"
echo ""

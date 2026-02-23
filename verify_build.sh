#!/bin/bash

# 🔍 VERIFICAÇÃO FINAL - Apple Login
# Verifica TUDO antes do build para evitar perda de tempo

echo "🔍 VERIFICAÇÃO FINAL - APPLE LOGIN"
echo "=================================="
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_PATH="$HOME/Downloads/notaok-ios"
PBXPROJ="$PROJECT_PATH/ios/Runner.xcodeproj/project.pbxproj"
ENTITLEMENTS="$PROJECT_PATH/ios/Runner/Runner.entitlements"
INFO_PLIST="$PROJECT_PATH/ios/Runner/Info.plist"

cd "$PROJECT_PATH" || exit 1

PROBLEMS=0
WARNINGS=0

echo "📋 CHECKLIST DE VERIFICAÇÃO"
echo "----------------------------"
echo ""

# ============================================
# 1. VERIFICAR GOOGLE LOGIN
# ============================================
echo "1️⃣  Google Login Configuration"
echo ""

# GoogleService-Info.plist
if grep -q "REVERSED_CLIENT_ID" ios/Runner/GoogleService-Info.plist 2>/dev/null; then
    REVERSED_ID=$(grep -A 1 "REVERSED_CLIENT_ID" ios/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>/\1/')
    echo -e "${GREEN}✅ GoogleService-Info.plist: OK${NC}"
    echo "   REVERSED_CLIENT_ID: ${REVERSED_ID:0:40}..."
else
    echo -e "${RED}❌ GoogleService-Info.plist: REVERSED_CLIENT_ID MISSING${NC}"
    PROBLEMS=$((PROBLEMS+1))
fi

# URL Scheme
if grep -q "$REVERSED_ID" ios/Runner/Info.plist 2>/dev/null; then
    echo -e "${GREEN}✅ URL Scheme: Configured${NC}"
else
    echo -e "${RED}❌ URL Scheme: NOT configured${NC}"
    PROBLEMS=$((PROBLEMS+1))
fi

echo ""

# ============================================
# 2. VERIFICAR APPLE LOGIN
# ============================================
echo "2️⃣  Apple Login Configuration"
echo ""

# Runner.entitlements existe
if [ -f "$ENTITLEMENTS" ]; then
    echo -e "${GREEN}✅ Runner.entitlements: Exists${NC}"
    
    # Verificar Sign in with Apple
    if grep -q "com.apple.developer.applesignin" "$ENTITLEMENTS"; then
        echo -e "${GREEN}✅ Sign in with Apple: Configured in entitlements${NC}"
    else
        echo -e "${RED}❌ Sign in with Apple: NOT in entitlements${NC}"
        PROBLEMS=$((PROBLEMS+1))
    fi
else
    echo -e "${RED}❌ Runner.entitlements: NOT FOUND${NC}"
    PROBLEMS=$((PROBLEMS+1))
fi

# Verificar referência no projeto
if grep -q "CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements" "$PBXPROJ"; then
    echo -e "${GREEN}✅ Entitlements: Referenced in Xcode project${NC}"
else
    echo -e "${RED}❌ Entitlements: NOT referenced in project${NC}"
    PROBLEMS=$((PROBLEMS+1))
fi

echo ""

# ============================================
# 3. VERIFICAR BUNDLE ID
# ============================================
echo "3️⃣  Bundle Identifier"
echo ""

# Extrair Bundle ID do Info.plist
BUNDLE_ID=$(grep -A 1 "CFBundleIdentifier" "$INFO_PLIST" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>/\1/')

if [[ "$BUNDLE_ID" == *"PRODUCT_BUNDLE_IDENTIFIER"* ]]; then
    # Tentar extrair do project.pbxproj
    BUNDLE_ID=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "$PBXPROJ" | grep -v "//" | head -1 | sed 's/.*= \(.*\);/\1/' | tr -d ' ')
fi

echo "📋 Bundle ID: $BUNDLE_ID"

# Verificar se é válido
if [[ "$BUNDLE_ID" =~ ^[a-z]+\.[a-z]+\.[a-z]+ ]]; then
    echo -e "${GREEN}✅ Bundle ID: Valid format${NC}"
else
    echo -e "${YELLOW}⚠️  Bundle ID: Format may be invalid${NC}"
    WARNINGS=$((WARNINGS+1))
fi

echo ""

# ============================================
# 4. VERIFICAR SIGNING
# ============================================
echo "4️⃣  Code Signing Configuration"
echo ""

# Verificar DEVELOPMENT_TEAM
if grep -q "DEVELOPMENT_TEAM" "$PBXPROJ"; then
    TEAM_ID=$(grep "DEVELOPMENT_TEAM" "$PBXPROJ" | grep -v "//" | head -1 | sed 's/.*= \(.*\);/\1/' | tr -d ' ;')
    
    if [ -n "$TEAM_ID" ] && [ "$TEAM_ID" != '""' ]; then
        echo -e "${GREEN}✅ Development Team: Configured${NC}"
        echo "   Team ID: $TEAM_ID"
    else
        echo -e "${YELLOW}⚠️  Development Team: Not set (may use Personal Team)${NC}"
        WARNINGS=$((WARNINGS+1))
    fi
else
    echo -e "${YELLOW}⚠️  Development Team: Not found in project${NC}"
    WARNINGS=$((WARNINGS+1))
fi

# Verificar CODE_SIGN_STYLE
if grep -q "CODE_SIGN_STYLE = Automatic" "$PBXPROJ"; then
    echo -e "${GREEN}✅ Code Sign Style: Automatic${NC}"
elif grep -q "CODE_SIGN_STYLE = Manual" "$PBXPROJ"; then
    echo -e "${YELLOW}⚠️  Code Sign Style: Manual (pode precisar certificado)${NC}"
    WARNINGS=$((WARNINGS+1))
fi

echo ""

# ============================================
# 5. VERIFICAR CÓDIGO FLUTTER
# ============================================
echo "5️⃣  Flutter Code Verification"
echo ""

MAIN_DART="$PROJECT_PATH/lib/main.dart"
LOGIN_SCREEN="$PROJECT_PATH/lib/screens/login_screen.dart"
AUTH_SERVICE="$PROJECT_PATH/lib/services/auth_service.dart"

# Firebase inicialização duplicada
if grep -q "_firebaseInitialized" "$MAIN_DART"; then
    echo -e "${GREEN}✅ Firebase: Duplicate initialization prevention${NC}"
else
    echo -e "${RED}❌ Firebase: No duplicate prevention${NC}"
    PROBLEMS=$((PROBLEMS+1))
fi

# Botão visitante removido
if grep -q "signInAnonymously" "$LOGIN_SCREEN"; then
    echo -e "${RED}❌ Guest Login: Button still exists${NC}"
    PROBLEMS=$((PROBLEMS+1))
else
    echo -e "${GREEN}✅ Guest Login: Removed${NC}"
fi

# Recuperação de senha
if grep -q "mostrarDialogRecuperarSenha" "$LOGIN_SCREEN"; then
    echo -e "${GREEN}✅ Password Recovery: Implemented${NC}"
else
    echo -e "${RED}❌ Password Recovery: NOT implemented${NC}"
    PROBLEMS=$((PROBLEMS+1))
fi

echo ""

# ============================================
# 6. VERIFICAR FIREBASE CONSOLE
# ============================================
echo "6️⃣  Firebase Console (Manual Check Required)"
echo ""

echo -e "${BLUE}📱 AÇÕES MANUAIS NECESSÁRIAS:${NC}"
echo ""
echo "1. Firebase Console - Google Sign-In:"
echo "   https://console.firebase.google.com/project/notaok-4d791/authentication/providers"
echo "   ✓ Verificar se Google está Enabled"
echo "   ✓ Verificar OAuth iOS client configurado"
echo ""
echo "2. Firebase Console - Apple Sign-In:"
echo "   ✓ Verificar se Apple está Enabled"
echo "   ✓ OAuth code flow: iOS"
echo ""
echo "3. Apple Developer Account:"
echo "   https://developer.apple.com/account/"
echo "   ✓ App ID criado com Bundle ID: $BUNDLE_ID"
echo "   ✓ Sign In with Apple capability habilitada"
echo ""

# ============================================
# 7. RESUMO FINAL
# ============================================
echo ""
echo "================================"
echo "📊 RESUMO DA VERIFICAÇÃO"
echo "================================"
echo ""

if [ $PROBLEMS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 TUDO PERFEITO!${NC}"
    echo ""
    echo "✅ Nenhum problema encontrado"
    echo "✅ Nenhum aviso"
    echo ""
    echo "🚀 PRONTO PARA BUILD & RUN!"
    echo ""
    echo "Próximos passos:"
    echo "1. Abrir Xcode"
    echo "2. Clean Build Folder (Shift + Cmd + K)"
    echo "3. Build & Run (Cmd + R)"
    
elif [ $PROBLEMS -eq 0 ] && [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS AVISO(S) ENCONTRADO(S)${NC}"
    echo ""
    echo "Avisos não bloqueiam o build, mas revise os itens marcados com ⚠️"
    echo ""
    echo "🚀 VOCÊ PODE PROSSEGUIR COM O BUILD"
    echo ""
    echo "Próximos passos:"
    echo "1. Abrir Xcode"
    echo "2. Verificar itens marcados com ⚠️"
    echo "3. Clean Build Folder (Shift + Cmd + K)"
    echo "4. Build & Run (Cmd + R)"
    
else
    echo -e "${RED}❌ $PROBLEMS PROBLEMA(S) CRÍTICO(S) ENCONTRADO(S)${NC}"
    
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNINGS AVISO(S) ENCONTRADO(S)${NC}"
    fi
    
    echo ""
    echo "🛑 CORRIJA OS PROBLEMAS ANTES DO BUILD"
    echo ""
    echo "Revise os itens marcados com ❌ acima e corrija-os."
    echo ""
    echo "Para corrigir automaticamente, execute:"
    echo "  ./fix_google.sh    (se Google Login tiver problemas)"
    echo "  ./fix_apple.sh     (se Apple Login tiver problemas)"
fi

echo ""
echo "================================"
echo ""

# Criar arquivo de relatório
REPORT_FILE="/tmp/notaok_verification_report.txt"
{
    echo "RELATÓRIO DE VERIFICAÇÃO - NotaOK iOS"
    echo "======================================"
    echo ""
    echo "Data: $(date)"
    echo "Projeto: $PROJECT_PATH"
    echo ""
    echo "Problemas críticos: $PROBLEMS"
    echo "Avisos: $WARNINGS"
    echo ""
    echo "Bundle ID: $BUNDLE_ID"
    echo "Team ID: $TEAM_ID"
    echo ""
} > "$REPORT_FILE"

echo "📄 Relatório salvo em: $REPORT_FILE"
echo ""

# Exit code baseado em problemas
if [ $PROBLEMS -eq 0 ]; then
    exit 0
else
    exit 1
fi

#!/bin/bash

echo "🍎 CORRIGINDO APPLE SIGN IN..."
echo ""

PROJECT_FILE="ios/Runner.xcodeproj/project.pbxproj"

# Backup
cp "$PROJECT_FILE" "${PROJECT_FILE}.backup_apple_$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Verificar se já tem SystemCapabilities
if grep -q "SystemCapabilities" "$PROJECT_FILE"; then
  echo "⚠️  SystemCapabilities já existe no projeto"
  echo ""
  echo "🔧 Você precisa abrir o Xcode e habilitar manualmente:"
  echo ""
  echo "1. Abra o projeto no Xcode:"
  echo "   open ios/Runner.xcworkspace"
  echo ""
  echo "2. Selecione o target 'Runner' no painel esquerdo"
  echo ""
  echo "3. Vá na aba 'Signing & Capabilities'"
  echo ""
  echo "4. Clique em '+ Capability'"
  echo ""
  echo "5. Adicione 'Sign in with Apple'"
  echo ""
  echo "6. Salve o projeto (Cmd+S)"
  echo ""
else
  echo "ℹ️  SystemCapabilities não encontrado"
  echo ""
  echo "🔧 Solução manual necessária (mais confiável):"
  echo ""
  echo "Abra o Xcode e habilite 'Sign in with Apple':"
  echo ""
  echo "   open ios/Runner.xcworkspace"
  echo ""
fi

echo "=============================================="
echo "📋 CHECKLIST APPLE SIGN IN:"
echo "=============================================="
echo "✅ 1. Pacote sign_in_with_apple instalado"
echo "✅ 2. Runner.entitlements configurado"
echo "⚠️  3. Abrir Xcode e adicionar Capability"
echo "✅ 4. Bundle ID: com.warrantywizard.warranty"
echo ""
echo "Após adicionar o Capability no Xcode, o Apple Sign In vai funcionar!"


#!/bin/bash

echo "🍎 DIAGNÓSTICO COMPLETO - SIGN IN WITH APPLE"
echo "=============================================="
echo ""

# 1. Verificar pubspec.yaml
echo "📦 1. Verificando pacote sign_in_with_apple..."
if grep -q "sign_in_with_apple" pubspec.yaml 2>/dev/null; then
  grep "sign_in_with_apple" pubspec.yaml
  echo "✅ Pacote instalado"
else
  echo "❌ Pacote NÃO instalado"
fi
echo ""

# 2. Verificar Runner.entitlements
echo "🔐 2. Verificando Runner.entitlements..."
if [ -f "ios/Runner/Runner.entitlements" ]; then
  cat ios/Runner/Runner.entitlements
  echo "✅ Arquivo existe"
else
  echo "❌ Arquivo NÃO existe - PRECISA CRIAR!"
fi
echo ""

# 3. Verificar Info.plist
echo "📋 3. Verificando Info.plist (Apple Sign In)..."
if grep -q "com.apple.developer.applesignin" ios/Runner/Info.plist 2>/dev/null; then
  grep -A 3 "com.apple.developer.applesignin" ios/Runner/Info.plist
  echo "✅ Configurado no Info.plist"
else
  echo "⚠️  NÃO configurado no Info.plist (pode ser opcional)"
fi
echo ""

# 4. Verificar projeto Xcode
echo "🔨 4. Verificando configuração do Xcode..."
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
  if grep -q "Sign in with Apple" ios/Runner.xcodeproj/project.pbxproj 2>/dev/null; then
    echo "✅ Capability configurado no Xcode"
  else
    echo "⚠️  Capability NÃO configurado no Xcode"
  fi
else
  echo "❌ Projeto Xcode não encontrado"
fi
echo ""

# 5. Verificar Bundle ID
echo "📱 5. Verificando Bundle ID..."
BUNDLE_ID=$(grep -A 1 "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj 2>/dev/null | grep -o "com\.[^;]*" | head -1)
if [ -n "$BUNDLE_ID" ]; then
  echo "Bundle ID: $BUNDLE_ID"
  echo "✅ Bundle ID encontrado"
else
  echo "⚠️  Bundle ID não detectado automaticamente"
fi
echo ""

echo "=============================================="
echo "🎯 RESUMO DO DIAGNÓSTICO"
echo "=============================================="
echo ""
echo "Para o Sign in with Apple funcionar, você precisa:"
echo "1. ✅ Pacote sign_in_with_apple instalado"
echo "2. ✅ Runner.entitlements com com.apple.developer.applesignin"
echo "3. ✅ Capability habilitado no Xcode"
echo "4. ✅ Bundle ID registrado no Apple Developer"
echo ""


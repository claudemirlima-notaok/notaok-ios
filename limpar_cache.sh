#!/bin/bash

# Script de limpeza completa de cache Flutter/Xcode
# Uso: ./limpar_cache_completo.sh [caminho_do_projeto]

PROJECT_PATH="${1:-/home/user/flutter_app}"

echo "🧹 INICIANDO LIMPEZA COMPLETA DE CACHE..."
echo "📁 Projeto: $PROJECT_PATH"
echo ""

# Navegar para o projeto
cd "$PROJECT_PATH" || exit 1

# 1. Limpar caches do Flutter
echo "1️⃣ Limpando cache do Flutter..."
flutter clean
echo "   ✅ Flutter clean concluído"
echo ""

# 2. Limpar caches do projeto
echo "2️⃣ Limpando caches do projeto..."
rm -rf build/
rm -rf .dart_tool/
rm -rf ios/build/
rm -rf ios/DerivedData/
rm -rf android/build/
rm -rf android/app/build/
rm -rf android/.gradle/
echo "   ✅ Caches do projeto removidos"
echo ""

# 3. Limpar caches globais do Xcode (se existir)
echo "3️⃣ Limpando caches globais do Xcode..."
if [ -d ~/Library/Developer/Xcode/DerivedData ]; then
    rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
    echo "   ✅ Cache do Xcode removido"
else
    echo "   ⚠️  Diretório do Xcode não encontrado (normal em sandbox)"
fi
echo ""

# 4. Reinstalar dependências
echo "4️⃣ Reinstalando dependências Flutter..."
flutter pub get
echo "   ✅ Dependências instaladas"
echo ""

# 5. Se iOS, reinstalar pods
if [ -d "ios" ]; then
    echo "5️⃣ Reinstalando CocoaPods..."
    cd ios
    rm -rf Pods/ Podfile.lock
    pod install --repo-update
    cd ..
    echo "   ✅ CocoaPods reinstalados"
    echo ""
fi

echo "✅ LIMPEZA COMPLETA CONCLUÍDA!"
echo ""
echo "🚀 PRÓXIMOS PASSOS:"
echo "   1. Abra o Xcode: open ios/Runner.xcworkspace"
echo "   2. Clean Build Folder: Shift + Cmd + K"
echo "   3. Build & Run: Cmd + R"
echo ""


#!/bin/bash

# Script para corrigir configuração do Google Sign-In no Info.plist

INFO_PLIST="ios/Runner/Info.plist"

# CLIENT_ID correto do GoogleService-Info.plist
CORRECT_CLIENT_ID="266728357187-7mhd6usv2ie2odchtv4qofvvc5jt4f4a.apps.googleusercontent.com"
CORRECT_REVERSED="com.googleusercontent.apps.266728357187-7mhd6usv2ie2odchtv4qofvvc5jt4f4a"

echo "🔧 Corrigindo configuração do Google Sign-In..."
echo ""

# Backup do Info.plist
cp "$INFO_PLIST" "${INFO_PLIST}.backup_google_$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Substituir GIDClientID
if grep -q "GIDClientID" "$INFO_PLIST"; then
  sed -i.tmp "s|<key>GIDClientID</key>|<key>GIDClientID</key>|g" "$INFO_PLIST"
  sed -i.tmp "s|<string>266728357187-q6tgtamj2o5k6rae0jf4deftbgmtt9qk\.apps\.googleusercontent\.com</string>|<string>$CORRECT_CLIENT_ID</string>|g" "$INFO_PLIST"
  rm -f "${INFO_PLIST}.tmp"
  echo "✅ GIDClientID atualizado"
else
  echo "⚠️  GIDClientID não encontrado"
fi

# Remover Client ID incorreto do CFBundleURLSchemes
sed -i.tmp "s|<string>com\.googleusercontent\.apps\.266728357187-q6tgtamj2o5k6rae0jf4deftbgmtt9qk</string>||g" "$INFO_PLIST"
rm -f "${INFO_PLIST}.tmp"
echo "✅ Client ID incorreto removido dos URL Schemes"

# Verificar se o REVERSED_CLIENT_ID correto já está presente
if grep -q "$CORRECT_REVERSED" "$INFO_PLIST"; then
  echo "✅ REVERSED_CLIENT_ID correto já está presente"
else
  echo "⚠️  REVERSED_CLIENT_ID correto não encontrado nos URL Schemes"
fi

echo ""
echo "🎉 Correção concluída!"
echo ""
echo "📋 Verificar configuração atual:"
grep -A 10 "CFBundleURLSchemes" "$INFO_PLIST"
echo ""
grep -A 1 "GIDClientID" "$INFO_PLIST"


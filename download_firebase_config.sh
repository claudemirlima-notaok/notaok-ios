#!/bin/bash
echo "📥 Baixando GoogleService-Info.plist do Gist privado..."
GIST_ID="a12408364baeae5ed724b3a59917e291"
gh gist view $GIST_ID --filename GoogleService-Info.plist > ios/Runner/GoogleService-Info.plist
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "✅ Config baixado com sucesso!"
    ls -lh ios/Runner/GoogleService-Info.plist
else
    echo "❌ Erro ao baixar config!"
    exit 1
fi

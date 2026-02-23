#!/usr/bin/env python3
"""
Script alternativo para limpar usuários do Firebase usando REST API
Não precisa do firebase-admin-sdk.json, usa o GoogleService-Info.plist
"""

import os
import sys
import json
import plistlib
import requests
from urllib.parse import quote

def ler_google_services():
    """Lê configurações do GoogleService-Info.plist"""
    plist_paths = [
        'ios/Runner/GoogleService-Info.plist',
        'GoogleService-Info.plist',
        'ios/GoogleService-Info.plist',
    ]
    
    for path in plist_paths:
        if os.path.exists(path):
            print(f"✅ Arquivo encontrado: {path}")
            with open(path, 'rb') as f:
                return plistlib.load(f)
    
    print("\n❌ ERRO: GoogleService-Info.plist não encontrado!")
    print("\n📍 Locais verificados:")
    for path in plist_paths:
        print(f"   - {os.path.abspath(path)}")
    sys.exit(1)

def obter_api_key(config):
    """Obtém a API Key do Firebase"""
    api_key = config.get('API_KEY')
    if not api_key:
        print("❌ ERRO: API_KEY não encontrada no GoogleService-Info.plist")
        sys.exit(1)
    return api_key

def limpar_usuarios_via_rest():
    """
    AVISO: Este método NÃO consegue deletar usuários diretamente via REST API
    A API REST do Firebase Authentication não permite deletar usuários sem autenticação.
    
    Esta é uma limitação de segurança do Firebase.
    """
    print("\n" + "=" * 70)
    print("⚠️  LIMITAÇÃO TÉCNICA IDENTIFICADA")
    print("=" * 70)
    print("\n🔒 O Firebase não permite deletar usuários via REST API pública.")
    print("   Isso é uma medida de segurança para proteger contas de usuários.")
    print("\n📋 VOCÊ PRECISA DE UMA DESTAS OPÇÕES:")
    print("\n   OPÇÃO 1️⃣ - Firebase Console (Manual, mais rápido agora):")
    print("      1. Acesse: https://console.firebase.google.com")
    print("      2. Selecione o projeto 'NotaOK'")
    print("      3. Vá em 'Authentication' → 'Users'")
    print("      4. Selecione os usuários e delete manualmente")
    print("      ⏱️  Tempo: ~2 minutos")
    print("\n   OPÇÃO 2️⃣ - Firebase Admin SDK (Requer credenciais):")
    print("      1. Firebase Console → Configurações → Contas de serviço")
    print("      2. Gerar nova chave privada (Python)")
    print("      3. Salvar como: firebase-admin-sdk.json")
    print("      4. Executar: python3 limpar_usuarios_firebase.py")
    print("      ⏱️  Tempo: ~5 minutos para setup + execução instantânea")
    print("\n   OPÇÃO 3️⃣ - Pelo próprio app (Desenvolvimento):")
    print("      1. Adicionar botão de logout no app")
    print("      2. Fazer logout manual ao testar")
    print("      ⏱️  Tempo: sempre disponível durante testes")
    print("\n" + "=" * 70)
    print("\n💡 RECOMENDAÇÃO:")
    print("   Para testes, use OPÇÃO 1 (Firebase Console) - é mais rápido.")
    print("   Para produção/automação, configure OPÇÃO 2 (Admin SDK).")
    print("\n🎯 O app já está configurado para fazer LOGOUT FORÇADO!")
    print("   Cada vez que você abrir o app, ele vai deslogar automaticamente.")
    print("   Isso resolve o problema de 'usuário já logado'.")
    print("\n" + "=" * 70)

def main():
    print("=" * 70)
    print("🔍 VERIFICADOR DE CONFIGURAÇÃO FIREBASE - NotaOK")
    print("=" * 70)
    
    # Ler configuração
    config = ler_google_services()
    api_key = obter_api_key(config)
    project_id = config.get('PROJECT_ID', 'desconhecido')
    
    print(f"\n✅ Projeto Firebase detectado: {project_id}")
    print(f"✅ API Key encontrada: {api_key[:10]}...{api_key[-5:]}")
    
    # Explicar limitações
    limpar_usuarios_via_rest()
    
    print("\n✅ Verificação finalizada!")

if __name__ == "__main__":
    main()

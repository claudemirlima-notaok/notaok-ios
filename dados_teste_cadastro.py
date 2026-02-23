#!/usr/bin/env python3
"""
Script para preencher dados de teste no formulário de cadastro
Uso: Execute este script e depois use os dados abaixo no app
"""

DADOS_TESTE = {
    "nome": "Claudemir Lima",
    "cpf": "154.667.848-42",
    "telefone": "(19) 98282-8291",
    "email": "claudemir.lima@gmail.com",
    "senha": "teste123"
}

print("="*60)
print("DADOS DE TESTE PARA CADASTRO - NotaOK")
print("="*60)
print(f"Nome Completo: {DADOS_TESTE['nome']}")
print(f"CPF: {DADOS_TESTE['cpf']}")
print(f"Telefone: {DADOS_TESTE['telefone']}")
print(f"Email: {DADOS_TESTE['email']}")
print(f"Senha: {DADOS_TESTE['senha']}")
print("="*60)
print("\n💡 Use esses dados para testar o cadastro no app")
print("\n📋 Copiando para clipboard (se disponível)...")

try:
    import pyperclip
    texto = f"""Nome: {DADOS_TESTE['nome']}
CPF: {DADOS_TESTE['cpf']}
Telefone: {DADOS_TESTE['telefone']}
Email: {DADOS_TESTE['email']}
Senha: {DADOS_TESTE['senha']}"""
    pyperclip.copy(texto)
    print("✅ Dados copiados para clipboard!")
except:
    print("⚠️  Clipboard não disponível (instale pyperclip se quiser)")

#!/bin/bash

echo "========================================="
echo "DEPLOY CLOUD FUNCTIONS - NotaOK"
echo "========================================="
echo ""

# Verificar se esta na pasta correta
if [ ! -d "functions" ]; then
    echo "ERRO: Pasta functions nao encontrada"
    echo "Execute este script da pasta raiz do projeto notaok-ios"
    exit 1
fi

cd functions

echo "1. Instalando dependencias..."
npm install

echo ""
echo "2. Verificando funcoes..."
grep "exports\." index.js

echo ""
echo "3. Fazendo deploy..."
firebase deploy --only functions

echo ""
echo "========================================="
echo "DEPLOY CONCLUIDO"
echo "========================================="
echo ""
echo "Funcoes deployadas:"
echo "- enviarCodigoVerificacao"
echo "- validarCodigoVerificacao"
echo ""
echo "Regiao: us-central1"
echo ""

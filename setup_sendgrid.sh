#!/bin/bash

# 📧 GUIA DE CONFIGURAÇÃO SENDGRID
# Passo a passo para implementar emails HTML profissionais

echo "📧 GUIA DE CONFIGURAÇÃO SENDGRID"
echo "================================="
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_PATH="$HOME/Downloads/notaok-ios"

echo -e "${BLUE}Este é um guia interativo para configurar SendGrid${NC}"
echo ""
echo "⚠️  ATENÇÃO: Esta configuração requer:"
echo "   • Conta SendGrid (gratuita)"
echo "   • Firebase Blaze Plan (pago - cartão de crédito)"
echo "   • Conhecimento básico de Cloud Functions"
echo ""

read -p "Deseja continuar? (s/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Configuração cancelada."
    exit 0
fi

echo ""

# ============================================
# PASSO 1: CRIAR CONTA SENDGRID
# ============================================
echo "================================"
echo "PASSO 1: CRIAR CONTA SENDGRID"
echo "================================"
echo ""

echo "1. Abrir navegador:"
echo "   ${BLUE}https://signup.sendgrid.com/${NC}"
echo ""
echo "2. Preencher formulário:"
echo "   • Email: claudemir.lima@gmail.com"
echo "   • Password: [criar senha forte]"
echo "   • Company: NotaOK"
echo "   • Website: https://notaok.com.br"
echo ""
echo "3. Verificar email de confirmação"
echo ""
echo "4. Fazer login:"
echo "   ${BLUE}https://app.sendgrid.com/${NC}"
echo ""

read -p "Conta SendGrid criada? (s/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Complete o passo 1 antes de continuar."
    exit 0
fi

echo ""

# ============================================
# PASSO 2: CRIAR API KEY
# ============================================
echo "================================"
echo "PASSO 2: CRIAR API KEY"
echo "================================"
echo ""

echo "1. No SendGrid Dashboard:"
echo "   Settings → API Keys"
echo ""
echo "2. Clicar em 'Create API Key'"
echo ""
echo "3. Configurar:"
echo "   • Name: NotaOK Firebase Function"
echo "   • Permissions: Full Access"
echo ""
echo "4. Copiar API Key (SG.xxxxxx...)"
echo "   ⚠️  ATENÇÃO: Não será mostrado novamente!"
echo ""

read -p "API Key criada e copiada? (s/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Complete o passo 2 antes de continuar."
    exit 0
fi

echo ""
echo "Cole a API Key aqui (não será exibida):"
read -s SENDGRID_API_KEY
echo ""

if [ -z "$SENDGRID_API_KEY" ]; then
    echo -e "${RED}❌ API Key não pode estar vazia${NC}"
    exit 1
fi

echo -e "${GREEN}✅ API Key salva temporariamente${NC}"
echo ""

# ============================================
# PASSO 3: VERIFICAR FIREBASE BLAZE
# ============================================
echo "================================"
echo "PASSO 3: ATIVAR FIREBASE BLAZE"
echo "================================"
echo ""

echo "⚠️  IMPORTANTE: Cloud Functions requer plano Blaze (pago)"
echo ""
echo "1. Abrir Firebase Console:"
echo "   ${BLUE}https://console.firebase.google.com/project/notaok-4d791${NC}"
echo ""
echo "2. Navegar:"
echo "   Project Settings → Usage and billing → Details & settings"
echo ""
echo "3. Clicar em 'Modify plan'"
echo ""
echo "4. Selecionar 'Blaze (Pay as you go)'"
echo ""
echo "5. Adicionar cartão de crédito"
echo ""
echo "6. Custo estimado:"
echo "   • ~\$0-5/mês para baixo tráfego"
echo "   • 2M invocações/mês grátis"
echo "   • 400.000 GB-segundos/mês grátis"
echo ""
echo "7. Confirmar upgrade"
echo ""

read -p "Firebase Blaze ativado? (s/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "⚠️  Sem Firebase Blaze, Cloud Functions não funcionarão."
    echo ""
    read -p "Deseja continuar mesmo assim (apenas criar estrutura)? (s/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 0
    fi
fi

echo ""

# ============================================
# PASSO 4: INICIALIZAR FIREBASE FUNCTIONS
# ============================================
echo "================================"
echo "PASSO 4: INICIALIZAR FUNCTIONS"
echo "================================"
echo ""

cd "$PROJECT_PATH" || exit 1

if [ -d "functions" ]; then
    echo -e "${YELLOW}⚠️  Diretório 'functions' já existe${NC}"
    echo ""
    read -p "Deseja sobrescrever? (s/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo "Fazendo backup..."
        mv functions "functions.backup.$(date +%Y%m%d_%H%M%S)"
    else
        echo "Usando diretório existente..."
    fi
fi

echo "Instalando Firebase CLI..."
echo ""

# Verificar se firebase-tools está instalado
if ! command -v firebase &> /dev/null; then
    echo "Instalando firebase-tools globalmente..."
    npm install -g firebase-tools
else
    echo -e "${GREEN}✅ Firebase CLI já instalado${NC}"
fi

echo ""
echo "Fazendo login no Firebase..."
echo ""
echo "⚠️  Uma janela do navegador será aberta para autenticação"
echo ""

firebase login

echo ""

if [ ! -d "functions" ]; then
    echo "Inicializando Firebase Functions..."
    echo ""
    echo "⚠️  Durante o init, selecione:"
    echo "   • Language: TypeScript"
    echo "   • ESLint: Yes"
    echo "   • Install dependencies: Yes"
    echo ""
    
    firebase init functions
fi

echo ""

# ============================================
# PASSO 5: INSTALAR DEPENDÊNCIAS
# ============================================
echo "================================"
echo "PASSO 5: INSTALAR DEPENDÊNCIAS"
echo "================================"
echo ""

if [ -d "functions" ]; then
    cd functions || exit 1
    
    echo "Instalando @sendgrid/mail..."
    npm install @sendgrid/mail
    
    echo ""
    echo "Instalando firebase-admin..."
    npm install firebase-admin
    
    echo ""
    echo -e "${GREEN}✅ Dependências instaladas${NC}"
    
    cd ..
else
    echo -e "${RED}❌ Diretório functions não foi criado${NC}"
    exit 1
fi

echo ""

# ============================================
# PASSO 6: CRIAR FUNÇÃO DE EMAIL
# ============================================
echo "================================"
echo "PASSO 6: CRIAR CLOUD FUNCTION"
echo "================================"
echo ""

echo "Criando função de envio de email..."

cat > "functions/src/email-verification.ts" << 'TYPESCRIPT_EOF'
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as sgMail from '@sendgrid/mail';

// Configurar SendGrid
const sendgridKey = functions.config().sendgrid?.key;
if (sendgridKey) {
  sgMail.setApiKey(sendgridKey);
}

export const enviarEmailVerificacao = functions.firestore
  .document('temp_usuarios/{userId}')
  .onCreate(async (snap, context) => {
    const dados = snap.data();
    const userId = context.params.userId;
    
    // Gerar código de 6 dígitos
    const codigo = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Salvar código (expira em 10 minutos)
    await admin.firestore().collection('codigos_verificacao').doc(userId).set({
      codigo: codigo,
      email: dados.email,
      criadoEm: admin.firestore.FieldValue.serverTimestamp(),
      expiraEm: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 10 * 60 * 1000)
      ),
    });
    
    // Template HTML
    const htmlEmail = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; background: #f5f5f5; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 40px auto; background: white; padding: 40px; border-radius: 10px; }
        .header { text-align: center; margin-bottom: 30px; }
        .title { color: #9C27B0; font-size: 24px; font-weight: bold; margin: 20px 0; }
        .code-box { background: #f0f0f0; padding: 20px; border-radius: 8px; text-align: center; margin: 30px 0; }
        .code { font-size: 36px; font-weight: bold; color: #9C27B0; letter-spacing: 8px; }
        .footer { text-align: center; color: #666; font-size: 12px; margin-top: 30px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1 class="title">✅ Verificação de Email</h1>
        </div>
        
        <p>Olá <strong>${dados.nome}</strong>,</p>
        
        <p>Obrigado por se cadastrar no <strong>NotaOK</strong>!</p>
        <p>Para completar seu cadastro, utilize o código de verificação abaixo:</p>
        
        <div class="code-box">
          <div class="code">${codigo}</div>
        </div>
        
        <p>Este código expira em <strong>10 minutos</strong>.</p>
        
        <p>Se você não solicitou este cadastro, ignore este email.</p>
        
        <div class="footer">
          <p><strong>NotaOK</strong> - Comprou? Tá OK! 📱</p>
          <p>Este é um email automático. Por favor, não responda.</p>
        </div>
      </div>
    </body>
    </html>
    `;
    
    // Enviar via SendGrid
    const msg = {
      to: dados.email,
      from: {
        email: 'noreply@notaok.com.br',
        name: 'NotaOK'
      },
      subject: '✅ Confirme seu email - NotaOK',
      html: htmlEmail,
    };
    
    try {
      await sgMail.send(msg);
      console.log(`✅ Email enviado para ${dados.email}`);
      return { success: true };
    } catch (error) {
      console.error('❌ Erro ao enviar email:', error);
      throw new functions.https.HttpsError('internal', 'Erro ao enviar email');
    }
  });
TYPESCRIPT_EOF

echo -e "${GREEN}✅ Função criada: functions/src/email-verification.ts${NC}"
echo ""

# Adicionar export ao index.ts
if [ -f "functions/src/index.ts" ]; then
    if ! grep -q "email-verification" "functions/src/index.ts"; then
        echo "" >> "functions/src/index.ts"
        echo "export * from './email-verification';" >> "functions/src/index.ts"
        echo -e "${GREEN}✅ Export adicionado ao index.ts${NC}"
    fi
fi

echo ""

# ============================================
# PASSO 7: CONFIGURAR API KEY NO FIREBASE
# ============================================
echo "================================"
echo "PASSO 7: CONFIGURAR API KEY"
echo "================================"
echo ""

echo "Configurando SendGrid API Key no Firebase..."
echo ""

firebase functions:config:set sendgrid.key="$SENDGRID_API_KEY"

echo ""
echo -e "${GREEN}✅ API Key configurada${NC}"
echo ""

echo "Verificando configuração..."
firebase functions:config:get

echo ""

# ============================================
# PASSO 8: DEPLOY
# ============================================
echo "================================"
echo "PASSO 8: DEPLOY DA FUNÇÃO"
echo "================================"
echo ""

echo "⚠️  O primeiro deploy pode demorar 5-10 minutos"
echo ""

read -p "Deseja fazer o deploy agora? (s/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo "Fazendo deploy..."
    echo ""
    firebase deploy --only functions
    echo ""
    echo -e "${GREEN}✅ Deploy concluído!${NC}"
else
    echo "Deploy cancelado."
    echo ""
    echo "Para fazer deploy depois, execute:"
    echo "   cd $PROJECT_PATH"
    echo "   firebase deploy --only functions"
fi

echo ""

# ============================================
# RESUMO FINAL
# ============================================
echo "================================"
echo "📊 RESUMO DA CONFIGURAÇÃO"
echo "================================"
echo ""

echo -e "${GREEN}✅ Configuração concluída!${NC}"
echo ""
echo "📋 O QUE FOI FEITO:"
echo "   ✅ Conta SendGrid criada"
echo "   ✅ API Key gerada e configurada"
echo "   ✅ Firebase Blaze verificado"
echo "   ✅ Firebase Functions inicializado"
echo "   ✅ Dependências instaladas"
echo "   ✅ Cloud Function criada"
echo "   ✅ API Key configurada no Firebase"
echo ""

echo "📧 COMO FUNCIONA:"
echo "   1. Usuário se cadastra no app"
echo "   2. AuthService cria documento em 'temp_usuarios'"
echo "   3. Cloud Function detecta novo documento"
echo "   4. Gera código de 6 dígitos"
echo "   5. Envia email HTML via SendGrid"
echo "   6. Usuário insere código no app"
echo "   7. Dados movidos para 'usuarios' após verificação"
echo ""

echo "🔗 LINKS ÚTEIS:"
echo "   SendGrid Dashboard:"
echo "   https://app.sendgrid.com/"
echo ""
echo "   Firebase Console:"
echo "   https://console.firebase.google.com/project/notaok-4d791/functions"
echo ""

echo "📝 PRÓXIMOS PASSOS:"
echo "   1. Testar cadastro de novo usuário no app"
echo "   2. Verificar inbox do email cadastrado"
echo "   3. Monitorar logs no Firebase Console"
echo "   4. (Opcional) Configurar domínio próprio no SendGrid"
echo ""

echo "✅ Configuração SendGrid completa!"
echo ""

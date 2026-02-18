# 🍎 Guia de Configuração - Apple Developer para NotaOK iOS

## 📋 PASSO 1: Verificar Apple Developer Account

### Se você JÁ TEM conta Apple Developer:
1. Acesse: https://developer.apple.com/account
2. Login com seu Apple ID
3. Anote as seguintes informações:

**Team ID:**
- Vá em: Membership > Team ID
- Exemplo: ABC123XYZ

**Bundle ID disponível:**
- Vá em: Identifiers
- Verifique se tem um Bundle ID ou crie um novo
- Sugestão: com.warrantywizard.notaok
- Ou: com.seunome.notaok

### Se você NÃO TEM conta Apple Developer:
1. Acesse: https://developer.apple.com/programs/enroll/
2. Clique em "Start Your Enrollment"
3. Custo: $99/ano (USD)
4. Aprovação: 1-2 dias úteis

---

## 🔐 PASSO 2: Criar App-Specific Password

Para o Codemagic acessar sua conta:

1. Acesse: https://appleid.apple.com/account/manage
2. Vá em: "Sign-In and Security"
3. Clique em: "App-Specific Passwords"
4. Clique em: "Generate an app-specific password"
5. Nome: "Codemagic NotaOK"
6. **COPIE E SALVE** a senha gerada (aparece apenas uma vez!)

---

## 📱 PASSO 3: Registrar Bundle ID

1. Acesse: https://developer.apple.com/account/resources/identifiers/list
2. Clique em: "+" (adicionar novo)
3. Selecione: "App IDs"
4. Continue
5. Selecione: "App"
6. Continue
7. Preencha:
   - **Description:** NotaOK - Gerenciador de Garantias
   - **Bundle ID:** Explicit
   - **Bundle ID:** com.warrantywizard.notaok (ou seu escolhido)
8. **Capabilities:** Marque as necessárias:
   - ✅ Push Notifications (se usar)
   - ✅ Sign In with Apple
   - ✅ Associated Domains (se usar)
9. Continue
10. Register

---

## 🔑 PASSO 4: Informações para o Codemagic

Após completar os passos acima, me forneça:

1. **Apple ID:** seu-email@exemplo.com
2. **App-Specific Password:** xxxx-xxxx-xxxx-xxxx
3. **Team ID:** ABC123XYZ
4. **Bundle ID:** com.warrantywizard.notaok

---

## 🚀 PASSO 5: Configurar no Codemagic

Com essas informações, vou te guiar para:

1. Adicionar credenciais no Codemagic
2. Configurar code signing automático
3. Build do app assinado
4. Distribuição via:
   - TestFlight (recomendado)
   - Ou link direto de instalação

---

## ⏱️ TEMPO ESTIMADO:

- Se já tem Apple Developer: ~15 minutos
- Se precisa criar conta: ~2 dias (aprovação Apple) + 15 minutos

---

## 💡 DICA:

O Codemagic pode criar os certificados automaticamente!
Você só precisa fornecer:
- Apple ID
- App-Specific Password
- Team ID
- Bundle ID

O resto ele faz sozinho! 🎉

---

## ❓ DÚVIDAS?

Me chame quando tiver as informações prontas!

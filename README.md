# 🛡️ Warranty Wizard

**Gerenciador inteligente de garantias e notas fiscais com scanner QR Code e OCR**

## 📱 Sobre o App

O Warranty Wizard é um aplicativo Flutter completo para gerenciamento de garantias de produtos, arquivamento de notas fiscais e avaliação de compras. Com design moderno em gradiente roxo e laranja, o app oferece uma experiência visual atraente e funcional.

## ✨ Funcionalidades Principais

### 1. 🏠 Tela Inicial - Garantias Ativas
- Lista de produtos com garantias ativas
- Visualização de dias restantes até o vencimento
- Indicadores visuais por status (ativa, expirando, vencida)
- Cards coloridos com informações do produto
- Estado vazio com orientação para escanear NF-e

### 2. 📄 Scanner de QR Code NF-e
- Leitura de QR Code de Notas Fiscais Eletrônicas
- Integração com dados da API da Receita Federal
- Extração automática de informações da chave de acesso
- Criação automática de produtos com garantia
- Controle de flash e troca de câmera

### 3. 📋 Galeria de Notas Fiscais
- Arquivamento digital de todas as NF-e escaneadas
- Visualização organizada por data
- Detalhes completos de cada nota fiscal
- Informações de emitente, CNPJ, valores

### 4. ⭐ Sistema de Avaliações
- Avaliação de 4 categorias:
  - Loja/Estabelecimento
  - Produto
  - Vendedor
  - Atendimento
- Sistema de estrelas (1 a 5)
- Comentários opcionais
- Cálculo automático de média geral
- Edição de avaliações existentes

### 5. 📸 OCR de Comprovantes
- Captura de comprovantes de cartão de crédito
- Extração automática de dados via OCR:
  - Estabelecimento
  - Valor da compra
  - Últimos 4 dígitos do cartão
  - Bandeira do cartão
  - Data da transação
  - Descrição do produto

### 6. 🎨 Design Moderno
- Gradientes roxo (#9C27B0) e laranja (#FF6F00)
- Cards com elevação e bordas arredondadas
- Animações suaves
- Ícones personalizados
- Interface intuitiva e responsiva

## 🛠️ Tecnologias Utilizadas

### Flutter & Dart
- Flutter 3.35.4
- Dart 3.9.2
- Material Design 3

### Pacotes Principais
- **mobile_scanner** ^5.2.3 - Scanner de QR Code compatível com Web
- **hive** 2.2.3 + **hive_flutter** 1.1.0 - Banco de dados local
- **google_mlkit_text_recognition** ^0.13.1 - OCR para leitura de comprovantes
- **image_picker** ^1.0.7 - Captura de imagens
- **intl** ^0.19.0 - Formatação de datas e valores
- **provider** 6.1.5+1 - Gerenciamento de estado

### Armazenamento Local
- Hive para persistência de dados
- 4 coleções:
  - Produtos
  - Notas Fiscais
  - Avaliações
  - Comprovantes

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada do app
├── models/                      # Modelos de dados
│   ├── produto.dart
│   ├── nota_fiscal.dart
│   ├── avaliacao.dart
│   └── comprovante.dart
├── services/                    # Serviços e lógica de negócio
│   ├── hive_service.dart       # Gerenciamento do banco de dados
│   ├── nfe_service.dart        # Processamento de NF-e
│   └── ocr_service.dart        # Processamento de OCR
└── screens/                     # Telas do aplicativo
    ├── home_screen.dart        # Tela inicial
    ├── scanner_screen.dart     # Scanner de QR Code
    ├── notas_fiscais_screen.dart  # Lista de notas
    └── produto_detalhes_screen.dart # Detalhes e avaliação
```

## 🚀 Como Usar

### No Navegador Web (Preview)
1. Acesse a URL do preview: https://5060-icfqhkv3tyr4h1bijjv92-18e660f9.sandbox.novita.ai
2. Navegue pelas telas usando a barra inferior
3. Teste as funcionalidades disponíveis

### Scanner de QR Code
1. Toque no ícone "Escanear" na barra inferior
2. Posicione o QR Code da NF-e na câmera
3. Aguarde o processamento automático
4. Os produtos serão adicionados automaticamente

### Avaliar uma Compra
1. Na tela inicial, toque em um produto
2. Toque em "Avaliar Compra"
3. Avalie as 4 categorias (1-5 estrelas)
4. Adicione um comentário (opcional)
5. Salve a avaliação

### OCR de Comprovante
1. Na tela Scanner, toque em "Capturar Comprovante"
2. Tire uma foto do comprovante de cartão
3. O OCR extrairá as informações automaticamente
4. Visualize os dados extraídos

## 🔮 Funcionalidades Futuras

- [ ] Notificações push para garantias expirando
- [ ] Backup em nuvem (Firebase)
- [ ] Compartilhamento de avaliações
- [ ] Relatórios de compras
- [ ] Estatísticas de gastos
- [ ] Integração com calendário
- [ ] Exportação de dados em PDF/CSV

## 📝 Notas Técnicas

### Compatibilidade Web
- Scanner de QR Code funciona em navegadores modernos
- OCR requer permissão de câmera
- Armazenamento local via IndexedDB (Hive Web)

### Integração NF-e
- Extração de dados da chave de acesso (44 dígitos)
- Suporte a QR Code padrão da Receita Federal
- Produtos de exemplo criados automaticamente

### Banco de Dados Local
- Hive com adaptadores TypeAdapter
- Dados persistidos localmente
- Sincronização automática

## 👨‍💻 Desenvolvimento

### Comandos Úteis
```bash
# Analisar código
flutter analyze

# Executar testes
flutter test

# Build para web
flutter build web --release

# Build para Android
flutter build apk --release
```

### Permissões Android
- CAMERA - Scanner de QR Code e OCR
- INTERNET - Futura integração com APIs
- READ_EXTERNAL_STORAGE - Leitura de imagens
- WRITE_EXTERNAL_STORAGE - Salvamento de arquivos

## 📄 Licença

Projeto desenvolvido como demonstração de capacidades Flutter.

---

**Desenvolvido com ❤️ usando Flutter**

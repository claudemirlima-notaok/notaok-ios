# Tesseract OCR - Arquivos de Linguagem

## Arquivos necessários:

1. **por.traineddata** (Português) - ~4.7 MB
   Download: https://github.com/tesseract-ocr/tessdata/raw/main/por.traineddata

2. **eng.traineddata** (Inglês) - ~4.9 MB  
   Download: https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata

## Como baixar manualmente:

```bash
cd assets/tessdata

# Português
curl -LO https://github.com/tesseract-ocr/tessdata/raw/main/por.traineddata

# Inglês
curl -LO https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata
```

## Estrutura final:
```
assets/tessdata/
├── por.traineddata
├── eng.traineddata
└── README.md
```

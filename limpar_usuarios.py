#!/usr/bin/env python3
import firebase_admin
from firebase_admin import credentials, auth, firestore
import sys

def init_firebase():
    try:
        firebase_admin.get_app()
    except ValueError:
        cred = credentials.Certificate('firebase-admin-sdk.json')
        firebase_admin.initialize_app(cred)
        print("✅ Firebase conectado\n")

def limpar_tudo():
    db = firestore.client()
    
    print("🗑️  LIMPANDO USUÁRIOS DE TESTE...\n")
    
    # Listar e deletar usuários
    page = auth.list_users()
    usuarios_deletados = 0
    
    while page:
        for user in page.users:
            try:
                # Deletar do Authentication
                auth.delete_user(user.uid)
                print(f"✅ {user.email}")
                
                # Deletar do Firestore
                db.collection('usuarios').document(user.uid).delete()
                db.collection('verification_codes').document(user.uid).delete()
                db.collection('codigos_verificacao').document(user.uid).delete()
                
                usuarios_deletados += 1
            except:
                pass
        
        page = page.get_next_page()
    
    print(f"\n✅ Total deletado: {usuarios_deletados} usuários")
    print("🎉 Banco limpo! Pode testar novamente.\n")

if __name__ == '__main__':
    init_firebase()
    limpar_tudo()

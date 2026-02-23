#!/usr/bin/env python3
import firebase_admin
from firebase_admin import credentials, auth, firestore
import sys

# Inicializar Firebase
cred = credentials.Certificate("firebase-admin-sdk.json")
try:
    firebase_admin.get_app()
except ValueError:
    firebase_admin.initialize_app(cred)

db = firestore.client()

def listar_usuarios():
    print("\n=== USUÁRIOS NO FIREBASE AUTH ===")
    page = auth.list_users()
    count = 0
    auth_uids = set()
    for user in page.users:
        count += 1
        auth_uids.add(user.uid)
        print(f"{count}. Email: {user.email}")
        print(f"   UID: {user.uid}")
        print(f"   Verificado: {user.email_verified}")
        print(f"   Criado: {user.user_metadata.creation_timestamp}")
        print("---")
    
    print(f"\nTotal: {count} usuários")
    
    # Listar também do Firestore
    print("\n=== USUÁRIOS NO FIRESTORE ===")
    usuarios = db.collection("usuarios").stream()
    count_firestore = 0
    orfaos = []
    for doc in usuarios:
        count_firestore += 1
        data = doc.to_dict()
        is_orfao = doc.id not in auth_uids
        status = "⚠️  ÓRFÃO" if is_orfao else "✅"
        print(f"{count_firestore}. {status} Email: {data.get('email')}")
        print(f"   UID: {doc.id}")
        print(f"   Nome: {data.get('nome')}")
        print(f"   Verificado: {data.get('email_verificado')}")
        print("---")
        if is_orfao:
            orfaos.append((doc.id, data.get("email")))
    
    print(f"\nTotal: {count_firestore} usuários no Firestore")
    if orfaos:
        print(f"⚠️  ATENÇÃO: {len(orfaos)} usuário(s) órfão(s) encontrado(s)!")
    
    return orfaos

def limpar_orfaos():
    print("\n🔍 Procurando usuários órfãos...")
    
    # Obter UIDs do Auth
    page = auth.list_users()
    auth_uids = {user.uid for user in page.users}
    
    # Procurar órfãos no Firestore
    usuarios = db.collection("usuarios").stream()
    orfaos = []
    for doc in usuarios:
        if doc.id not in auth_uids:
            data = doc.to_dict()
            orfaos.append((doc.id, data.get("email")))
    
    if not orfaos:
        print("✅ Nenhum usuário órfão encontrado!")
        return
    
    print(f"\n⚠️  Encontrados {len(orfaos)} usuário(s) órfão(s):")
    for uid, email in orfaos:
        print(f"   - {email} (UID: {uid})")
    
    resposta = input("\n🗑️  Deseja deletar todos os usuários órfãos? (sim/não): ")
    if resposta.lower() != "sim":
        print("❌ Operação cancelada")
        return
    
    # Deletar órfãos
    count = 0
    for uid, email in orfaos:
        try:
            db.collection("usuarios").document(uid).delete()
            count += 1
            print(f"✅ Deletado: {email} (UID: {uid})")
        except Exception as e:
            print(f"❌ Erro ao deletar {email}: {e}")
    
    print(f"\n✅ Limpeza concluída! {count} usuário(s) órfão(s) deletado(s)")

def limpar_todos():
    resposta = input("\n⚠️  ATENÇÃO: Deseja realmente apagar TODOS os usuários? (sim/não): ")
    if resposta.lower() != "sim":
        print("❌ Operação cancelada")
        return
    
    # Limpar Firebase Auth
    print("\n🗑️  Limpando Firebase Auth...")
    page = auth.list_users()
    count_auth = 0
    for user in page.users:
        try:
            auth.delete_user(user.uid)
            count_auth += 1
            print(f"✅ Deletado: {user.email}")
        except Exception as e:
            print(f"❌ Erro ao deletar {user.email}: {e}")
    
    # Limpar Firestore
    print("\n🗑️  Limpando Firestore...")
    usuarios = db.collection("usuarios").stream()
    count_firestore = 0
    for doc in usuarios:
        try:
            db.collection("usuarios").document(doc.id).delete()
            count_firestore += 1
            print(f"✅ Deletado documento: {doc.id}")
        except Exception as e:
            print(f"❌ Erro ao deletar documento {doc.id}: {e}")
    
    print(f"\n✅ Limpeza concluída!")
    print(f"   Auth: {count_auth} usuários deletados")
    print(f"   Firestore: {count_firestore} documentos deletados")

def deletar_especifico():
    email = input("\n📧 Digite o email do usuário a deletar: ")
    try:
        user = auth.get_user_by_email(email)
        auth.delete_user(user.uid)
        print(f"✅ Usuário deletado do Auth: {email}")
        db.collection("usuarios").document(user.uid).delete()
        print(f"✅ Documento deletado do Firestore: {user.uid}")
    except auth.UserNotFoundError:
        print(f"❌ Usuário não encontrado: {email}")
    except Exception as e:
        print(f"❌ Erro: {e}")

def menu():
    while True:
        print("\n" + "="*50)
        print("GERENCIADOR DE USUÁRIOS FIREBASE")
        print("="*50)
        print("1. Listar todos os usuários")
        print("2. Limpar usuários órfãos (só no Firestore)")
        print("3. Limpar TODOS os usuários")
        print("4. Deletar usuário específico")
        print("5. Sair")
        print("="*50)
        
        opcao = input("\nEscolha uma opção: ")
        
        if opcao == "1":
            listar_usuarios()
        elif opcao == "2":
            limpar_orfaos()
        elif opcao == "3":
            limpar_todos()
        elif opcao == "4":
            deletar_especifico()
        elif opcao == "5":
            print("\n👋 Até logo!")
            break
        else:
            print("❌ Opção inválida!")

if __name__ == "__main__":
    menu()

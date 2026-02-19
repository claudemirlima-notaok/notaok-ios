import 'package:hive_flutter/hive_flutter.dart';
import '../models/produto.dart';
import '../models/nota_fiscal.dart';
import '../models/avaliacao.dart';
import '../models/comprovante.dart';
import '../models/usuario.dart';

class HiveService {
  static const String produtosBox = 'produtos';
  static const String notasFiscaisBox = 'notas_fiscais';
  static const String avaliacoesBox = 'avaliacoes';
  static const String comprovantesBox = 'comprovantes';
  static const String usuariosBox = 'usuarios';

  // 🔒 Flag para controlar se já foi inicializado
  static bool _isInitialized = false;

  // Inicializar Hive (com proteção contra múltiplas chamadas)
  static Future<void> init() async {
    // ✅ Se já foi inicializado, não fazer nada
    if (_isInitialized) {
      print('⚠️ HiveService já foi inicializado anteriormente');
      return;
    }

    await Hive.initFlutter();

    // Registrar adaptadores SOMENTE se ainda não foram registrados
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProdutoAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NotaFiscalAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AvaliacaoAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ComprovanteAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(UsuarioAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(EnderecoAdapter());
    }

    // Abrir boxes SOMENTE se ainda não estão abertas
    if (!Hive.isBoxOpen(produtosBox)) {
      await Hive.openBox<Produto>(produtosBox);
    }
    if (!Hive.isBoxOpen(notasFiscaisBox)) {
      await Hive.openBox<NotaFiscal>(notasFiscaisBox);
    }
    if (!Hive.isBoxOpen(avaliacoesBox)) {
      await Hive.openBox<Avaliacao>(avaliacoesBox);
    }
    if (!Hive.isBoxOpen(comprovantesBox)) {
      await Hive.openBox<Comprovante>(comprovantesBox);
    }
    if (!Hive.isBoxOpen(usuariosBox)) {
      await Hive.openBox<Usuario>(usuariosBox);
    }

    // ✅ Marcar como inicializado
    _isInitialized = true;
    print('✅ HiveService inicializado com sucesso!');
  }

  // Produtos
  static Box<Produto> get produtosDatabase => Hive.box<Produto>(produtosBox);

  static Future<void> adicionarProduto(Produto produto) async {
    await produtosDatabase.put(produto.id, produto);
  }

  static Future<void> atualizarProduto(Produto produto) async {
    await produtosDatabase.put(produto.id, produto);
  }

  static Future<void> deletarProduto(String id) async {
    await produtosDatabase.delete(id);
  }

  static Produto? getProduto(String id) {
    return produtosDatabase.get(id);
  }

  static List<Produto> getTodosProdutos() {
    return produtosDatabase.values.toList();
  }

  static List<Produto> getProdutosAtivos() {
    return produtosDatabase.values
        .where((p) => p.garantiaAtiva && p.diasRestantesGarantia > 0)
        .toList()
      ..sort((a, b) => a.diasRestantesGarantia.compareTo(b.diasRestantesGarantia));
  }

  // Notas Fiscais
  static Box<NotaFiscal> get notasFiscaisDatabase => Hive.box<NotaFiscal>(notasFiscaisBox);

  static Future<void> adicionarNotaFiscal(NotaFiscal nota) async {
    await notasFiscaisDatabase.put(nota.id, nota);
  }

  static Future<void> atualizarNotaFiscal(NotaFiscal nota) async {
    await notasFiscaisDatabase.put(nota.id, nota);
  }

  static Future<void> deletarNotaFiscal(String id) async {
    await notasFiscaisDatabase.delete(id);
  }

  static NotaFiscal? getNotaFiscal(String id) {
    return notasFiscaisDatabase.get(id);
  }

  static List<NotaFiscal> getTodasNotasFiscais() {
    return notasFiscaisDatabase.values.toList()
      ..sort((a, b) => b.dataEmissao.compareTo(a.dataEmissao));
  }

  // Avaliações
  static Box<Avaliacao> get avaliacoesDatabase => Hive.box<Avaliacao>(avaliacoesBox);

  static Future<void> adicionarAvaliacao(Avaliacao avaliacao) async {
    await avaliacoesDatabase.put(avaliacao.id, avaliacao);
  }

  static Future<void> atualizarAvaliacao(Avaliacao avaliacao) async {
    await avaliacoesDatabase.put(avaliacao.id, avaliacao);
  }

  static Future<void> deletarAvaliacao(String id) async {
    await avaliacoesDatabase.delete(id);
  }

  static Avaliacao? getAvaliacao(String id) {
    return avaliacoesDatabase.get(id);
  }

  static List<Avaliacao> getTodasAvaliacoes() {
    return avaliacoesDatabase.values.toList()
      ..sort((a, b) => b.dataAvaliacao.compareTo(a.dataAvaliacao));
  }

  // Comprovantes
  static Box<Comprovante> get comprovantesDatabase => Hive.box<Comprovante>(comprovantesBox);

  static Future<void> adicionarComprovante(Comprovante comprovante) async {
    await comprovantesDatabase.put(comprovante.id, comprovante);
  }

  static Future<void> atualizarComprovante(Comprovante comprovante) async {
    await comprovantesDatabase.put(comprovante.id, comprovante);
  }

  static Future<void> deletarComprovante(String id) async {
    await comprovantesDatabase.delete(id);
  }

  static Comprovante? getComprovante(String id) {
    return comprovantesDatabase.get(id);
  }

  static List<Comprovante> getTodosComprovantes() {
    return comprovantesDatabase.values.toList()
      ..sort((a, b) => b.dataCadastro.compareTo(a.dataCadastro));
  }

  // Usuários
  static Box<Usuario> get usuariosDatabase => Hive.box<Usuario>(usuariosBox);

  static Future<void> salvarUsuario(Usuario usuario) async {
    await usuariosDatabase.put('usuario_atual', usuario);
  }

  static Usuario? getUsuarioAtual() {
    return usuariosDatabase.get('usuario_atual');
  }

  static Future<void> limparUsuario() async {
    await usuariosDatabase.clear();
  }
}

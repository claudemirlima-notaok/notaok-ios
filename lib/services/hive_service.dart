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

  // Inicializar Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // Registrar adaptadores
    Hive.registerAdapter(ProdutoAdapter());
    Hive.registerAdapter(NotaFiscalAdapter());
    Hive.registerAdapter(AvaliacaoAdapter());
    Hive.registerAdapter(ComprovanteAdapter());
    Hive.registerAdapter(UsuarioAdapter());
    Hive.registerAdapter(EnderecoAdapter());

    // Abrir boxes
    await Hive.openBox<Produto>(produtosBox);
    await Hive.openBox<NotaFiscal>(notasFiscaisBox);
    await Hive.openBox<Avaliacao>(avaliacoesBox);
    await Hive.openBox<Comprovante>(comprovantesBox);
    await Hive.openBox<Usuario>(usuariosBox);
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

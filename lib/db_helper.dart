import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  late Database _db;

  DBHelper() {
    _initDB(); // Chama o método assíncrono no construtor
  }

  // Acesse o banco de dados de forma segura
  Future<Database> get db async {
    return _db;
  }

  // Método que inicializa o banco de dados
  Future<void> _initDB() async {
    String path = await getDatabasesPath();
    _db = await openDatabase(
      join(path, 'pontos.db'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE pontos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data DATE,
            entrada TIME,
            saida_intervalo TIME,
            retorno_intervalo TIME,
            saida TIME
        )''');
      },
      version: 1,
    );
  }

  // Método para adicionar ponto no banco de dados
  Future<void> adicionarPonto(String data, String entrada, String? saidaIntervalo, String? retornoIntervalo, String? saida) async {
    final dbClient = await db;
    await dbClient.insert(
      'pontos',
      {
        'data': data,
        'entrada': entrada,
        'saida_intervalo': saidaIntervalo,
        'retorno_intervalo': retornoIntervalo,
        'saida': saida,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Método para atualizar ponto no banco de dados
  Future<void> atualizarPonto(String data, String? entrada, String? saidaIntervalo, String? retornoIntervalo, String? saida) async {
    final dbClient = await db;
    await dbClient.update(
      'pontos',
      {
        'entrada': entrada,
        'saida_intervalo': saidaIntervalo,
        'retorno_intervalo': retornoIntervalo,
        'saida': saida,
      },
      where: 'data = ?',
      whereArgs: [data],
    );
  }

  // Método para obter ponto por data
  Future<Map<String, dynamic>?> obterPontoPorData(String data) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> results = await dbClient.query(
      'pontos',
      where: 'data = ?',
      whereArgs: [data],
    );
    if (results.isEmpty) {
      return null;
    } else {
      return results.first;
    }
  }

  // Método para obter todos os pontos
  Future<List<Map<String, dynamic>>> obterTodosPontos() async {
    final dbClient = await db;
    return dbClient.query('pontos');
  }
}

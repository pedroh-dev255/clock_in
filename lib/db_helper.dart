import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Ponto {
  String data;
  String? entrada;
  String? saidaIntervalo;
  String? retornoIntervalo;
  String? saida;

  Ponto({
    required this.data,
    this.entrada,
    this.saidaIntervalo,
    this.retornoIntervalo,
    this.saida,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'entrada': entrada,
      'saida_intervalo': saidaIntervalo,
      'retorno_intervalo': retornoIntervalo,
      'saida': saida,
    };
  }
}



class DBHelper {
  Database? _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDB();
    }
    return _db!;
  }

  // Método que inicializa o banco de dados
  Future<Database> _initDB() async {
    String path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'pontos.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pontos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT NOT NULL,
            entrada TEXT NOT NULL,
            saida_intervalo TEXT,
            retorno_intervalo TEXT,
            saida TEXT
          )
        ''');
      },
    );
  }

  Future<void> adicionarPonto(Ponto ponto) async {
  final dbClient = await db;
  await dbClient.insert(
    'pontos',
    ponto.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  Future<void> atualizarPonto(Ponto ponto) async {
    final dbClient = await db;

    await dbClient.update(
      'pontos',
      ponto.toMap(),
      where: 'data = ?',
      whereArgs: [ponto.data],
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
    return results.isEmpty ? null : results.first;
  }

  // Método para obter todos os pontos
  Future<List<Map<String, dynamic>>> obterTodosPontos() async {
    final dbClient = await db;
    return await dbClient.query('pontos');
  }
}

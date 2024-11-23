import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'google_auth.dart';

// Classe para a tabela de pontos
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

  static Ponto fromMap(Map<String, dynamic> map) {
    return Ponto(
      data: map['data'],
      entrada: map['entrada'],
      saidaIntervalo: map['saida_intervalo'],
      retornoIntervalo: map['retorno_intervalo'],
      saida: map['saida'],
    );
  }
}

// Classe para a tabela de configurações
class Configuracoes {
  int id;
  String entradaPadraoSemana;
  String saidaIntervaloPadraoSemana;
  String retornoIntervaloPadraoSemana;
  String saidaPadraoSemana;
  String entradaPadraoSabado;
  String saidaPadraoSabado;
  int horasMensais;
  int horasSemanais;

  Configuracoes({
    this.id = 1,
    required this.entradaPadraoSemana,
    required this.saidaIntervaloPadraoSemana,
    required this.retornoIntervaloPadraoSemana,
    required this.saidaPadraoSemana,
    required this.entradaPadraoSabado,
    required this.saidaPadraoSabado,
    required this.horasMensais,
    required this.horasSemanais,
  });

  @override
  String toString() {
    return 'Configuracoes(entradaSemana: $entradaPadraoSemana, saidaIntervaloSemana: $saidaIntervaloPadraoSemana, retornoIntervaloSemana: $retornoIntervaloPadraoSemana, saidaSemana: $saidaPadraoSemana, entradaSabado: $entradaPadraoSabado, saidaSabado: $saidaPadraoSabado, horasMensais: $horasMensais, horasSemanais: $horasSemanais)';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entrada_padrao_semana': entradaPadraoSemana,
      'saida_intervalo_padrao_semana': saidaIntervaloPadraoSemana,
      'retorno_intervalo_padrao_semana': retornoIntervaloPadraoSemana,
      'saida_padrao_semana': saidaPadraoSemana,
      'entrada_padrao_sabado': entradaPadraoSabado,
      'saida_padrao_sabado': saidaPadraoSabado,
      'horas_mensais': horasMensais,
      'horas_semanais': horasSemanais,
    };
  }

  static Configuracoes fromMap(Map<String, dynamic> map) {
    return Configuracoes(
      id: map['id'],
      entradaPadraoSemana: map['entrada_padrao_semana'],
      saidaIntervaloPadraoSemana: map['saida_intervalo_padrao_semana'],
      retornoIntervaloPadraoSemana: map['retorno_intervalo_padrao_semana'],
      saidaPadraoSemana: map['saida_padrao_semana'],
      entradaPadraoSabado: map['entrada_padrao_sabado'],
      saidaPadraoSabado: map['saida_padrao_sabado'],
      horasMensais: map['horas_mensais'],
      horasSemanais: map['horas_semanais'],
    );
  }
}

// Classe DBHelper para gerenciar o banco de dados
class DBHelper {
  Database? _db;
  final GoogleDriveSync _googleDriveSync = GoogleDriveSync();

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDB();
    }
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'pontos.db'),
      version: 2, // Versão atual do banco
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pontos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT NOT NULL,
            entrada TEXT,
            saida_intervalo TEXT,
            retorno_intervalo TEXT,
            saida TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE configuracoes (
            id INTEGER PRIMARY KEY,
            entrada_padrao_semana TEXT NOT NULL,
            saida_intervalo_padrao_semana TEXT,
            retorno_intervalo_padrao_semana TEXT,
            saida_padrao_semana TEXT NOT NULL,
            entrada_padrao_sabado TEXT,
            saida_padrao_sabado TEXT,
            horas_mensais INTEGER NOT NULL,
            horas_semanais INTEGER NOT NULL
          )
        ''');
        await syncWithGoogleDrive(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE configuracoes (
              id INTEGER PRIMARY KEY,
              entrada_padrao_semana TEXT NOT NULL,
              saida_intervalo_padrao_semana TEXT,
              retorno_intervalo_padrao_semana TEXT,
              saida_padrao_semana TEXT NOT NULL,
              entrada_padrao_sabado TEXT,
              saida_padrao_sabado TEXT,
              horas_mensais INTEGER NOT NULL,
              horas_semanais INTEGER NOT NULL
            )
          ''');
          await syncWithGoogleDrive(db);
        }
      },
    );
  }

  Future<void> syncWithGoogleDrive(Database db) async {
    // Obter todos os pontos registrados
    final pontos = await db.query('pontos');
    final pontosJson = pontos.map((e) => json.encode(e)).toList();
    await _googleDriveSync.uploadData('pontos.json', pontosJson.join(','));

    // Obter configurações e sincronizar
    final configuracoes = await db.query('configuracoes');
    if (configuracoes.isNotEmpty) {
      final configuracaoJson = json.encode(configuracoes.first);
      await _googleDriveSync.uploadData('configuracoes.json', configuracaoJson);
    }
  }

  // Métodos para a tabela de pontos
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
    await syncWithGoogleDrive(dbClient);
  }

  Future<Map<String, dynamic>?> obterPontoPorData(String data) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> results = await dbClient.query(
      'pontos',
      where: 'data = ?',
      whereArgs: [data],
    );
    await syncWithGoogleDrive(dbClient);  
    return results.isEmpty ? null : results.first;
  }

  Future<List<Map<String, dynamic>>> obterTodosPontos() async {
    final dbClient = await db;
    return await dbClient.query('pontos');
  }

  // Métodos para a tabela de configurações
  Future<void> salvarConfiguracoes(Configuracoes config) async {
    final dbClient = await db;
    await dbClient.insert(
      'configuracoes',
      config.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Configuracoes?> obterConfiguracoes() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> results = await dbClient.query('configuracoes');
    if (results.isNotEmpty) {
      return Configuracoes.fromMap(results.first);
    }
    return null;
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/filme.dart';

class DatabaseHelper{

    // Definindo a versão do DB e nome da tabela
    static const int _version = 1;
    static const String _dbName = 'filmes_database.db';
    static const String _tableName = 'filmes';

    // Usando o padrão Singleton para ter apenas uma instância do DB
    static final DatabaseHelper instance = DatabaseHelper._internal();
    static Database? _database;

    DatabaseHelper._internal();

    // Getter para o banco de dados, inicializando-o se ainda não existir
    Future<Database> get database async {

        if(_database != null) return _database!;
        _database = await _initDatabase();
        return _database!;

    }

    // Inicializa o banco
    Future<Database> _initDatabase() async {

        // Obtém o caminho padrão onde o DB deve ser armazenado
        String dbPath = await getDatabasesPath();
        String path = join(dbPath, _dbName);

        // Abre o DB ou cria(caso não exista)
        return await openDatabase(
            path,
            version: _version,
            onCreate: _onCreate,
        );

    }

    // Criando as tabelas
    Future _onCreate(Database db, int version) async {

        await db.execute('''
            CREATE TABLE $_tableName (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                urlImagem TEXT NOT NULL,
                titulo TEXT NOT NULL,
                genero TEXT NOT NULL,
                faixaEtaria TEXT NOT NULL,
                duracao TEXT NOT NULL,
                nota REAL NOT NULL,
                ano INTEGER NOT NULL,
                descricao TEXT NOT NULL
            );
        '''); // CORRIGIDO: Adicionado ponto e vírgula final
    }

    // CRUD

    // CREATE: Inserindo um filme novo no banco de dados
    // CORRIGIDO: Nome da função agora é 'insertFilme' (camelCase)
    Future<int> insertFilme(Filme filme) async {
        Database db = await database;
        // O 'conflictAlgorithm' substitui o filme se o mesmo ID foi inserido
        return await db.insert(
            _tableName,
            filme.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
        ); // Inserir no banco
    }

    // READ: Retorna todos os filmes do banco
    Future<List<Filme>> getFilmes() async {
        Database db = await database;
        final List<Map<String, dynamic>> maps = await db.query(_tableName);

        // de List<Map> para List<Filme>
        return List.generate(maps.length, (i) {
            return Filme.fromMap(maps[i]);
        });
    }

    // UPDATE: Atualizar um filme
    Future<int> updateFilme(Filme filme) async {
        Database db = await database;
        return await db.update(
            _tableName,
            filme.toMap(),
            where: 'id = ?',
            whereArgs: [filme.id],
        );
    }

    // DELETE: Deletando um filme pelo ID
    Future<int> deleteFilme(int id) async {
        Database db = await database;
        return await db.delete(
            _tableName,
            where: 'id = ?',
            whereArgs: [id],
        );
    }
}
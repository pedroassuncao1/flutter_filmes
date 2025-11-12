class Filme {
  int? id;
  String urlImagem;
  String titulo;
  String genero;
  String faixaEtaria;
  String duracao;
  double nota;
  int ano;
  String descricao;

  Filme({
    this.id,
    required this.urlImagem,
    required this.titulo,
    required this.genero,
    required this.faixaEtaria,
    required this.duracao,
    required this.nota,
    required this.ano,
    required this.descricao,
  });

  // 1. Converte um objeto Filme para um Map para CREATE
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'urlImagem': urlImagem,
      'titulo': titulo,
      'genero': genero,
      'faixaEtaria': faixaEtaria,
      'duracao': duracao,
      'nota': nota,
      'ano': ano,
      'descricao': descricao,
    };
  }

  // 2. Cria um objeto Filme a partir de um Map para READ
  factory Filme.fromMap(Map<String, dynamic> map) {
    return Filme(
      id: map['id'],
      urlImagem: map['urlImagem'] as String,
      titulo: map['titulo'] as String,
      genero: map['genero'] as String,
      faixaEtaria: map['faixaEtaria'] as String,
      duracao: map['duracao'] as String,
      // O 'as num' garante a leitura de int ou double
      nota: (map['nota'] as num).toDouble(),
      ano: map['ano'] as int,
      descricao: map['descricao'] as String,
    );
  }
}
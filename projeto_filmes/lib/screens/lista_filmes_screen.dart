import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/filme.dart';
import '../database/database_helper.dart';
import 'cadastro_filme_screen.dart';
import 'detalhes_filme_screen.dart'; // <--- CORREÇÃO 1: Import de Detalhes

class ListaFilmesScreen extends StatefulWidget {
  const ListaFilmesScreen({super.key});

  @override
  State<ListaFilmesScreen> createState() => _ListaFilmesScreenState();
}

class _ListaFilmesScreenState extends State<ListaFilmesScreen> {
  // Lista que armazenará os filmes carregados do banco
  late Future<List<Filme>> _filmesFuture;

  @override
  void initState() {
    super.initState();
    _carregarFilmes();
  }

  // Função para carregar os filmes e atualizar o FutureBuilder
  void _carregarFilmes(){
    setState(() {
      _filmesFuture = DatabaseHelper.instance.getFilmes();
    });
  }

  // Mostra um alerta com o nome do grupo
  void _mostrarAlertaGrupo() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Informação do Grupo'),
              content: const Text('Projeto de Faculdade - Pedro Assunção, Ítalo Cauã, Pablo Samuel'),
              actions: <Widget> [
                TextButton(
                    child: const Text('Fechar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
                )
              ]
          );
        }
    );
  }

  // Lógica de Exclusão
  Future<bool> _confirmarExclusao(DismissDirection direction, Filme filme) async {
    if (direction == DismissDirection.endToStart) {
      await DatabaseHelper.instance.deleteFilme(filme.id!);
      _carregarFilmes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${filme.titulo} excluído!')),
      );
      return true;
    }
    return false;
  }

  // Barra de estrelas
  Widget _buildRatingBar(double nota){
    return RatingBar.builder(
      initialRating: nota,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 20.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {},
    );
  }

  // Widget de item da lista
  Widget _buildFilmeItem(Filme filme) {
    return Dismissible(
      key: Key(filme.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) => _confirmarExclusao(direction, filme),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
        child: ListTile(
          // <--- CORREÇÃO 2: Navegação para a Tela de Detalhes no clique
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalhesFilmeScreen(filme: filme),
              ),
              // Recarrega a lista quando voltar
            ).then((_) => _carregarFilmes());
          },
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          leading: SizedBox(
            width: 70,
            child: AspectRatio(
              aspectRatio: 2/3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: CachedNetworkImage(
                  imageUrl: filme.urlImagem,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          title: Text(
            filme.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 4),
              // Genero e duração
              Text('${filme.genero}, ${filme.duracao}'),
              const SizedBox(height: 4),
              // Widget de Estrelas
              _buildRatingBar(filme.nota),
            ],
          ),
        ),
      ),
    );
  }

  // BUILD PRINCIPAL DA TELA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filmes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Botão com alerta a direita
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _mostrarAlertaGrupo,
          ),
        ],
      ),

      // FutureBuilder para lidar com o carregamento dos filmes (assincrono)
      body: FutureBuilder<List<Filme>>(
        future: _filmesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());

          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar filmes: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum filme cadastrado. Clique em "+" para adicionar.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            // Se tiver algum dado, exibe a lista
            final filmes = snapshot.data!;
            return ListView.builder(
              itemCount: filmes.length,
              itemBuilder: (context, index) {
                return _buildFilmeItem(filmes[index]);
              },
            );
          }
        },
      ),

      // botão flutuante para adicionar filmes novos
      floatingActionButton: FloatingActionButton(
        // <--- CORREÇÃO 3: Adicionado heroTag para evitar conflito com outras telas
        heroTag: 'addBtn',
        onPressed: () {
          // Navega para a tela de cadastro e espera o resultado
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastroFilmeScreen(),
            ),
          ).then((result) {
            // Se 'result' for true (passado após o cadastro), recarrega a lista
            if (result == true) {
              _carregarFilmes();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
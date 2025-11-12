import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/filme.dart';
import 'cadastro_filme_screen.dart';

class DetalhesFilmeScreen extends StatelessWidget {
  final Filme filme;
  const DetalhesFilmeScreen({super.key, required this.filme});

  Widget _buildRatingBar(double nota) {
    return RatingBar.builder(
      initialRating: nota,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      ignoreGestures: true,
      itemCount: 5,
      itemSize: 22.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(filme.titulo),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            // Seção principal com capa, título e dados
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Imagem de Capa
                  SizedBox(
                    width: 120,
                    child: AspectRatio(
                      aspectRatio: 2 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: filme.urlImagem,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.movie, size: 50),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 2. Detalhes (Gênero, Duração, Nota, Ano, Faixa Etária)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 4),
                        // Gênero e Duração
                        Text(
                          '${filme.genero} • ${filme.duracao}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),

                        // Nota (Estrelas)
                        _buildRatingBar(filme.nota),
                        const SizedBox(height: 12),

                        // Ano e Faixa Etária
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${filme.ano}', style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                            const SizedBox(width: 16),
                            // Faixa Etária formatada
                            Text('${filme.faixaEtaria} anos', style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Linha Divisória
            const Divider(),

            // 3. Descrição/Sinopse
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sinopse:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    filme.descricao,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Botão Flutuante de Edição
      floatingActionButton: FloatingActionButton(
        heroTag: 'editBtn',
        onPressed: () {
          // Navega para a tela de Cadastro/Edição, passando o filme atual
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CadastroFilmeScreen(filmeParaEditar: filme),
            ),
          ).then((result) {
            // Recarrega a lista de filmes se a edição foi concluída com sucesso
            if (result == true) {
              // Volta para a lista principal e recarrega os filmes lá
              Navigator.pop(context, true);
            }
          });
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/filme.dart';
import '../database/database_helper.dart';

class CadastroFilmeScreen extends StatefulWidget {
  // Filme a ser editado
  final Filme? filmeParaEditar;

  const CadastroFilmeScreen({super.key, this.filmeParaEditar});

  @override
  State<CadastroFilmeScreen> createState() => _CadastroFilmeScreenState();
}

class _CadastroFilmeScreenState extends State<CadastroFilmeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final TextEditingController _duracaoController = TextEditingController();
  final TextEditingController _anoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  String? _faixaEtariaSelecionada;
  double _notaSelecionada = 0.0;

  final List<String> _faixaEtariaOpcoes = [
    'Livre',
    '10',
    '12',
    '14',
    '16',
    '18'
  ];

  @override
  void initState() {
    super.initState();
    // Preenche os campos se estiver em modo Edição
    if (widget.filmeParaEditar != null) {
      final filme = widget.filmeParaEditar!;
      _urlController.text = filme.urlImagem;
      _tituloController.text = filme.titulo;
      _generoController.text = filme.genero;
      _duracaoController.text = filme.duracao;
      _anoController.text = filme.ano.toString();
      _descricaoController.text = filme.descricao;

      _faixaEtariaSelecionada = filme.faixaEtaria;
      _notaSelecionada = filme.nota;
    }
  }

  Future<void> _salvarFilme() async {
    if (!_formKey.currentState!.validate()) {
      return; // Sai se a validação falha
    }

    // Cria o objeto, incluindo o ID se estiver editando
    final filmeParaSalvar = Filme(
      id: widget.filmeParaEditar?.id,
      urlImagem: _urlController.text,
      titulo: _tituloController.text,
      genero: _generoController.text,
      faixaEtaria: _faixaEtariaSelecionada ?? 'Livre',
      duracao: _duracaoController.text,
      nota: _notaSelecionada,
      ano: int.tryParse(_anoController.text) ?? 0,
      descricao: _descricaoController.text,
    );

    String mensagem;
    if (widget.filmeParaEditar == null) {
      await DatabaseHelper.instance.insertFilme(filmeParaSalvar);
      mensagem = 'Filme cadastrado com sucesso!';
    } else {
      await DatabaseHelper.instance.updateFilme(filmeParaSalvar);
      mensagem = 'Filme atualizado com sucesso!';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );

    // Fecha a tela e retorna 'true' para recarregar a lista
    Navigator.pop(context, true);
  }

  // Limpa todos os TextEditingController para evitar memory leak
  @override
  void dispose() {
    _urlController.dispose();
    _tituloController.dispose();
    _generoController.dispose();
    _duracaoController.dispose();
    _anoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle = widget.filmeParaEditar == null ? 'Cadastrando Filme' : 'Editando Filme';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              // 1. URL Imagem
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'Url Imagem', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Insira a URL da imagem.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Título
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Insira o título do filme.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Gênero
              TextFormField(
                controller: _generoController,
                decoration: const InputDecoration(labelText: 'Gênero', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Insira o gênero.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 4. Faixa Etária
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Faixa Etária: Livre -',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  errorText: (_faixaEtariaSelecionada == null && _formKey.currentState != null && !_formKey.currentState!.validate())
                      ? 'Selecione a faixa etária.'
                      : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _faixaEtariaSelecionada,
                    hint: const Text('Selecione a Faixa Etária'),
                    isExpanded: true,
                    items: _faixaEtariaOpcoes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _faixaEtariaSelecionada = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Duração
              TextFormField(
                controller: _duracaoController,
                decoration: const InputDecoration(labelText: 'Duração', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Insira a duração.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 6. Nota (RatingBar)
              const Text('Nota:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: _notaSelecionada,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _notaSelecionada = rating;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 7. Ano
              TextFormField(
                controller: _anoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Ano', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Insira o ano.';
                  if (int.tryParse(value) == null) return 'Insira um ano válido.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 8. Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Insira a descrição.';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão de Cadastrar / Atualizar (Agora é um Elevated Button, não o FAB)
              ElevatedButton.icon(
                onPressed: _salvarFilme,
                icon: Icon(widget.filmeParaEditar == null ? Icons.save : Icons.update),
                label: Text(widget.filmeParaEditar == null ? 'Cadastrar Filme' : 'Atualizar Filme', style: const TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),


      floatingActionButton: FloatingActionButton(
        heroTag: 'saveUpdateFab',
        onPressed: _salvarFilme,
        child: Icon(widget.filmeParaEditar == null ? Icons.save : Icons.update),
      ),
    );
  }
}
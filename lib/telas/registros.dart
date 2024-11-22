import 'package:flutter/material.dart';
import '../db_helper.dart';  // Importando o DBHelper
//import 'package:intl/intl.dart';

class TelaPontosRegistrados extends StatelessWidget {
  final DBHelper _dbHelper = DBHelper();

  TelaPontosRegistrados({super.key});  // Inicializando diretamente na declaração

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios de Ponto')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbHelper.obterTodosPontos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os registros'));
          }

          final pontos = snapshot.data ?? [];

          return ListView.builder(
            itemCount: pontos.length,
            itemBuilder: (context, index) {
              final ponto = pontos[index];
              return ListTile(
                title: Text('Data: ${ponto['data']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Entrada: ${ponto['entrada']}'),
                    Text('Saída Intervalo: ${ponto['saida_intervalo']}'),
                    Text('Retorno Intervalo: ${ponto['retorno_intervalo']}'),
                    Text('Saída: ${ponto['saida']}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

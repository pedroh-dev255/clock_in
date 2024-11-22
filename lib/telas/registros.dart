import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para manipulação de datas e formatação
import '../db_helper.dart';

class TelaPontosRegistrados extends StatefulWidget {
  @override
  _TelaPontosRegistradosState createState() => _TelaPontosRegistradosState();
}

class _TelaPontosRegistradosState extends State<TelaPontosRegistrados> {
  final DBHelper _dbHelper = DBHelper();

  late Future<List<Map<String, dynamic>>> _futurePontos;
  int _mesSelecionado = DateTime.now().month;
  int _anoSelecionado = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _carregarPontos();
  }

  // Recarrega os pontos do banco
  void _carregarPontos() {
    setState(() {
      _futurePontos = _dbHelper.obterTodosPontos();
    });
  }

  // Gera todos os dias do mês selecionado
  List<String> _gerarDiasDoMes() {
    final firstDay = DateTime(_anoSelecionado, _mesSelecionado, 1);
    final lastDay = DateTime(_anoSelecionado, _mesSelecionado + 1, 0);
    return List.generate(
      lastDay.day,
      (index) => DateFormat('dd/MM/yyyy').format(firstDay.add(Duration(days: index))),
    );
  }

  // Calcula as horas trabalhadas para um dia específico
  double _calcularHorasTrabalhadas(Map<String, dynamic> ponto) {
    if (ponto['entrada'] == null || ponto['saida'] == null) return 0.0;

    final entrada = DateFormat('HH:mm').parse(ponto['entrada']);
    final saida = DateFormat('HH:mm').parse(ponto['saida']);
    final saidaIntervalo = ponto['saida_intervalo'] != null
        ? DateFormat('HH:mm').parse(ponto['saida_intervalo'])
        : null;
    final retornoIntervalo = ponto['retorno_intervalo'] != null
        ? DateFormat('HH:mm').parse(ponto['retorno_intervalo'])
        : null;

    Duration totalTrabalhado = saida.difference(entrada);

    if (saidaIntervalo != null && retornoIntervalo != null) {
      totalTrabalhado -= retornoIntervalo.difference(saidaIntervalo);
    }

    return totalTrabalhado.inMinutes / 60.0; // Retorna horas trabalhadas
  }

  // Deleta o registro no banco de dados
  Future<void> _deletarRegistro(BuildContext context, String data) async {
    final confirmar = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content: Text("Tem certeza que deseja excluir o registro do dia $data?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await _dbHelper.db.then((db) {
        db.delete('pontos', where: 'data = ?', whereArgs: [data]);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro do dia $data excluído com sucesso.')),
      );
      _carregarPontos(); // Recarrega a tela
    }
  }

  @override
  Widget build(BuildContext context) {
    final diasDoMes = _gerarDiasDoMes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios de Ponto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarPontos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown para selecionar mês e ano
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DropdownButton<int>(
                  value: _mesSelecionado,
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(DateFormat.MMMM().format(DateTime(0, index + 1))),
                    );
                  }),
                  onChanged: (novoMes) {
                    setState(() {
                      _mesSelecionado = novoMes!;
                      _carregarPontos();
                    });
                  },
                ),
                DropdownButton<int>(
                  value: _anoSelecionado,
                  items: List.generate(10, (index) {
                    final ano = DateTime.now().year - 5 + index;
                    return DropdownMenuItem(
                      value: ano,
                      child: Text(ano.toString()),
                    );
                  }),
                  onChanged: (novoAno) {
                    setState(() {
                      _anoSelecionado = novoAno!;
                      _carregarPontos();
                    });
                  },
                ),
              ],
            ),
          ),
          // Lista de registros
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futurePontos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar os registros'));
                }

                final pontos = snapshot.data ?? [];
                final registrosPorData = {for (var ponto in pontos) ponto['data']: ponto};

                return ListView.builder(
                  itemCount: diasDoMes.length,
                  itemBuilder: (context, index) {
                    final dia = diasDoMes[index];
                    final ponto = registrosPorData[dia];
                    final horasTrabalhadas =
                        ponto != null ? _calcularHorasTrabalhadas(ponto) : 0.0;

                    return ListTile(
                      title: Text(
                        dia,
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: ponto != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Entrada: ${ponto['entrada'] ?? "-"}'),
                                Text('Saída Intervalo: ${ponto['saida_intervalo'] ?? "-"}'),
                                Text('Retorno Intervalo: ${ponto['retorno_intervalo'] ?? "-"}'),
                                Text('Saída: ${ponto['saida'] ?? "-"}'),
                              ],
                            )
                          : const Text("Sem registros"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Horas trabalhadas
                          Text(
                            horasTrabalhadas.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: horasTrabalhadas == 0
                                  ? Colors.grey // Cinza para 0 horas trabalhadas
                                  : (horasTrabalhadas >= 8.0 ? Colors.green : Colors.red),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Botão de deletar
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletarRegistro(context, dia),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db_helper.dart';  // Importando o DBHelper

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final TextEditingController _horarioController = TextEditingController();
  bool _isButtonDisabled = false; // Variável para desabilitar o botão por 15 minutos
  late DBHelper _dbHelper = DBHelper();  // Instância do DBHelper

  @override
  void initState() {
    super.initState();
    _dbHelper = DBHelper();  // Inicializando o DBHelper aqui
    _horarioController.text = DateFormat('HH:mm').format(DateTime.now());
  }

  void _registrarHorario() async {
    String hora = _horarioController.text;
    String data = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Obtém o ponto existente para a data atual
    final pontoExistente = await _dbHelper.obterPontoPorData(data);

    if (pontoExistente == null) {
      // Cria um novo registro caso não exista
      await _dbHelper.adicionarPonto(Ponto(
        data: data,
        entrada: hora,
        saidaIntervalo: null,
        retornoIntervalo: null,
        saida: null,
      ));
    } else {
      // Cria uma cópia mutável do ponto existente
      final pontoAtualizado = {
        'data': pontoExistente['data'],
        'entrada': pontoExistente['entrada'],
        'saida_intervalo': pontoExistente['saida_intervalo'],
        'retorno_intervalo': pontoExistente['retorno_intervalo'],
        'saida': pontoExistente['saida'],
      };

      // Atualiza o horário disponível na ordem correta
      if (pontoAtualizado['saida_intervalo'] == null) {
        pontoAtualizado['saida_intervalo'] = hora;
      } else if (pontoAtualizado['retorno_intervalo'] == null) {
        pontoAtualizado['retorno_intervalo'] = hora;
      } else if (pontoAtualizado['saida'] == null) {
        pontoAtualizado['saida'] = hora;
      } else {
        // Todos os horários já foram preenchidos
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Erro"),
              content: const Text("Todos os horários para o dia já foram preenchidos."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
        return;
      }

      // Atualiza o ponto no banco de dados
      await _dbHelper.atualizarPonto(Ponto(
        data: pontoAtualizado['data'],
        entrada: pontoAtualizado['entrada'],
        saidaIntervalo: pontoAtualizado['saida_intervalo'],
        retornoIntervalo: pontoAtualizado['retorno_intervalo'],
        saida: pontoAtualizado['saida'],
      ));
    }

    // Mensagem de confirmação
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Horário Registrado"),
          content: Text("Horário $hora foi salvo!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );

    // Desabilitar o botão por 15 minutos
    setState(() {
      _isButtonDisabled = true;
    });

    Future.delayed(const Duration(minutes: 15), () {
      setState(() {
        _isButtonDisabled = false;
      });
    });
  }



  Future<void> _mostrarTimePicker() async {
    final TimeOfDay? horarioEscolhido = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (horarioEscolhido != null) {
      setState(() {
        // Converte TimeOfDay para DateTime
        final now = DateTime.now();
        final selectedTime = DateTime(
          now.year,
          now.month,
          now.day,
          horarioEscolhido.hour,
          horarioEscolhido.minute,
        );

        // Atualiza o campo de texto com o horário no formato 24h
        _horarioController.text = DateFormat('HH:mm').format(selectedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Ponto'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
            crossAxisAlignment: CrossAxisAlignment.center, // Centraliza horizontalmente
            children: [
              GestureDetector(
                onTap: _mostrarTimePicker,
                child: AbsorbPointer(
                  child: SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _horarioController,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: 'Horário',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isButtonDisabled ? null : _registrarHorario,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: Text(
                  'Registrar Ponto',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db_helper.dart';  // Importando o DBHelper

class TelaManual extends StatefulWidget {
  const TelaManual({super.key});

  @override
  _TelaManualState createState() => _TelaManualState();
}

class _TelaManualState extends State<TelaManual> {
  DateTime _dataSelecionada = DateTime.now();
  late DBHelper _dbHelper = DBHelper();

  final TextEditingController _entradaController = TextEditingController();
  final TextEditingController _saidaIntervaloController = TextEditingController();
  final TextEditingController _retornoIntervaloController = TextEditingController();
  final TextEditingController _saidaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper = DBHelper();  // Inicializando o DBHelper aqui
    _entradaController.text = "08:00";
    _saidaIntervaloController.text = "11:00";
    _retornoIntervaloController.text = "13:00";
    _saidaController.text = "18:00";
  }

  Future<void> _selecionarData() async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (dataEscolhida != null && dataEscolhida != _dataSelecionada) {
      setState(() {
        _dataSelecionada = dataEscolhida;
      });
    }
  }

  void _salvarHorario() async {
    final String dataFormatada = DateFormat('yyyy-MM-dd').format(_dataSelecionada);

    final pontoExistente = await _dbHelper.obterPontoPorData(dataFormatada);

    if (pontoExistente == null) {
      await _dbHelper.adicionarPonto(dataFormatada,
          _entradaController.text,
          _saidaIntervaloController.text,
          _retornoIntervaloController.text,
          _saidaController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ponto registrado para $dataFormatada")));
    } else {
      await _dbHelper.atualizarPonto(dataFormatada,
          _entradaController.text,
          _saidaIntervaloController.text,
          _retornoIntervaloController.text,
          _saidaController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ponto atualizado para $dataFormatada")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro Manual')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _selecionarData,
              child: Text('Selecionar Data: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada)}'),
            ),
            TextField(controller: _entradaController, decoration: const InputDecoration(labelText: 'Entrada')),
            TextField(controller: _saidaIntervaloController, decoration: const InputDecoration(labelText: 'Saída Intervalo')),
            TextField(controller: _retornoIntervaloController, decoration: const InputDecoration(labelText: 'Retorno Intervalo')),
            TextField(controller: _saidaController, decoration: const InputDecoration(labelText: 'Saída')),
            ElevatedButton(onPressed: _salvarHorario, child: const Text('Salvar Horário')),
          ],
        ),
      ),
    );
  }
}

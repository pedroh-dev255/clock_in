import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db_helper.dart'; // Importando o DBHelper

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
    _dbHelper = DBHelper(); // Inicializando o DBHelper aqui
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

  Future<void> _selecionarHorario(TextEditingController controller) async {
    final TimeOfDay? horarioEscolhido = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (horarioEscolhido != null) {
      final String horarioFormatado =
          horarioEscolhido.hour.toString().padLeft(2, '0') +
              ':' +
              horarioEscolhido.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = horarioFormatado;
      });
    }
  }

  void _salvarHorario() async {
    final String dataFormatada = DateFormat('dd/MM/yyyy').format(_dataSelecionada);

    final pontoExistente = await _dbHelper.obterPontoPorData(dataFormatada);

    if (pontoExistente == null) {
      // Cria um novo registro caso não exista
      await _dbHelper.adicionarPonto(Ponto(
        data: dataFormatada,
        entrada: _entradaController.text,
        saidaIntervalo: _saidaIntervaloController.text,
        retornoIntervalo: _retornoIntervaloController.text,
        saida: _saidaController.text,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ponto registrado para $dataFormatada")));
    } else {
      // Atualiza os horários
      await _dbHelper.atualizarPonto(Ponto(
        data: dataFormatada,
        entrada: _entradaController.text,
        saidaIntervalo: _saidaIntervaloController.text,
        retornoIntervalo: _retornoIntervaloController.text,
        saida: _saidaController.text,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ponto atualizado para $dataFormatada")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro Manual')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding horizontal
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _selecionarData,
              child: Text('Selecionar Data: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada)}'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _entradaController,
              decoration: const InputDecoration(labelText: 'Entrada'),
              readOnly: true, // Desabilita a edição manual
              onTap: () => _selecionarHorario(_entradaController),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _saidaIntervaloController,
              decoration: const InputDecoration(labelText: 'Saída Intervalo'),
              readOnly: true, // Desabilita a edição manual
              onTap: () => _selecionarHorario(_saidaIntervaloController),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _retornoIntervaloController,
              decoration: const InputDecoration(labelText: 'Retorno Intervalo'),
              readOnly: true, // Desabilita a edição manual
              onTap: () => _selecionarHorario(_retornoIntervaloController),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _saidaController,
              decoration: const InputDecoration(labelText: 'Saída'),
              readOnly: true, // Desabilita a edição manual
              onTap: () => _selecionarHorario(_saidaController),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _salvarHorario, child: const Text('Salvar Horário')),
          ],
        ),
      ),
    );
  }
}

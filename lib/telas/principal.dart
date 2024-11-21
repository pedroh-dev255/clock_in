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

    // Salvando o horário no banco de dados
    await _dbHelper.adicionarPonto(data, hora, null, null, null);

    // Exibindo uma mensagem de confirmação
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
        _isButtonDisabled = false; // Habilitar o botão após 15 minutos
      });
    });
  }

  Future<void> _mostrarTimePicker() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        final selectedTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}

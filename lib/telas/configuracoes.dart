import 'package:flutter/material.dart';
import '../db_helper.dart';

class TelaConfiguracoes extends StatefulWidget {
  @override
  _TelaConfiguracoesState createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  final DBHelper _dbHelper = DBHelper();
  final _formKey = GlobalKey<FormState>();

  String entradaSemana = '';
  String saidaIntervaloSemana = '';
  String retornoIntervaloSemana = '';
  String saidaSemana = '';
  String entradaSabado = '';
  String saidaSabado = '';
  int horasMensais = 0;
  int horasSemanais = 0;

  // Controladores para os campos de hora
  final TextEditingController _entradaSemanaController = TextEditingController();
  final TextEditingController _saidaIntervaloSemanaController = TextEditingController();
  final TextEditingController _retornoIntervaloSemanaController = TextEditingController();
  final TextEditingController _saidaSemanaController = TextEditingController();
  final TextEditingController _entradaSabadoController = TextEditingController();
  final TextEditingController _saidaSabadoController = TextEditingController();
  final TextEditingController _horasMensaisController = TextEditingController();
  final TextEditingController _horasSemanaisController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    
    final config = await _dbHelper.obterConfiguracoes();
    print('Configuração carregada: $config');
    if (config != null) {
      setState(() {
        entradaSemana = config.entradaPadraoSemana;
        saidaIntervaloSemana = config.saidaIntervaloPadraoSemana;
        retornoIntervaloSemana = config.retornoIntervaloPadraoSemana;
        saidaSemana = config.saidaPadraoSemana;
        entradaSabado = config.entradaPadraoSabado;
        saidaSabado = config.saidaPadraoSabado;
        horasMensais = config.horasMensais;
        horasSemanais = config.horasSemanais;

        // Atualizar os controladores com as horas carregadas
        _entradaSemanaController.text = entradaSemana;
        _saidaIntervaloSemanaController.text = saidaIntervaloSemana;
        _retornoIntervaloSemanaController.text = retornoIntervaloSemana;
        _saidaSemanaController.text = saidaSemana;
        _entradaSabadoController.text = entradaSabado;
        _saidaSabadoController.text = saidaSabado;
        _horasMensaisController.text = horasMensais.toString();
        _horasSemanaisController.text = horasSemanais.toString();


      });
    }
  }

  Future<void> _salvarConfiguracoes() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final config = Configuracoes(
        entradaPadraoSemana: entradaSemana,
        saidaIntervaloPadraoSemana: saidaIntervaloSemana,
        retornoIntervaloPadraoSemana: retornoIntervaloSemana,
        saidaPadraoSemana: saidaSemana,
        entradaPadraoSabado: entradaSabado,
        saidaPadraoSabado: saidaSabado,
        horasMensais: horasMensais,
        horasSemanais: horasSemanais,
      );
      
      // Imprimir os dados formatados de configuração
      print('Configuracoes a serem salvas: ${config.toString()}');
      
      await _dbHelper.salvarConfiguracoes(config);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações salvas com sucesso!')),
      );
    }
  }

  Future<void> _selecionarHora(BuildContext context, String campo) async {
    TimeOfDay time = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && picked != time) {
      setState(() {
        String horaFormatada = _formatarHora24h(picked);
        // Atualiza o campo correspondente
        if (campo == 'entradaSemana') {
          entradaSemana = horaFormatada;
          _entradaSemanaController.text = horaFormatada;
        } else if (campo == 'saidaIntervaloSemana') {
          saidaIntervaloSemana = horaFormatada;
          _saidaIntervaloSemanaController.text = horaFormatada;
        } else if (campo == 'retornoIntervaloSemana') {
          retornoIntervaloSemana = horaFormatada;
          _retornoIntervaloSemanaController.text = horaFormatada;
        } else if (campo == 'saidaSemana') {
          saidaSemana = horaFormatada;
          _saidaSemanaController.text = horaFormatada;
        } else if (campo == 'entradaSabado') {
          entradaSabado = horaFormatada;
          _entradaSabadoController.text = horaFormatada;
        } else if (campo == 'saidaSabado') {
          saidaSabado = horaFormatada;
          _saidaSabadoController.text = horaFormatada;
        }
      });
    }
  }

  String _formatarHora24h(TimeOfDay time) {
    final int hora24h = time.hour;
    final int minuto = time.minute;
    return '${hora24h.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Entrada Semana
              TextFormField(
                controller: _entradaSemanaController,
                decoration: const InputDecoration(labelText: 'Entrada (Semana)'),
                readOnly: true,
                onTap: () => _selecionarHora(context, 'entradaSemana'),
                onSaved: (value) => entradaSemana = value ?? '',
              ),
              // Saída para Intervalo Semana
              TextFormField(
                controller: _saidaIntervaloSemanaController,
                decoration: const InputDecoration(labelText: 'Saída para Intervalo (Semana)'),
                readOnly: true,
                onTap: () => _selecionarHora(context, 'saidaIntervaloSemana'),
                onSaved: (value) => saidaIntervaloSemana = value ?? '',
              ),
              // Retorno do Intervalo Semana
              TextFormField(
                controller: _retornoIntervaloSemanaController,
                decoration: const InputDecoration(labelText: 'Retorno do Intervalo (Semana)'),
                readOnly: true,
                onTap: () => _selecionarHora(context, 'retornoIntervaloSemana'),
                onSaved: (value) => retornoIntervaloSemana = value ?? '',
              ),
              // Saída Semana
              TextFormField(
                controller: _saidaSemanaController,
                decoration: const InputDecoration(labelText: 'Saída (Semana)'),
                readOnly: true,
                onTap: () => _selecionarHora(context, 'saidaSemana'),
                onSaved: (value) => saidaSemana = value ?? '',
              ),
              // Entrada Sábado
              TextFormField(
                controller: _entradaSabadoController,
                decoration: const InputDecoration(labelText: 'Entrada (Sábado)'),
                readOnly: true,
                onTap: () => _selecionarHora(context, 'entradaSabado'),
                onSaved: (value) => entradaSabado = value ?? '',
              ),
              // Saída Sábado
              TextFormField(
                controller: _saidaSabadoController,
                decoration: const InputDecoration(labelText: 'Saída (Sábado)'),
                readOnly: true,
                onTap: () => _selecionarHora(context, 'saidaSabado'),
                onSaved: (value) => saidaSabado = value ?? '',
              ),
              // Horas Mensais
              TextFormField(
                controller: _horasMensaisController,
                decoration: const InputDecoration(labelText: 'Horas Mensais'),
                keyboardType: TextInputType.number,
                onSaved: (value) => horasMensais = int.tryParse(value ?? '0') ?? 0,
              ),
              // Horas Semanais
              TextFormField(
                controller: _horasSemanaisController,
                decoration: const InputDecoration(labelText: 'Horas Semanais'),
                keyboardType: TextInputType.number,
                onSaved: (value) => horasSemanais = int.tryParse(value ?? '0')?? 0,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarConfiguracoes,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'telas/principal.dart'; // Importando a TelaInicial
import 'telas/manual.dart'; // Importando a TelaManual
import 'telas/registros.dart';
import 'telas/configuracoes.dart'; // Importando a Tela de Configurações


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Ponto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt', ''), // Português
        const Locale('en', ''), // Inglês
      ],
      home: TelaPrincipal(), // Alterando para a TelaPrincipal com PageView
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _currentIndex = 0; // Para controlar o índice da tela
  final PageController _pageController = PageController(); // Controlador para o PageView

  // Função para navegar pelas telas usando o índice
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Ponto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TelaConfiguracoes()),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController, // Controlador para navegação por deslize
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          TelaInicial(), // Tela inicial
          TelaManual(), // Tela manual
          TelaPontosRegistrados(), // Tela de registros
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Índice da página atual
        onTap: _onItemTapped, // Método que é chamado quando o ícone da barra é pressionado
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Manual',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'Tabela',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'telas/principal.dart'; // Importando a TelaInicial
import 'telas/manual.dart'; // Importando a TelaManual
import 'telas/registros.dart';
import 'db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter esteja completamente inicializado antes de qualquer operação assíncrona

  runApp(const MyApp()); // Agora o runApp é chamado diretamente após garantir que a inicialização esteja completa
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Ponto',
      theme: ThemeData(primarySwatch: Colors.blue),
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
    _pageController.jumpToPage(index); // Navega para a página selecionada
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controle de Ponto')),
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
          TelaPontosRegistrados(), // Placeholder para outras telas
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

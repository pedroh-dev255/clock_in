import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'db_helper.dart';
import 'telas/principal.dart'; // Importando a TelaInicial
import 'telas/manual.dart'; // Importando a TelaManual
import 'telas/registros.dart';
import 'telas/configuracoes.dart'; // Importando a Tela de Configurações

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DBHelper();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>['https://www.googleapis.com/auth/drive.file'], // Corrigido para List<String>
  );
  await dbHelper.syncWithGoogleDrive(await dbHelper.db);
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
      home: const TelaPrincipal(), // Alterando para a TelaPrincipal com PageView
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
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Instância do GoogleSignIn

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

  Future<void> _selecionarContaGoogle() async {
    try {
      // Solicita ao usuário que faça login com sua conta do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        print("Conta selecionada: ${googleUser.displayName}");
        
        // Obtém as credenciais de autenticação
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        if (googleAuth.accessToken != null) {
          // Aqui você pode usar o token de acesso para autenticar com o Google Drive
          print("Token de acesso: ${googleAuth.accessToken}");
        } else {
          print("Erro: Token de acesso não disponível.");
        }
      } else {
        print("Nenhuma conta foi selecionada.");
      }
    } catch (error) {
      print("Erro ao selecionar conta do Google: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Ponto'),
        actions: [
          // Botão de configurações
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TelaConfiguracoes()),
              );
            },
          ),
          // Botão para selecionar a conta do Google
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _selecionarContaGoogle, // Lógica para selecionar a conta
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

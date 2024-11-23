import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleDriveSync {
  final _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'], // Corrigido para uma lista de escopos
  );

  // Função de autenticação
  Future<AuthClient> authenticate() async {
    try {
      // Solicita ao usuário que faça login com sua conta do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Usuário não selecionado.');
      }

      // Obtém as credenciais de autenticação
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Verifica se o token de acesso não é nulo
      if (googleAuth.accessToken == null) {
        throw Exception('Token de acesso não disponível');
      }

      // Cria as credenciais de acesso com o token do Google
      final credentials = AccessCredentials(
        AccessToken(
          'Bearer', // Tipo do token
          googleAuth.accessToken!, // Token de acesso
          DateTime.now().add(Duration(hours: 1)), // Tempo de expiração do token
        ),
        googleAuth.idToken,
        // Aqui você deve passar uma lista de escopos
        ['https://www.googleapis.com/auth/drive.file'],
      );

      // Retorna o cliente autenticado
      return authenticatedClient(http.Client(), credentials);
    } catch (error) {
      print("Erro ao autenticar com a conta do Google: $error");
      rethrow;
    }
  }

  // Função para sincronizar dados com o Google Drive
  Future<void> uploadData(String fileName, String data) async {
    try {
      final client = await authenticate(); // Autenticação do usuário
      final driveApi = drive.DriveApi(client);

      final file = drive.File()
        ..name = fileName
        ..mimeType = 'application/json';

      final media = drive.Media(Stream.value(data.codeUnits), data.length);

      // Verifica se o arquivo já existe no Drive e substitui, se necessário
      try {
        final existingFile = await driveApi.files.list(q: "name = '$fileName'");
        if (existingFile.files?.isNotEmpty ?? false) {
          final fileId = existingFile.files!.first.id;
          await driveApi.files.update(file, fileId!, uploadMedia: media);
        } else {
          await driveApi.files.create(file, uploadMedia: media);
        }
      } catch (e) {
        await driveApi.files.create(file, uploadMedia: media);
      }

      client.close();
    } catch (e) {
      print("Erro ao sincronizar com o Google Drive: $e");
    }
  }
}

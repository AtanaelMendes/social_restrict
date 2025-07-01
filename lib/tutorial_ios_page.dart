import 'package:flutter/material.dart';

class TutorialIosPage extends StatefulWidget {
  @override
  _TutorialIosPageState createState() => _TutorialIosPageState();
}

class _TutorialIosPageState extends State<TutorialIosPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> tutorialSteps = [
    {
      'image': 'assets/tutorial/welcome.jpg',
      'title': 'Bem-vindo',
      'subtitle': 'Configurar aplicativo',
      'text': 'Proteja sua família: defina limites de uso ou bloqueie apps nocivos. Vamos para as configurações. Clique em Próximo.'
    },
    {
      'id': '1',
      'image': 'assets/tutorial/ios/step1.png',
      'title': 'Permissões',
      'subtitle': 'Notificações.',
      'text': 'Ao iniciar o aplicativo foi solicitado que você permitisse o envio de notificações. Caso não tenha permitido, você pode conceder essa permissão manualmente nas configurações do seu dispositivo.'
    },
    {
      'id': '2',
      'image': 'assets/tutorial/ios/step2.png',
      'title': 'Permissões',
      'subtitle': 'Verificação de permissões',
      'text': 'Clique no botão "VERIFICAR PERMISSSÕES" e conceda as permissões necessárias para o correto funcionamento do aplicativo.'
    },
    {
      'id': '3',
      'image': 'assets/tutorial/ios/step3.png',
      'title': 'Permissões',
      'subtitle': 'Conceda as permissões na sequência uma por vez.',
      'text': 'Para os próximos passos, clique em voltar até essa tela, para conceder as permissões uma por vez.'
    },
    {
      'id': '4',
      'image': 'assets/tutorial/ios/step4.png',
      'title': 'Acesso ao tempo de uso',
      'subtitle': 'Conceda essa permissão para o Social Restrict possa monitorar e restringir o uso de aplicativos.',
      'text': 'Caso ainda não esteja concedido essa permissão, acesse as configurações do seu dispositivo e defina a permissão de "Tempo de Uso".'
    },
    {
      'id': '5',
      'image': 'assets/tutorial/ios/step5.png',
      'title': 'Acesso ao tempo de uso',
      'subtitle': 'Clique no botão e informe a senha do aparelho ou face ID.',
      'text': ''
    },
    {
      'id': '6',
      'image': 'assets/tutorial/ios/step6.png',
      'title': 'Acesso ao tempo de uso',
      'subtitle': 'Permissão concedida',
      'text': 'Caso ainda não esteja concedido essa permissão, acesse as configurações do seu dispositivo e defina a permissão de "Tempo de Uso".'
    },
    {
      'id': '7',
      'image': 'assets/tutorial/ios/step7.png',
      'title': 'Ativar Aplicativo',
      'subtitle': 'Basta inserir o código de ativacao no campo e clicar em "Ativar".',
      'text': 'Após ativar o app entrará em funcionamento, você poderá acessar as configurações do app e definir os limites de uso ou bloquear aplicativos nocivos.'
    },
    {
      'id': '8',
      'image': 'assets/tutorial/ios/step8.png',
      'title': 'Concluído',
      'subtitle': 'Configuração concluída',
      'text': 'Após ativar o app voce deve ser redirecionado para essa tela, onde é possível acessar o painel administrativo e realizar os comandos de restrição.'
    },
  ];

  void _nextPage() {
    if (_currentIndex < tutorialSteps.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context); // ou vá para a tela principal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutorial')),
      body: PageView.builder(
        controller: _controller,
        itemCount: tutorialSteps.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final step = tutorialSteps[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  step['title']!,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  step['subtitle']!,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: InteractiveViewer(
                              child: Center(
                                child: Image.asset(
                                  step['image']!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      step['image']!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  step['text']!,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    index == tutorialSteps.length - 1 ? 'Concluir' : 'Próximo',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TutorialAndroidPage extends StatefulWidget {
  @override
  _TutorialAndroidPageState createState() => _TutorialAndroidPageState();
}

class _TutorialAndroidPageState extends State<TutorialAndroidPage> {
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
      'image': 'assets/tutorial/step1.png',
      'title': 'Permissões',
      'subtitle': 'Execução em segundo plano.',
      'text': 'Clique em permitir para que o aplicativo possa ser executado em segundo plano, caso não apareça essa opção, a permissão deve ser concedida em configurações de aplicativos.'
    },
    {
      'id': '2',
      'image': 'assets/tutorial/step2.png',
      'title': 'Permissões',
      'subtitle': 'Verificação de permissões',
      'text': 'Clique no botão "VERIFICAR PERMISSSÕES" para o correto funcionamento do aplicativo.'
    },
    {
      'id': '3',
      'image': 'assets/tutorial/step3.png',
      'title': 'Permissões',
      'subtitle': 'Conceda as permissões na sequência uma por vez.',
      'text': 'Para os próximos passos, clique em voltar até essa tela, para conceder as permissões uma por vez.'
    },
    {
      'id': '4',
      'image': 'assets/tutorial/step4.png',
      'title': 'Acesso ao uso',
      'subtitle': 'Acesso a execução dos aplicativos.',
      'text': 'Caso ainda não esteja concedido essa permissão, clique no APP para conceder.'
    },
    {
      'id': '5',
      'image': 'assets/tutorial/step5.png',
      'title': 'Acesso ao uso',
      'subtitle': 'Conceda acesso ao uso marcando essa opção.',
      'text': 'Após marcar, clique em voltar até a tela de verificação e clique na próxima verificação.'
    },
    {
      'id': '6',
      'image': 'assets/tutorial/step6.png',
      'title': 'Sobrepor a outros apps',
      'subtitle': 'Executar em conjunto aos apps definidos para restrição.',
      'text': 'Caso ainda não esteja concedido essa permissão, clique no APP para conceder.'
    },
    {
      'id': '7',
      'image': 'assets/tutorial/step7.png',
      'title': 'Sobrepor a outros apps',
      'subtitle': 'Conceda a sobreposição marcando essa opção.',
      'text': 'Após marcar, clique em voltar até a tela de verificação e clique na próxima verificação.'
    },
    {
      'id': '8',
      'image': 'assets/tutorial/step8.png',
      'title': 'Notificações',
      'subtitle': 'Permitir execução de notificações.',
      'text': 'Clique em permitir, para receber alertas de uso. Após conceder todas as permissões clique em "Confirm"'
    },
    {
      'id': '9',
      'image': 'assets/tutorial/step9.png',
      'title': 'Iniciar execução de restrição',
      'subtitle': 'Clique em ler QR CODE',
      'text': 'Isso deve abrir a camêra para ler o QR CODE.'
    },
    {
      'id': '10',
      'image': 'assets/tutorial/step10.png',
      'title': 'Camêra',
      'subtitle': 'Conceda acesso ao uso da camêra.',
      'text': 'Após ler o QR CODE o Social Restric entra em ação'
    },
    {
      'id': '11',
      'image': 'assets/tutorial/step11.png',
      'title': 'Concluído',
      'subtitle': 'Configuração concluída',
      'text': 'Após ler o QR CODE o APP deve abrir essa tela, nesse momento pode fechar o APP.'
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

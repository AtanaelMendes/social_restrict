import 'package:flutter/material.dart';

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> tutorialSteps = [
    {
      'image': 'assets/tutorial/welcome.jpg',
      'title': 'Bem-vindo',
      'text': 'Descubra como usar o app para monitorar o uso de aplicativos.'
    },
    {
      'image': 'assets/tutorial/step1.png',
      'title': 'Permissões',
      'text': 'Permita o acesso às permissões necessárias.'
    },
    {
      'image': 'assets/tutorial/step2.png',
      'title': 'Permissões',
      'text': 'Dê as permissões necessárias para o app funcionar corretamente.'
    },
    {
      'image': 'assets/tutorial/step3.png',
      'title': 'Apps Bloqueados',
      'text': 'Você pode selecionar quais aplicativos deseja bloquear.'
    },
    {
      'image': 'assets/tutorial/step4.png',
      'title': 'Relatórios',
      'text': 'Visualize relatórios de uso diário e semanal.'
    },
    {
      'image': 'assets/tutorial/step5.png',
      'title': 'Alertas',
      'text': 'Receba alertas ao ultrapassar limites de tempo.'
    },
    {
      'image': 'assets/tutorial/step6.png',
      'title': 'Personalização',
      'text': 'Configure bloqueios por horário e dias da semana.'
    },
    {
      'image': 'assets/tutorial/step7.png',
      'title': 'Ajuda',
      'text': 'Acesse a central de ajuda a qualquer momento.'
    },
    {
      'image': 'assets/tutorial/step8.png',
      'title': 'Pronto!',
      'text': 'Agora você está pronto para usar o aplicativo.'
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
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Image.asset(
                    step['image']!,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  step['text']!,
                  style: const TextStyle(fontSize: 16),
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

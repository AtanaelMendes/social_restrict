import 'package:flutter/material.dart';

class TutorialPage extends StatelessWidget {
  final List<Map<String, String>> tutorialSteps = [
    {
      'image': 'assets/tutorial/welcome.jpg',
      'title': 'Bem-vindo',
      'text': 'Descubra como usar o app para monitorar o uso de aplicativos.'
    },
    {
      'image': 'assets/tutorial/step1.jpg',
      'title': 'Permissões',
      'text': 'Permita'
    },
    {
      'image': 'assets/tutorial/step2.jpg',
      'title': 'Permissões',
      'text': 'Dê as permissões necessárias para o app funcionar corretamente.'
    },
    {
      'image': 'assets/tutorial/step3.jpg',
      'title': 'Apps Bloqueados',
      'text': 'Você pode selecionar quais aplicativos deseja bloquear.'
    },
    {
      'image': 'assets/tutorial/step4.jpg',
      'title': 'Relatórios',
      'text': 'Visualize relatórios de uso diário e semanal.'
    },
    {
      'image': 'assets/tutorial/step5.jpg',
      'title': 'Alertas',
      'text': 'Receba alertas ao ultrapassar limites de tempo.'
    },
    {
      'image': 'assets/tutorial/step6.jpg',
      'title': 'Personalização',
      'text': 'Configure bloqueios por horário e dias da semana.'
    },
    {
      'image': 'assets/tutorial/step7.jpg',
      'title': 'Ajuda',
      'text': 'Acesse a central de ajuda a qualquer momento.'
    },
    {
      'image': 'assets/tutorial/step8.jpg',
      'title': 'Pronto!',
      'text': 'Agora você está pronto para usar o aplicativo.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tutorial')),
      body: PageView.builder(
        itemCount: tutorialSteps.length,
        itemBuilder: (context, index) {
          final step = tutorialSteps[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  step['title']!,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Image.asset(
                    step['image']!,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  step['text']!,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}

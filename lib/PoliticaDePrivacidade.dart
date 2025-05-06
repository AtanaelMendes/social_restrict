import 'package:flutter/material.dart';

class PoliticaDePrivacidade extends StatelessWidget {
  const PoliticaDePrivacidade({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: const Text(
            '''
Política de Privacidade

Esta aplicação respeita e protege sua privacidade. Ao utilizar nossos serviços, você concorda com a coleta e uso das informações de acordo com esta política.

1. Acesso à Câmera
Utilizamos a câmera do dispositivo apenas para funcionalidades específicas, como leitura de QR Codes ou captura de imagens no contexto do uso do app. Nenhuma imagem é armazenada ou compartilhada sem sua permissão explícita.

2. Acesso ao Uso do Dispositivo
Solicitamos permissão para acessar dados de uso do dispositivo com o objetivo de monitorar o tempo de uso de aplicativos instalados. Essas informações são utilizadas exclusivamente dentro do aplicativo para fornecer relatórios e alertas personalizados. Nenhum dado de uso é compartilhado com terceiros.

3. Sobreposição Sobre Outros Aplicativos
A permissão de "sobrepor outros apps" pode ser utilizada para exibir notificações persistentes, alertas, ou ferramentas flutuantes. Esse recurso é utilizado para melhorar sua experiência, e nunca para registrar informações de outros aplicativos.

4. Armazenamento e Compartilhamento de Dados
Nenhum dado coletado é armazenado em servidores externos. Todos os dados permanecem localmente no seu dispositivo, salvo quando explicitamente informado ou autorizado.

5. Segurança
Implementamos medidas para proteger os dados e as permissões utilizadas pelo aplicativo contra acesso não autorizado.

6. Alterações nesta Política
Esta política poderá ser atualizada periodicamente. Recomendamos que você revise esta página com frequência para estar sempre informado.

7. Contato
Em caso de dúvidas sobre esta política, entre em contato com o suporte pelo e-mail: suporte@exemplo.com

Última atualização: 29 de abril de 2025
            ''',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

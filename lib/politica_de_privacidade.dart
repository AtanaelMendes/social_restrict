import 'package:flutter/material.dart';

class PoliticaDePrivacidade extends StatelessWidget {
  const PoliticaDePrivacidade({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
Política de Privacidade – Social Restric
Última atualização: 24/05/2025

Esta Política de Privacidade descreve como o aplicativo Social Restric, desenvolvido por Dayone System, coleta, utiliza e protege as informações dos usuários.

1. Informações Coletadas
O Social Restric coleta apenas as informações necessárias para seu funcionamento adequado, incluindo:

Dados de uso de aplicativos:

Para identificar quais aplicativos estão sendo utilizados e aplicar restrições, o app requer acesso à estatística de uso (perm. PACKAGE_USAGE_STATS).

Permissões do sistema:

Algumas permissões, como sobreposição de tela (SYSTEM_ALERT_WINDOW), são necessárias para exibir alertas de bloqueio.

Localização (opcional):

Pode ser coletada para recursos contextuais, como definir restrições por localização. As permissões ACCESS_FINE_LOCATION e ACCESS_COARSE_LOCATION são usadas apenas com consentimento.

Dados de inicialização do sistema:

Utiliza a permissão RECEIVE_BOOT_COMPLETED para reiniciar o serviço de bloqueio automaticamente ao ligar o dispositivo.
Permissão de notificações: Usada para informar o usuário sobre restrições ativas ou alterações no aplicativo.

Permissões de Bluetooth:

Usadas apenas se funcionalidades futuras envolverem controle via dispositivos Bluetooth (não obrigatórias para uso básico).

2. Uso das Informações
As informações coletadas são usadas exclusivamente para:

Aplicar bloqueios a aplicativos conforme definido pelo guardião;
Exibir notificações e alertas relacionados ao controle de uso;
Garantir que os serviços continuem funcionando corretamente, mesmo após reinicialização do sistema;
Otimizar a experiência do usuário com base em comportamentos de uso (sem coleta identificável).
Nenhuma informação pessoal identificável é coletada, armazenada ou compartilhada com terceiros.

3. Compartilhamento de Dados
Não compartilhamos nenhum dado com terceiros. Todas as informações processadas permanecem no dispositivo do usuário.

4. Segurança
Adotamos medidas de segurança apropriadas para proteger os dados do usuário contra acesso não autorizado, alteração ou divulgação.

5. Permissões Sensíveis
O Social Restric solicita permissões que exigem atenção, como:

QUERY_ALL_PACKAGES: Necessária para detectar e aplicar regras de bloqueio a todos os apps instalados;
SYSTEM_ALERT_WINDOW: Necessária para exibir bloqueios em tela;
PACKAGE_USAGE_STATS: Necessária para monitorar tempo de uso de aplicativos.
O aplicativo solicitará essas permissões explicitamente, explicando sua finalidade antes da ativação.

6. Direitos do Usuário
O usuário pode, a qualquer momento:

Revogar permissões nas configurações do sistema;
Desinstalar o aplicativo se não concordar com esta política.

7. Alterações nesta Política
Reservamo-nos o direito de modificar esta política a qualquer momento. Notificações serão exibidas no aplicativo em caso de mudanças significativas.

8. Contato
Caso tenha dúvidas sobre esta política ou sobre o funcionamento do Social Restric, entre em contato pelo e-mail: suporte@dayonesystem.com.br
            ''',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

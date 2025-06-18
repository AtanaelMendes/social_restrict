import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:flutter_screentime/modules/home/apps_repository.dart';
import 'package:flutter_screentime/models/block_app_model.dart';
import 'package:flutter_screentime/home_page.dart';
import 'package:flutter_screentime/navigation_service.dart'; // Adicione este import

class PainelPage extends StatefulWidget {
  final String token;
  const PainelPage({Key? key, required this.token}) : super(key: key);

  @override
  State<PainelPage> createState() => _PainelPageState();
}

class _PainelPageState extends State<PainelPage> {
  List<dynamic> usersList = [];
  bool isLoading = false;
  bool selectAll = false;
  Set<int> selectedUsers = {};
  String selectedAction = 'unblock';
  bool showSuccess = false;
  bool showError = false;
  Map<String, dynamic>? qrcodeData;

  // Para o modal de apps
  bool showAppsModal = false;
  List<AppInfo> apps = [];

  @override
  void initState() {
    super.initState();
    fetchPainelData();
  }

  Future<void> fetchPainelData() async {
    setState(() => isLoading = true);
    final api = Api();
    final resp = await api.getCustomers(widget.token);
    setState(() {
      usersList = resp?['rows'] ?? [];
      isLoading = false;
      selectedUsers.clear();
      selectAll = false;
    });
  }

  void handleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      if (selectAll) {
        selectedUsers = usersList.map<int>((u) => u['id'] as int).toSet();
      } else {
        selectedUsers.clear();
      }
    });
  }

  void handleUserSelect(bool? value, int userId) {
    setState(() {
      if (value == true) {
        selectedUsers.add(userId);
      } else {
        selectedUsers.remove(userId);
      }
      selectAll = selectedUsers.length == usersList.length;
    });
  }

  Future<void> confirmAction() async {
    if (selectedUsers.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Atenção'),
          content: Text('Nenhum usuário selecionado.'),
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
      showSuccess = false;
      showError = false;
    });
    final api = Api();
    final ok = await api.painelAction(
      widget.token,
      selectedAction,
      selectedUsers.toList(),
    );
    setState(() {
      isLoading = false;
      showSuccess = ok;
      showError = !ok;
    });
    if (ok) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => showSuccess = false);
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => showError = false);
      });
    }
  }

  Future<void> showQrcode(int userId, String userName) async {
    setState(() => isLoading = true);
    final api = Api();
    final resp = await api.getQrcode(widget.token, userId);
    setState(() {
      isLoading = false;
      qrcodeData = resp != null && resp['qrcode'] != null
          ? {'name': userName, 'qrcode': resp['qrcode']}
          : null;
    });
    if (qrcodeData == null) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Atenção'),
          content: Text('QR Code não encontrado.'),
        ),
      );
    }
  }

  Widget buildQrcodeModal() {
    if (qrcodeData == null) return const SizedBox.shrink();
    final base64Str = qrcodeData!['qrcode'] as String;
    final bytes = base64Decode(base64Str.split(',').last);
    return GestureDetector(
      onTap: () => setState(() => qrcodeData = null),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  qrcodeData!['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Image.memory(bytes),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => qrcodeData = null),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatDate(String? dateString) {
    if (dateString == null) return '--';
    final date = DateTime.tryParse(dateString);
    if (date == null) return '--';
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year} ${pad(date.hour)}:${pad(date.minute)}';
  }

  Widget buildStatus(int? statusId) {
    Color color;
    switch (statusId) {
      case 1:
        color = Colors.red;
        break;
      case 2:
        color = Colors.green;
        break;
      case 3:
        color = Colors.yellow;
        break;
      case 4:
        color = Colors.grey;
        break;
      default:
        color = Colors.black26;
    }
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Future<void> _showAppsModal() async {
    setState(() => isLoading = true);

    // Corrija aqui para pegar os valores do NavigationService
    int companyId = NavigationService.prefs?.getInt("companyId") ?? 0;
    int customerId = NavigationService.prefs?.getInt("id") ?? 0;

    final repo = AppsRepository(Api());
    final appsList = await repo.apiGetOrders(customerId, companyId);
    setState(() {
      isLoading = false;
      apps = appsList;
      showAppsModal = true;
    });
  }

  Widget buildAppsModal() {
    return GestureDetector(
      onTap: () => setState(() => showAppsModal = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Lista de Aplicativos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: apps.isEmpty
                      ? const Center(child: Text('Nenhum aplicativo encontrado.'))
                      : ListView.builder(
                          itemCount: apps.length,
                          itemBuilder: (context, index) {
                            final app = apps[index];
                            return ListTile(
                              title: Text(app.bundle ?? '--'),
                              subtitle: Text(app.bundle ?? ''),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => showAppsModal = false),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        backgroundColor: Colors.blue[700],
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) async {
              if (value == 'logout') {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              } else if (value == 'apps') {
                await _showAppsModal();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'apps',
                child: Text('Visualizar lista de aplicativos'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Sair'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (showSuccess)
                Container(
                  width: double.infinity,
                  color: Colors.green[100],
                  padding: const EdgeInsets.all(12),
                  child: const Text(
                    'Restrições aplicadas com sucesso.',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (showError)
                Container(
                  width: double.infinity,
                  color: Colors.red[100],
                  padding: const EdgeInsets.all(12),
                  child: const Text(
                    'Ocorreu um erro ao aplicar as restrições.',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Text('Aplicar ação: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    DropdownButton<String>(
                      value: selectedAction,
                      items: const [
                        DropdownMenuItem(value: 'unblock', child: Text('Desbloquear Apps')),
                        DropdownMenuItem(value: 'block', child: Text('Bloqueio total')),
                      ],
                      onChanged: (v) => setState(() => selectedAction = v ?? 'unblock'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLoading ? null : confirmAction,
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: fetchPainelData,
                        child: Scrollbar(
                          thumbVisibility: true,
                          trackVisibility: true,
                          controller: ScrollController(),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(
                                  label: Row(
                                    children: [
                                      Checkbox(
                                        value: selectAll,
                                        onChanged: handleSelectAll,
                                      ),
                                      const Text('*'),
                                    ],
                                  ),
                                ),
                                const DataColumn(label: Text('Conexão')),
                                const DataColumn(label: Text('Nome')),
                                const DataColumn(label: Text('Último app usado')),
                                const DataColumn(label: Text('Último registro')),
                                const DataColumn(label: Text('QRCODE')),
                              ],
                              rows: usersList.map<DataRow>((user) {
                                final userId = user['id'] as int;
                                final isChecked = selectedUsers.contains(userId);
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Checkbox(
                                        value: isChecked,
                                        onChanged: (v) => handleUserSelect(v, userId),
                                      ),
                                    ),
                                    DataCell(buildStatus(user['statusId'])),
                                    DataCell(Text(user['name'] ?? '--')),
                                    DataCell(Text(
                                      (user['uses_by_customers'] != null &&
                                       user['uses_by_customers'].isNotEmpty)
                                        ? (user['uses_by_customers'][0]['appInfo']?['name'] ?? '--')
                                        : '--'
                                    )),
                                    DataCell(Text(user['uses_by_customers'] != null &&
                                            user['uses_by_customers'].isNotEmpty
                                        ? formatDate(user['uses_by_customers'][0]['createdAt'])
                                        : formatDate(user['timeStatus']))),
                                    DataCell(
                                      ElevatedButton(
                                        onPressed: () => showQrcode(userId, user['name'] ?? ''),
                                        child: const Text('QRCODE'),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          if (showAppsModal) buildAppsModal(),
          if (qrcodeData != null) buildQrcodeModal(),
        ],
      ),
    );
  }
}
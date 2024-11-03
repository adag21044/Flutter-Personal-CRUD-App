import 'package:flutter/material.dart';
import 'database_helper.dart';

class PersonelApp extends StatefulWidget {
  const PersonelApp({super.key});

  @override
  _PersonelAppState createState() => _PersonelAppState();
}

class _PersonelAppState extends State<PersonelApp> {
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _departmanController = TextEditingController();
  final TextEditingController _maasController = TextEditingController();

  List<Map<String, dynamic>> _personelList = [];

  @override
  void initState() {
    super.initState();
    _refreshPersonelList();
  }

  Future<void> _refreshPersonelList() async {
    final data = await DatabaseHelper.instance.getAllPersonel();
    setState(() {
      _personelList = data;
    });
  }

  Future<void> _addPersonel() async {
    await DatabaseHelper.instance.addPersonel({
      'ad': _adController.text,
      'soyad': _soyadController.text,
      'departman': _departmanController.text,
      'maas': int.tryParse(_maasController.text) ?? 0,
    });
    _refreshPersonelList();
  }

  Future<void> _deletePersonel(int id) async {
    await DatabaseHelper.instance.deletePersonel(id);
    _refreshPersonelList();
  }

  Future<void> _showGroupedByDepartment() async {
    final data = await DatabaseHelper.instance.getPersonelGroupedByDepartment();
    for (var item in data) {
      print('Departman: ${item['departman']}, Toplam Maaş: ${item['toplam_maas']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personel Uygulaması'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: _showGroupedByDepartment,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _adController, decoration: const InputDecoration(labelText: 'Ad')),
            TextField(controller: _soyadController, decoration: const InputDecoration(labelText: 'Soyad')),
            TextField(controller: _departmanController, decoration: const InputDecoration(labelText: 'Departman')),
            TextField(controller: _maasController, decoration: const InputDecoration(labelText: 'Maaş'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addPersonel,
              child: const Text('Personel Ekle'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _personelList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${_personelList[index]['ad']} ${_personelList[index]['soyad']}'),
                    subtitle: Text('${_personelList[index]['departman']} - Maaş: ${_personelList[index]['maas']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deletePersonel(_personelList[index]['id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Podcast Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          primary: Colors.purple,
          secondary: Colors.amber,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: PodcastListScreen(),
    );
  }
}

class PodcastListScreen extends StatelessWidget {
  final CollectionReference podcasts =
      FirebaseFirestore.instance.collection('Podcasts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Podcast List', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 98, 80, 121),
      ),
      body: StreamBuilder(
        stream: podcasts.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          return ListView(
            padding: EdgeInsets.all(8),
            children: snapshot.data!.docs.map((doc) {
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(doc['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(doc['category']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => podcasts.doc(doc.id).delete(),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPodcastScreen(doc: doc),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddPodcastScreen()),
        ),
      ),
    );
  }
}

class AddPodcastScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController hostController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final CollectionReference podcasts =
      FirebaseFirestore.instance.collection('Podcasts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Podcast'), backgroundColor: const Color.fromARGB(255, 98, 80, 121)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(nameController, 'Podcast Name'),
            _buildTextField(hostController, 'Host Name'),
            _buildTextField(categoryController, 'Category'),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: Text('Add', style: TextStyle(color: Colors.white)),
              onPressed: () {
                podcasts.add({
                  'name': nameController.text,
                  'host': hostController.text,
                  'category': categoryController.text,
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditPodcastScreen extends StatelessWidget {
  final DocumentSnapshot doc;
  EditPodcastScreen({required this.doc});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController hostController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameController.text = doc['name'];
    hostController.text = doc['host'];
    categoryController.text = doc['category'];

    return Scaffold(
      appBar: AppBar(title: Text('Edit Podcast'), backgroundColor: Colors.purple),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(nameController, 'Podcast Name'),
            _buildTextField(hostController, 'Host Name'),
            _buildTextField(categoryController, 'Category'),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: Text('Update Podcast', style: TextStyle(color: Colors.white)),
              onPressed: () {
                doc.reference.update({
                  'name': nameController.text,
                  'host': hostController.text,
                  'category': categoryController.text,
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTextField(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.amber.shade50,
      ),
    ),
  );
}

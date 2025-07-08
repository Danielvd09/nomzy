
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nomzy MVP',
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Niet ingelogd: toon sign-in scherm
          return ui_auth.SignInScreen(
            providers: [
              ui_auth.EmailAuthProvider(),
              // ui_auth.GoogleAuthProvider(),
            ],
          );
        }
        // Wel ingelogd: toon deals-lijst en "Add Surplus Bag" knop
        return DealsPage();
      },
    );
  }
}

// =====================
// DealsPage, AddDealPage, DealDetailDialog, _discountPercent
// =====================

class DealsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surplus Bags bij jou in de buurt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Voeg Surplus Bag toe',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddDealPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('deals').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nog geen deals beschikbaar.'));
          }
          final deals = snapshot.data!.docs;
          return ListView.builder(
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final deal = deals[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: deal['photoUrl'] != null
                      ? Image.network(deal['photoUrl'], width: 56, height: 56, fit: BoxFit.cover)
                      : const Icon(Icons.shopping_bag),
                  title: Text(deal['title'] ?? 'Onbekend'),
                  subtitle: Text(deal['description'] ?? ''),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('€${deal['discountPrice'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (deal['originalPrice'] != null && deal['discountPrice'] != null)
                        Text('-${_discountPercent(deal['originalPrice'], deal['discountPrice'])}%', style: const TextStyle(color: Colors.orange)),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => DealDetailDialog(deal: deal),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

int _discountPercent(dynamic original, dynamic discount) {
  try {
    final orig = double.tryParse(original.toString()) ?? 0;
    final disc = double.tryParse(discount.toString()) ?? 0;
    if (orig == 0) return 0;
    return ((1 - (disc / orig)) * 100).round();
  } catch (_) {
    return 0;
  }
}

class DealDetailDialog extends StatelessWidget {
  final Map<String, dynamic> deal;
  const DealDetailDialog({required this.deal});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(deal['title'] ?? ''),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (deal['photoUrl'] != null)
            Image.network(deal['photoUrl'], height: 120, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(deal['description'] ?? ''),
          const SizedBox(height: 8),
          Text('Originele prijs: €${deal['originalPrice'] ?? '-'}'),
          Text('Korting prijs: €${deal['discountPrice'] ?? '-'}'),
          Text('Hoeveelheid: ${deal['quantity'] ?? '-'}'),
          Text('Ophaaltijd: ${deal['pickupStart'] ?? '-'} - ${deal['pickupEnd'] ?? '-'}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Sluiten'),
        ),
      ],
    );
  }
}

class AddDealPage extends StatefulWidget {
  @override
  State<AddDealPage> createState() => _AddDealPageState();
}

class _AddDealPageState extends State<AddDealPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pickupStartController = TextEditingController();
  final _pickupEndController = TextEditingController();
  final _photoUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voeg Surplus Bag toe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titel'),
                validator: (v) => v == null || v.isEmpty ? 'Vul een titel in' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Beschrijving'),
              ),
              TextFormField(
                controller: _originalPriceController,
                decoration: const InputDecoration(labelText: 'Originele prijs (€)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _discountPriceController,
                decoration: const InputDecoration(labelText: 'Korting prijs (€)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Hoeveelheid'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _pickupStartController,
                decoration: const InputDecoration(labelText: 'Ophaaltijd start (bv. 16:00)'),
              ),
              TextFormField(
                controller: _pickupEndController,
                decoration: const InputDecoration(labelText: 'Ophaaltijd eind (bv. 18:00)'),
              ),
              TextFormField(
                controller: _photoUrlController,
                decoration: const InputDecoration(labelText: 'Foto URL (optioneel)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await FirebaseFirestore.instance.collection('deals').add({
                      'title': _titleController.text,
                      'description': _descController.text,
                      'originalPrice': _originalPriceController.text,
                      'discountPrice': _discountPriceController.text,
                      'quantity': _quantityController.text,
                      'pickupStart': _pickupStartController.text,
                      'pickupEnd': _pickupEndController.text,
                      'photoUrl': _photoUrlController.text,
                      'sellerId': FirebaseAuth.instance.currentUser?.uid,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    if (mounted) Navigator.of(context).pop();
                  }
                },
                child: const Text('Opslaan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Einde extra widgets

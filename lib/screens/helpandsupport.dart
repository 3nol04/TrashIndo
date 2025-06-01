import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Fungsi untuk mengirim pesan melalui WhatsApp
  Future<void> sendMessage(
      BuildContext context, String phoneNumber, String message) async {
    final Uri whatsappUrl = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");
    bool canOpen = await launchUrl(whatsappUrl);
    if (canOpen) {
      await launchUrl(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Could not open WhatsApp. Please check your app configuration.')),
      );
    }
  }

  // Dialog untuk chat WhatsApp
  void showChatDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chat with WhatsApp'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'Type your message...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Ambil pesan dan kirim melalui WhatsApp
                String message = messageController.text;
                if (message.isNotEmpty) {
                  // Ganti dengan nomor WhatsApp yang diinginkan
                  String phoneNumber =
                      '6285840430658'; // Gantilah dengan nomor WhatsApp yang valid
                  sendMessage(context, phoneNumber, message);
                  Navigator.pop(
                      context); // Menutup dialog setelah mengirim pesan
                } else {
                  // Beri tahu pengguna jika pesan kosong
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please enter a message.'),
                  ));
                }
              },
              child: Text('Send'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Menutup dialog tanpa mengirim pesan
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'How can we help you?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Find answers to common questions or contact our team for help.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildFaqItem(
              question: 'Bagaimana cara menggunakan aplikasi Trashindo?',
              answer:
                  'Anda cukup mendaftar, lalu pilih kategori sampah dan lokasi pengumpulan terdekat.',
            ),
            _buildFaqItem(
              question: 'Apakah saya bisa menjadwalkan pengambilan sampah?',
              answer:
                  'Ya, Anda bisa memilih jadwal pengambilan sampah sesuai waktu yang tersedia.',
            ),
            _buildFaqItem(
              question: 'Bagaimana saya menghubungi tim Trashindo?',
              answer:
                  'Gunakan tombol "Contact Us" di bawah untuk mengirim pesan atau email ke tim kami.',
            ),
            const SizedBox(height: 30),

            const Text(
              'Need more help?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Tambahkan navigasi ke chat atau email
                    },
                    icon: const Icon(Icons.whatshot_outlined),
                    label: const Text('Live Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigasi ke WhatsApp chat
                      showChatDialog(context);
                    },
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('WhatApp Us'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.green.shade600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membangun item FAQ
  Widget _buildFaqItem({required String question, required String answer}) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0, left: 8.0, right: 8.0),
          child: Text(answer, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}

class FLutterLauncher {}

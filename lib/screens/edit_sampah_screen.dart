import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trashindo/model/Sampah.dart';
import 'package:trashindo/services/sampahServices.dart';

class EditSampahScreen extends StatefulWidget {
  final Sampah sampah;

  const EditSampahScreen({super.key, required this.sampah});

  @override
  State<EditSampahScreen> createState() => _EditSampahScreenState();
}

class _EditSampahScreenState extends State<EditSampahScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> statusList = ["Kosong", "Penuh", "Rusak"];
  late TextEditingController _deskripsiController;
  late TextEditingController _lokasiController;
  late String _status;
  Uint8List? _imageBytes;
  bool _loading = false;

  @override
  void initState() {
    _deskripsiController = TextEditingController(text: widget.sampah.deskripsi);
    _lokasiController = TextEditingController(text: widget.sampah.lokasiDetail);
    _status = widget.sampah.status ?? "Kosong";
    super.initState();
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Konfirmasi"),
        content: Text("Simpan perubahan data?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Batal")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Simpan")),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    try {
      final data = {
        'deskripsi': _deskripsiController.text,
        'lokasi_detail': _lokasiController.text,
        'status': _status,
        'image': _imageBytes != null
            ? base64Encode(_imageBytes!)
            : widget.sampah.image,
      };

      await SampahServices().updateSampah(widget.sampah.id!, data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data berhasil diperbarui")),
      );

      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui data: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Data Sampah")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text("Gambar", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickImage,
                      child: _imageBytes != null
                          ? Image.memory(_imageBytes!, height: 150, fit: BoxFit.cover)
                          : widget.sampah.image != null
                              ? Image.memory(
                                  base64Decode(widget.sampah.image!),
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: Center(child: Text("Klik untuk pilih gambar")),
                                ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _deskripsiController,
                      decoration: InputDecoration(labelText: "Deskripsi"),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Deskripsi tidak boleh kosong" : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _lokasiController,
                      decoration: InputDecoration(labelText: "Lokasi Detail"),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Lokasi tidak boleh kosong" : null,
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: InputDecoration(labelText: "Status"),
                      items: statusList.map((val) {
                        return DropdownMenuItem(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _status = val;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: Icon(Icons.save),
                      label: Text("Simpan Perubahan"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
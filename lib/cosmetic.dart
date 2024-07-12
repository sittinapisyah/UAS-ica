import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddCosmeticPage extends StatefulWidget {
  @override
  _AddCosmeticPageState createState() => _AddCosmeticPageState();
}

class _AddCosmeticPageState extends State<AddCosmeticPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List categories = [];
  String? selectedCategory;
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse(
        'https://a242-36-69-98-90.ngrok-free.app/project_uas_api/category.php?action=read'));

    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> createCosmetic() async {
    final String name = _nameController.text;
    final String description = _descriptionController.text;
    final String price = _priceController.text;

    if (name.isEmpty ||
        description.isEmpty ||
        price.isEmpty ||
        selectedCategory == null ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All fields and image are required'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://a242-36-69-98-90.ngrok-free.app/project_uas_api/cosmetic.php?action=create'),
    );

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['category_id'] = selectedCategory!;
    request.fields['price'] = price;
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    print('Response status: ${response.statusCode}');
    print('Response body: $responseBody');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Cosmetic created successfully'),
        backgroundColor: Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'].toString(),
                    child: Text(category['category_name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              _image != null ? Image.file(_image!) : Container(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: createCosmetic,
                child: Text('Add Cosmetic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditCosmeticPage extends StatefulWidget {
  final Map cosmetic;

  EditCosmeticPage({required this.cosmetic});

  @override
  _EditCosmeticPageState createState() => _EditCosmeticPageState();
}

class _EditCosmeticPageState extends State<EditCosmeticPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List categories = [];
  String? selectedCategory;
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.cosmetic['name'];
    _descriptionController.text = widget.cosmetic['description'];
    _priceController.text = widget.cosmetic['price'].toString();
    selectedCategory = widget.cosmetic['category_id'].toString();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse(
        'https://a242-36-69-98-90.ngrok-free.app/project_uas_api/category.php?action=read'));

    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> updateCosmetic() async {
    final String name = _nameController.text;
    final String description = _descriptionController.text;
    final String price = _priceController.text;

    if (name.isEmpty ||
        description.isEmpty ||
        price.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All fields are required'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://a242-36-69-98-90.ngrok-free.app/project_uas_api/cosmetic.php?action=update'),
    );

    request.fields['id'] = widget.cosmetic['id'].toString();
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['category_id'] = selectedCategory!;
    request.fields['price'] = price;

    if (_image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));
    }

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    print('Response status: ${response.statusCode}');
    print('Response body: $responseBody');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Cosmetic updated successfully'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Cosmetic'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'].toString(),
                    child: Text(category['category_name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              _image != null
                  ? Image.file(_image!)
                  : widget.cosmetic['image'] != null
                      ? Image.network(
                          'https://a242-36-69-98-90.ngrok-free.app/project_uas_api/${widget.cosmetic['image']}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Container(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateCosmetic,
                child: Text('Update Cosmetic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

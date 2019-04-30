import 'dart:io';

import 'package:flutter/material.dart';
import 'package:agenda_de_contados/helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  String _tipo;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode(); //fazer foco

  bool _userEdited = false;

  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      //verificação se será editado ou fará um novo contato
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //ele chama uma função quando for dar um pop-fechar uma tela
      onWillPop: _requestPop,
      child: Scaffold(
        //ja inclui o appbar e o floatingbutton
        appBar: AppBar(
          //declaração da appbar
          title: Text(_editedContact.name ??
              "Novo Contato"), //se ja tiver o nome ou digitar o nome vai se usar o nome como titulo
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        floatingActionButton: FloatingActionButton(
          //botão salvar
          onPressed: () {
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          //para dar movimento de rolagem
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                //para ter um geto quando clicar em cima
                child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            //colocar imagem
                            image: _editedContact.img != null
                                ? FileImage(File(_editedContact.img))
                                : AssetImage("images/person.png")))),
                onTap: () {
                  _showOptions(context);
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Nome:",
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _nameController,
                focusNode: _nameFocus, //texto onde se utiliza o focus
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: "Email:",
                    labelStyle: TextStyle(color: Colors.black)),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
                },
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Telefone",
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    //opção de onte tirar a foto
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: FlatButton(
                          onPressed: () {
                            _tipo = "camera";
                            _escolherCamera();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Camera",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: FlatButton(
                          onPressed: () {
                            _tipo = "galerry";
                            _escolherCamera();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Galeria",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          )),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  Future _escolherCamera() {
    //escolher o local da foto
    if (_tipo == "camera") {
      ImagePicker.pickImage(source: ImageSource.camera).then((file) {
        if (file == null) return;
        _editedContact.img = file.path;
      });
    } else {
      ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
        if (file == null) return;
        _editedContact.img = file.path;
      });
    }
  }

  Future<bool> _requestPop() async {
    //função de deseja mesmo sair
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Deseja descartar alterações?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    //faz voltar para a pagina alterior
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  //
                  child: Text("Sim"),
                  onPressed: () {
                    //faz descartar as alterações e voltar para a pagina inicial
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else
      return Future.value(true);
  }
}

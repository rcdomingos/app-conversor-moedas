import 'dart:convert';

import 'package:app_conversor_moeda/widgets/widget.TextField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeCotacao extends StatefulWidget {
  @override
  _HomeCotacaoState createState() => _HomeCotacaoState();
}

class _HomeCotacaoState extends State<HomeCotacao> {
  //variaveis locais
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

//valores da API
  double cotacaoDolar;
  double cotacaoEuro;

  Future<Map> consultaCotacao() async {
    http.Response response = await http.get(
        'https://api.hgbrasil.com/finance/?format=json-cors&key=development');

    this.cotacaoDolar =
        jsonDecode(response.body)['results']['currencies']['USD']['buy'];
    this.cotacaoEuro =
        jsonDecode(response.body)['results']['currencies']['EUR']['buy'];

    return jsonDecode(response.body);
  }

//função para limpar os campos
  void _limparCampos() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

//funções para alterar quando o real for digitado
  void _realAlterado() {
    double vReal = double.parse(realController.text);

    dolarController.text = (vReal / this.cotacaoDolar).toStringAsFixed(2);
    euroController.text = (vReal / this.cotacaoEuro).toStringAsFixed(2);
  }

//funções para alterar quando o dolar for digitado
  void _dolarAlterado() {
    double vDolar = double.parse(dolarController.text);

    realController.text = (vDolar * this.cotacaoDolar).toStringAsFixed(2);
    euroController.text =
        (vDolar * this.cotacaoDolar / cotacaoEuro).toStringAsFixed(2);
  }

//funções para convertar quando o euro for digitado
  void _euroAlterado() {
    double vEuro = double.parse(euroController.text);
    realController.text = (vEuro * this.cotacaoEuro).toStringAsFixed(2);
    dolarController.text =
        (vEuro * this.cotacaoEuro / cotacaoDolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('\$ Conversor de Moedas'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              final snackbar = SnackBar(
                content: Text(
                  'Atualizando Cotações...',
                  style: TextStyle(color: Colors.black),
                ),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.amber,
                action: SnackBarAction(label: 'Fechar', onPressed: () {}),
              );
              _scaffoldkey.currentState.showSnackBar(snackbar);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {},
        child: FutureBuilder<Map>(
          future: consultaCotacao(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                );
                break;
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar dados: \n ' + snapshot.error.toString(),
                      style: TextStyle(color: Colors.red, fontSize: 15),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 100,
                        ),
                        InputText(
                          label: 'Real',
                          prefixo: 'R\$ ',
                          funcaoChanged: this._realAlterado,
                          ctr: realController,
                        ),
                        Divider(),
                        InputText(
                          label: 'Dolar',
                          prefixo: 'U\$\$ ',
                          funcaoChanged: this._dolarAlterado,
                          ctr: dolarController,
                        ),
                        Divider(),
                        InputText(
                          label: 'Euro',
                          prefixo: '€ ',
                          funcaoChanged: this._euroAlterado,
                          ctr: euroController,
                        ),
                      ],
                    ),
                  );
                }
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _limparCampos();
          final snackbar = SnackBar(
            content: Text(
              'Campos limpos com sucesso!',
              style: TextStyle(color: Colors.black),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.amber,
            action: SnackBarAction(label: 'Fechar', onPressed: () {}),
          );
          _scaffoldkey.currentState.showSnackBar(snackbar);
        },
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        child: Icon(Icons.clear),
      ),
    );
  }
}

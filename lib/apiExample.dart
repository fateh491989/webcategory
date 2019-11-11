import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiTest extends StatefulWidget {
  @override
  _ApiTestState createState() => _ApiTestState();
}

class _ApiTestState extends State<ApiTest> {
  var codec = latin1.fuse(base64); // to convert string to base64 nd vice versa
  Map<String,dynamic> data= {};
  final  _textEditingController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future fetchPost() async {
    String targetWebsite = _textEditingController.text;
    String key = "MwOEjAcAjoeqWUSsXVyB";
    String secretKey = "VeamKI0rBFGYRpvM8QhJ";
    var base64Str = codec.encode('$targetWebsite');
    String api_url = "https://api.webshrinker.com/hosts/v3/$base64Str";
    print(targetWebsite);
    String codedInfo = codec.encode('$key:$secretKey');
    final response =
    await http
        .get(api_url
        ,headers: {
          'Authorization': 'Basic $codedInfo',
          'Host': 'api.webshrinker.com'
        }
    );
    data = json.decode(response.body);
    setState(() {
      isLoading= false;
    });
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      setState(() {
        isShown = true;
      });
      return json.decode(response.body);
    } else {
      // If that call was not successful, throw an error.
      final snackbar = SnackBar(content: Text('Error: ${data['message']}'));
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  bool isShown = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(237, 237, 237, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Domain Category Identifier'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: 'Please enter the url along with www',
                suffixIcon: IconButton(
                    icon: Icon(Icons.search,color: Colors.blue,),
                    onPressed: () async {
                      setState(() {
                        isLoading= true;
                      });
                      await fetchPost().then((a){

                      });
                    }
                    )
              ),
            ),
          ),
          isLoading?CircularProgressIndicator():Container(),
          isLoading?Text('Please Wait'):Container(),
          Expanded(
            child: isShown?ListView.builder(
                itemCount: data.length==null?0:data['data'][0]['categories'].length,
                itemBuilder: (context,index){
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text((index+1).toString()),
                    ),
                    title: Text(data['data'][0]['categories'][index]),
                  );
                }):Container(),
          ),

        ],
      ),
    );
  }
}

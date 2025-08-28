import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nba_app/components/my_drawer.dart';
import 'package:nba_app/models/team.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Team> teams = [];

  //get teams
  Future getTeams() async {
    var response = await http.get(
      Uri.https('api.balldontlie.io', '/v1/teams'),
      headers: {'Authorization': dotenv.env['API_KEY'] ?? ''},
    );
    var jsonData = jsonDecode(response.body);

    for (var eachTeam in jsonData['data']) {
      final team = Team(
        id: eachTeam['id'],
        abbreviation: eachTeam['abbreviation'],
        city: eachTeam['city'],
      );
      teams.add(team);
    }

    print(teams.length);
  }

  @override
  void initState() {
    super.initState();
    getTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('NBA TEAMS'),
        centerTitle: true,
        backgroundColor: Colors.blue[500],
      ),

      //when you make a request to an API, it takes time to get the response that why you use a Future builder
      body: FutureBuilder(
        future: getTeams(),
        builder: (context, snapshot) {
          //is it done loading? then show team data
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/TeamPage');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],

                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),

                    child: ListTile(
                      title: Text(teams[index].abbreviation),
                      subtitle: Text(teams[index].city),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[600],
                        child: Text(
                          teams[index].abbreviation[0],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                );
              },
            );
          }
          //if it is still loading show loading circle
          else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

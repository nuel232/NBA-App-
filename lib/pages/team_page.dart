import 'package:flutter/material.dart';
import 'package:nba_app/models/team.dart';

class TeamPage extends StatefulWidget {
  final Team team;
  const TeamPage({super.key, required this.team});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.city),
        centerTitle: true,
        backgroundColor: Colors.blue[500],
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Team: ${widget.team.city}', style: TextStyle(fontSize: 24)),
          Text(
            'Abbreviation: ${widget.team.abbreviation}',
            style: TextStyle(fontSize: 18),
          ),
          Text('ID: ${widget.team.id}', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

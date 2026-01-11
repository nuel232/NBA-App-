import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nba_app/components/my_drawer.dart';
import 'package:nba_app/components/error_widget.dart';
import 'package:nba_app/pages/team_page.dart';
import 'package:nba_app/providers/teams_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load teams when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamsProvider>().loadTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('NBA TEAMS'),
        centerTitle: true,
        backgroundColor: Colors.blue[500],
      ),
      body: Consumer<TeamsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.teams.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return ErrorDisplayWidget(
              message: provider.errorMessage ?? 'Failed to load teams',
              onRetry: () => provider.loadTeams(refresh: true),
            );
          }

          if (provider.teams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_basketball,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No teams found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadTeams(refresh: true);
            },
            child: ListView.builder(
              itemCount: provider.teams.length,
              itemBuilder: (context, index) {
                final team = provider.teams[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamPage(team: team),
                      ),
                    );
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
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(team.abbreviation),
                      subtitle: Text(team.city),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[600],
                        child: Text(
                          team.abbreviation[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

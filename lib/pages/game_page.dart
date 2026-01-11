import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nba_app/components/error_widget.dart';
import 'package:nba_app/providers/games_provider.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load games when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamesProvider>().loadGames();
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = context.read<GamesProvider>();
      if (provider.hasMoreGames && !provider.isLoading) {
        provider.loadMoreGames();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('NBA GAMES'),
        centerTitle: true,
        backgroundColor: Colors.blue[500],
      ),
      body: Consumer<GamesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.games.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return ErrorDisplayWidget(
              message: provider.errorMessage ?? 'Failed to load games',
              onRetry: () => provider.loadGames(refresh: true),
            );
          }

          if (provider.games.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_basketball, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No games found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadGames(refresh: true);
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.games.length + (provider.hasMoreGames ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.games.length) {
                  // Loading more indicator
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final game = provider.games[index];
                return Container(
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
                    title: Text(
                      '${game.visitorTeam} @ ${game.homeTeam}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Score: ${game.visitorTeamScore} - ${game.homeTeamScore}'),
                        Text('Date: ${game.date ?? "N/A"}'),
                        Text('Status: ${game.status}'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: game.status == 'Final'
                            ? Colors.green[300]
                            : Colors.orange[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        game.status,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

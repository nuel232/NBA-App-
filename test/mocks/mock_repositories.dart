import 'package:mockito/mockito.dart';
import 'package:nba_app/repositories/teams_repository.dart';
import 'package:nba_app/repositories/games_repository.dart';
import 'package:nba_app/repositories/team_details_repository.dart';

class MockTeamsRepository extends Mock implements ITeamsRepository {}
class MockGamesRepository extends Mock implements IGamesRepository {}
class MockTeamDetailsRepository extends Mock implements ITeamDetailsRepository {}

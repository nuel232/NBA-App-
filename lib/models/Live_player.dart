class LivePlayer {
  final int id;
  final String firstName;
  final String lastName;
  final String position;
  final String? height;
  final String? weight;
  final String? jerseyNumber;
  final String? college;
  final String? country;
  final int? draftYear;
  final int? draftRound;
  final int? draftNumber;

  LivePlayer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.position,
    this.height,
    this.weight,
    this.jerseyNumber,
    this.college,
    this.country,
    this.draftYear,
    this.draftRound,
    this.draftNumber,
  });

  // Convert JSON to LivePlayer object
  factory LivePlayer.fromJson(Map<String, dynamic> json) {
    return LivePlayer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      position: json['position'],
      height: json['height'],
      weight: json['weight'],
      jerseyNumber: json['jersey_number'],
      college: json['college'],
      country: json['country'],
      draftYear: json['draft_year'],
      draftRound: json['draft_round'],
      draftNumber: json['draft_number'],
    );
  }
}

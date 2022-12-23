class YearFromBackupV3 {
  final int? id;
  final String? year;
  final int? yearChallengeBooks;
  final int? yearChallengePages;

  YearFromBackupV3({
    this.id,
    this.year,
    this.yearChallengeBooks,
    this.yearChallengePages,
  });

  factory YearFromBackupV3.fromJson(Map<String, dynamic> json) {
    return YearFromBackupV3(
      id: json['id'] as int?,
      year: json['item_year'] as String?,
      yearChallengeBooks: json['item_challenge_books'] as int?,
      yearChallengePages: json['item_challenge_pages'] as int?,
    );
  }
}

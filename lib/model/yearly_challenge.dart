class YearlyChallenge {
  int year;
  int? books;
  int? pages;

  YearlyChallenge({
    required this.year,
    required this.books,
    required this.pages,
  });

  factory YearlyChallenge.fromJSON(Map<String, dynamic> json) {
    return YearlyChallenge(
      year: json['year'],
      books: json['books'],
      pages: json['pages'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'year': year,
      'books': books,
      'pages': pages,
    };
  }
}

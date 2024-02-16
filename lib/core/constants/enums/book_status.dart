enum BookStatus {
  read,
  inProgress,
  forLater,
  unfinished,
}

extension BookStatusExtension on BookStatus {
  int get value {
    switch (this) {
      case BookStatus.read:
        return 0;
      case BookStatus.inProgress:
        return 1;
      case BookStatus.forLater:
        return 2;
      case BookStatus.unfinished:
        return 3;
      default:
        return 0;
    }
  }
}

BookStatus parseBookStatus(int value) {
  switch (value) {
    case 0:
      return BookStatus.read;
    case 1:
      return BookStatus.inProgress;
    case 2:
      return BookStatus.forLater;
    case 3:
      return BookStatus.unfinished;
    default:
      return BookStatus.read;
  }
}

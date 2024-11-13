class RicetteFav {
  final String origin;
  final String drinkId;

  RicetteFav({required this.origin, required this.drinkId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RicetteFav &&
              runtimeType == other.runtimeType &&
              drinkId == other.drinkId &&
              origin == other.origin;

  @override
  int get hashCode => drinkId.hashCode ^ origin.hashCode;
}
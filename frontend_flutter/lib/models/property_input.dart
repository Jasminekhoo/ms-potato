class PropertyInput {
  PropertyInput({
    required this.propertyName,
    required this.location,
    required this.askingRent,
    required this.monthlyIncome,
  });

  final String propertyName;
  final String location;
  final double askingRent;
  final double monthlyIncome;

  Map<String, dynamic> toJson() => {
        'propertyName': propertyName,
        'location': location,
        'askingRent': askingRent,
        'monthlyIncome': monthlyIncome,
      };
}

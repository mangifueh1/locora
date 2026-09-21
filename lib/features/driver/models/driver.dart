
class Driver {
  const Driver({
    required this.id,
    required this.name,
    required this.phone,
  });

  final String id;
  final String name;
  final String phone;

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'].toString(),
      name: json['name'].toString(),
      phone: json['phone'].toString(),
    );
  }
}


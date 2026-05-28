num _asNum(dynamic value, [num fallback = 0]) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? fallback;
  return fallback;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatar;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: (json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        role: (json['role'] ?? 'member').toString(),
        avatar: json['avatar']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'avatar': avatar,
      };
}

class GymClass {
  GymClass({
    required this.id,
    required this.name,
    required this.time,
    required this.duration,
    required this.location,
    required this.trainerName,
    required this.days,
    required this.price,
    required this.capacity,
    required this.registered,
  });

  final int id;
  final String name;
  final String time;
  final int duration;
  final String location;
  final String trainerName;
  final String days;
  final double price;
  final int capacity;
  final int registered;

  factory GymClass.fromJson(Map<String, dynamic> json) => GymClass(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: (json['name'] ?? '').toString(),
        time: (json['time'] ?? '').toString(),
        duration: _asNum(json['duration']).toInt(),
        location: (json['location'] ?? '').toString(),
        trainerName: (json['trainer_name'] ?? '').toString(),
        days: (json['days'] ?? '').toString(),
        price: _asNum(json['price']).toDouble(),
        capacity: _asNum(json['capacity']).toInt(),
        registered: _asNum(json['registered']).toInt(),
      );
}

class Trainer {
  Trainer({
    required this.id,
    required this.name,
    required this.spec,
    required this.rating,
    required this.exp,
    required this.price,
    required this.availability,
    this.imageUrl,
    this.email,
  });

  final dynamic id;
  final String name;
  final String spec;
  final double rating;
  final String exp;
  final double price;
  final String availability;
  final String? imageUrl;
  final String? email;

  factory Trainer.fromJson(Map<String, dynamic> json) => Trainer(
        id: json['id'],
        name: (json['name'] ?? '').toString(),
        spec: (json['spec'] ?? '').toString(),
        rating: _asNum(json['rating']).toDouble(),
        exp: (json['exp'] ?? '').toString(),
        price: _asNum(json['price']).toDouble(),
        availability: (json['availability'] ?? '').toString(),
        imageUrl: json['image_url']?.toString(),
        email: json['email']?.toString(),
      );
}

class MembershipPackage {
  MembershipPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.benefits,
    this.oldPrice,
    this.color,
    this.isPopular = false,
  });

  final int id;
  final String name;
  final double price;
  final int duration;
  final List<String> benefits;
  final double? oldPrice;
  final String? color;
  final bool isPopular;

  factory MembershipPackage.fromJson(Map<String, dynamic> json) {
    final txt = (json['benefits_text'] ?? '').toString();
    final benefits = txt
        .split(RegExp(r'[\n,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return MembershipPackage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      price: _asNum(json['price']).toDouble(),
      duration: _asNum(json['duration']).toInt().clamp(1, 999),
      benefits: benefits,
      oldPrice: json['old_price'] == null ? null : _asNum(json['old_price']).toDouble(),
      color: json['color']?.toString(),
      isPopular: json['is_popular'] == true || json['is_popular'] == 1,
    );
  }
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.title,
  });

  final int id;
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? title;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: (json['id'] as num?)?.toInt() ?? 0,
        type: (json['type'] ?? 'info').toString(),
        message: (json['message'] ?? '').toString(),
        isRead: json['is_read'] == 1 || json['is_read'] == true,
        createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
        title: json['title']?.toString(),
      );
}

class CartItem {
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    this.schedule,
    this.quantity,
    this.schedules,
    this.bookedForMember,
    this.memberId,
    this.memberName,
    this.memberEmail,
  });

  final dynamic id;
  final String name;
  final double price;
  final String type;
  final String? schedule;
  final int? quantity;
  final List<String>? schedules;
  final bool? bookedForMember;
  final int? memberId;
  final String? memberName;
  final String? memberEmail;

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        name: (json['name'] ?? '').toString(),
        price: (json['price'] as num?)?.toDouble() ?? 0,
        type: (json['type'] ?? '').toString(),
        schedule: json['schedule']?.toString(),
        quantity: (json['quantity'] as num?)?.toInt(),
        schedules: (json['schedules'] as List?)?.map((e) => e.toString()).toList(),
        bookedForMember: json['bookedForMember'] as bool?,
        memberId: (json['memberId'] as num?)?.toInt(),
        memberName: json['memberName']?.toString(),
        memberEmail: json['memberEmail']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'type': type,
        'schedule': schedule,
        'quantity': quantity,
        'schedules': schedules,
        'bookedForMember': bookedForMember,
        'memberId': memberId,
        'memberName': memberName,
        'memberEmail': memberEmail,
      };
}

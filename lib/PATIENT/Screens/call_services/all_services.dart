import 'dart:convert';

class AllServices {
  final int? count;
  final dynamic next;
  final dynamic previous;
  final List<Result>? results;

  AllServices({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  AllServices copyWith({
    int? count,
    dynamic next,
    dynamic previous,
    List<Result>? results,
  }) =>
      AllServices(
        count: count ?? this.count,
        next: next ?? this.next,
        previous: previous ?? this.previous,
        results: results ?? this.results,
      );

  factory AllServices.fromRawJson(String str) =>
      AllServices.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AllServices.fromJson(Map<String, dynamic> json) => AllServices(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results: json["results"] == null
            ? []
            : List<Result>.from(
                json["results"]!.map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toJson())),
      };
}

class Result {
  final int? id;
  final List<ProviderInfo>? providerInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? name;
  final String? description;
  final String? price;
  final String? duration;
  final String? image;
  final bool? isActive;
  final dynamic location;
  final int? subcategory;
  final int? category;
  final List<int>? doctors;
  final List<int>? nurses;
  final List<dynamic>? hospitals;
  final List<dynamic>? labs;

  Result({
    this.id,
    this.providerInfo,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.description,
    this.price,
    this.duration,
    this.image,
    this.isActive,
    this.location,
    this.subcategory,
    this.category,
    this.doctors,
    this.nurses,
    this.hospitals,
    this.labs,
  });

  Result copyWith({
    int? id,
    List<ProviderInfo>? providerInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? description,
    String? price,
    String? duration,
    String? image,
    bool? isActive,
    dynamic location,
    int? subcategory,
    int? category,
    List<int>? doctors,
    List<int>? nurses,
    List<dynamic>? hospitals,
    List<dynamic>? labs,
  }) =>
      Result(
        id: id ?? this.id,
        providerInfo: providerInfo ?? this.providerInfo,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        duration: duration ?? this.duration,
        image: image ?? this.image,
        isActive: isActive ?? this.isActive,
        location: location ?? this.location,
        subcategory: subcategory ?? this.subcategory,
        category: category ?? this.category,
        doctors: doctors ?? this.doctors,
        nurses: nurses ?? this.nurses,
        hospitals: hospitals ?? this.hospitals,
        labs: labs ?? this.labs,
      );

  factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        providerInfo: json["provider_info"] == null
            ? []
            : List<ProviderInfo>.from(
                json["provider_info"]!.map((x) => ProviderInfo.fromJson(x))),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        name: json["name"],
        description: json["description"],
        price: json["price"],
        duration: json["duration"],
        image: json["image"],
        isActive: json["is_active"],
        location: json["location"],
        subcategory: json["subcategory"],
        category: json["category"],
        doctors: json["doctors"] == null
            ? []
            : List<int>.from(json["doctors"]!.map((x) => x)),
        nurses: json["nurses"] == null
            ? []
            : List<int>.from(json["nurses"]!.map((x) => x)),
        hospitals: json["hospitals"] == null
            ? []
            : List<dynamic>.from(json["hospitals"]!.map((x) => x)),
        labs: json["labs"] == null
            ? []
            : List<dynamic>.from(json["labs"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "provider_info": providerInfo == null
            ? []
            : List<dynamic>.from(providerInfo!.map((x) => x.toJson())),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "name": name,
        "description": description,
        "price": price,
        "duration": duration,
        "image": image,
        "is_active": isActive,
        "location": location,
        "subcategory": subcategory,
        "category": category,
        "doctors":
            doctors == null ? [] : List<dynamic>.from(doctors!.map((x) => x)),
        "nurses":
            nurses == null ? [] : List<dynamic>.from(nurses!.map((x) => x)),
        "hospitals": hospitals == null
            ? []
            : List<dynamic>.from(hospitals!.map((x) => x)),
        "labs": labs == null ? [] : List<dynamic>.from(labs!.map((x) => x)),
      };
}

class ProviderInfo {
  final String? type;
  final int? id;
  final String? name;

  ProviderInfo({
    this.type,
    this.id,
    this.name,
  });

  ProviderInfo copyWith({
    String? type,
    int? id,
    String? name,
  }) =>
      ProviderInfo(
        type: type ?? this.type,
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory ProviderInfo.fromRawJson(String str) =>
      ProviderInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProviderInfo.fromJson(Map<String, dynamic> json) => ProviderInfo(
        type: json["type"],
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
        "name": name,
      };
}

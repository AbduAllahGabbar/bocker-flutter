import 'package:dio/dio.dart';
import '../../errors/failure.dart';

// Country model
class CountryModel {
  final dynamic id;
  final String name;
  final String? callingCode;
  final String? code;
  final Map<String, dynamic>? image;
  final Map<String, dynamic> rawJson;

  CountryModel({
    required this.id,
    required this.name,
    this.callingCode,
    this.code,
    this.image,
    this.rawJson = const {},
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      callingCode: json['callingCode']?.toString(),
      code: json['code']?.toString(),
      image: json['image'] is Map<String, dynamic> ? json['image'] : null,
      rawJson: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() {
    if (rawJson.isNotEmpty) {
      return rawJson;
    }
    return {
      'id': id,
      'name': name,
      'callingCode': callingCode,
      'code': code,
      'image': image,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Country API Services
class CountryApiServices {
  final Dio _dio = Dio();
  List<CountryModel>? _cachedCountries;

  // Get all countries from API (cached in memory after first load)
  Future<List<CountryModel>> fetchCountries({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCountries != null && _cachedCountries!.isNotEmpty) {
      return _cachedCountries!;
    }
    try {
      final response = await _dio.post(
        '/countries/all',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "select": {
            "id": 1,
            "name": 1,
            "image": 1,
            "callingCode": 1
          },
          "where": {
            "active": true
          }
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final list = response.data['list'] as List?;
        if (list != null) {
          _cachedCountries = list
              .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return _cachedCountries!;
        }
      }
      return _cachedCountries ?? [];
    } catch (e) {
      return _cachedCountries ?? [];
    }
  }

  // Get country by ID
  Future<Either<Failure, CountryModel>> getById(String countryId) async {
    try {
      final countries = await fetchCountries();
      final country = countries.firstWhere(
        (c) => c.id.toString() == countryId.toString(),
        orElse: () => CountryModel(id: countryId, name: 'Unknown'),
      );
      return Right(country);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Get all countries wrapped in Either
  Future<Either<Failure, List<CountryModel>>> getAllCountries() async {
    try {
      final countries = await fetchCountries();
      return Right(countries);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

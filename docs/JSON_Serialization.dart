// // lib/core/json_serialization_guide.dart
//
// /*
// FLUTTER JSON SERIALIZATION COMPLETE GUIDE
//
// 1. DEPENDENCIES (pubspec.yaml):
// dependencies:
//   json_annotation: ^4.9.0
//
// dev_dependencies:
//   build_runner: ^2.4.13
//   json_serializable: ^6.8.0
//
// 2. COMMANDS TO RUN (in order):
// flutter clean
// flutter pub get
// flutter pub run build_runner clean
// flutter pub run build_runner build --delete-conflicting-outputs
//
// 3. FILE STRUCTURE:
// lib/
//   ├── core/
//   │   └── base_model.dart
//   └── features/
//       └── your_feature/
//           └── data/
//               └── models/
//                   ├── your_model.dart
//                   └── your_model.g.dart (generated)
// */
//
// // TEMPLATE 1: Base Model
// // lib/core/base_model.dart
// abstract class BaseModel {
//   Map<String, dynamic> toJson();
// }
//
// // TEMPLATE 2: Basic Model
// // lib/features/your_feature/data/models/basic_model.dart
// import 'package:json_annotation/json_annotation.dart';
// import '../../../../core/base_model.dart';
//
// part 'basic_model.g.dart';
//
// @JsonSerializable(
//   explicitToJson: true,
//   includeIfNull: false,
//   fieldRename: FieldRename.snake,
// )
// class BasicModel implements BaseModel {
//   final String id;
//   final String name;
//   @JsonKey(defaultValue: '')
//   final String description;
//
//   const BasicModel({
//     required this.id,
//     required this.name,
//     this.description = '',
//   });
//
//   factory BasicModel.fromJson(Map<String, dynamic> json) =>
//       _$BasicModelFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => _$BasicModelToJson(this);
// }
//
// // TEMPLATE 3: Complex Model with All Features
// // lib/features/your_feature/data/models/complex_model.dart
// import 'package:json_annotation/json_annotation.dart';
// import '../../../../core/base_model.dart';
//
// part 'complex_model.g.dart';
//
// @JsonSerializable(
//   explicitToJson: true,
//   includeIfNull: false,
//   fieldRename: FieldRename.snake,
// )
// class ComplexModel implements BaseModel {
//   // 1. Basic Fields
//   @JsonKey(name: 'custom_id')
//   final String id;
//   final String name;
//
//   // 2. Fields with Default Values
//   @JsonKey(defaultValue: '')
//   final String description;
//   @JsonKey(defaultValue: 0)
//   final int count;
//
//   // 3. Nested Objects
//   final List<SubModel> items;
//   final MetadataModel metadata;
//
//   // 4. Date Fields
//   @JsonKey(
//     fromJson: _dateFromJson,
//     toJson: _dateToJson,
//   )
//   final DateTime createdAt;
//
//   // 5. Enum Fields
//   @JsonKey(
//     fromJson: StatusEnum.fromString,
//     toJson: _enumToString,
//   )
//   final StatusEnum status;
//
//   // 6. Optional Fields
//   final String? optionalField;
//
//   // 7. Constructor
//   const ComplexModel({
//     required this.id,
//     required this.name,
//     this.description = '',
//     this.count = 0,
//     required this.items,
//     required this.metadata,
//     required this.createdAt,
//     required this.status,
//     this.optionalField,
//   });
//
//   // 8. JSON Factories
//   factory ComplexModel.fromJson(Map<String, dynamic> json) =>
//       _$ComplexModelFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => _$ComplexModelToJson(this);
//
//   // 9. Helper Methods
//   static DateTime _dateFromJson(String date) => DateTime.parse(date);
//   static String _dateToJson(DateTime date) => date.toIso8601String();
//   static String _enumToString(StatusEnum status) => status.value;
//
//   // 10. copyWith Method
//   ComplexModel copyWith({
//     String? id,
//     String? name,
//     String? description,
//     int? count,
//     List<SubModel>? items,
//     MetadataModel? metadata,
//     DateTime? createdAt,
//     StatusEnum? status,
//     String? optionalField,
//   }) {
//     return ComplexModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       description: description ?? this.description,
//       count: count ?? this.count,
//       items: items ?? this.items,
//       metadata: metadata ?? this.metadata,
//       createdAt: createdAt ?? this.createdAt,
//       status: status ?? this.status,
//       optionalField: optionalField ?? this.optionalField,
//     );
//   }
// }
//
// // TEMPLATE 4: Sub-Models
// @JsonSerializable()
// class SubModel implements BaseModel {
//   final String id;
//   final String value;
//
//   const SubModel({
//     required this.id,
//     required this.value,
//   });
//
//   factory SubModel.fromJson(Map<String, dynamic> json) =>
//       _$SubModelFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => _$SubModelToJson(this);
// }
//
// @JsonSerializable()
// class MetadataModel implements BaseModel {
//   final String version;
//   @JsonKey(defaultValue: <String>[])
//   final List<String> tags;
//
//   const MetadataModel({
//     required this.version,
//     this.tags = const [],
//   });
//
//   factory MetadataModel.fromJson(Map<String, dynamic> json) =>
//       _$MetadataModelFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => _$MetadataModelToJson(this);
// }
//
// // TEMPLATE 5: Enum Example
// enum StatusEnum {
//   active('active'),
//   pending('pending'),
//   inactive('inactive');
//
//   final String value;
//   const StatusEnum(this.value);
//
//   factory StatusEnum.fromString(String status) {
//     return StatusEnum.values.firstWhere(
//           (e) => e.value == status,
//       orElse: () => StatusEnum.inactive,
//     );
//   }
// }
//
// // TEMPLATE 6: Example Usage
// void example() {
//   // Create model
//   final model = ComplexModel(
//     id: '123',
//     name: 'Test',
//     items: [
//       SubModel(id: '1', value: 'test'),
//     ],
//     metadata: MetadataModel(version: '1.0'),
//     createdAt: DateTime.now(),
//     status: StatusEnum.active,
//   );
//
//   // Convert to JSON
//   final json = model.toJson();
//
//   // Create from JSON
//   final decoded = ComplexModel.fromJson(json);
// }
//
// /* COMMON ISSUES AND SOLUTIONS:
//
// 1. Missing Generated Files:
//    - Ensure part directive matches file name exactly
//    - Run build_runner commands in sequence
//
// 2. Nested Object Issues:
//    - Add @JsonSerializable to all nested classes
//    - Use explicitToJson: true in parent class
//    - Ensure all nested classes have fromJson/toJson
//
// 3. Default Value Warnings:
//    - Choose between @JsonKey(defaultValue) or constructor default
//    - Don't use both to avoid warnings
//
// 4. Type Errors:
//    - Use proper types that match JSON data
//    - Add custom converters for complex types
//    - Handle null cases properly
//
// 5. Best Practices:
//    - Make models immutable (final fields)
//    - Use const constructors
//    - Implement copyWith()
//    - Add proper documentation
//    - Include meaningful defaults
//    - Handle nullability explicitly
// */

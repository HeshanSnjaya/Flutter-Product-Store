// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemModelImpl _$$ItemModelImplFromJson(Map<String, dynamic> json) =>
    _$ItemModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String,
    );

Map<String, dynamic> _$$ItemModelImplToJson(_$ItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'category': instance.category,
      'subCategory': instance.subCategory,
    };

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/item.dart';

part 'item_model.freezed.dart';
part 'item_model.g.dart';

@freezed
class ItemModel with _$ItemModel {
  const factory ItemModel({
    required String id,
    required String name,
    required String brand,
    required String category,
    required String subCategory,
  }) = _ItemModel;

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);
}

extension ItemModelX on ItemModel {
  Item toEntity() {
    return Item(
      id: id,
      name: name,
      brand: brand,
      category: category,
      subCategory: subCategory,
    );
  }
}

extension ItemX on Item {
  ItemModel toModel() {
    return ItemModel(
      id: id,
      name: name,
      brand: brand,
      category: category,
      subCategory: subCategory,
    );
  }
}

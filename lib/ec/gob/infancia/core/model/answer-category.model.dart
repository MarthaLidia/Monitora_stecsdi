/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.core;

class ModelAnswerCategory {
  final int id;
  final int order;
  final String label;

  ModelAnswerCategory({
    required this.id,
    required this.order,
    required this.label,
  });

  factory ModelAnswerCategory.from(Map<String, dynamic> obj) =>
      ModelAnswerCategory(
        id: obj['id'],
        order: obj['order'] ?? 1,
        label: obj['label'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order,
        'label': label,
      };

  @override
  toString() => '''{'id': $id, 'order': $order, 'label': $label,}''';
}

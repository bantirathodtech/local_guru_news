/// State Model - matches get_states_api.php response
class StateModel {
  final String id;
  final String state;

  StateModel({
    required this.id,
    required this.state,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
        id: json['id']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'state': state,
      };
}


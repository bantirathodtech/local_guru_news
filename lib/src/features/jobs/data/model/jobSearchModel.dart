class JobsSearchModel {
  JobsSearchModel({
    this.id,
    this.tags,
    this.title,
    this.salary,
    this.jobType,
    this.hires,
    this.qualification,
    this.customLocation,
    this.contact,
    this.shorDescription,
    this.description,
    this.time,
    this.readableTime,
    this.location,
  });

  String? id;
  List<String>? tags;
  String? title;
  String? salary;
  String? jobType;
  String? hires;
  String? qualification;
  String? customLocation;
  String? contact;
  String? shorDescription;
  String? description;
  DateTime? time;
  String? readableTime;
  String? location;

  factory JobsSearchModel.fromJson(Map<String, dynamic> json) =>
      JobsSearchModel(
        id: json["id"],
        tags: List<String>.from(json["tags"].map((x) => x)),
        title: json["title"],
        salary: json["salary"],
        jobType: json["jobType"],
        hires: json["hires"],
        qualification: json["qualification"],
        customLocation: json["customLocation"],
        contact: json["contact"],
        shorDescription: json['short_description'],
        description: json["description"],
        time: DateTime.parse(json["time"]),
        readableTime: json["readableTime"],
        location: json["location"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tags": List<dynamic>.from(tags!.map((x) => x)),
        "title": title,
        "salary": salary,
        "jobType": jobType,
        "hires": hires,
        "qualification": qualification,
        "customLocation": customLocation,
        "contact": contact,
        'short_description': shorDescription,
        "description": description,
        "time": time,
        "readableTime": readableTime,
        "location": location,
      };
}

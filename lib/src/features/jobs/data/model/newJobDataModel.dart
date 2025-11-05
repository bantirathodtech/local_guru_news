
import 'dart:convert';

NewJobModel newJobModelFromJson(String str) => NewJobModel.fromJson(json.decode(str));

String newJobModelToJson(NewJobModel data) => json.encode(data.toJson());

class NewJobModel {
    NewJobModel({
        this.categories,
        this.types,
    });

    List<Category> ?categories;
    List<Type> ?types;

    factory NewJobModel.fromJson(Map<String, dynamic> json) => NewJobModel(
        categories: List<Category>.from(json["categories"].map((x) => Category.fromJson(x))),
        types: List<Type>.from(json["types"].map((x) => Type.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "categories": List<dynamic>.from(categories!.map((x) => x.toJson())),
        "types": List<dynamic>.from(types!.map((x) => x.toJson())),
    };
}

class Category {
    Category({
        this.id,
        this.category,
        this.tags,
    });

    String ?id;
    String ?category;
    List<Tag> ?tags;

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        category: json["category"],
        tags: json["tags"] == null ? null : List<Tag>.from(json["tags"].map((x) => Tag.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "category": category,
        "tags": tags == null ? null : List<dynamic>.from(tags!.map((x) => x.toJson())),
    };
}

class Tag {
    Tag({
        this.id,
        this.catid,
        this.name,
    });

    String? id;
    String ?catid;
    String ?name;

    factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json["id"],
        catid: json["catid"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "catid": catid,
        "name": name,
    };
}

class Type {
    Type({
        this.id,
        this.jobtype,
    });

    String ?id;
    String ?jobtype;

    factory Type.fromJson(Map<String, dynamic> json) => Type(
        id: json["id"],
        jobtype: json["jobtype"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "jobtype": jobtype,
    };
}

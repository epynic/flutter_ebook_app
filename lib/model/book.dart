import 'dart:convert';

//Book bookFromJson(String str) => Book.fromJson(json.decode(str));

List<Book> booksFromJson(String str) =>
    List<Book>.from(json.decode(str).map((x) => Book.fromJson(x)));

String booksToJson(List<Book> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

String bookToJson(Book data) => json.encode(data.toJson());

class Book {
  String bookid;
  String imgUrl;
  String title;
  String description;
  String epubUrl;
  String rating;

  Book({
    this.bookid,
    this.imgUrl,
    this.title,
    this.description,
    this.epubUrl,
    this.rating,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        bookid: json["bookid"],
        imgUrl: json["imgURL"],
        title: json["title"],
        description: json["description"],
        epubUrl: json["epubURL"],
        rating: json["rating"],
      );

  Map<String, dynamic> toJson() => {
        "bookid": bookid,
        "imgURL": imgUrl,
        "title": title,
        "description": description,
        "epubURL": epubUrl,
        "rating": rating,
      };
}

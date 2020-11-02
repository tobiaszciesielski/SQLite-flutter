
// Model Class
class Student {
  final int id;
  final String firstName;
  final String lastName;
  final int grade;

  Student({
    this.id,
    this.firstName,
    this.lastName,
    this.grade
  });

  factory Student.fromMap(
      Map<String, dynamic> map
      ) => new Student(
        id: map["id"],
        firstName: map["first_name"],
        lastName: map["last_name"],
        grade: map["grade"]
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "grade": grade
  };
}

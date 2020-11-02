# SQLite i flutter - z czym to się je\*** ***.

W tym poradniku przestawiam, jak napisać prostą aplikację do dodawania i usuwania studentów za pomocą interfejsu użytkownika w bazie danych. 

---

💡 Zanim przeczytasz upewnij się, że: 
- 🔗Posiadasz zainstalowany [flutter](https://flutter.dev/docs/get-started/install),
- 🔗Posiadasz skonfigurowane  [IDE](https://flutter.dev/docs/get-started/editor) 
- 🔗Zapoznałeś się ze składnią języka [Dart](https://learnxinyminutes.com/docs/dart/)
- 🔗Wykonałeś  [pierwsze kroki](https://flutter.dev/docs/get-started/codelab) we flutterze

☕ Jeżeli wszystko ogarnięte to kawusia w dłoń i lecimy.

## 📚Czym jest flutter i SQLite

***Flutter*** to framework służący do tworzenia aplikacji wieloplatformowych. Pozwala nam na napisanie kodu, który działa równocześnie na platformach Android, iOS, Linux, Windows i MacOS. Flutter to projekt opensource stworzony przez Googla, więc możemy być pewni, że famework będzie wspierany jeszcze przez wiele lat. 

***SQLite*** to biblioteka C implementująca silnik bazy danych SQL. Została ona bardzo dobrze przetestowana co świadczy o jej niezawodności. Całość mieści się w pojedynczym pliku systemowym, a jego format jest wieloplatformowy. SQLite wypada bardzo dobrze w testach wydajności przy obsłudze jednego użytkownika. To wszystko sprawia, że SQLite sprawdza się świetnie w świecie mobile.

---

### ⚙️ Krok 1. Depencencies 

Stwórzmy nowy projekt, do którego dodamy dwie nowe zależności.

- ***[sqflite](https://pub.dev/packages/sqflite)*** to pakiet udostępniający nam klasy oraz funkcje do obsługi bazy danych SQLite
- ***[path_provider](https://pub.dev/packages/path_provider)*** to pakiet udostępniający funkcje do lokalizowania bazy danych na dysku

Do pliku `pubspec.yaml` dopisz najnowsze wersje tych pakietów. Nie zapomnij zaktualizować zależności.

```dart
dependencies:  
  flutter:  
    sdk: flutter  
  sqflite: ^1.3.0  
  path_provider: ^1.6.22
```
---
### 🌳 Krok 2. Przygotowanie struktury projektu 

Usuńmy folder `test`, nie będzie on nam potrzebny. 

W folderze `lib` stwórzmy folder `database` w którym będziemy trzymać całą logikę bazy danych naszej aplikacji. Stwórzmy w tym folderze plik `database.dart` w którym obsłużymy naszą bazę.

W folderze `database` stwórzmy folder`models`  (będziemy tu przechowywać klasy, które reprezentują model danych w bazie). Dodajmy do niego nowy plik `StudentModel.dart`.
```
+ --- + lib/
      |   main.dart
      |
      + --- + database/
            |   database.dart
            |
            + --- models/
                    StudentModel.dart
```

Gdy mamy przygotowaną strukturę, pora zabrać się za kodzenie 🧑‍💻. 

---
### 📐 Krok 3. Model Class
Aby zapewnić spójną komunikację między bazą danych a naszą aplikacją musimy zadbać o odpowiednie przechowywanie spójnego modelu danych. Posłuży nam do tego klasa `Student`.
`Student` będzie posiadał 4 pola. Typy danych będą różne dla języka Dart i SQL.  Pole`id` będzie  kluczem głównym.

| Pole klasy | Dart   | SQLite  |
|-----------:|-------:|-----:|
|🗝️ id       | int    | INT  |
| firstName  | String | TEXT |
| lastName   | String | TEXT |
| grade	     | int    | INT  |

🔗 [Typy danych SQLite](https://www.sqlite.org/datatype3.html)

Implementacja wygląda następująco. Pola posiadają typ `final`, ponieważ chcemy aby pierwsza przypisana do nich wartość była stała. Konstruktor domyślny z listą inicjalizacyjną. 

```dart
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
}
```
To nie koniec. SQLite z naszą aplikacją wymienia się danymi w postaci [Mapy](https://www.tutorialspoint.com/dart_programming/dart_programming_map.htm) . Aby sprawnie przechodzić z instancji klasy na mapę i odwrotnie należy zaimplementować odpowiednie do tego metody.
Zmapujemy ciąg znaków na dynamiczny typ danych ponieważ posiadamy różne rodzaje danych w modelu `Map<String, dynamic>`.

```dart
class Student {  

// ...

  factory Student.fromMap(  
    Map<String, dynamic> map) => new Student(  
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
```
Zauważ, że konstruktor klasy Student `fromMap` posiada słowo kluczowe `factory` (tak zwany *factory constructor*) dzięki któremu możemy obsłużyć logikę tworzenia instancji, której nie jest w stanie obsłużyć lista inicjalizacyjna. 

🔗 Więcej o *factory consturctor* na [dart.dev](https://dart.dev/guides/language/language-tour#factory-constructors) oraz [stackoverflow](https://stackoverflow.com/questions/53886304/understanding-factory-constructor-code-example-dart).

---
### 📊 Krok 4. DatabaseProvider

Pora zadbać o inicjalizację naszej bazy danych. Skorzystamy z wzorca [Singleton](https://refactoring.guru/pl/design-patterns/singleton) dzięki któremu obiekt `DatabaseProvider`  będzie jedynym tego rodzaju obiektem w naszej aplikacji. Taką logikę uzyskujemy za pomocą pola `static` instancji klasy oraz  prywatnego konstruktora. Dzięki temu instancja istnieje cały czas a prywatny konstruktor uniemożliwia stworzenia kolejnego obiektu z zewnątrz. 

```dart
  
class DatabaseProvider {  
  // private constructor  
  DatabaseProvider.internal();  
  
  // static instance  
  static final DatabaseProvider db = DatabaseProvider.internal();  
  
  // SQLite database  
  Database _database;  
}
```

Teraz potrzebujemy funkcji, która będzie zwracała nam połączenie z bazą danych lub tworzyła je jeżeli jeszcze nie zostało ustanowione. 

```dart
class DatabaseProvider { 
 
// ...

  Future<Database> get database async {  
    if(_database != null) return databaseInstance();  
    _database = await databaseInstance();  
    return _database;
  }  
  
  Future<Database> databaseInstance() async {  
    Directory dir = await getApplicationDocumentsDirectory();  
    String path = join(dir.path, "app_database.db");  
    return await openDatabase(  
      path,  
      version: 1,  
      onCreate: (db, v) async {  
        await db.execute("CREATE TABLE IF NOT EXISTS `students` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `first_name` TEXT, `last_name` TEXT, `grade` INT)");  
      }  
    );  
  }  
}
```

Zauważ, że powyższy kod nie zadziała nam jeżeli nie dodamy odpowiednich pakietów. 
``` dart
import 'package:sqflite/sqflite.dart';              // Database, openDatabase()
import 'package:path/path.dart';  	            // join()
import 'package:path_provider/path_provider.dart';  // getApplicationDocumentsDirectory()
import 'dart:io'; 				    // Diretory
```
---
### 🚀 Krok 5. CRUD

Stworzymy teraz funkcje do tworzenia, pobierania, aktualizowania i usuwania studentów. Należy też dodać model` Student `do naszego pliku `database.dart` .

1. Pobieranie studentów lub studenta po id
```dart
// ...

import 'models/StudentModel.dart';

class DatabaseProvider { 

// ...

  Future<List<Student>> getAllStudents() async {  
    final db = await database;  
    var response = await db.query('students');  
    List<Student> list = response.map(  
      (s) => Student.fromMap(s)  
    ).toList();  
    return list;  
  }  
  
  Future<Student> getStudentById(int id) async {  
    final db = await database;  
    var response = await db.query(  
      'students',  
      where: "id = ?",  
      whereArgs: [id]  
    );  
    return response.isEmpty ? Student.fromMap(response.first) : null;  
  }

// ...
```

2. Tworzenie studenta

```dart
// ...

  Future<int> addStudent(Student student) async {  
    final db = await database;  
    int id = await db.insert(  
      'students',  
      student.toMap(),  
      conflictAlgorithm: ConflictAlgorithm.replace  
    );  
    return id;

// ...
```

3. Usuwanie studentów lub studenta po id

```dart
// ...

  deleteAllStudents() async {  
    final db = await database;  
    db.delete("students");  
  }  
  
  deleteStudent(int id) async {  
    final db = await database;  
    db.delete("students", where: "id = ?", whereArgs: [id]);  
  }

// ...
```

4. Aktualizowanie studenta po id
```dart
// ...

  Future<int> updateStudent(Student student) async {  
    final db = await database;  
    var id = await db.update(  
      "students",   
      student.toMap(),  
      where: "id = ?",   
      whereArgs: [student.id]  
    );  
    return id;  
  }
}
```
---
### 🌟 Krok 6. UI

Nasze bazodanowe API w postaci `DatabaseProvider`  jest już gotowe. Pora wykorzystać je w praktyce! 
Przejdźmy do pliku `main.dart`. Stwórzmy `Stateful Widget`, który będzie przechowywał listę naszych studentów, zmienną `isLoading` informującą czy dane są pobierane oraz metodę `fetchStudents`, która będzie pobierała naszych studentów. 

```dart
void main () => runApp(MaterialApp(home: HomePage()));  
  
class HomePage extends StatefulWidget {  
  @override  
  _HomePageState createState() => _HomePageState();  
}  
  
class _HomePageState extends State<HomePage> {  
  bool isLoading;  
  List<StudentDriver> studentsList;  
  
  @override  
  void initState() {  
    super.initState();  
    isLoading = true;  
    fetchStudents();  
  }  
  
 //...
  
  void fetchStudents() async {  
    setState(() => isLoading = true);  
    final tmpList = await DatabaseProvider.db.getAllStudentDrivers();  
    setState(() {  
      isLoading = false;  
      studentsList = tmpList;  
    });  
  }  
}
```

Struktura Widgetów naszej aplikacji aplikacji będzie wyglądała następująco. 

```dart
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Center(child: Text('SQLite Demo')),
      ),
      body: Column(
        children: <Widget>[
          form(),
          list(),
        ],
      ),
    );
  }
```

Wykorzystamy prostą funkcję `split` do dzielenia ciągu znaków na dwa pola - imię i nazwisko. Ocena będzie wartością losowaną - od 1 do 5. Aby korzystać z wartości losowych, musimy dodać w nagłówku naszego pliku linijkę

```dart 
import 'dart:math';
```
Implementacja formularza. 
```dart 
  final textController = TextEditingController();  
  final formKey = GlobalKey<FormState>();

// ...

  form() {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Enter student full name'
              ),
              controller: textController,
              validator: (value) =>
              value.isEmpty ? "Field is empty" : null
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final words = textController.text.split(' ');
              if(formKey.currentState.validate()) {
                await DatabaseProvider.db.addStudent(
                  new Student(
                    firstName: words[0],
                    lastName: words[1],
                    grade: (Random().nextInt(4) + 1)
                  )
                );
                fetchStudents();
                textController.clear();
              }
            },
            child: Text("Add Student")
          )
        ]
      )
    );
  }
```
Implementacja listy studentów.

```dart
  list() {
    return Expanded(
      child: isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Dismissible(
              background: Container(color: Colors.red),
              key: Key(student.id.toString()),
              onDismissed: (direction) async {
                await DatabaseProvider.db.deleteStudent(student.id);
                fetchStudents();
              },
              child: ListTile(
                title: Text("${student.firstName} ${student.lastName}"),
                subtitle: Text('id: ${student.id} grade: ${student.grade}'),
              ),
            );
          }
        )
    );
  }
```
---
### 👏  Efekt końcowy

<img src="https://i.ibb.co/hsj3mV6/ezgif-6-5488300e3db8.gif" width="300">

---
### 💬 Podsumowanie

Zapoznałeś się z obsługą `sqlfite`. Teraz jesteś w stanie budować zapamiętujące dane. To otwiera przed Tobą pełnie możliwości. Co dalej ? Zachęcam do rozbudowania powyższej aplikacji (walidacja danych, kolejne pole formularza, aktualizowanie studenta) oraz zapoznania się z  [floor](https://pub.dev/packages/floor).
Dziękuję za przeczytanie tego artykułu i życzę Ci powodzenia w dalszym rozwijaniu się. 

\- Tobiasz Ciesielski [tobiaszciesielski](https://github.com/tobiaszciesielski)
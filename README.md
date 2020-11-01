# SQLite i flutter - z czym to się je*** ***.

W tym poradniku przestawiam, jak napisać prostą aplikację do dodawania i usuwania studentów za pomocą interfejsu użytkownika w bazie danych.

---

💡 Zanim przeczytasz upewnij się, że: 
- 🔗Posiadasz zainstalowany [flutter](https://flutter.dev/docs/get-started/install),
- 🔗Posiadasz skonfigurowane  [IDE](https://flutter.dev/docs/get-started/editor) 
- 🔗Zapoznałeś się ze składnią języka [Dart](https://learnxinyminutes.com/docs/dart/)
- 🔗Wykonałeś  [pierwsze kroki](https://flutter.dev/docs/get-started/codelab) we flutterze
- ☕ Masz obok siebie kawę

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
+ --- lib/
|       main.dart
|
+ --- + database/
      |   database.dart
      |
      + --- models/
              StudentModel.dart
```

Gdy mamy przygotowaną strukturę, pora zabrać się za kodzenie 🧑‍💻. 

---
### 🌳 Krok 3. Model Class
Aby zapewnić spójną komunikację między bazą danych a naszą aplikacją musimy zadbać o odpowiednie przechowywanie spójnego modelu danych. Posłuży nam do tego klasa `StudentModelClass`.
Obiekt Student będzie posiadał 4 pola. Typy danych będą różne dla języka Dart i SQL.  Pole`id` będzie  kluczem głównym.

| Pole klasy | Dart   | SQL  |
|-----------:|-------:|-----:|
|🗝️ id       | int    | INT  |
| firstName  | String | TEXT |
| lastName   | String | TEXT |
| grade	     | int    | INT  |

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

//...
```
To nie koniec. Format danych pobranych z SQLite ma postać JSON. Aby konwertować 

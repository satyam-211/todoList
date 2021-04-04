import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/model/todo.dart';

class DatabaseService {
  CollectionReference todosCollection =
      FirebaseFirestore.instance.collection("todos");

  Future createNewTodo(String title) async {
    return await todosCollection.add({
      "title": title,
      "isComplete": false,
    });
  }

  Future completTask(uid) async {
    await todosCollection.doc(uid).update({"isComplete": true});
  }

  Future removeTodo(uid) async {
    await todosCollection.doc(uid).delete();
  }

  List<Todo> todoFromFirestore(QuerySnapshot snapshot) {
    if (snapshot != null) {
      return snapshot.docs.map((e) {
        return Todo(
          isComplete: e.data()["isComplete"],
          title: e.data()["title"],
          uid: e.id,
        );
      }).toList();
    } else {
      return null;
    }
  }

  Stream<List<Todo>> listTodos() {
    return todosCollection.snapshots().map(todoFromFirestore);
  }
}

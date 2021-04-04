import 'package:flutter/material.dart';
import 'package:todo_app/loading.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/services/database_services.dart';
import 'package:todo_app/widgets/header.dart';

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  bool isComplet = false;
  TextEditingController todoTitleController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    todoTitleController.dispose();
  }

  void _saveTodo(BuildContext context) async {
    if (todoTitleController.text.isNotEmpty) {
      await DatabaseService().createNewTodo(todoTitleController.text.trim());
      todoTitleController.clear();
      Navigator.pop(context);
    }
  }

  TextFormField inputForm() {
    return TextFormField(
      controller: todoTitleController,
      style: TextStyle(
        fontSize: 18,
        height: 1.5,
        color: Colors.white,
      ),
      autofocus: true,
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
    );
  }

  Row dialogTitle(BuildContext context) {
    return Row(
      children: [
        Text(
          "Add Todo",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        Spacer(),
        IconButton(
          icon: Icon(
            Icons.cancel,
            color: Colors.grey,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Todo>>(
            stream: DatabaseService().listTodos(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              }
              List<Todo> todos = snapshot.data;
              return Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(),
                    ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[800],
                      ),
                      shrinkWrap: true,
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(todos[index].title),
                          background: Container(
                            padding: EdgeInsets.only(left: 20),
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.delete),
                            color: Colors.red,
                          ),
                          onDismissed: (direction) async {
                            await DatabaseService()
                                .removeTodo(todos[index].uid);
                          },
                          child: ListTile(
                            onTap: () {
                              DatabaseService().completTask(todos[index].uid);
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(2),
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: todos[index].isComplete
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    )
                                  : Container(),
                            ),
                            title: Text(
                              todos[index].title,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[200],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              );
            }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 20,
              ),
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: dialogTitle(context),
              children: [
                Divider(),
                inputForm(),
                SizedBox(height: 20),
                SizedBox(
                  width: width,
                  height: 50,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("Add"),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () => _saveTodo(context),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

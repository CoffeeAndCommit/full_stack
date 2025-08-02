import 'dart:convert';
import 'package:frontend/constants/api.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/widgets/app_bar.dart';
import 'package:frontend/widgets/todo_container.dart';
import 'package:http/http.dart' as http;
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loader = true;
  List<Todo> todosAll = [];
  int done = 0;
  int incomplete = 0;
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<List<Todo>> fetchData() async {
    try {
      final response = await http.get(Uri.parse(api));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<Todo> todos = jsonList.map((e) => Todo.fromJson(e)).toList();

        // For debugging
        // Reset counts before calculation
        int doneCount = 0;
        int incompleteCount = 0;
        for (var todo in todos) {
          print('${todo.id} - ${todo.title} - ${todo.isDone}');
          if (todo.isDone) {
            doneCount++;
          } else {
            incompleteCount++;
          }
        }
        setState(() {
          loader = false;
          todosAll = todos;
          done = doneCount;
          incomplete = incompleteCount;
        });
        todosAll = todos;
        return todos;
      } else {
        throw Exception("Failed to load todos: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  void delete_todo(int id) async {
    try {
      final url = Uri.parse('$deleteApi$id/');
      print("DELETE: $url");
      final response = await http.delete(url);

      print("Status: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          todosAll.removeWhere((todo) => todo.id == id);
          done = todosAll.where((t) => t.isDone).length;
          incomplete = todosAll.length - done;
        });
      } else {
        print("Failed to delete: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void add_todo(String title, String description, bool isDone) async {
    try {
      final url = Uri.parse(api);
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'title': title,
          'description': description,
          'isDone': isDone,
          'date': DateTime.now().toIso8601String(),
        }),
      );
      if (response.statusCode == 201) {
        setState(() {
          todosAll = [];
          fetchData();
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff001133),
      appBar: customAppBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            todosAll.isEmpty
                ? Container(
                    margin: EdgeInsets.all(16),
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Center(
                      child: Text(
                        " No Todo Found ",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: PieChart(
                      dataMap: {
                        "Done": done.toDouble(),
                        "Incomplete": incomplete.toDouble(),
                      },
                      colorList: [Colors.green, Colors.red],
                      legendOptions: LegendOptions(
                        showLegends: true,
                        legendTextStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            loader
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: todosAll
                        .map(
                          (e) => ToDoContainer(
                            id: e.id,
                            title: e.title,
                            isDone: e.isDone,
                            desc: e.description,
                            onDelete: () => delete_todo(e.id),
                          ),
                        )
                        .toList(),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                color: Color(0xff001133),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "Add Todo",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: titleController,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Enter Todo Title",

                              hintStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                            controller: descriptionController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Enter Todo Description",

                              hintStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () {
                                _formKey.currentState!.validate();
                                if (titleController.text.isEmpty ||
                                    descriptionController.text.isEmpty) {
                                  return;
                                } else {
                                  add_todo(
                                    titleController.text,
                                    descriptionController.text,
                                    false,
                                  );
                                  Navigator.pop(context);
                                  titleController.clear();
                                  descriptionController.clear();
                                }
                              },
                              child: Text(
                                "Add",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
       
       
        },
        backgroundColor: Colors.green,
        tooltip: 'Add Todo',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

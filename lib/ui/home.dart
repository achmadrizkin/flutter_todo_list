import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/helpers/database_helpers.dart';
import 'package:todo_app/models/task_models.dart';
import 'package:todo_app/ui/add_taskScreen.dart';
import 'add_taskScreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat("MMM dd, yyy");

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          ListTile(
            title: Text(task.title,
                style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'PopinsBold',
                    decoration: task.status == 0
                        ? TextDecoration.none
                        : TextDecoration.lineThrough)),
            subtitle: Text(
                '${_dateFormatter.format(task.date)} - ${task.priority}',
                style: TextStyle(
                    fontSize: 12.0,
                    fontFamily: 'PopinsReg',
                    decoration: task.status == 0
                        ? TextDecoration.none
                        : TextDecoration.lineThrough)),
            trailing: Checkbox(
              activeColor: Color(0xFFff6961),
              onChanged: (value) {
                task.status = value ? 1 : 0;
                DatabaseHelper.instance.updateTask(task);
                _updateTaskList();
              },
              value: task.status == 1 ? true : false,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTaskScreen(
                  updateTaskList: _updateTaskList,
                  task: task,
                ),
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFFff6961),
          child: Icon(Icons.add),
          onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTaskScreen(
                    updateTaskList: _updateTaskList,
                  ),
                ),
              )),
      body: FutureBuilder(
        future: _taskList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final int completedTaskCount = snapshot.data
              .where((Task task) => task.status == 1)
              .toList()
              .length;

          return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 80.0),
              itemCount: 1 + snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("My Task",
                            style: TextStyle(
                              fontSize: 60.0,
                              fontFamily: 'PopinsExBold',
                            )),
                        SizedBox(height: 5.0),
                        Text("$completedTaskCount of ${snapshot.data.length}",
                            style: TextStyle(
                              fontSize: 24.0,
                              fontFamily: 'PopinsReg',
                            )),
                      ],
                    ),
                  );
                }
                return _buildTask(snapshot.data[index - 1]);
              });
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/task_models.dart';
import 'package:todo_app/helpers/database_helpers.dart';

class AddTaskScreen extends StatefulWidget {
  final Function updateTaskList;
  final Task task;

  const AddTaskScreen({Key key, this.task, this.updateTaskList})
      : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // input
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _priority;

  /// _priorities, not _priority
  final List<String> _priorities = ["Low", "Medium", "High"];

  // pick date (coded)
  DateTime _date = DateTime.now(); // date now
  TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat("MMM dd, yyy");

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTask(widget.task.id);
    widget.updateTaskList();
    Navigator.pop(context);
  }

  ///save Data Task
  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print("$_title, $_date, $_priority");

      // insert task to the database
      Task task = Task(title: _title, date: _date, priority: _priority);
      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
      } else {
        //update the task
        task.id = widget.task.id;
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }
      widget.updateTaskList();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2002),
        lastDate: DateTime(2050));
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 35,
                        color: Color(0xFFff6961),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Text(widget.task == null ? "Add Task" : "Update Task",
                        style: TextStyle(
                          fontSize: 30.0,
                          fontFamily: 'PopinsBold',
                        )),
                  ],
                ),
                SizedBox(
                  key: _formKey,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: TextFormField(
                            style: TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              labelText: "Title",
                              labelStyle: TextStyle(fontSize: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (input) => input.trim().isEmpty
                                ? "Please enter a task title"
                                : null,
                            onSaved: (input) => _title = input,
                            initialValue: _title,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: TextFormField(
                            readOnly: true,
                            controller: _dateController,
                            onTap: _handleDatePicker,
                            style: TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              labelText: "Date",
                              labelStyle: TextStyle(fontSize: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (input) => input.trim().isEmpty
                                ? "Please enter a task"
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: DropdownButtonFormField(
                            // icon
                            icon: Icon(Icons.arrow_drop_down_circle),
                            iconSize: 25.0,
                            iconEnabledColor: Color(0xFFff6961),
                            items: _priorities.map((String priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(
                                  priority,
                                  style: TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                            // input
                            style: TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              labelText: "Priority",
                              labelStyle: TextStyle(fontSize: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (input) => _priority == null
                                ? "Please Select a priority level"
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _priority = value;
                              });
                            },
                            value: _priority,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20.0),
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 12,
                          decoration: BoxDecoration(
                            color: Color(0xFFff6961),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: FlatButton(
                            onPressed: _submit,
                            child: Text(widget.task == null ? "Add" : "Update",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontFamily: 'PopinsBolds')),
                          ),
                        ),
                        widget.task != null
                            ? Container(
                                margin: EdgeInsets.symmetric(vertical: 20.0),
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height / 12,
                                decoration: BoxDecoration(
                                  color: Color(0xFFff6961),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: FlatButton(
                                  onPressed: _delete,
                                  child: Text("Delete",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontFamily: 'PopinsBolds')),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

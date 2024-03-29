import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:time_range_picker/time_range_picker.dart';

import 'dart:async';

import 'push_notifications.dart';

final PushNotifications pushNoti = PushNotifications();

User? currentUser = FirebaseAuth.instance.currentUser;

DateTime selectedDate = DateTime.now();
String todayDate = DateFormat('yyyy년 MM월 d일').format(selectedDate);
bool isAdd = true;

CollectionReference toDo = FirebaseFirestore.instance
    .collection('user')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('toDo');
CollectionReference users = FirebaseFirestore.instance.collection('user');

dynamic id = 0;

Future<void> deleteToDo(data) {
  return toDo.doc(data.id).delete().then(
    (value) {
      pushNoti.deleteNotifications(data['id']);
    },
  );
}

Future<void> saveToDo(
    String time, TextEditingController content, int priority) async {
  var contents = content.text;
  String times = time;
  int id = 0;
  await users.doc(currentUser!.uid).get().then((value) {
    id = value.get('NumOfList');
  });
  return await toDo.doc().set({
    'date': todayDate,
    'time': time,
    'id': id,
    'content': contents,
    'priority': priority,
    'status': "Incomplete",
  }).then(
      // TODO: modify id
      (value) {
    pushNoti.setPushNotification(id, contents, todayDate, times);
    users.doc(currentUser!.uid).update({'NumOfList': id++ + 1});
  });
}

Future<void> updateTodo(
    data, String time, TextEditingController content, int priority) {
  int id = data['id'];
  var contents = content.text;
  return toDo.doc(data.id).update({
    'time': time,
    'content': content.text,
    'priority': priority,
  }).then(
      // TODO: modify id
      (value) => pushNoti.modifyNotifications(id, contents, todayDate, time));
}

// List<Map<String, Object>> status_todo = [
//   {"status": "Incomplete", "icon": const Icon(Icons.crop_square_outlined)},
// ];

Future<void> updateStatus(data, String text, context) {
  return toDo.doc(data.id).update({
    'status': text,
  }).then((value) {
    print("Status Updated");
    Navigator.pop(context);
  });
}

void showStatus(context, data) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ButtonBar(
                children: [
                  TextButton(
                    onPressed: () {
                      updateStatus(data, 'Complete', context);
                      // TODO: modify id
                      pushNoti.deleteNotifications(0);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_box,
                        ),
                        SizedBox(width: 10),
                        Text('Complete'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => updateStatus(data, 'In Progress', context),
                    child: Row(
                      children: [
                        Icon(Icons.star_half),
                        SizedBox(width: 10),
                        Text('In Progress'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => updateStatus(data, 'Postponed', context),
                    child: Row(
                      children: [
                        Icon(Icons.forward),
                        SizedBox(width: 10),
                        Text('Postponed'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => updateStatus(data, 'Cancel', context),
                    child: Row(
                      children: [
                        Icon(Icons.cancel_presentation_outlined),
                        SizedBox(width: 10),
                        Text('Cancel'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => updateStatus(data, 'Incomplete', context),
                    child: Row(
                      children: [
                        Icon(Icons.check_box_outline_blank),
                        SizedBox(width: 10),
                        Text('Incomplete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      });
}

void showContentDialog(context, data) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text("To Do")),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Date: " + data['date']),
              SizedBox(height: 10),
              Text("Time: " + data['time']),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Priority: "),
                  if (data['priority'] == 1)
                    Icon(Icons.circle, color: Colors.red),
                  if (data['priority'] == 2)
                    Icon(Icons.circle, color: Colors.blue),
                  if (data['priority'] == 3)
                    Icon(Icons.circle, color: Colors.green),
                ],
              ),
              SizedBox(height: 10),
              Text("Content: " + data['content']),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("삭제"),
              onPressed: () {
                deleteToDo(data);
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: new Text("수정"),
              onPressed: () {
                Navigator.pop(context);
                addContentDialog(context, data);
              },
            ),
          ],
        );
      });
}

TextEditingController _time = TextEditingController();
TextEditingController _content = TextEditingController();
int _value = 1;

TimeOfDay _startTime = TimeOfDay.now();
TimeOfDay _endTime = TimeOfDay.now();

_selectTime(BuildContext context, TimeOfDay selectedTime, bool start) async {
  var provider = myProvider();
  final TimeOfDay? timeOfDay = await showTimePicker(
    context: context,
    initialTime: selectedTime,
    initialEntryMode: TimePickerEntryMode.input,
  );

  if (timeOfDay != null && start) {
    _startTime = timeOfDay;
    print(_startTime);
  }
  if (timeOfDay != null && !start) {
    _endTime = timeOfDay;
  }
}

void addContentDialog(context, data) {
  String timeI = "";
  if (data != null) {
    _content = TextEditingController(text: data['content']);
    _time = TextEditingController(text: data['time']);
    _value = data['priority'];
    if (data['time'] != "") {
      timeI = data['time'];
    }
  }

  final List<int> listItems = <int>[1, 2, 3];
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text("To Do")),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          actions: <Widget>[
            FlatButton(
              child: new Text("취소"),
              onPressed: () {
                _content.clear();
                _value = 1;

                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: new Text("저장"),
              onPressed: () {
                if (data == null) {
                  saveToDo(timeI, _content, _value);
                } else {
                  updateTodo(data, timeI, _content, _value);
                }

                _content.clear();
                Navigator.pop(context);
              },
            ),
          ],
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    child: const Text("Time: "),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          TimeRange result = await showTimeRangePicker(
                            context: context,
                          );

                          setState(() => timeI = result.startTime
                                  .toString()
                                  .replaceAll(RegExp('[A-Za-z]'), '')
                                  .replaceAll("(", "")
                                  .replaceAll(")", "") +
                              " - " +
                              result.endTime
                                  .toString()
                                  .replaceAll(RegExp('[A-Za-z]'), '')
                                  .replaceAll("(", "")
                                  .replaceAll(")", ""));
                        },
                        child: Text("Selete Time"),
                      ),
                      SizedBox(width: 20),
                      Text(timeI),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Priority: "),
                      DropdownButton(
                        value: _value,
                        items: listItems.map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text("$value 순위"),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _value = value as int);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Content: "),
                      Expanded(
                        child: TextField(
                          maxLines: null,
                          controller: _content,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        );
      });
}

class myProvider with ChangeNotifier {
  void setPriority(value) {
    print(value);
    _value = value as int;
    notifyListeners();
  }

  void setTime(timeOfDay, start) {
    if (start)
      _startTime = timeOfDay;
    else
      _endTime = timeOfDay;

    print(_endTime);
    notifyListeners();
  }
}

Icon selectIcon(data) {
  if (data['status'] == "Complete") return Icon(Icons.check_box);
  if (data['status'] == "In Progress") return Icon(Icons.star_half);
  if (data['status'] == "Postponed") return Icon(Icons.forward);
  if (data['status'] == "Cancel")
    return Icon(Icons.cancel_presentation_outlined);

  return Icon(Icons.check_box_outline_blank);
}

class ToDoPage extends StatefulWidget {
  const ToDoPage({Key? key}) : super(key: key);

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  Stream toDoList = FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('toDo')
      .where('date', isEqualTo: todayDate)
      .orderBy('time', descending: false)
      .snapshots();

  bool isFull = false;

  @override
  Widget build(BuildContext context) {
    getTotalNumber(true);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(200, 10, 0, 0),
                      child: IconButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate, // Refer step 1
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2023),
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                                todayDate = DateFormat('yyyy년 MM월 d일')
                                    .format(selectedDate);
                                toDoList = FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('toDo')
                                    .where('date', isEqualTo: todayDate)
                                    .orderBy('time', descending: false)
                                    .snapshots();
                                if (selectedDate.isAfter(DateTime.now()
                                    .subtract(Duration(days: 1)))) {
                                  isAdd = true;
                                } else {
                                  isAdd = false;
                                }
                              });
                            }
                          },
                          icon: Icon(Icons.calendar_today)),
                    ),
                    Text(
                      todayDate,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  width: 280,
                  height: 420,
                  margin: EdgeInsets.fromLTRB(30, 30, 30, 30),
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "To Do",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      StreamBuilder(
                          stream: toDoList,
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (!snapshot.hasData) {
                              return LoadingFlipping.circle();
                            }
                            var len = toDoList.length;
                            print(len);

                            return ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot data =
                                    snapshot.data.docs[index];

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: selectIcon(data),
                                      onPressed: () =>
                                          showStatus(context, data),
                                    ),
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () =>
                                            showContentDialog(context, data),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            data['content'],
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Divider(height: 10, thickness: 1),
                                  ],
                                );
                              },
                            );
                          }),
                      IconButton(
                        icon: Icon(isAdd ? Icons.add : null),
                        onPressed: () async {
                          if (selectedDate.isAfter(
                                  DateTime.now().subtract(Duration(days: 1))) &&
                              await getTotalNumber(false) < 7) {
                            addContentDialog(context, null);
                          }

                          if (await getTotalNumber(false) >= 7) {
                            final snackBar = const SnackBar(
                                content: Text(
                                    'You can plan for 7 tasks for a day!'));

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future getTotalNumber(bool isSave) async {
  CollectionReference toDoData = FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('toDo');

  QuerySnapshot completedN = await toDoData
      .where("date", isEqualTo: todayDate)
      .where("status", isEqualTo: "Complete")
      .get();
  QuerySnapshot totalN =
      await toDoData.where("date", isEqualTo: todayDate).get();
  if (isSave) saveSta(completedN.size, totalN.size);
  return await totalN.size;
}

Future saveSta(int comp, int total) {
  CollectionReference toDoSta = FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('statistic');

  return toDoSta.doc(todayDate).set({
    "date": todayDate.split(" ")[0] + " " + todayDate.split(" ")[1],
    "totalN": total,
    "completed": comp,
    "percentage": total != 0 ? ((comp / total) * 100).roundToDouble() : 0
  }).then((value) => print("save"));
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'todo.dart';
import 'dashboard.dart';
import 'diary.dart';
import 'badge.dart';
import 'monthly.dart';

enum PageState {
  dashboard,
  diary,
  todo,
  calendar,
  badge,
}

final controller = PageController(
  initialPage: 0,
);
int pageChanged = 0;

class PageControll {
  void pageController(int pageNum) {
    controller.jumpToPage(pageNum);
  }
}

class HighlightPage extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const HighlightPage({
    required this.pageState,
    required this.pageFlow,
    required this.signOut,
  });

  final PageState pageState;
  final Function(int index) pageFlow;
  final Function() signOut;

  @override
  State<HighlightPage> createState() => _HighlightPageState();
}

class _HighlightPageState extends State<HighlightPage> {
  BottomAppBar appBar(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // TODO: modify
          IconButton(
            onPressed: () => controller.jumpToPage(0),
            icon: Icon(widget.pageState == PageState.dashboard
                ? Icons.home
                : Icons.home_outlined),
          ),
          IconButton(
            onPressed: () => controller.jumpToPage(1),
            icon: Icon(widget.pageState == PageState.diary
                ? Icons.fact_check
                : Icons.fact_check_outlined),
          ),
          IconButton(
            onPressed: () => controller.jumpToPage(2),
            icon: Icon(widget.pageState == PageState.todo
                ? Icons.note_alt
                : Icons.note_alt_outlined),
          ),
          IconButton(
            onPressed: () => controller.jumpToPage(3),
            icon: Icon(widget.pageState == PageState.calendar
                ? Icons.calendar_today
                : Icons.calendar_today_outlined),
          ),
          IconButton(
            onPressed: () => controller.jumpToPage(4),
            icon: Icon(widget.pageState == PageState.badge
                ? Icons.account_circle
                : Icons.account_circle_outlined),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.lightBlueAccent,
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      bottomNavigationBar: appBar(context),
      body: PageView(
        controller: controller,
        onPageChanged: (index) {
          setState(() {
            pageChanged = index;
          });
          widget.pageFlow(index);
        },
        children: [
          DashboardPage(),
          ToDoPage(),
          DiaryPage(),
          MonthlyPage(),
          BadgedPage(signOut: widget.signOut),
        ],
      ),
    );
  }
}

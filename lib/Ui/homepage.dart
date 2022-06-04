import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/Ui/add_task.dart';
import 'package:todoapp/Ui/themes.dart';
import 'package:todoapp/Ui/widgets/button.dart';
import 'package:todoapp/Ui/widgets/task_tile.dart';
import 'package:todoapp/controllers/task_controller.dart';
import 'package:todoapp/models/task.dart';
import 'package:todoapp/services/notification_services.dart';
import 'package:todoapp/services/theme_services.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var notifyHelper;
  DateTime _selecteddate = DateTime.now();
  final _taskcontroller = Get.put(TaskController());

  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.backgroundColor,
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          SizedBox(
            height: 10,
          ),
          _showTasks(),
        ],
      ),
    );
  }

  _addDateBar() {
    return Container(
        margin: const EdgeInsets.only(top: 20, left: 20),
        child: DatePicker(
          DateTime.now(),
          height: 100,
          width: 80,
          initialSelectedDate: DateTime.now(),
          selectionColor: primaryclr,
          selectedTextColor: white,
          dateTextStyle: GoogleFonts.lato(
              textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          )),
          monthTextStyle: GoogleFonts.lato(
              textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          )),
          dayTextStyle: GoogleFonts.lato(
              textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          )),
          onDateChange: (date) {
            setState(() {
              _selecteddate = date;
            });
          },
        ));
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                Text(
                  "Today",
                  style: HeadingStyle,
                ),
              ],
            ),
          ),
          MyButton(
              label: " + Add Task",
              onTap: () async {
                await Get.to(() => MyTask());
                _taskcontroller.getTasks();
              }),
        ],
      ),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          ThemeService().switchtheme();
          notifyHelper.displayNotification(
            title: "Theme changed",
            body: Get.isDarkMode
                ? "Activated light Theme "
                : "Activated dark theme",
          );
          notifyHelper.scheduledNotification();
        },
        child: Icon(
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: const [
        CircleAvatar(backgroundImage: AssetImage("assets/images/profile.jpg")),
        SizedBox(
          width: 20,
        )
      ],
    );
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
          itemCount: _taskcontroller.tasklist.length,
          itemBuilder: (_, index) {
            Task task = _taskcontroller.tasklist[index];
            print(task.toJson());
            if (task.repeat == 'daily ') {
              return AnimationConfiguration.staggeredList(
                  position: index,
                  child: FadeInAnimation(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showBottomsheet(context, task);
                            print("clicked");
                          },
                          child: TaskTile(task),
                        )
                      ],
                    ),
                  ));
            }
            if (task.date == DateFormat.yMd().format(_selecteddate)) {
              return AnimationConfiguration.staggeredList(
                  position: index,
                  child: FadeInAnimation(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showBottomsheet(context, task);
                            print("clicked");
                          },
                          child: TaskTile(task),
                        )
                      ],
                    ),
                  ));
            } else {
              return Container();
            }
          },
        );
      }),
    );
  }

  void _showBottomsheet(BuildContext context, Task task) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.only(top: 4),
      height: task.isCompleted == 1
          ? MediaQuery.of(context).size.height * 0.24
          : MediaQuery.of(context).size.height * 0.32,
      color: Get.isDarkMode ? darkGreyClr : white,
      child: Column(children: [
        Container(
          height: 6,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
          ),
        ),
        Spacer(),
        task.isCompleted == 1
            ? Container()
            : _bottomsheetButton(
                label: " Task Completed ",
                onTap: () {
                  _taskcontroller.markisCompleted(task.id!);
                  Get.back();
                },
                clr: primaryclr,
                context: context,
              ),
        SizedBox(
          height: 20,
        ),
        _bottomsheetButton(
          label: " Delete Task ",
          onTap: () {
            _taskcontroller.delete(task);
            Get.back();
          },
          clr: Colors.red[300]!,
          context: context,
        ),
        SizedBox(
          height: 20,
        ),
        _bottomsheetButton(
          label: " Close ",
          onTap: () {
            Get.back();
          },
          isclose: true,
          clr: Colors.red[300]!,
          context: context,
        ),
        SizedBox(
          height: 10,
        )
      ]),
    ));
  }
}

_bottomsheetButton({
  required String label,
  required Function()? onTap,
  required Color clr,
  bool isclose = false,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 55,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        border: Border.all(
          color: isclose == true
              ? Get.isDarkMode
                  ? Colors.grey[600]!
                  : Colors.grey[300]!
              : clr,
        ),
        borderRadius: BorderRadius.circular(20),
        color: isclose == true ? Colors.transparent : clr,
      ),
      child: Center(
        child: Text(
          label,
          style:
              isclose ? titleStyle : titleStyle.copyWith(color: Colors.white),
        ),
      ),
    ),
  );
}

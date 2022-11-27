// ignore_for_file: unused_local_variable
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:todo/constants/consts.dart';
import 'package:todo/exception/app_exception.dart';
import 'package:todo/helper/page_helper.dart';
import 'package:todo/model/tasks.dart';
import 'package:todo/notification/local_notification.dart';
import 'package:todo/view/auth_page.dart';
import 'package:todo/view/add_task.dart';
import 'package:todo/view_model/select_viewmodel.dart';
import 'package:todo/view_model/sf_calendar.dart';
import 'package:todo/view_model/task_crud_viewmodel.dart';
import 'package:todo/view_model/login_viewmodel.dart';

class HomePage extends StatefulWidget with PageHelper {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> cancelAllNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  String value = "";
  String monthSayi = "";
  String monthName = "";
  String dayName = "";
  bool visble = false;
  List<String> selectIndex = [];
  CalendarController controller = CalendarController();
  DateTime cupertinoInitialDateTime = DateTime.now();

  @override
  void initState() {
    //aşağıdaki metod bitmeden ekran çizilmez
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<Notifications>(context, listen: false)
          .getPendingNotificationCount();
      setState(() {});
    });
    Provider.of<LoginViewModel>(context, listen: false).currentUserUid();
    super.initState();
  }

  TextEditingController detailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final notifications = Provider.of<Notifications>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Yapılacaklar',
          style: TextStyle(color: Colors.black, fontFamily: "DonegalOne"),
        ),
        leading: IconButton(
            onPressed: () async {
              await Provider.of<LoginViewModel>(context, listen: false)
                  .logOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthPage(),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.deepOrangeAccent,
            )),
      ),
      body: body(),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Provider.of<Notifications>(context, listen: false)
                .getPendingNotificationCount;
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddTask()));
            Provider.of<Notifications>(context, listen: false)
                .getPendingNotificationCount();
          },
          backgroundColor: Colors.deepOrangeAccent,
          child: const Icon(Icons.add)),
      backgroundColor: Colors.white,
    );
  }

  Widget body() {
    final taskviewModel = Provider.of<TaskViewModel>(context, listen: false);
    final userUid = Provider.of<LoginViewModel>(context, listen: false).userUid;
    final clearList = Provider.of<SelectItem>(context, listen: false).list;

    Random random = Random();
    return StreamBuilder<List<Task>>(
      stream: taskviewModel.getAllTask(userUid),
      builder: (context, firebaseGetData) {
        if (firebaseGetData.connectionState == ConnectionState.waiting) {
          if (!firebaseGetData.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrangeAccent,
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.deepOrangeAccent,
            ),
          );
        } else {
          final dataReceived = firebaseGetData.data!;
          if (dataReceived.isNotEmpty) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: dataReceived.length,
                itemBuilder: (context, dataIndex) {
                  String taskName = dataReceived[dataIndex].taskName!;
                  String denemece = dataReceived[dataIndex].taskDate!;
                  return Stack(
                    children: [
                      showModalBottom(taskviewModel, denemece, userUid!,
                          taskName, dataIndex, dataReceived),
                      stackPositioned(taskName),
                    ],
                  );
                });
          } else {
            return noData();
          }
        }
      },
    );
  }

  Widget bodyListTile(
      dynamic task, String uid, String item, dynamic index, dynamic data) {
    DateTime subTitleText = DateTime.parse(data[index].taskDate);
    final taskviewModel = Provider.of<TaskViewModel>(context, listen: false);
    final userUid = Provider.of<LoginViewModel>(context, listen: false).userUid;
    return Column(
      children: [
        SizedBox(
          height: 70,
          child: ListTile(
            tileColor: Colors.white,
            leading: selected(item),
            title: Text(
              data[index].taskName!,
              style: PageHelper.textStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text("${DateFormat('dd-MM-yyyy').format(subTitleText)} ",
                style: PageHelper.textStyle()),
            isThreeLine: true,
            trailing:
                Consumer<SelectItem>(builder: (context, viewModel, child) {
              if (viewModel.list.contains(item)) {
                return IconButton(
                    onPressed: () {
                      setState(() {
                        taskviewModel.deleteTask(userUid!, data[index].date);
                        //taskviewModel.deleteTask(userUid!, data[index].date);
                        cancelAllNotification(data[index].id!);
                      });
                    },
                    icon: const Icon(Icons.clear_rounded, color: Colors.grey));
              } else {
                return const Text("");
              }
            }),
          ),
        ),
      ],
    );
  }

  Widget stackPositioned(dynamic item) {
    return Positioned(
      top: 33,
      child: Consumer<SelectItem>(builder: (context, viewModel, child) {
        if (viewModel.list.contains(item)) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const Padding(
              padding: EdgeInsets.only(left: 60, right: 50),
              child: Divider(
                height: 2,
                thickness: 1,
                color: Colors.grey,
              ),
            ),
          );
        } else {
          return const Text("");
        }
      }),
    );
  }

  Widget selected(String item) {
    return Consumer<SelectItem>(builder: (context, viewModel, child) {
      return IconButton(
        icon: Icon(
          viewModel.list.contains(item)
              ? Icons.check_circle_rounded
              : Icons.radio_button_off,
          color: Colors.grey,
        ),
        onPressed: () {
          if (viewModel.list.contains(item)) {
            viewModel.removeItem(item);
          } else {
            viewModel.addItem(item);
          }
        },
      );
    });
  }

  Widget noData() {
    return Container(
        color: Colors.white,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            "assets/dataYok.png",
            width: 100,
            height: 100,
          ),
          const Text('Yeni bir görev ekleyin')
        ]));
  }

  showModalBottom(dynamic task, String denemece, String uid, String taskIndex,
      dynamic index, dynamic data) {
    return GestureDetector(
      onTap: () {
        detailController.text = taskIndex;
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setStatem) {
                return Container(
                  height: MediaQuery.of(context).size.height - 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 3,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ]),
                              width: 50,
                              height: 5,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "GÖREV AYRINTILARI",
                                  style: PageHelper.textStyle(),
                                ),
                              ),
                              const SizedBox(
                                width: 155,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Divider(
                                    height: 5,
                                    thickness: 2,
                                    color: Colors.deepOrangeAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              updateData(
                                data[index].id,
                                data[index].date,
                                data[index].fullTime,
                                data[index].taskDate,
                              );
                            },
                            child: const Text("Kaydet"),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          controller: detailController,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            counterText: "",
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2.0),
                            ),
                            /* border: OutlineInputBorder(), */
                          ),
                          maxLength: 300,
                          maxLines: 2,
                        ),
                      ),
                      dateTimeWidget(data, index, setStatem),
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sfCalendar(index, denemece, data, taskIndex,
                                    setStatem),
                                cupertinoDataPicker(setStatem),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
            });
      },
      child: bodyListTile(task, uid, taskIndex, index, data),
    );
  }

  Future updateData(
      dynamic id, String date, DateTime fullTime, String taskDate) async {
    final notification = Provider.of<Notifications>(context, listen: false);
    final userUid = Provider.of<LoginViewModel>(context, listen: false).userUid;
    try {
      if (detailController.text.trim().isNotEmpty) {
        Task saveTask = Task(
          id: id,
          date: date,
          fullTime: fullTime,
          taskDate: fullDateTime.toString(),
          taskName: detailController.text,
        );
        await Provider.of<TaskViewModel>(context, listen: false)
            .updateTask(saveTask, userUid!);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      /// exception hatasına göre metin sergileyeceğiz
      String defaultErrorText = "Hata";
      String errorText = (e is AppException)
          ? (e.detail != null)
              ? (e.detail!.isNotEmpty)
                  ? e.detail!
                  : defaultErrorText
              : defaultErrorText
          : defaultErrorText;
      ScaffoldMessenger(
        child: SnackBar(
          content: Text(errorText),
        ),
      );
    }
  }

  sfCalendar(dynamic index, String denemece, dynamic data, String item,
      StateSetter state) {
    final taskviewModel = Provider.of<TaskViewModel>(context, listen: false);
    final userUid = Provider.of<LoginViewModel>(context, listen: false).userUid;
    List<Meeting> collection = <Meeting>[];

    final getCalendarData = Provider.of<Meeting>(context, listen: false)
        .getCalendarDataSource(collection);
    if (data != null) {
      final dataReceived = data!;
      for (int i = 0; i < data.length; i++) {
        DateTime tempDate = DateFormat("yyyy-MM-dd").parse(data[i].taskDate!);
        collection.add(Meeting(
            eventName: dataReceived[i].taskName,
            from: tempDate,
            to: tempDate,
            isAllDay: true,
            background: Colors.deepOrangeAccent));
      }
      return Column(
        children: [
          Visibility(
            visible: dateVisible,
            child: SizedBox(
              height: 400,
              child: SfCalendar(
                dataSource: getCalendarData,
                viewHeaderHeight: 30,
                cellBorderColor: Colors.transparent,
                headerStyle:
                    CalendarHeaderStyle(textStyle: PageHelper.textStyle()),
                controller: controller,
                view: CalendarView.month,
                onTap: (CalendarTapDetails details) {
                  state(() {
                    dynamic appointment = details.appointments;
                    dayNum = details.date!.day;
                    month = details.date!.month;
                    year = details.date!.year;
                    fullDateTime = details.date!;
                    monthName = DateFormat.MMMM('tr').format(details.date!);
                    dayName = DateFormat.EEEE('tr').format(details.date!);
                    CalendarElement element = details.targetElement;
                  });
                },
                onViewChanged: (ViewChangedDetails viewChangedDetails) {
                  List<DateTime> dates = viewChangedDetails.visibleDates;
                  SchedulerBinding.instance
                      .addPostFrameCallback((Duration duration) {
                    controller.selectedDate = dates
                        .where((e) =>
                            e.day == DateTime.parse(data[index].taskDate!).day)
                        .first;
                    controller.selectedDate = viewChangedDetails.visibleDates
                        .where((e) => e.month == controller.selectedDate!.month)
                        .last;

                    state(() {
                      dayNum = (DateTime.parse(data[index].taskDate!).day);

                      dayName = DateFormat.EEEE('tr')
                          .format(DateTime.parse(data[index].taskDate!));
                      debugPrint(dayName);

                      monthName = DateFormat.MMMM('tr')
                          .format(DateTime.parse(data[index].taskDate!));
                    });
                  });
                },
                monthViewSettings: const MonthViewSettings(
                    showAgenda: true,
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.indicator),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      );
    } else {
      return const Center(child: Text("Yok"));
    }
  }

  Widget cupertinoDataPicker(StateSetter setState) {
    return Visibility(
      visible: timeVisible,
      child: Column(
        children: [
          SizedBox(
            height: kDateTimePickerHeight,
            width: MediaQuery.of(context).size.width / 2,
            child: CupertinoDatePicker(
              use24hFormat: true,
              mode: CupertinoDatePickerMode.time,
              initialDateTime: cupertinoInitialDateTime,
              onDateTimeChanged: (newDateTime) {
                setState(() {
                  cupertinoInitialDateTime = newDateTime;
                  hour = newDateTime.hour;
                  minute = newDateTime.minute;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget dateTimeWidget(dynamic data, dynamic index, StateSetter setState) {
    return Column(
      children: [
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 13.0),
              child: Text(
                "Tarih",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontFamily: "DonegalOne"),
              ),
            ),
            const SizedBox(
              width: 23,
            ),
            dateTextWidget(data, index, setState),
          ],
        ),
        timeTextWidget(setState),
      ],
    );
  }

  Widget dateTextWidget(dynamic data, dynamic index, StateSetter setState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (() {
            setState(() {
              dateVisible = true;
              timeVisible = false;
              select = 1;
              color1 = Colors.greenAccent.shade100;
              color2 = Colors.white;
            });
          }),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 30,
              constraints: const BoxConstraints(
                maxWidth: 220,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: color1,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(
                        dayNum.toString(),
                        style: const TextStyle(
                            fontSize: 18, fontFamily: "DonegalOne"),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      monthName,
                      style: const TextStyle(
                          fontSize: 18, fontFamily: "DonegalOne"),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        dayName,
                        style: const TextStyle(
                            fontSize: 18, fontFamily: "DonegalOne"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget timeTextWidget(StateSetter setState) {
    return GestureDetector(
      onTap: (() {
        setState(() {
          timeVisible = true;
          dateVisible = false;
          select = 2;
          color2 = Colors.greenAccent.shade100;
          color1 = Colors.white;
        });
      }),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 120,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color2,
          ),
          child: Center(
            child: Text(
              // ignore: unnecessary_string_interpolations
              "${DateFormat.Hm().format(cupertinoInitialDateTime)}",
              style: const TextStyle(fontSize: 18, fontFamily: "DonegalOne"),
            ),
          ),
        ),
      ),
    );
  }
}

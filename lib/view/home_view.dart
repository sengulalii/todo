// ignore_for_file: public_member_api_docs, sort_constructors_first
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
import 'package:todo/view/add_view.dart';
import 'package:todo/view/auth_view.dart';
import 'package:todo/view_model/login_viewmodel.dart';
import 'package:todo/view_model/select_viewmodel.dart';
import 'package:todo/view_model/sf_calendar.dart';
import 'package:todo/view_model/task_crud_viewmodel.dart';

class HomePage extends StatefulWidget {
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

  TextEditingController detailController = TextEditingController();
  TextEditingController hourController = TextEditingController();
  TextEditingController minuteController = TextEditingController();
  CalendarController calendarController = CalendarController();
  bool visble = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<Notifications>(context, listen: false)
          .getPendingNotificationCount();
      setState(() {});
    });
    Provider.of<LoginViewModel>(context, listen: false).currentUserUid();

    super.initState();
  }

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
                    builder: (context) => AuthPage(),
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
      floatingActionButton: _fab(context),
      backgroundColor: Colors.white,
    );
  }

  FloatingActionButton _fab(BuildContext context) {
    return FloatingActionButton(
        onPressed: () async {
          Provider.of<Notifications>(context, listen: false)
              .getPendingNotificationCount();
          //flutterLocalNotificationsPlugin.cancelAll();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddTask()));
        },
        backgroundColor: Colors.deepOrangeAccent,
        child: const Icon(Icons.add));
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
          List<Task> dataReceived = firebaseGetData.data!;
          if (dataReceived.isNotEmpty) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: dataReceived.length,
                itemBuilder: (context, dataIndex) {
                  String taskName = dataReceived[dataIndex].taskName!;
                  String hour = dataReceived[dataIndex].notificationHour!;
                  String minute = dataReceived[dataIndex].notificationMinute!;
                  return Stack(
                    children: [
                      showModalBottom(
                        dataReceived,
                        taskName,
                        hour,
                        minute,
                        dataIndex,
                      ),
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
    List<Task> dataReceived,
    String item,
    int dataIndex,
  ) {
    DateTime subTitleText = DateTime.parse(dataReceived[dataIndex].taskDate!);
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
              dataReceived[dataIndex].taskName!,
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
                        taskviewModel.deleteTask(
                            userUid!, dataReceived[dataIndex].date!);
                        cancelAllNotification(dataReceived[dataIndex].id!);
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
            debugPrint(item);
            viewModel.removeItem(item);
          } else {
            debugPrint(item);
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
          Center(
            child: Image.asset(
              "assets/dataYok.png",
              width: 100,
              height: 100,
            ),
          ),
          const Text('Yeni bir görev ekleyin')
        ]));
  }

  showModalBottom(List<Task> dataReceived, String taskName, String hour,
      String minute, int dataIndex) {
    List<PendingNotificationRequest> notificationList = [];
    DateTime firebaseDate =
        DateTime.parse("${dataReceived[dataIndex].taskDate}");
    String day = DateFormat.d('tr').format(firebaseDate);
    String month = DateFormat.MMMM('tr').format(firebaseDate);
    String dayName = DateFormat.EEEE('tr').format(firebaseDate);
    return GestureDetector(
      onTap: () {
        detailController.text = taskName;
        hourController.text = hour;
        minuteController.text = minute;
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            builder: (BuildContext context) {
              return _BottomSheetContent(
                index: dataIndex,
                data: dataReceived,
                item: taskName,
                day: day,
                month: month,
                dayName: dayName,
                updateData: updateData,
                databaseDate: firebaseDate,
                detailController: detailController,
                hourController: hourController,
                minuteController: minuteController,
              );
            });
      },
      child: bodyListTile(
        dataReceived,
        taskName,
        dataIndex,
      ),
    );
  }

  /*  Widget dateText(String day, String month, String dayName) {
    return Center(child: Text("$day $month $dayName"));
  } */

  Future updateData(
      int id, String date, DateTime fullTime, String taskDate) async {
    final notification = Provider.of<Notifications>(context, listen: false);
    final userUid = Provider.of<LoginViewModel>(context, listen: false).userUid;
    try {
      if (detailController.text.trim().isNotEmpty) {
        Task saveTask = Task(
          id: id,
          date: date,
          fullTime: fullTime,
          taskDate: PageHelper.taskDateTime.toString(),
          notificationHour: hourController.text,
          notificationMinute: minuteController.text,
          notificationYear: PageHelper.years.toString(),
          notificationMonth: PageHelper.months.toString(),
          notificationDay: PageHelper.days.toString(),
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
}

// ignore: must_be_immutable
class _BottomSheetContent extends StatefulWidget {
  int index;
  List<Task> data;
  String item;
  String day;
  String month;
  String dayName;
  DateTime databaseDate;
  Function updateData;
  TextEditingController detailController;
  TextEditingController hourController;
  TextEditingController minuteController;
  _BottomSheetContent({
    Key? key,
    required this.index,
    required this.data,
    required this.item,
    required this.day,
    required this.month,
    required this.dayName,
    required this.databaseDate,
    required this.updateData,
    required this.detailController,
    required this.hourController,
    required this.minuteController,
  }) : super(key: key);

  @override
  State<_BottomSheetContent> createState() => __BottomSheetContentState();
}

class __BottomSheetContentState extends State<_BottomSheetContent> {
  String uiDay = "";
  String uidMonth = "";
  CalendarController calendarController = CalendarController();
  DateTime firebaseDatePicker = DateTime.now();
  Widget cupertinoDatePicker(int index, List<Task> data, String item,
      String day, String month, String dayName, DateTime firebaseDate) {
    DateTime databaseTaskDate = DateTime.parse("${data[index].taskDate}");

    final taskviewModel = Provider.of<TaskViewModel>(context, listen: false);
    final userUid = Provider.of<LoginViewModel>(context, listen: false).userUid;
    return Column(
      children: [
        Center(
          child: SizedBox(
            height: kDateTimePickerHeight,
            width: MediaQuery.of(context).size.width / 1,
            child: CupertinoDatePicker(
              backgroundColor: Colors.greenAccent.shade100,
              use24hFormat: true,
              mode: CupertinoDatePickerMode.date,
              initialDateTime: databaseTaskDate,
              onDateTimeChanged: (newDateTime) {
                setState(() {
                  firebaseDatePicker = newDateTime;
                  day = DateFormat.d('tr').format(newDateTime);
                  month = DateFormat.MMMM('tr').format(newDateTime);
                  dayName = DateFormat.EEEE('tr').format(newDateTime);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget sfCalendar() {
    final taskviewModel = Provider.of<TaskViewModel>(context, listen: false);
    final userUid = Provider.of<LoginViewModel>(context, listen: false).userUid;
    DateTime firebaseDate =
        DateTime.parse("${widget.data[widget.index].taskDate}");
    List<Meeting> collection = <Meeting>[];

    Random random = Random();
    final getCalendarData = Provider.of<Meeting>(context, listen: false)
        .getCalendarDataSource(collection);

    return StreamBuilder<List<Task>>(
      stream: taskviewModel.getAllTask(userUid),
      builder: (context, firebaseGetData) {
        if (firebaseGetData.hasData) {
          final dataReceived = firebaseGetData.data!;
          int indeks = 0;
          for (int i = 0; i < dataReceived.length; i++) {
            indeks = random.nextInt(dataReceived.length);
            DateTime tempDate =
                DateFormat("yyyy-MM-dd").parse(dataReceived[i].taskDate!);
            collection.add(Meeting(
              eventName: dataReceived[i].taskName,
              from: tempDate,
              to: tempDate,
              isAllDay: true,
              background: Colors.blue,
            ));
          }
          return Column(
            children: [
              Visibility(
                visible: PageHelper.dateVisible,
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 1.3,
                  child: SfCalendar(
                    dataSource: getCalendarData,
                    todayHighlightColor: Colors.deepOrangeAccent,
                    initialDisplayDate: firebaseDate,
                    viewHeaderHeight: 30,
                    headerStyle:
                        CalendarHeaderStyle(textStyle: PageHelper.textStyle()),
                    controller: calendarController,
                    view: CalendarView.month,
                    onTap: onTapChanged,
                    onViewChanged: viewChanged,
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
              Visibility(
                visible: PageHelper.dateVisible,
                child: PageHelper.paddingHelper(),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Visibility(
                visible: PageHelper.dateVisible,
                child: SfCalendar(
                  viewHeaderHeight: 30,
                  headerStyle:
                      CalendarHeaderStyle(textStyle: PageHelper.textStyle()),
                  controller: calendarController,
                  initialDisplayDate: firebaseDatePicker,
                  initialSelectedDate: firebaseDatePicker,
                  view: CalendarView.month,
                  onTap: onTapChanged,
                  onViewChanged: viewChanged,
                  monthViewSettings: const MonthViewSettings(
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Visibility(
                visible: PageHelper.dateVisible,
                child: PageHelper.paddingHelper(),
              ),
            ],
          );
        }
      },
    );
  }

  void onTapChanged(CalendarTapDetails details) {
    setState(() {
      List<dynamic>? appointment = details.appointments;
      PageHelper.dayNum = details.date!.day;
      PageHelper.month = details.date!.month;
      PageHelper.year = details.date!.year;
      PageHelper.taskDateTime = details.date!;
      widget.day = DateFormat.d('tr').format(details.date!);
      widget.month = DateFormat.MMMM('tr').format(details.date!);
      widget.dayName = DateFormat.EEEE('tr').format(details.date!);

      PageHelper.years = details.date!.year;
      PageHelper.months = details.date!.month;
      PageHelper.days = details.date!.day;
      debugPrint(PageHelper.taskDateTime.toString());
      uidMonth = DateFormat.MMMM('tr').format(details.date!);
      uiDay = DateFormat.EEEE('tr').format(details.date!);
      CalendarElement element = details.targetElement;
    });
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    List<DateTime> dates = viewChangedDetails.visibleDates;
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      calendarController.selectedDate = viewChangedDetails.visibleDates
          .where((e) => e.day == firebaseDatePicker.day)
          .first;
      viewChangedDetails.visibleDates
          .where((e) => e.month == calendarController.selectedDate!.month)
          .last;
      setState(() {
        uiDay = DateFormat.EEEE('tr').format(DateTime.now());
        uidMonth = DateFormat.MMMM('tr').format(DateTime.now());
        PageHelper.days;
        PageHelper.years;
        PageHelper.months;
      });
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<Notifications>(context, listen: false)
          .getPendingNotificationCount();
      setState(() {});
    });
    super.initState();
    firebaseDatePicker = widget.databaseDate;
    widget.day = DateFormat.d('tr').format(firebaseDatePicker);
    widget.month = DateFormat.MMMM('tr').format(firebaseDatePicker);
    widget.dayName = DateFormat.EEEE('tr').format(firebaseDatePicker);
  }

  @override
  Widget build(BuildContext context) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final notification = Provider.of<Notifications>(context, listen: false);
    return Container(
      height: MediaQuery.of(context).size.height - 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
                          offset:
                              const Offset(0, 3), // changes position of shadow
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
                  debugPrint(widget.data[widget.index].id.toString());
                  widget.updateData(
                    widget.data[widget.index].id,
                    widget.data[widget.index].date,
                    widget.data[widget.index].fullTime,
                    widget.data[widget.index].taskDate,
                  );
                  notification.init();
                  flutterLocalNotificationsPlugin
                      .cancel(widget.data[widget.index].id!);
                  notification.scheduleWeeklyNotification(
                    widget.data[widget.index].id!,
                    widget.detailController.text,
                    PageHelper.years,
                    PageHelper.months,
                    PageHelper.days,
                    int.parse(widget.hourController.text),
                    int.parse(widget.minuteController.text),
                  );
                },
                child: const Text("Kaydet"),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: TextFormField(
              controller: widget.detailController,
              enableInteractiveSelection: false,
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
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
                /* border: OutlineInputBorder(), */
              ),
              maxLength: 300,
              maxLines: 2,
            ),
          ),
          Center(
              child: Text("${widget.day} ${widget.month} ${widget.dayName}",
                  style:
                      const TextStyle(fontFamily: 'DonegalOne', fontSize: 18))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 25,
                child: TextFormField(
                  textAlign: TextAlign.right,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.number,
                  controller: widget.hourController,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Text(
                ":",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 50,
                height: 25,
                child: TextFormField(
                  textAlign: TextAlign.left,
                  enableInteractiveSelection: false,
                  controller: widget.minuteController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sfCalendar(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

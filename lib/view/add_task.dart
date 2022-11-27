// ignore_for_file: unused_local_variable, prefer_interpolation_to_compose_strings, prefer_is_empty
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:todo/constants/consts.dart';
import 'package:todo/exception/app_exception.dart';
import 'package:todo/helper/page_helper.dart';
import 'package:todo/model/tasks.dart';
import 'package:todo/notification/local_notification.dart';
import 'package:todo/view_model/login_viewmodel.dart';
import 'package:todo/view_model/sf_calendar.dart';
import 'package:todo/view_model/task_crud_viewmodel.dart';

class AddTask extends StatefulWidget with PageHelper {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController taskText = TextEditingController();
  CalendarController controller = CalendarController();
  DateTime cupertinoInitialDateTime = DateTime.now();
  String uidMonth = "";
  String uiDay = "";

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
    return Scaffold(
      body: bodyWidget(),
      backgroundColor: Colors.grey.shade300,
    );
  }

  Widget bodyWidget() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    textFormField(),
                    PageHelper.paddingHelper(),
                    dateTimeWidget(),
                    PageHelper.paddingHelper(),
                    sfCalendar(),
                    cupertinoDataPicker(),
                  ],
                ),
              ),
            ),
          ),
          buttons(),
        ],
      ),
    );
  }

  Widget sfCalendar() {
    final taskviewModel = Provider.of<TaskViewModel>(context, listen: false);
    final userUid = Provider.of<LoginViewModel>(context, listen: false).userUid;
    List<Meeting> collection = <Meeting>[];
    int indeks = 0;
    Random random = Random();
    final getCalendarData = Provider.of<Meeting>(context, listen: false)
        .getCalendarDataSource(collection);

    return StreamBuilder<List<Task>>(
      stream: taskviewModel.getAllTask(userUid),
      builder: (context, firebaseGetData) {
        if (firebaseGetData.hasData) {
          final dataReceived = firebaseGetData.data!;

          for (int i = 0; i < dataReceived.length; i++) {
            indeks = random.nextInt(dataReceived.length);
            DateTime tempDate =
                DateFormat("yyyy-MM-dd").parse(dataReceived[i].taskDate!);
            collection.add(Meeting(
                eventName: dataReceived[i].taskName,
                from: tempDate,
                to: tempDate,
                isAllDay: true,
                background: PageHelper.colors[indeks]));
          }
          return Column(
            children: [
              Visibility(
                visible: dateVisible,
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 1.3,
                  child: SfCalendar(
                    dataSource: getCalendarData,
                    viewHeaderHeight: 30,
                    headerStyle:
                        CalendarHeaderStyle(textStyle: PageHelper.textStyle()),
                    controller: controller,
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
                visible: dateVisible,
                child: PageHelper.paddingHelper(),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Visibility(
                visible: dateVisible,
                child: SfCalendar(
                  viewHeaderHeight: 30,
                  headerStyle:
                      CalendarHeaderStyle(textStyle: PageHelper.textStyle()),
                  controller: controller,
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
                visible: dateVisible,
                child: PageHelper.paddingHelper(),
              ),
            ],
          );
        }
      },
    );
  }

  Widget cupertinoDataPicker() {
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
          Visibility(
            visible: timeVisible,
            child: PageHelper.paddingHelper(),
          ),
        ],
      ),
    );
  }

  Widget dateTimeWidget() {
    return Container(
      color: Colors.white,
      child: Column(
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
              date(),
            ],
          ),
          time(),
        ],
      ),
    );
  }

  Widget date() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (() {
            setState(() {
              dateVisible = true;
              timeVisible = false;
              select = 1;
              color1 = Colors.grey.shade300;
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
                      uidMonth,
                      style: const TextStyle(
                          fontSize: 18, fontFamily: "DonegalOne"),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        uiDay,
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

  Widget time() {
    return GestureDetector(
      onTap: (() {
        setState(() {
          timeVisible = true;
          dateVisible = false;
          select = 2;
          color2 = Colors.grey.shade300;
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

  Widget textFormField() {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      style: PageHelper.textStyle(),
      minLines: 1, //Normal textInputField will be displayed
      maxLines: 5,
      maxLength: 250,
      controller: taskText,
      decoration: const InputDecoration(
        counterText: "",
        hintText: "Başlık",
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
    );
  }

  Widget buttons() {
    final notification = Provider.of<Notifications>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: ElevatedButton(
            style: ButtonStyle(
                maximumSize:
                    MaterialStateProperty.all<Size>(const Size(150, 150)),
                elevation: MaterialStateProperty.all<double>(0),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade300),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)))),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "İptal",
              style: TextStyle(
                  color: Colors.black, fontSize: 20, fontFamily: "DonegalOne"),
            ),
          ),
        ),
        const SizedBox(
          width: 30,
        ),
        SizedBox(
          width: 120,
          child: ElevatedButton(
            style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(0),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade300),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)))),
            onPressed: () {
              setData();
              notification.init();
              notification.scheduleWeeklyNotification(
                  notification.notificationList.length == 0
                      ? 0
                      : notification.notificationList.last.id + 1,
                  taskText.text,
                  hour,
                  minute);
            },
            child: const Text(
              "Kaydet",
              style: TextStyle(
                  color: Colors.black, fontSize: 20, fontFamily: "DonegalOne"),
            ),
          ),
        ),
      ],
    );
  }

  void onTapChanged(CalendarTapDetails details) {
    setState(() {
      dynamic appointment = details.appointments;
      dayNum = details.date!.day;
      month = details.date!.month;
      year = details.date!.year;
      fullDateTime = details.date!;
      debugPrint(fullDateTime.toString());
      uidMonth = DateFormat.MMMM('tr').format(details.date!);
      uiDay = DateFormat.EEEE('tr').format(details.date!);
      CalendarElement element = details.targetElement;
    });
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    List<DateTime> dates = viewChangedDetails.visibleDates;
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      controller.selectedDate =
          viewChangedDetails.visibleDates.where((e) => e.day == 1).first;
      viewChangedDetails.visibleDates
          .where((e) => e.month == controller.selectedDate!.month)
          .last;

      setState(() {
        uiDay = DateFormat.EEEE('tr').format(DateTime.now());
        uidMonth = DateFormat.MMMM('tr').format(DateTime.now());
      });
    });
  }

  Future setData() async {
    final notification = Provider.of<Notifications>(context, listen: false);
    final userUid = Provider.of<LoginViewModel>(context, listen: false).userUid;

    try {
      if (taskText.text.trim().isNotEmpty) {
        Task saveTask = Task(
          id: notification.notificationList.isEmpty
              ? 0
              : notification.notificationList.last.id + 1,
          date: DateTime.now().toString(),
          fullTime: DateTime.now(),
          taskDate: fullDateTime.toString(),
          taskName: taskText.text,
        );
        await Provider.of<TaskViewModel>(context, listen: false)
            .addTask(saveTask, userUid!);
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/exception/app_exception.dart';
import 'package:todo/helper/page_helper.dart';
import 'package:todo/view/home_page.dart';
import 'package:todo/view_model/create_viewmodel.dart';
import 'package:todo/view_model/login_viewmodel.dart';

enum AUTHOPTIONS {
  emailLogin,
  emailcreate,
}

class AuthPage extends StatefulWidget with PageHelper {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController mailText = TextEditingController();
  TextEditingController passText = TextEditingController();

  List<FocusNode> focusNodes = [
    FocusNode(),
    FocusNode(),
  ];
  var state = AUTHOPTIONS.emailLogin;
  @override
  void initState() {
    for (var node in focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: state == AUTHOPTIONS.emailLogin ? loginWidget() : createWidget(),
      backgroundColor: Colors.white,
    );
  }

  Widget createWidget() {
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Container(
              width: 200,
              height: 100,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(image: AssetImage('assets/todo.png'))),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Container(
              width: width / 1.3,
              decoration: const BoxDecoration(color: Colors.white),
              child: TextFormField(
                focusNode: focusNodes[0],
                style: PageHelper.textStyle(),
                controller: mailText,
                decoration: InputDecoration(
                  hintText: "E-mail",
                  hintStyle: PageHelper.textStyle(),
                  prefixIcon: Icon(Icons.mail,
                      color: focusNodes[0].hasFocus
                          ? Colors.deepOrangeAccent
                          : Colors.deepOrangeAccent.shade100),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrangeAccent),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrangeAccent),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Container(
              width: width / 1.3,
              decoration: const BoxDecoration(color: Colors.white),
              child: TextFormField(
                focusNode: focusNodes[1],
                controller: passText,
                style: PageHelper.textStyle(),
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.key,
                      color: focusNodes[1].hasFocus
                          ? Colors.deepOrangeAccent
                          : Colors.deepOrangeAccent.shade100),
                  hintText: "Şifre",
                  hintStyle: PageHelper.textStyle(),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrangeAccent),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrangeAccent),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    state = AUTHOPTIONS.emailLogin;
                  });
                },
                child: Text(
                  "Zaten Üyeyim/Giriş Yap",
                  style: PageHelper.textStyle(),
                ),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                create();
              },
              style: ElevatedButton.styleFrom(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  backgroundColor: Colors.deepOrangeAccent,
                  minimumSize: const Size(150, 40)),
              child: Text(
                "Kaydol",
                style: PageHelper.textStyle(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future create() async {
    try {
      await Provider.of<CreateViewModel>(context, listen: false).create(
        mailText.text,
        passText.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
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

  Widget loginWidget() {
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Container(
              width: 200,
              height: 100,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(image: AssetImage('assets/todo.png'))),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Container(
              width: width / 1.3,
              decoration: const BoxDecoration(color: Colors.white),
              child: TextFormField(
                focusNode: focusNodes[0],
                cursorColor: Colors.deepOrangeAccent,
                controller: mailText,
                style: PageHelper.textStyle(),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.mail,
                      color: focusNodes[0].hasFocus
                          ? Colors.deepOrangeAccent
                          : Colors.deepOrangeAccent.shade100),
                  hintText: "E-mail",
                  hintStyle: PageHelper.textStyle(),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrangeAccent),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrangeAccent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Container(
              width: width / 1.3,
              decoration: const BoxDecoration(color: Colors.white),
              child: TextFormField(
                focusNode: focusNodes[1],
                controller: passText,
                style: PageHelper.textStyle(),
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.key,
                      color: focusNodes[1].hasFocus
                          ? Colors.deepOrangeAccent
                          : Colors.deepOrangeAccent.shade100),
                  hintText: "Şifre",
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrangeAccent),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrangeAccent),
                  ),
                  hintStyle: PageHelper.textStyle(),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    state = AUTHOPTIONS.emailcreate;
                  });
                },
                child: Text(
                  "Üye değilim/Kayıt Ol",
                  style: PageHelper.textStyle(),
                ),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                login();
              },
              style: ElevatedButton.styleFrom(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  backgroundColor: Colors.deepOrangeAccent,
                  minimumSize: const Size(150, 40)),
              child: Text(
                "Giriş",
                style: PageHelper.textStyle(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future login() async {
    debugPrint("1");
    try {
      debugPrint("2");
      await Provider.of<LoginViewModel>(context, listen: false).loginClassic(
        mailText.text,
        passText.text,
      );
      debugPrint("3");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }

      debugPrint("4");
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

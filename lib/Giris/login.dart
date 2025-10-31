import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gez_gor_saticii/Giris/telefondogrulama.dart';

class LoginSayfasi extends StatefulWidget {
  const LoginSayfasi({super.key});

  @override
  LoginSayfasiState createState() => LoginSayfasiState();
}

class LoginSayfasiState extends State<LoginSayfasi> {
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String defaultFontFamily = 'Roboto-Light.ttf';
    double defaultFontSize = 14;
    double defaultIconSize = 17;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 35, bottom: 30),
        width: double.infinity,
        height: double.infinity,
        color: Colors.white70,
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 230,
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      "Gez Gör",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: 150,
                    height: 20,
                    alignment: Alignment.center,
                    child: const Text(
                      "Satıcı Paneli",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextField(
                    controller: _phoneController,
                    showCursor: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.phone,
                        color: const Color(0xFF666666),
                        size: defaultIconSize,
                      ),
                      fillColor: const Color(0xFFF2F3F5),
                      hintStyle: TextStyle(
                          color: const Color(0xFF666666), fontFamily: defaultFontFamily, fontSize: defaultFontSize),
                      hintText: "Telefon Numarası",
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Şifremi Unuttum",
                      style: TextStyle(
                        color: const Color(0xFF666666),
                        fontFamily: defaultFontFamily,
                        fontSize: defaultFontSize,
                        fontStyle: FontStyle.normal,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  const SizedBox(height: 15),
                  /* SignInButtonWidget(
                    onPressed: () async {
                      try {
                        final phone = _phoneController.text;

                        // Telefon numarasıyla giriş yap
                        final confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(phone);

                        // Giriş başarılıysa, telefon doğrulama ekranına yönlendir
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhoneVerificationPage(confirmationResult),
                          ),
                        );
                      } catch (e) {
                        // Hata mesajı gösterin
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Giriş yapılırken bir hata oluştu.'),
                          ),
                        );
                        print("$e");
                      }
                    },
                  ), */
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*class SignInButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const SignInButtonWidget({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.grey,
            ),
            BoxShadow(
              color: Colors.grey,
            ),
          ],
          gradient: LinearGradient(
              colors: [Colors.black, Colors.grey.shade500],
              begin: const FractionalOffset(0.2, 0.2),
              end: const FractionalOffset(1.0, 1.0),
              stops: const [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: MaterialButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.grey,
          onPressed: onPressed,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
            child: Text(
              "Doğrulama Kodu Gönder",
              style: TextStyle(color: Colors.white, fontSize: 20.0, fontFamily: "WorkSansBold"),
            ),
          ),
        ));
  }
} */

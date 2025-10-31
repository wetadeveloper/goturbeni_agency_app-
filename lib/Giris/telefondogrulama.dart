import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneVerificationPage extends StatefulWidget {
  final ConfirmationResult confirmationResult;

  const PhoneVerificationPage(this.confirmationResult, {super.key});

  @override
  PhoneVerificationPageState createState() => PhoneVerificationPageState();
}

class PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _verificationCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telefon Doğrulama'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _verificationCodeController,
              decoration: const InputDecoration(
                labelText: 'Doğrulama Kodu',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String verificationCode = _verificationCodeController.text.trim();

                // Doğrulama kodunu kullanarak telefonu doğrula
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: widget.confirmationResult.verificationId,
                  smsCode: verificationCode,
                );
                final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

                if (userCredential.user != null) {
                  // Giriş başarılı, kullanıcıyı ana sayfaya yönlendir
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(),   ),);
                } else {
                  // Kullanıcı yoksa, hata mesajı göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kullanıcı bulunamadı.'),
                    ),
                  );
                }
              },
              child: const Text('Doğrula'),
            ),
          ],
        ),
      ),
    );
  }
}

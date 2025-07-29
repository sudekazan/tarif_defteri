import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase kimlik doğrulama paketini içe aktarın

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance; // Firebase Auth örneğini alıyoruz
  final _formKey = GlobalKey<FormState>(); // Formu yönetmek için anahtar
  String _email = '';
  String _password = '';
  bool _isLogin = true; // Giriş mi kayıt mı ekranı olduğunu tutar
  String? _errorMessage; // Hata mesajlarını göstermek için

  void _submitAuthForm() async {
    final isValid = _formKey.currentState?.validate();
    FocusScope.of(context).unfocus(); // Klavyeyi kapat

    if (isValid == null || !isValid) {
      return;
    }
    _formKey.currentState?.save(); // Form alanlarını kaydet

    setState(() {
      _errorMessage = null; // Yeni denemeden önce hata mesajını temizle
    });

    try {
      if (_isLogin) {
        // Giriş yap
        await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        // Başarılı girişten sonra bir sonraki ekrana yönlendirme yapılabilir.
        // Örneğin: Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => HomeScreen()));
        print('Giriş başarılı: ${_auth.currentUser?.email}');
      } else {
        // Kayıt ol
        await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        // Başarılı kayıttan sonra bir sonraki ekrana yönlendirme yapılabilir.
        print('Kayıt başarılı: ${_auth.currentUser?.email}');
      }
    } on FirebaseAuthException catch (e) {
      // Firebase'den gelen hataları yakala
      String message = 'Bir hata oluştu, lütfen tekrar deneyin.';
      if (e.code == 'weak-password') {
        message = 'Parola çok zayıf.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Bu e-posta adresi zaten kullanılıyor.';
      } else if (e.code == 'user-not-found') {
        message = 'Bu e-posta adresine sahip bir kullanıcı bulunamadı.';
      } else if (e.code == 'wrong-password') {
        message = 'Yanlış parola.';
      }
      setState(() {
        _errorMessage = message;
      });
      print(e.message); // Hatanın tam mesajını görmek için
    } catch (e) {
      // Diğer genel hataları yakala
      setState(() {
        _errorMessage = 'Bilinmeyen bir hata oluştu.';
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: const ValueKey('email'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-posta Adresi'),
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Lütfen geçerli bir e-posta adresi girin.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),
                  TextFormField(
                    key: const ValueKey('password'),
                    obscureText: true, // Şifreyi gizler
                    decoration: const InputDecoration(labelText: 'Şifre'),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Şifre en az 6 karakter olmalıdır.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_errorMessage != null) // Hata mesajını göster
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _submitAuthForm,
                    child: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin; // Giriş ve kayıt ekranını değiştir
                        _errorMessage = null; // Ekran değişince hata mesajını temizle
                      });
                    },
                    child: Text(_isLogin ? 'Yeni Hesap Oluştur' : 'Zaten hesabım var'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
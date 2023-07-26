/*import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        return googleUser.email;
      }
    } catch (error) {
      print('Google sign-in error: $error');
    }
    return null;
  }
}*/

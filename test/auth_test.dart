import 'dart:math';

import 'package:learningdart/services/auth/auth_exceptions.dart';
import 'package:learningdart/services/auth/auth_provider.dart';
import 'package:learningdart/services/auth/auth_user.dart';
import 'package:test/test.dart';


void  main() {
  group('Mock Authetication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', (){
      expect(provider.isInitialized, false);
    });
    test('Cannot log out if not initialized', (){
      expect(provider.logOut(), throwsA(const TypeMatcher<NotInitializedException>()));
    });
    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider._isInitialized, true);
    });
    test('User should be null after initialization', (){
      expect(provider.currentUser, null);
    });
    test('Should be able to initialized in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider._isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));
    test('Create user should delegate to logIn function', () async {
      final badEmailUser = provider.createUser(email: "teste@gmail.com", password: "opsssss");
      expect(badEmailUser, throwsA(const TypeMatcher<UserNotFoundAuthException>()));
      final badPassUser = provider.createUser(email: "testes@gmail.com", password: "teste");
      expect(badPassUser, throwsA(const TypeMatcher<WrongPasswordAuthException>()));
      final user = await provider.createUser(email: 'testes@gmail.com', password: "testes");
      expect(provider.currentUser, user);
      expect(user?.isEmailVerified, false);
    });

    test("Logged in user should be able to get verified", (){
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('should be able to log out and log in again', () async {
      await provider.logOut();
      await provider.logIn(email: 'victorvirgolino@gmail.com', password: 'vaporubi');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider{
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  AuthUser? _user;

  @override
  Future<AuthUser?> createUser({required String email, required String password}) async {
    if(!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized =  true;
  }

  @override
  Future<AuthUser?> logIn({required String email, required String password}) {
    if(!isInitialized) throw NotInitializedException();
    if(email == 'teste@gmail.com') throw UserNotFoundAuthException();
    if(password == 'teste') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false, email: 'teste@gmail.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if(!isInitialized) throw NotInitializedException();
    if(_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
    }

  @override
  Future<void> sendEmailVerification() async{
    if(!isInitialized) throw NotInitializedException();
    final user = _user;
    if(_user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: 'teste@gmail.com');
    _user = newUser;
  }

}
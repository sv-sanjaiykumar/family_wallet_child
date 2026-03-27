import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Keys ──────────────────────────────────────────────────────
const _kUsername      = 'child_username';
const _kPasswordHash  = 'child_password_hash';
const _kSessionActive = 'child_session_active';
const _kRememberMe    = 'child_remember_me';

/// Singleton authentication service for the Child Module.
///
/// The parent creates / updates the child's credentials from the
/// Parent Module.  The child can only log in — never register.
///
/// Passwords are stored as SHA-256 hashes; the plaintext is never
/// saved to disk.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // ── Helpers ───────────────────────────────────────────────

  /// SHA-256 hash of [plain] text.
  String _hash(String plain) {
    final bytes = utf8.encode(plain);
    return sha256.convert(bytes).toString();
  }

  // ── Parent actions ────────────────────────────────────────

  /// Called by the parent to create / update the child's credentials.
  /// Stores the hashed password — never the plaintext.
  Future<void> setChildCredentials({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsername, username.trim().toLowerCase());
    await prefs.setString(_kPasswordHash, _hash(password));
  }

  /// Returns `true` if the parent has already set credentials.
  Future<bool> hasCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kUsername) && prefs.containsKey(_kPasswordHash);
  }

  Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUsername);
  }

  // ── Child login / logout ──────────────────────────────────

  /// Validates the [username] and [password] against stored credentials.
  /// Returns `true` on success.  Starts a session on success.
  Future<bool> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString(_kUsername);
    final storedHash = prefs.getString(_kPasswordHash);

    if (storedUser == null || storedHash == null) return false;

    final inputHash = _hash(password);
    final match = storedUser == username.trim().toLowerCase() &&
        storedHash == inputHash;

    if (match) {
      await prefs.setBool(_kSessionActive, true);
      await prefs.setBool(_kRememberMe, rememberMe);
    }
    return match;
  }

  /// End the child's session.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSessionActive, false);
    // Clear remember-me flag too
    await prefs.setBool(_kRememberMe, false);
  }

  /// Returns `true` if a valid session exists (e.g. "Remember Me" was used).
  Future<bool> isSessionActive() async {
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getBool(_kSessionActive) ?? false;
    final remember = prefs.getBool(_kRememberMe) ?? false;
    return active && remember;
  }

  /// Clear all stored credentials (e.g. parent resets child account).
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUsername);
    await prefs.remove(_kPasswordHash);
    await prefs.remove(_kSessionActive);
    await prefs.remove(_kRememberMe);
  }
}

import React, { useState } from 'react';
import {
  View, Text, StyleSheet, TouchableOpacity, Image, ActivityIndicator,
  Alert, SafeAreaView, ScrollView, TextInput, KeyboardAvoidingView, Platform,
} from 'react-native';
import { router } from 'expo-router';
import Constants from 'expo-constants';
import * as AuthSession from 'expo-auth-session';
import * as GoogleAuth from 'expo-auth-session/providers/google';
import * as WebBrowser from 'expo-web-browser';
import { useAuthStore } from '../src/stores/authStore';
import { COLORS, SPACING, FONTS } from '../src/constants/theme';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import api from '../src/config/api';
import storage from '../src/utils/storage';

const WEB_CLIENT_ID = '125166695153-frfr2u1qgvjlh00buou5hb5kcc8e2gfd.apps.googleusercontent.com';
WebBrowser.maybeCompleteAuthSession();

export default function LoginScreen() {
  const [loading, setLoading] = useState(false);
  const [googleLoading, setGoogleLoading] = useState(false);
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [gender, setGender] = useState('Male');
  const [showPassword, setShowPassword] = useState(false);
  const { signInWithEmail, signUpWithEmail } = useAuthStore();
  const expoRedirectUri = React.useMemo(
    () =>
      Constants.appOwnership === 'expo'
        ? AuthSession.makeRedirectUri({ scheme: 'vivahsetu' })
        : undefined,
    []
  );
  const [expoGoogleRequest, expoGoogleResponse, expoPromptAsync] = GoogleAuth.useIdTokenAuthRequest(
    Constants.appOwnership === 'expo'
      ? {
          clientId: WEB_CLIENT_ID,
          redirectUri: expoRedirectUri,
          scopes: ['openid', 'profile', 'email'],
          selectAccount: true,
        }
      : {},
  );

  const completeGoogleLogin = React.useCallback(async (payload: { idToken?: string; email?: string; name?: string; photoUrl?: string }) => {
    const res = await api.post('/auth/google-login', payload);
    const { token, user } = res.data;

    await storage.setItem('auth_token', token);
    await storage.setItem('user_data', JSON.stringify(user));

    if (!user.gender || user.gender === '') {
      useAuthStore.setState({ user, token, isAuthenticated: true, isLoading: false });
      router.replace('/google-complete');
    } else {
      useAuthStore.setState({ user, token, isAuthenticated: true, isLoading: false });
      router.replace('/(tabs)/home');
    }
  }, []);

  React.useEffect(() => {
    const handleExpoGoogleResponse = async () => {
      if (Constants.appOwnership !== 'expo' || !expoGoogleResponse) {
        return;
      }

      if (expoGoogleResponse.type === 'dismiss' || expoGoogleResponse.type === 'cancel') {
        setGoogleLoading(false);
        return;
      }

      if (expoGoogleResponse.type !== 'success') {
        setGoogleLoading(false);
        Alert.alert('Google Sign-In', 'Google sign-in failed. Please try again.');
        return;
      }

      try {
        const idToken = expoGoogleResponse.params?.id_token || expoGoogleResponse.authentication?.idToken;
        const accessToken = expoGoogleResponse.params?.access_token || expoGoogleResponse.authentication?.accessToken;

        if (idToken) {
          await completeGoogleLogin({ idToken });
          return;
        }

        if (!accessToken) {
          throw new Error('Google access token not available.');
        }

        const userInfoResponse = await fetch('https://openidconnect.googleapis.com/v1/userinfo', {
          headers: { Authorization: `Bearer ${accessToken}` },
        });
        const userInfo = await userInfoResponse.json();

        if (!userInfo?.email) {
          throw new Error('Google user info not available.');
        }

        await completeGoogleLogin({
          email: userInfo.email,
          name: userInfo.name || '',
          photoUrl: userInfo.picture || '',
        });
      } catch (error: any) {
        console.error('Expo Google sign-in failed', error);
        Alert.alert('Google Sign-In', error?.response?.data?.detail || error?.message || 'Google sign-in failed. Please try again.');
      } finally {
        setGoogleLoading(false);
      }
    };

    handleExpoGoogleResponse();
  }, [completeGoogleLogin, expoGoogleResponse]);

  React.useEffect(() => {
    if (Constants.appOwnership === 'expo') {
      return;
    }

    try {
      const { GoogleSignin } = require('@react-native-google-signin/google-signin');
      GoogleSignin.configure({
        webClientId: WEB_CLIENT_ID,
        offlineAccess: false,
      });
    } catch (error) {
      console.error('Google Sign-In native module unavailable', error);
    }
  }, []);

  const handleGoogleSignIn = async () => {
    const nativeStatusCodes =
      Constants.appOwnership === 'expo'
        ? {}
        : require('@react-native-google-signin/google-signin').statusCodes;
    try {
      setGoogleLoading(true);
      if (Constants.appOwnership === 'expo') {
        if (!expoGoogleRequest) {
          Alert.alert('Google Sign-In', 'Google sign-in is still initializing. Please try again in a moment.');
          return;
        }
        const result = await expoPromptAsync();
        if (result.type === 'dismiss' || result.type === 'cancel') {
          setGoogleLoading(false);
        }
        return;
      }

      const { GoogleSignin } = require('@react-native-google-signin/google-signin');
      await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
      const signInResult = await GoogleSignin.signIn();

      if (signInResult.type !== 'success') {
        Alert.alert('Google Sign-In', 'Google sign-in was cancelled.');
        return;
      }

      const { user: googleUser, idToken } = signInResult.data;
      if (!idToken) {
        throw new Error('Google ID token not available. Please check the Google web client ID configuration.');
      }

      await completeGoogleLogin({
        idToken,
        email: googleUser.email,
        name: googleUser.name || '',
        photoUrl: googleUser.photo || '',
      });
    } catch (error: any) {
      console.error('Google native sign-in failed', { message: error?.message, code: error?.code, status: error?.response?.status, detail: error?.response?.data?.detail, data: error?.response?.data });
      if (error?.code === nativeStatusCodes.SIGN_IN_CANCELLED) {
        Alert.alert('Google Sign-In', 'Google sign-in was cancelled.');
      } else if (error?.code === nativeStatusCodes.PLAY_SERVICES_NOT_AVAILABLE) {
        Alert.alert('Google Sign-In', 'Google Play Services is not available or needs to be updated on this device.');
      } else if (error?.code === nativeStatusCodes.IN_PROGRESS) {
        Alert.alert('Google Sign-In', 'Google sign-in is already in progress.');
      } else {
        Alert.alert('Error', error?.response?.data?.detail || error?.message || 'Google sign-in failed. Please try again.');
      }
    } finally {
      setGoogleLoading(false);
    }
  };

  const handleEmailAuth = async () => {
    if (!email.trim()) { Alert.alert('Error', 'Please enter your email'); return; }
    if (password.length < 6) { Alert.alert('Error', 'Password must be at least 6 characters'); return; }
    if (isSignUp && !name.trim()) { Alert.alert('Error', 'Please enter your name'); return; }
    try {
      setLoading(true);
      if (isSignUp) { await signUpWithEmail(email, password, name, gender); }
      else { await signInWithEmail(email, password); }
      router.replace('/(tabs)/home');
    } catch (error: any) {
      console.error('Email auth failed', { message: error?.message, status: error?.response?.status, detail: error?.response?.data?.detail, data: error?.response?.data });
      const detail = error?.response?.data?.detail || error?.message || 'Authentication failed';
      Alert.alert('Sign-In Issue', detail);
    } finally { setLoading(false); }
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar style="dark" />
      <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={{ flex: 1 }}>
        <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false} keyboardShouldPersistTaps="handled">
          <View style={styles.logoContainer}>
            <Image source={require('../assets/images/logo.png')} style={styles.logo} resizeMode="contain" />
          </View>
          <Text style={styles.title}>{isSignUp ? 'Create Account' : 'Welcome Back'}</Text>
          <Text style={styles.subtitle}>{isSignUp ? 'Join VivahSetu to find your match' : 'Sign in to continue'}</Text>

          <TouchableOpacity
            testID="google-signin-btn"
            style={[styles.googleButton, googleLoading && styles.buttonDisabled]}
            onPress={handleGoogleSignIn}
            disabled={googleLoading}
            activeOpacity={0.8}
          >
            {googleLoading ? (
              <ActivityIndicator color="#333" />
            ) : (
              <>
                <View style={styles.googleIconWrap}>
                  <Text style={styles.googleG}>G</Text>
                </View>
                <Text style={styles.googleButtonText}>Continue with Google</Text>
              </>
            )}
          </TouchableOpacity>

          <View style={styles.divider}>
            <View style={styles.dividerLine} />
            <Text style={styles.dividerText}>OR</Text>
            <View style={styles.dividerLine} />
          </View>

          <View style={styles.form}>
            {isSignUp && (
              <>
                <View style={styles.inputContainer}>
                  <Ionicons name="person-outline" size={20} color={COLORS.textSecondary} style={styles.inputIcon} />
                  <TextInput testID="signup-name-input" style={styles.input} placeholder="Full Name" value={name} onChangeText={setName} placeholderTextColor={COLORS.textSecondary} />
                </View>
                <View style={styles.genderContainer}>
                  <Text style={styles.genderLabel}>Gender:</Text>
                  {['Male', 'Female'].map((g) => (
                    <TouchableOpacity key={g} testID={`gender-${g.toLowerCase()}-btn`} style={[styles.genderBtn, gender === g && styles.genderBtnActive]} onPress={() => setGender(g)}>
                      <Text style={[styles.genderBtnText, gender === g && styles.genderBtnTextActive]}>{g}</Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </>
            )}
            <View style={styles.inputContainer}>
              <Ionicons name="mail-outline" size={20} color={COLORS.textSecondary} style={styles.inputIcon} />
              <TextInput testID="email-input" style={styles.input} placeholder="Email Address" value={email} onChangeText={setEmail} keyboardType="email-address" autoCapitalize="none" placeholderTextColor={COLORS.textSecondary} />
            </View>
            <View style={styles.inputContainer}>
              <Ionicons name="lock-closed-outline" size={20} color={COLORS.textSecondary} style={styles.inputIcon} />
              <TextInput testID="password-input" style={[styles.input, { flex: 1 }]} placeholder="Password" value={password} onChangeText={setPassword} secureTextEntry={!showPassword} placeholderTextColor={COLORS.textSecondary} />
              <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
                <Ionicons name={showPassword ? 'eye-off-outline' : 'eye-outline'} size={20} color={COLORS.textSecondary} />
              </TouchableOpacity>
            </View>
            <TouchableOpacity testID="auth-submit-btn" style={[styles.submitButton, loading && styles.buttonDisabled]} onPress={handleEmailAuth} disabled={loading} activeOpacity={0.8}>
              {loading ? <ActivityIndicator color="#fff" /> : <Text style={styles.submitButtonText}>{isSignUp ? 'Create Account' : 'Sign In'}</Text>}
            </TouchableOpacity>
            <TouchableOpacity testID="toggle-auth-mode-btn" style={styles.toggleButton} onPress={() => setIsSignUp(!isSignUp)}>
              <Text style={styles.toggleText}>{isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Create one"}</Text>
            </TouchableOpacity>
            <Text style={styles.helperText}>
              If this email was first created with Google, tap Create Account with the same email once to add password sign-in too.
            </Text>
          </View>

          <View style={styles.featuresRow}>
            {[
              { icon: 'checkmark-circle', text: 'Verified Profiles' },
              { icon: 'heart', text: 'Serious Matchmaking' },
              { icon: 'time', text: '15-Day Timer' },
              { icon: 'people', text: 'Max 5 Connections' },
            ].map((f, i) => (
              <View key={i} style={styles.featureItem}>
                <Ionicons name={f.icon as any} size={16} color={COLORS.primary} />
                <Text style={styles.featureText}>{f.text}</Text>
              </View>
            ))}
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: COLORS.background },
  scrollContent: { flexGrow: 1, paddingHorizontal: SPACING.xl, paddingTop: SPACING.lg, paddingBottom: SPACING.xxl },
  logoContainer: { alignItems: 'center', marginBottom: SPACING.md },
  logo: { width: 140, height: 140 },
  title: { fontSize: FONTS.sizes.title, fontWeight: '700', color: COLORS.text, textAlign: 'center' },
  subtitle: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, textAlign: 'center', marginTop: SPACING.xs, marginBottom: SPACING.lg },
  googleButton: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', backgroundColor: '#fff', borderWidth: 1, borderColor: COLORS.border, paddingVertical: 14, borderRadius: 12, marginBottom: SPACING.md },
  googleIconWrap: { width: 28, height: 28, backgroundColor: '#4285F4', borderRadius: 14, alignItems: 'center', justifyContent: 'center', marginRight: SPACING.sm },
  googleG: { fontSize: 16, fontWeight: '700', color: '#fff' },
  googleButtonText: { fontSize: FONTS.sizes.large, fontWeight: '600', color: COLORS.text },
  buttonDisabled: { opacity: 0.5 },
  divider: { flexDirection: 'row', alignItems: 'center', marginVertical: SPACING.md },
  dividerLine: { flex: 1, height: 1, backgroundColor: COLORS.border },
  dividerText: { marginHorizontal: SPACING.md, fontSize: FONTS.sizes.small, color: COLORS.textSecondary, fontWeight: '600' },
  form: {},
  inputContainer: { flexDirection: 'row', alignItems: 'center', backgroundColor: COLORS.surface, borderRadius: 12, paddingHorizontal: SPACING.md, marginBottom: SPACING.md, borderWidth: 1, borderColor: COLORS.border, height: 52 },
  inputIcon: { marginRight: SPACING.sm },
  input: { flex: 1, fontSize: FONTS.sizes.medium, color: COLORS.text, height: '100%' },
  genderContainer: { flexDirection: 'row', alignItems: 'center', marginBottom: SPACING.md, gap: SPACING.sm },
  genderLabel: { fontSize: FONTS.sizes.medium, color: COLORS.text, fontWeight: '600' },
  genderBtn: { paddingHorizontal: SPACING.lg, paddingVertical: SPACING.sm, borderRadius: 20, borderWidth: 1, borderColor: COLORS.border },
  genderBtnActive: { backgroundColor: COLORS.primary, borderColor: COLORS.primary },
  genderBtnText: { fontSize: FONTS.sizes.medium, color: COLORS.text },
  genderBtnTextActive: { color: '#fff' },
  submitButton: { backgroundColor: COLORS.primary, paddingVertical: SPACING.md, borderRadius: 12, alignItems: 'center', height: 52, justifyContent: 'center' },
  submitButtonText: { fontSize: FONTS.sizes.large, fontWeight: '600', color: '#fff' },
  toggleButton: { alignItems: 'center', marginTop: SPACING.md },
  toggleText: { fontSize: FONTS.sizes.medium, color: COLORS.primary, fontWeight: '600' },
  helperText: { marginTop: SPACING.md, fontSize: FONTS.sizes.small, color: COLORS.textSecondary, textAlign: 'center', lineHeight: 20 },
  featuresRow: { flexDirection: 'row', flexWrap: 'wrap', gap: SPACING.md, marginTop: SPACING.xl },
  featureItem: { flexDirection: 'row', alignItems: 'center', width: '46%', gap: SPACING.xs },
  featureText: { fontSize: FONTS.sizes.small, color: COLORS.text, fontWeight: '500' },
});



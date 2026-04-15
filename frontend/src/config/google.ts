// Google Sign-In config - web-safe, no native imports at module level
// REMINDER: DO NOT HARDCODE THE URL, OR ADD ANY FALLBACKS OR REDIRECT URLS, THIS BREAKS THE AUTH
import Constants from 'expo-constants';

export const GOOGLE_WEB_CLIENT_ID = Constants.expoConfig?.extra?.googleWebClientId || '125166695153-frfr2u1qgvjlh00buou5hb5kcc8e2gfd.apps.googleusercontent.com';

export const configureGoogleSignIn = () => {
  // Google Sign-In configuration happens on native only
  // Web uses email/password fallback
};

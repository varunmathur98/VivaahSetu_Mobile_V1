import { getApp, getApps, initializeApp } from "firebase/app";

const firebaseConfig = {
  apiKey: "AIzaSyBr_iseE_of57O5rBtk5wp-2HiUQwquuqc",
  authDomain: "flutter-ai-playground-59a42.firebaseapp.com",
  projectId: "flutter-ai-playground-59a42",
  storageBucket: "flutter-ai-playground-59a42.firebasestorage.app",
  messagingSenderId: "125166695153",
  appId: "1:125166695153:web:d85aca72d64a9c6aebef50",
  measurementId: "G-X73YW2EBFX",
};

export const firebaseApp = getApps().length ? getApp() : initializeApp(firebaseConfig);

export async function getFirebaseAnalytics() {
  if (typeof window === "undefined") {
    return null;
  }

  const { getAnalytics, isSupported } = await import("firebase/analytics");
  const supported = await isSupported();

  return supported ? getAnalytics(firebaseApp) : null;
}

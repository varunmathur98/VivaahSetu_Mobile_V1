import { Stack } from 'expo-router';
import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { COLORS } from '../src/constants/theme';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="dark" />
      <Stack
        screenOptions={{
          headerStyle: { backgroundColor: COLORS.background },
          headerTintColor: COLORS.text,
          headerTitleStyle: { fontWeight: '700' },
          headerShadowVisible: false,
          animation: 'slide_from_right',
        }}
      >
        <Stack.Screen name="index" options={{ headerShown: false }} />
        <Stack.Screen name="login" options={{ headerShown: false }} />
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="edit-profile" options={{ title: 'Edit Profile', presentation: 'modal' }} />
        <Stack.Screen name="subscription" options={{ title: 'Subscription Plans' }} />
        <Stack.Screen name="settings" options={{ title: 'Settings' }} />
        <Stack.Screen name="match/[id]" options={{ title: 'Profile', headerShown: false }} />
        <Stack.Screen name="google-complete" options={{ title: 'Complete Profile', headerShown: false }} />
        <Stack.Screen name="chat" options={{ title: 'Chat', headerShown: false }} />
      </Stack>
    </>
  );
}

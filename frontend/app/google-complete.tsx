import React, { useState } from 'react';
import {
  View, Text, StyleSheet, TouchableOpacity, TextInput, Alert, SafeAreaView, Image,
} from 'react-native';
import { router } from 'expo-router';
import { useAuthStore } from '../src/stores/authStore';
import { COLORS, SPACING, FONTS } from '../src/constants/theme';
import { Ionicons } from '@expo/vector-icons';
import api from '../src/config/api';
import storage from '../src/utils/storage';

export default function GoogleCompleteScreen() {
  const { user, updateUser } = useAuthStore();
  const [name, setName] = useState(user?.name || '');
  const [gender, setGender] = useState('');
  const [loading, setLoading] = useState(false);

  const handleComplete = async () => {
    if (!name.trim()) { Alert.alert('Error', 'Please enter your full name'); return; }
    if (!gender) { Alert.alert('Error', 'Please select your gender'); return; }
    try {
      setLoading(true);
      const res = await api.post('/auth/google-complete-profile', { name: name.trim(), gender });
      const updatedUser = res.data.user;
      updateUser({ name: updatedUser.name, gender: updatedUser.gender });
      await storage.setItem('user_data', JSON.stringify({ ...user, name: updatedUser.name, gender: updatedUser.gender }));
      router.replace('/(tabs)/home');
    } catch (error: any) {
      Alert.alert('Error', error.response?.data?.detail || 'Failed to complete profile');
    } finally { setLoading(false); }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Image source={require('../assets/images/logo.png')} style={styles.logo} resizeMode="contain" />
        <Text style={styles.title}>Complete Your Profile</Text>
        <Text style={styles.subtitle}>Please fill in your details to get started</Text>

        <Text style={styles.label}>Full Name</Text>
        <TextInput testID="google-name-input" style={styles.input} value={name} onChangeText={setName} placeholder="Enter your full name" placeholderTextColor={COLORS.textSecondary} />

        <Text style={styles.label}>Gender</Text>
        <View style={styles.genderRow}>
          {['Male', 'Female'].map((g) => (
            <TouchableOpacity key={g} testID={`google-gender-${g.toLowerCase()}`} style={[styles.genderBtn, gender === g && styles.genderBtnActive]} onPress={() => setGender(g)}>
              <Ionicons name={g === 'Male' ? 'male' : 'female'} size={24} color={gender === g ? '#fff' : COLORS.text} />
              <Text style={[styles.genderBtnText, gender === g && styles.genderBtnTextActive]}>{g}</Text>
            </TouchableOpacity>
          ))}
        </View>

        <TouchableOpacity testID="google-complete-btn" style={[styles.submitBtn, loading && { opacity: 0.6 }]} onPress={handleComplete} disabled={loading}>
          <Text style={styles.submitBtnText}>{loading ? 'Saving...' : 'Continue'}</Text>
          <Ionicons name="arrow-forward" size={20} color="#fff" />
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FFF8E7' },
  content: { flex: 1, padding: SPACING.xl, justifyContent: 'center' },
  logo: { width: 120, height: 120, alignSelf: 'center', marginBottom: SPACING.lg },
  title: { fontSize: FONTS.sizes.title, fontWeight: '700', color: '#4A2C0A', textAlign: 'center' },
  subtitle: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, textAlign: 'center', marginTop: SPACING.xs, marginBottom: SPACING.xl },
  label: { fontSize: FONTS.sizes.medium, fontWeight: '600', color: COLORS.text, marginBottom: SPACING.sm },
  input: { backgroundColor: '#fff', borderRadius: 12, padding: SPACING.md, fontSize: FONTS.sizes.large, color: COLORS.text, borderWidth: 1, borderColor: '#E8DCC8', marginBottom: SPACING.lg },
  genderRow: { flexDirection: 'row', gap: SPACING.md, marginBottom: SPACING.xl },
  genderBtn: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: SPACING.sm, backgroundColor: '#fff', paddingVertical: SPACING.lg, borderRadius: 12, borderWidth: 2, borderColor: '#E8DCC8' },
  genderBtnActive: { backgroundColor: '#8B0000', borderColor: '#8B0000' },
  genderBtnText: { fontSize: FONTS.sizes.large, fontWeight: '600', color: COLORS.text },
  genderBtnTextActive: { color: '#fff' },
  submitBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: SPACING.sm, backgroundColor: '#8B0000', paddingVertical: SPACING.md, borderRadius: 12 },
  submitBtnText: { fontSize: FONTS.sizes.large, fontWeight: '700', color: '#fff' },
});

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { COLORS, SPACING, FONTS } from '../src/constants/theme';
import { Ionicons } from '@expo/vector-icons';

export default function SettingsScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.sectionTitle}>Preferences</Text>
      <SettingItem
        icon="notifications"
        label="Notifications"
        onPress={() => Alert.alert('Notifications', 'Configure notification settings')}
      />
      <SettingItem
        icon="lock-closed"
        label="Privacy"
        onPress={() => Alert.alert('Privacy', 'Configure privacy settings')}
      />

      <Text style={styles.sectionTitle}>Account</Text>
      <SettingItem
        icon="person-circle"
        label="Account Settings"
        onPress={() => Alert.alert('Account', 'Manage your account')}
      />
      <SettingItem
        icon="shield-checkmark"
        label="Security"
        onPress={() => Alert.alert('Security', 'Manage security settings')}
      />

      <Text style={styles.sectionTitle}>Support</Text>
      <SettingItem
        icon="help-circle"
        label="Help Center"
        onPress={() => Alert.alert('Help', 'Visit help center')}
      />
      <SettingItem
        icon="document-text"
        label="Terms & Privacy"
        onPress={() => Alert.alert('Terms', 'View terms and privacy policy')}
      />
    </ScrollView>
  );
}

function SettingItem({ icon, label, onPress }: any) {
  return (
    <TouchableOpacity style={styles.settingItem} onPress={onPress} activeOpacity={0.7}>
      <View style={styles.settingLeft}>
        <Ionicons name={icon} size={24} color={COLORS.text} />
        <Text style={styles.settingLabel}>{label}</Text>
      </View>
      <Ionicons name="chevron-forward" size={20} color={COLORS.textSecondary} />
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.surface,
  },
  content: {
    padding: SPACING.md,
  },
  sectionTitle: {
    fontSize: FONTS.sizes.large,
    fontWeight: '700',
    color: COLORS.text,
    marginTop: SPACING.lg,
    marginBottom: SPACING.md,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: COLORS.background,
    padding: SPACING.lg,
    borderRadius: 12,
    marginBottom: SPACING.sm,
  },
  settingLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  settingLabel: {
    fontSize: FONTS.sizes.large,
    color: COLORS.text,
    marginLeft: SPACING.md,
    fontWeight: '500',
  },
});
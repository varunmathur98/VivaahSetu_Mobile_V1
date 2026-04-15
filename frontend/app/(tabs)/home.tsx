import React, { useEffect, useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  RefreshControl, Image,
} from 'react-native';
import { router } from 'expo-router';
import { useAuthStore } from '../../src/stores/authStore';
import { useProfileStore } from '../../src/stores/profileStore';
import { useConnectionsStore } from '../../src/stores/connectionsStore';
import { COLORS, SPACING, FONTS } from '../../src/constants/theme';
import { Ionicons } from '@expo/vector-icons';

export default function HomeScreen() {
  const { user } = useAuthStore();
  const { profile, fetchProfile } = useProfileStore();
  const { count, max, fetchConnections } = useConnectionsStore();
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    fetchProfile();
    fetchConnections();
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    await Promise.all([fetchProfile(), fetchConnections()]);
    setRefreshing(false);
  };

  const profileProgress = profile ? calcProgress(profile) : 0;

  return (
    <ScrollView
      testID="home-screen"
      style={styles.container}
      contentContainerStyle={styles.content}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={COLORS.primary} />}
    >
      {/* Welcome */}
      <View style={styles.banner}>
        <View>
          <Text style={styles.welcomeText}>Welcome back,</Text>
          <Text style={styles.userName}>{user?.name?.split(' ')[0] || 'User'}!</Text>
        </View>
        <View style={[styles.profileImage, styles.profileImagePlaceholder]}>
          <Ionicons name="person" size={32} color={COLORS.textSecondary} />
        </View>
      </View>

      {/* Profile Completion */}
      {profileProgress < 100 && (
        <TouchableOpacity testID="complete-profile-btn" style={styles.profileCard} onPress={() => router.push('/edit-profile')} activeOpacity={0.7}>
          <View style={styles.profileCardHeader}>
            <Ionicons name="checkmark-circle" size={24} color={COLORS.primary} />
            <Text style={styles.profileCardTitle}>Complete Your Profile</Text>
          </View>
          <Text style={styles.profileCardDesc}>{profileProgress}% complete - add more details for better matches!</Text>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: `${profileProgress}%` }]} />
          </View>
        </TouchableOpacity>
      )}

      {/* Stats */}
      <View style={styles.statsRow}>
        <TouchableOpacity testID="stat-connections" style={styles.statCard} onPress={() => router.push('/(tabs)/connections')}>
          <Ionicons name="people" size={28} color={COLORS.primary} />
          <Text style={styles.statValue}>{count}/{max}</Text>
          <Text style={styles.statLabel}>Connections</Text>
        </TouchableOpacity>
        <TouchableOpacity testID="stat-plan" style={styles.statCard} onPress={() => router.push('/subscription')}>
          <Ionicons name="diamond" size={28} color={COLORS.secondary} />
          <Text style={styles.statValue}>{(profile as any)?.plan || user?.plan || 'Free'}</Text>
          <Text style={styles.statLabel}>Plan</Text>
        </TouchableOpacity>
      </View>

      {/* Quick Actions */}
      <Text style={styles.sectionTitle}>Quick Actions</Text>
      <View style={styles.actionsGrid}>
        <ActionBtn icon="search" label="Browse" color={COLORS.primary} onPress={() => router.push('/(tabs)/browse')} />
        <ActionBtn icon="person-add" label="Connections" color={COLORS.secondary} onPress={() => router.push('/(tabs)/connections')} />
        <ActionBtn icon="chatbubbles" label="Messages" color={COLORS.primary} onPress={() => router.push('/(tabs)/messages')} />
        <ActionBtn icon="create" label="Edit Profile" color={COLORS.textSecondary} onPress={() => router.push('/edit-profile')} />
      </View>

      {/* Upgrade Banner */}
      <TouchableOpacity testID="upgrade-banner" style={styles.upgradeBanner} onPress={() => router.push('/subscription')} activeOpacity={0.8}>
        <View style={styles.upgradeContent}>
          <Text style={styles.upgradeTitle}>Upgrade to Premium</Text>
          <Text style={styles.upgradeText}>Unlock chat, contacts, and more!</Text>
        </View>
        <Ionicons name="arrow-forward" size={24} color="#fff" />
      </TouchableOpacity>
    </ScrollView>
  );
}

function ActionBtn({ icon, label, color, onPress }: any) {
  return (
    <TouchableOpacity style={styles.actionBtn} onPress={onPress} activeOpacity={0.7}>
      <View style={[styles.actionIconWrap, { backgroundColor: color + '20' }]}>
        <Ionicons name={icon} size={24} color={color} />
      </View>
      <Text style={styles.actionLabel}>{label}</Text>
    </TouchableOpacity>
  );
}

function calcProgress(p: any): number {
  const fields = ['name', 'age', 'gender', 'height', 'religion', 'city', 'education', 'occupation', 'about'];
  const filled = fields.filter((f) => p[f]).length;
  const hasPhoto = p.photos && p.photos.length > 0 ? 1 : 0;
  return Math.round(((filled + hasPhoto) / (fields.length + 1)) * 100);
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: COLORS.surface },
  content: { padding: SPACING.md },
  banner: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    backgroundColor: COLORS.background, padding: SPACING.lg, borderRadius: 16, marginBottom: SPACING.md,
  },
  welcomeText: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary },
  userName: { fontSize: FONTS.sizes.title, fontWeight: '700', color: COLORS.text, marginTop: 4 },
  profileImage: { width: 60, height: 60, borderRadius: 30 },
  profileImagePlaceholder: { backgroundColor: COLORS.surface, alignItems: 'center', justifyContent: 'center' },
  profileCard: { backgroundColor: COLORS.background, padding: SPACING.lg, borderRadius: 12, marginBottom: SPACING.md },
  profileCardHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: SPACING.sm },
  profileCardTitle: { fontSize: FONTS.sizes.large, fontWeight: '600', color: COLORS.text, marginLeft: SPACING.sm },
  profileCardDesc: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, marginBottom: SPACING.md },
  progressBar: { height: 8, backgroundColor: COLORS.surface, borderRadius: 4, overflow: 'hidden' },
  progressFill: { height: '100%', backgroundColor: COLORS.primary },
  statsRow: { flexDirection: 'row', gap: SPACING.md, marginBottom: SPACING.lg },
  statCard: { flex: 1, backgroundColor: COLORS.background, padding: SPACING.lg, borderRadius: 12, alignItems: 'center' },
  statValue: { fontSize: FONTS.sizes.xxlarge, fontWeight: '700', color: COLORS.text, marginTop: SPACING.sm },
  statLabel: { fontSize: FONTS.sizes.small, color: COLORS.textSecondary, marginTop: 4 },
  sectionTitle: { fontSize: FONTS.sizes.large, fontWeight: '700', color: COLORS.text, marginBottom: SPACING.md },
  actionsGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: SPACING.md, marginBottom: SPACING.lg },
  actionBtn: { width: '47%', backgroundColor: COLORS.background, padding: SPACING.lg, borderRadius: 12, alignItems: 'center' },
  actionIconWrap: { width: 56, height: 56, borderRadius: 28, alignItems: 'center', justifyContent: 'center', marginBottom: SPACING.sm },
  actionLabel: { fontSize: FONTS.sizes.medium, fontWeight: '600', color: COLORS.text, textAlign: 'center' },
  upgradeBanner: {
    backgroundColor: COLORS.primary, padding: SPACING.lg, borderRadius: 12,
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: SPACING.md,
  },
  upgradeContent: { flex: 1 },
  upgradeTitle: { fontSize: FONTS.sizes.large, fontWeight: '700', color: '#fff', marginBottom: 4 },
  upgradeText: { fontSize: FONTS.sizes.medium, color: '#fff', opacity: 0.9 },
});

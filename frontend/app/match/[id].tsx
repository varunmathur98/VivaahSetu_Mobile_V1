import React, { useEffect, useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity, Image, Alert, ActivityIndicator,
} from 'react-native';
import { useLocalSearchParams, router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import api from '../../src/config/api';
import { useConnectionsStore } from '../../src/stores/connectionsStore';
import { useProfileStore } from '../../src/stores/profileStore';
import { COLORS, SPACING, FONTS } from '../../src/constants/theme';

export default function MatchProfileScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const [profile, setProfile] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const { sendRequest, count, max, connections } = useConnectionsStore();
  const myProfile = useProfileStore((s) => s.profile) as any;
  const myPlan = myProfile?.plan || 'free';

  const isConnected = connections.some((c: any) => c.id === id);
  const canSeePhotos = isConnected || myPlan !== 'free';
  const canSeeContact = isConnected && myPlan !== 'free';

  useEffect(() => {
    if (id) {
      api.get(`/profile/${id}`).then((res) => { setProfile(res.data); setLoading(false); })
        .catch(() => { setLoading(false); Alert.alert('Error', 'Failed to load profile'); });
    }
  }, [id]);

  const handleConnect = async () => {
    if (!id) return;
    if (count >= max) { Alert.alert('Limit', `Max ${max} connections. Remove one first.`); return; }
    try { await sendRequest(id); Alert.alert('Sent!', 'Connection request sent!'); }
    catch (error: any) { Alert.alert('Error', error.response?.data?.detail || 'Failed'); }
  };

  if (loading) return <View style={styles.center}><ActivityIndicator size="large" color={COLORS.primary} /></View>;
  if (!profile) return <View style={styles.center}><Text style={styles.errorText}>Profile not found</Text></View>;

  const photoVisible = profile.photoVisibility === 'yes';
  const showPhotos = photoVisible && (isConnected || myPlan !== 'free');
  const photos = profile.photos || [];

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {/* Back Button */}
      <TouchableOpacity testID="back-btn" style={styles.backButton} onPress={() => router.back()}>
        <Ionicons name="arrow-back" size={24} color={COLORS.text} />
      </TouchableOpacity>

      {/* Photo Gallery */}
      <View style={styles.photoSection}>
        {showPhotos && photos.length > 0 ? (
          <Image source={{ uri: photos[0] }} style={styles.mainPhoto} />
        ) : (
          <View style={[styles.mainPhoto, styles.photoPlaceholder]}>
            <Ionicons name="person" size={80} color={COLORS.border} />
            {!photoVisible && <Text style={styles.photoHiddenText}>Photos Hidden</Text>}
            {photoVisible && !isConnected && myPlan === 'free' && (
              <TouchableOpacity style={styles.upgradePhotoBtn} onPress={() => router.push('/subscription')}>
                <Ionicons name="lock-closed" size={16} color="#fff" />
                <Text style={styles.upgradePhotoBtnText}>{' Upgrade to see photos'}</Text>
              </TouchableOpacity>
            )}
          </View>
        )}
      </View>

      {/* Name & Basic Info */}
      <View style={styles.infoCard}>
        <Text style={styles.name}>{profile.name}</Text>
        <Text style={styles.subInfo}>
          {profile.age ? `${profile.age} yrs` : ''} {profile.height ? `\u2022 ${profile.height}` : ''} {profile.maritalStatus ? `\u2022 ${profile.maritalStatus}` : ''}
        </Text>
        <View style={styles.detailGrid}>
          <DetailRow icon="location" label="Location" value={`${profile.city || ''} ${profile.state || ''}`} />
          <DetailRow icon="heart" label="Religion" value={`${profile.religion || 'N/A'} ${profile.caste ? `- ${profile.caste}` : ''}`} />
          <DetailRow icon="school" label="Education" value={profile.education || 'N/A'} />
          <DetailRow icon="briefcase" label="Occupation" value={profile.occupation || 'N/A'} />
          <DetailRow icon="cash" label="Income" value={profile.income || 'N/A'} />
          <DetailRow icon="language" label="Mother Tongue" value={profile.motherTongue || 'N/A'} />
        </View>
      </View>

      {/* About */}
      {profile.about && (
        <View style={styles.infoCard}>
          <Text style={styles.sectionTitle}>About</Text>
          <Text style={styles.aboutText}>{profile.about}</Text>
        </View>
      )}

      {/* Family Details */}
      {profile.familyDetails && (
        <View style={styles.infoCard}>
          <Text style={styles.sectionTitle}>Family</Text>
          <Text style={styles.aboutText}>{profile.familyDetails}</Text>
        </View>
      )}

      {/* Contact Details - gated */}
      <View style={styles.infoCard}>
        <Text style={styles.sectionTitle}>Contact Details</Text>
        {canSeeContact ? (
          <>
            <DetailRow icon="mail" label="Email" value={profile.email || 'N/A'} />
            <DetailRow icon="call" label="Phone" value={profile.phone || 'N/A'} />
          </>
        ) : (
          <TouchableOpacity style={styles.upgradeCard} onPress={() => router.push('/subscription')}>
            <Ionicons name="lock-closed" size={24} color={COLORS.primary} />
            <Text style={styles.upgradeText}>Upgrade to see contact details</Text>
            <Text style={styles.upgradeSubText}>Subscribe to Focus or Commit plan and get matched</Text>
          </TouchableOpacity>
        )}
      </View>

      {/* Connection Timer */}
      {isConnected && (
        <View style={styles.timerCard}>
          <Ionicons name="time" size={24} color={COLORS.primary} />
          <View style={styles.timerInfo}>
            <Text style={styles.timerTitle}>Connection Active</Text>
            <Text style={styles.timerText}>15-day connection timer. Both users can mutually agree to extend by 15 more days.</Text>
          </View>
        </View>
      )}

      {/* Action Buttons */}
      <View style={styles.actions}>
        {!isConnected && (
          <TouchableOpacity testID="connect-profile-btn" style={styles.connectButton} onPress={handleConnect}>
            <Ionicons name="heart" size={20} color="#fff" />
            <Text style={styles.connectButtonText}>{' Send Connection Request'}</Text>
          </TouchableOpacity>
        )}
      </View>
    </ScrollView>
  );
}

function DetailRow({ icon, label, value }: { icon: any; label: string; value: string }) {
  return (
    <View style={styles.detailRow}>
      <Ionicons name={icon} size={18} color={COLORS.textSecondary} />
      <View style={styles.detailContent}>
        <Text style={styles.detailLabel}>{label}</Text>
        <Text style={styles.detailValue}>{value || 'N/A'}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FFF8E7' },
  content: { paddingBottom: SPACING.xxl * 2 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  errorText: { fontSize: FONTS.sizes.large, color: COLORS.error },
  backButton: { position: 'absolute', top: 50, left: SPACING.md, zIndex: 10, backgroundColor: '#fff', width: 40, height: 40, borderRadius: 20, justifyContent: 'center', alignItems: 'center', elevation: 4 },
  photoSection: { width: '100%' },
  mainPhoto: { width: '100%', height: 400, backgroundColor: '#FFF0F0' },
  photoPlaceholder: { justifyContent: 'center', alignItems: 'center' },
  photoHiddenText: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, marginTop: SPACING.sm },
  upgradePhotoBtn: { flexDirection: 'row', alignItems: 'center', backgroundColor: COLORS.primary, paddingHorizontal: SPACING.lg, paddingVertical: SPACING.sm, borderRadius: 20, marginTop: SPACING.md },
  upgradePhotoBtnText: { fontSize: FONTS.sizes.medium, color: '#fff', fontWeight: '600' },
  infoCard: { backgroundColor: '#fff', margin: SPACING.md, borderRadius: 12, padding: SPACING.lg, borderWidth: 1, borderColor: '#E8DCC8' },
  name: { fontSize: FONTS.sizes.title, fontWeight: '700', color: '#4A2C0A' },
  subInfo: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, marginTop: 4, marginBottom: SPACING.md },
  detailGrid: {},
  detailRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: SPACING.sm, borderBottomWidth: 1, borderBottomColor: '#f5f0e5' },
  detailContent: { marginLeft: SPACING.md, flex: 1 },
  detailLabel: { fontSize: FONTS.sizes.small, color: COLORS.textSecondary },
  detailValue: { fontSize: FONTS.sizes.medium, color: COLORS.text, fontWeight: '500' },
  sectionTitle: { fontSize: FONTS.sizes.large, fontWeight: '700', color: '#4A2C0A', marginBottom: SPACING.md },
  aboutText: { fontSize: FONTS.sizes.medium, color: COLORS.text, lineHeight: 22 },
  upgradeCard: { alignItems: 'center', padding: SPACING.xl, backgroundColor: '#FFF0F0', borderRadius: 12 },
  upgradeText: { fontSize: FONTS.sizes.large, fontWeight: '600', color: COLORS.primary, marginTop: SPACING.sm },
  upgradeSubText: { fontSize: FONTS.sizes.small, color: COLORS.textSecondary, textAlign: 'center', marginTop: 4 },
  timerCard: { flexDirection: 'row', backgroundColor: '#fff', margin: SPACING.md, padding: SPACING.lg, borderRadius: 12, borderWidth: 1, borderColor: '#E8DCC8', alignItems: 'center' },
  timerInfo: { marginLeft: SPACING.md, flex: 1 },
  timerTitle: { fontSize: FONTS.sizes.medium, fontWeight: '700', color: COLORS.text },
  timerText: { fontSize: FONTS.sizes.small, color: COLORS.textSecondary, marginTop: 4 },
  actions: { padding: SPACING.md },
  connectButton: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', backgroundColor: '#8B0000', paddingVertical: SPACING.md, borderRadius: 12 },
  connectButtonText: { fontSize: FONTS.sizes.large, fontWeight: '600', color: '#fff' },
});

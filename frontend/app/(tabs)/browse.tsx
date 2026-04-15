import React, { useEffect, useState } from 'react';
import {
  View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl,
  ActivityIndicator, Alert, Image, TextInput, ScrollView,
} from 'react-native';
import { router } from 'expo-router';
import { useMatchesStore } from '../../src/stores/matchesStore';
import { useConnectionsStore } from '../../src/stores/connectionsStore';
import { COLORS, SPACING, FONTS } from '../../src/constants/theme';
import { Ionicons } from '@expo/vector-icons';

const RELIGIONS = ['Hindu', 'Muslim', 'Christian', 'Sikh', 'Jain', 'Buddhist', 'Other'];

export default function BrowseScreen() {
  const { matches, isLoading, fetchMatches, updateFilters, filters } = useMatchesStore();
  const { sendRequest, count, max } = useConnectionsStore();
  const [refreshing, setRefreshing] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [localFilters, setLocalFilters] = useState<any>({
    minAge: '', maxAge: '', religion: '', caste: '', city: '', profession: '',
  });

  useEffect(() => { fetchMatches(true); }, []);

  const onRefresh = async () => { setRefreshing(true); await fetchMatches(true); setRefreshing(false); };

  const applyFilters = () => {
    const applied: any = {};
    if (localFilters.minAge) applied.minAge = parseInt(localFilters.minAge);
    if (localFilters.maxAge) applied.maxAge = parseInt(localFilters.maxAge);
    if (localFilters.religion) applied.religion = localFilters.religion;
    if (localFilters.caste) applied.caste = localFilters.caste;
    if (localFilters.city) applied.city = localFilters.city;
    updateFilters(applied);
    fetchMatches(true);
    setShowFilters(false);
  };

  const clearFilters = () => {
    setLocalFilters({ minAge: '', maxAge: '', religion: '', caste: '', city: '', profession: '' });
    updateFilters({});
    fetchMatches(true);
    setShowFilters(false);
  };

  const handleConnect = async (userId: string) => {
    if (count >= max) { Alert.alert('Limit Reached', `Max ${max} connections. Remove one to connect.`); return; }
    try { await sendRequest(userId); Alert.alert('Sent!', 'Connection request sent!'); fetchMatches(true); }
    catch (error: any) { Alert.alert('Error', error.response?.data?.detail || 'Failed'); }
  };

  const renderMatch = ({ item }: any) => (
    <TouchableOpacity testID={`match-card-${item.id}`} style={styles.matchCard} onPress={() => router.push(`/match/${item.id}`)} activeOpacity={0.8}>
      <View style={styles.cardImageContainer}>
        {item.photos && item.photos.length > 0 ? (
          <Image source={{ uri: item.photos[0] }} style={styles.matchImage} />
        ) : (
          <View style={[styles.matchImage, styles.placeholderImage]}>
            <Ionicons name="person" size={64} color={COLORS.border} />
          </View>
        )}
        {item.requestSent && <View style={styles.badge}><Text style={styles.badgeText}>Request Sent</Text></View>}
        {item.alreadyConnected && <View style={[styles.badge, { backgroundColor: COLORS.success }]}><Text style={styles.badgeText}>Connected</Text></View>}
      </View>
      <View style={styles.matchInfo}>
        <View style={styles.matchHeader}>
          <Text style={styles.matchName}>{item.name}</Text>
          {item.age ? <Text style={styles.matchAge}>{item.age} yrs</Text> : null}
        </View>
        <View style={styles.detailRow}><Ionicons name="location-outline" size={14} color={COLORS.textSecondary} /><Text style={styles.matchDetail}>{` ${item.city || 'N/A'}`}</Text></View>
        <View style={styles.detailRow}><Ionicons name="briefcase-outline" size={14} color={COLORS.textSecondary} /><Text style={styles.matchDetail}>{` ${item.occupation || 'N/A'}`}</Text></View>
        {item.religion ? <View style={styles.detailRow}><Ionicons name="heart-outline" size={14} color={COLORS.textSecondary} /><Text style={styles.matchDetail}>{` ${item.religion}`}</Text></View> : null}
        {!item.requestSent && !item.alreadyConnected && !item.requestReceived && (
          <TouchableOpacity testID={`connect-btn-${item.id}`} style={styles.connectButton} onPress={() => handleConnect(item.id)}>
            <Ionicons name="heart" size={18} color="#fff" />
            <Text style={styles.connectButtonText}>Connect</Text>
          </TouchableOpacity>
        )}
      </View>
    </TouchableOpacity>
  );

  return (
    <View testID="browse-screen" style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <View>
          <Text style={styles.headerTitle}>Find Your Match</Text>
          <Text style={styles.headerSub}>{matches.length} profiles available</Text>
        </View>
        <TouchableOpacity testID="toggle-filters-btn" style={styles.filterToggle} onPress={() => setShowFilters(!showFilters)}>
          <Ionicons name="funnel" size={20} color={COLORS.text} />
          <Text style={styles.filterToggleText}>{' Filters'}</Text>
        </TouchableOpacity>
      </View>

      {/* Filters */}
      {showFilters && (
        <View style={styles.filtersContainer}>
          <View style={styles.filterRow}>
            <View style={styles.filterField}>
              <Text style={styles.filterLabel}>Age Min</Text>
              <TextInput style={styles.filterInput} value={localFilters.minAge} onChangeText={(v) => setLocalFilters((p: any) => ({ ...p, minAge: v }))} keyboardType="numeric" placeholder="20" placeholderTextColor={COLORS.textSecondary} />
            </View>
            <View style={styles.filterField}>
              <Text style={styles.filterLabel}>Age Max</Text>
              <TextInput style={styles.filterInput} value={localFilters.maxAge} onChangeText={(v) => setLocalFilters((p: any) => ({ ...p, maxAge: v }))} keyboardType="numeric" placeholder="35" placeholderTextColor={COLORS.textSecondary} />
            </View>
            <View style={styles.filterField}>
              <Text style={styles.filterLabel}>City/State</Text>
              <TextInput style={styles.filterInput} value={localFilters.city} onChangeText={(v) => setLocalFilters((p: any) => ({ ...p, city: v }))} placeholder="Select state" placeholderTextColor={COLORS.textSecondary} />
            </View>
            <View style={styles.filterField}>
              <Text style={styles.filterLabel}>Religion</Text>
              <TextInput style={styles.filterInput} value={localFilters.religion} onChangeText={(v) => setLocalFilters((p: any) => ({ ...p, religion: v }))} placeholder="Select religion" placeholderTextColor={COLORS.textSecondary} />
            </View>
          </View>
          <View style={styles.filterRow}>
            <View style={styles.filterField}>
              <Text style={styles.filterLabel}>Caste</Text>
              <TextInput style={styles.filterInput} value={localFilters.caste} onChangeText={(v) => setLocalFilters((p: any) => ({ ...p, caste: v }))} placeholder="Select caste" placeholderTextColor={COLORS.textSecondary} />
            </View>
            <View style={styles.filterField}>
              <Text style={styles.filterLabel}>Profession</Text>
              <TextInput style={styles.filterInput} value={localFilters.profession} onChangeText={(v) => setLocalFilters((p: any) => ({ ...p, profession: v }))} placeholder="Profession" placeholderTextColor={COLORS.textSecondary} />
            </View>
          </View>
          <View style={styles.filterActions}>
            <TouchableOpacity testID="apply-filters-btn" style={styles.applyButton} onPress={applyFilters}>
              <Text style={styles.applyButtonText}>Apply Filters</Text>
            </TouchableOpacity>
            <TouchableOpacity testID="clear-filters-btn" style={styles.clearButton} onPress={clearFilters}>
              <Text style={styles.clearButtonText}>Clear All</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}

      {isLoading && matches.length === 0 ? (
        <View style={styles.center}><ActivityIndicator size="large" color={COLORS.primary} /></View>
      ) : (
        <FlatList
          data={matches}
          renderItem={renderMatch}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={COLORS.primary} />}
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Ionicons name="search" size={64} color={COLORS.textSecondary} />
              <Text style={styles.emptyText}>No matches found. Try adjusting your filters.</Text>
            </View>
          }
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FFF8E7' },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: SPACING.md, backgroundColor: '#fff', borderBottomWidth: 1, borderBottomColor: '#E8DCC8' },
  headerTitle: { fontSize: FONTS.sizes.xxlarge, fontWeight: '700', color: '#4A2C0A' },
  headerSub: { fontSize: FONTS.sizes.small, color: COLORS.textSecondary, marginTop: 2 },
  filterToggle: { flexDirection: 'row', alignItems: 'center', borderWidth: 1, borderColor: '#E8DCC8', borderRadius: 12, paddingHorizontal: SPACING.md, paddingVertical: SPACING.sm, backgroundColor: '#FFFDF5' },
  filterToggleText: { fontSize: FONTS.sizes.medium, fontWeight: '600', color: COLORS.text },
  filtersContainer: { backgroundColor: '#fff', padding: SPACING.lg, borderBottomWidth: 1, borderBottomColor: '#E8DCC8' },
  filterRow: { flexDirection: 'row', gap: SPACING.md, marginBottom: SPACING.md },
  filterField: { flex: 1 },
  filterLabel: { fontSize: FONTS.sizes.small, fontWeight: '600', color: COLORS.text, marginBottom: 4 },
  filterInput: { backgroundColor: '#FFFDF5', borderRadius: 8, padding: SPACING.sm, fontSize: FONTS.sizes.medium, borderWidth: 1, borderColor: '#E8DCC8', height: 40, color: COLORS.text },
  filterActions: { flexDirection: 'row', gap: SPACING.md },
  applyButton: { flex: 1, backgroundColor: '#8B0000', paddingVertical: SPACING.md, borderRadius: 12, alignItems: 'center' },
  applyButtonText: { fontSize: FONTS.sizes.medium, fontWeight: '700', color: '#fff' },
  clearButton: { flex: 1, backgroundColor: '#fff', paddingVertical: SPACING.md, borderRadius: 12, alignItems: 'center', borderWidth: 1, borderColor: '#E8DCC8' },
  clearButtonText: { fontSize: FONTS.sizes.medium, fontWeight: '600', color: COLORS.text },
  list: { padding: SPACING.md },
  matchCard: { backgroundColor: '#fff', borderRadius: 16, marginBottom: SPACING.md, overflow: 'hidden', borderWidth: 1, borderColor: '#E8DCC8' },
  cardImageContainer: { position: 'relative' },
  matchImage: { width: '100%', height: 260, backgroundColor: '#FFF0F0' },
  placeholderImage: { justifyContent: 'center', alignItems: 'center' },
  badge: { position: 'absolute', top: SPACING.md, right: SPACING.md, backgroundColor: '#FFD700', paddingHorizontal: SPACING.md, paddingVertical: 4, borderRadius: 12 },
  badgeText: { fontSize: FONTS.sizes.small, fontWeight: '700', color: '#333' },
  matchInfo: { padding: SPACING.lg },
  matchHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: SPACING.sm },
  matchName: { fontSize: FONTS.sizes.xlarge, fontWeight: '700', color: '#4A2C0A' },
  matchAge: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, fontWeight: '600' },
  detailRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 4 },
  matchDetail: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary },
  connectButton: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', backgroundColor: '#8B0000', paddingVertical: SPACING.sm, borderRadius: 12, marginTop: SPACING.md },
  connectButtonText: { fontSize: FONTS.sizes.medium, fontWeight: '600', color: '#fff' },
  emptyContainer: { alignItems: 'center', justifyContent: 'center', paddingVertical: SPACING.xxl * 2 },
  emptyText: { fontSize: FONTS.sizes.large, fontWeight: '500', color: COLORS.textSecondary, marginTop: SPACING.lg, textAlign: 'center' },
});

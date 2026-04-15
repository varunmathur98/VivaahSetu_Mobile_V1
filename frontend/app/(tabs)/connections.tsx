import React, { useEffect, useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  RefreshControl, Alert,
} from 'react-native';
import { useConnectionsStore } from '../../src/stores/connectionsStore';
import { COLORS, SPACING, FONTS } from '../../src/constants/theme';
import { Ionicons } from '@expo/vector-icons';

export default function ConnectionsScreen() {
  const {
    connections, pendingReceived, pendingSent, count, max,
    fetchConnections, acceptRequest, rejectRequest, cancelRequest, removeConnection,
  } = useConnectionsStore();
  const [refreshing, setRefreshing] = useState(false);
  const [activeTab, setActiveTab] = useState<'active' | 'received' | 'sent'>('received');

  useEffect(() => { fetchConnections(); }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchConnections();
    setRefreshing(false);
  };

  const handleAccept = async (id: string) => {
    try {
      await acceptRequest(id);
      Alert.alert('Accepted!', 'Connection established for 15 days.');
    } catch (error: any) {
      Alert.alert('Error', error.response?.data?.detail || 'Failed to accept');
    }
  };

  const getDaysRemaining = (expiresAt: string) => {
    const now = new Date();
    const exp = new Date(expiresAt);
    const diff = Math.ceil((exp.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
    return Math.max(0, diff);
  };

  const renderItem = (item: any, type: 'active' | 'received' | 'sent') => {
    const daysLeft = item.expiresAt ? getDaysRemaining(item.expiresAt) : null;
    return (
      <View key={item.id} testID={`connection-card-${item.id}`} style={styles.card}>
        <View style={styles.cardInfo}>
          <Text style={styles.cardName}>{item.name}</Text>
          <Text style={styles.cardDetail}>{item.age ? `${item.age} yrs` : ''} {item.city ? `\u2022 ${item.city}` : ''}</Text>
          <Text style={styles.cardDetail}>{item.occupation || ''}</Text>
          {daysLeft !== null && (
            <View style={[styles.timerBadge, daysLeft <= 3 && styles.timerBadgeUrgent]}>
              <Ionicons name="time-outline" size={14} color={daysLeft <= 3 ? '#fff' : COLORS.text} />
              <Text style={[styles.timerText, daysLeft <= 3 && styles.timerTextUrgent]}>
                {daysLeft > 0 ? `${daysLeft} days left` : 'Expired'}
              </Text>
            </View>
          )}
        </View>
        <View style={styles.cardActions}>
          {type === 'received' && (
            <>
              <TouchableOpacity testID={`accept-btn-${item.id}`} style={[styles.actionBtn, styles.acceptBtn]} onPress={() => handleAccept(item.id)}>
                <Ionicons name="checkmark" size={22} color="#fff" />
              </TouchableOpacity>
              <TouchableOpacity testID={`reject-btn-${item.id}`} style={[styles.actionBtn, styles.rejectBtn]} onPress={() => rejectRequest(item.id)}>
                <Ionicons name="close" size={22} color="#fff" />
              </TouchableOpacity>
            </>
          )}
          {type === 'sent' && (
            <TouchableOpacity style={[styles.actionBtn, styles.cancelBtn]} onPress={() => cancelRequest(item.id)}>
              <Text style={styles.cancelText}>Cancel</Text>
            </TouchableOpacity>
          )}
          {type === 'active' && (
            <TouchableOpacity style={[styles.actionBtn, styles.removeBtn]} onPress={() => {
              Alert.alert('Remove', 'Remove this connection?', [
                { text: 'No', style: 'cancel' },
                { text: 'Yes', style: 'destructive', onPress: () => removeConnection(item.id) },
              ]);
            }}>
              <Ionicons name="trash-outline" size={18} color={COLORS.error} />
            </TouchableOpacity>
          )}
        </View>
      </View>
    );
  };

  const getList = () => {
    switch (activeTab) {
      case 'active': return connections;
      case 'received': return pendingReceived;
      case 'sent': return pendingSent;
    }
  };

  return (
    <View testID="connections-screen" style={styles.container}>
      <View style={styles.counterBar}>
        <Text style={styles.counterText}>{count}/{max} Active Connections</Text>
      </View>
      <View style={styles.tabs}>
        {(['received', 'active', 'sent'] as const).map((tab) => (
          <TouchableOpacity
            key={tab}
            testID={`tab-${tab}`}
            style={[styles.tab, activeTab === tab && styles.activeTab]}
            onPress={() => setActiveTab(tab)}
          >
            <Text style={[styles.tabText, activeTab === tab && styles.activeTabText]}>
              {tab === 'received' ? `Received (${pendingReceived.length})`
                : tab === 'sent' ? `Sent (${pendingSent.length})`
                : `Active (${connections.length})`}
            </Text>
          </TouchableOpacity>
        ))}
      </View>
      <ScrollView
        contentContainerStyle={styles.content}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={COLORS.primary} />}
      >
        {getList().length === 0 ? (
          <View style={styles.emptyContainer}>
            <Ionicons name="people-outline" size={64} color={COLORS.textSecondary} />
            <Text style={styles.emptyText}>No {activeTab} connections</Text>
          </View>
        ) : (
          getList().map((item) => renderItem(item, activeTab))
        )}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: COLORS.surface },
  counterBar: { backgroundColor: COLORS.primary, padding: SPACING.sm, alignItems: 'center' },
  counterText: { fontSize: FONTS.sizes.small, fontWeight: '700', color: '#fff' },
  tabs: { flexDirection: 'row', backgroundColor: COLORS.background, borderBottomWidth: 1, borderBottomColor: COLORS.border },
  tab: { flex: 1, paddingVertical: SPACING.md, alignItems: 'center' },
  activeTab: { borderBottomWidth: 2, borderBottomColor: COLORS.primary },
  tabText: { fontSize: FONTS.sizes.small, color: COLORS.textSecondary, fontWeight: '600' },
  activeTabText: { color: COLORS.primary },
  content: { padding: SPACING.md },
  card: {
    backgroundColor: COLORS.background, padding: SPACING.lg, borderRadius: 12, marginBottom: SPACING.md,
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
  },
  cardInfo: { flex: 1 },
  cardName: { fontSize: FONTS.sizes.large, fontWeight: '700', color: COLORS.text, marginBottom: 4 },
  cardDetail: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, marginBottom: 2 },
  timerBadge: {
    flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: SPACING.xs,
    backgroundColor: COLORS.surface, paddingHorizontal: SPACING.sm, paddingVertical: 4, borderRadius: 8, alignSelf: 'flex-start',
  },
  timerBadgeUrgent: { backgroundColor: COLORS.error },
  timerText: { fontSize: FONTS.sizes.small, fontWeight: '600', color: COLORS.text },
  timerTextUrgent: { color: '#fff' },
  cardActions: { flexDirection: 'row', gap: SPACING.sm },
  actionBtn: { width: 44, height: 44, borderRadius: 22, justifyContent: 'center', alignItems: 'center' },
  acceptBtn: { backgroundColor: COLORS.success },
  rejectBtn: { backgroundColor: COLORS.error },
  cancelBtn: { backgroundColor: COLORS.surface, paddingHorizontal: SPACING.md, width: 'auto', borderRadius: 12 },
  cancelText: { fontSize: FONTS.sizes.small, fontWeight: '600', color: COLORS.error },
  removeBtn: { backgroundColor: COLORS.surface },
  emptyContainer: { alignItems: 'center', justifyContent: 'center', paddingVertical: SPACING.xxl * 2 },
  emptyText: { fontSize: FONTS.sizes.large, fontWeight: '600', color: COLORS.text, marginTop: SPACING.lg },
});

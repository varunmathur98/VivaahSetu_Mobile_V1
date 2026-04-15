import React, { useState, useEffect } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert, ActivityIndicator, Linking,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import api from '../src/config/api';
import { useProfileStore } from '../src/stores/profileStore';
import { COLORS, SPACING, FONTS } from '../src/constants/theme';

export default function SubscriptionScreen() {
  const [plans, setPlans] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [processingPlan, setProcessingPlan] = useState<string | null>(null);
  const { profile } = useProfileStore();
  const currentPlan = (profile as any)?.plan || 'free';

  useEffect(() => {
    api.get('/subscriptions/plans').then(res => setPlans(res.data.plans || [])).catch(() => {});
  }, []);

  const handleSubscribe = async (planId: string) => {
    if (planId === 'free' || planId === currentPlan) return;
    try {
      setProcessingPlan(planId);
      setLoading(true);
      const res = await api.post('/payment/create-order', { planId });
      const { paymentLink, paymentSessionId, orderId } = res.data;
      if (paymentLink) {
        await Linking.openURL(paymentLink);
        // After returning, verify
        setTimeout(async () => {
          try {
            const verifyRes = await api.get(`/payment/verify/${orderId}`);
            if (verifyRes.data.status === 'PAID') {
              Alert.alert('Success', 'Payment successful! Your plan has been upgraded.');
            }
          } catch {}
        }, 5000);
      } else {
        Alert.alert('Payment', 'Payment session created. Complete payment to activate your plan.');
      }
    } catch (error: any) {
      Alert.alert('Error', error.response?.data?.detail || 'Payment failed');
    } finally {
      setLoading(false);
      setProcessingPlan(null);
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>Choose Your Plan</Text>
      <Text style={styles.subtitle}>Start free and upgrade when ready</Text>

      {/* Free Plan */}
      <View style={styles.freeCard}>
        <Text style={styles.freeName}>Free - Explore</Text>
        <Text style={styles.freeTagline}>For discovery</Text>
        <View style={styles.featuresList}>
          {['Create profile', 'Unlimited browsing', 'Send interests', 'Max 5 connections', '15-day timer'].map((f, i) => (
            <View key={i} style={styles.featureRow}>
              <Ionicons name="checkmark-circle" size={18} color={COLORS.success} />
              <Text style={styles.featureText}>{f}</Text>
            </View>
          ))}
          {['No chat', 'No contact details'].map((f, i) => (
            <View key={`ex-${i}`} style={styles.featureRow}>
              <Ionicons name="close-circle" size={18} color={COLORS.error} />
              <Text style={[styles.featureText, styles.excludedText]}>{f}</Text>
            </View>
          ))}
        </View>
        {currentPlan === 'free' && (
          <View style={styles.currentPlanBadge}>
            <Text style={styles.currentPlanText}>Current Plan</Text>
          </View>
        )}
      </View>

      {/* Focus Plan - MOST POPULAR */}
      <View style={styles.focusCard}>
        <View style={styles.popularBadge}>
          <Text style={styles.popularBadgeText}>MOST POPULAR</Text>
        </View>
        <Ionicons name="star" size={32} color="#FFD700" style={styles.planIcon} />
        <Text style={styles.focusName}>Focus</Text>
        <Text style={styles.focusTagline}>For serious matchmaking</Text>
        <View style={styles.priceRow}>
          <Text style={styles.originalPrice}>{'\u20B9'}699</Text>
          <Text style={styles.focusPrice}>{'\u20B9'}210</Text>
        </View>
        <Text style={styles.priceInfo}>/month  <Text style={styles.discountBadge}>70% OFF</Text></Text>
        <View style={styles.featuresList}>
          {['Chat unlock after mutual connection', 'View contact details', 'See who viewed profile', 'Advanced filters', 'Connection expiry alerts', 'Request extension', 'Serious Intent badge'].map((f, i) => (
            <View key={i} style={styles.featureRow}>
              <Ionicons name="checkmark-circle" size={18} color="#FFD700" />
              <Text style={styles.focusFeatureText}>{f}</Text>
            </View>
          ))}
        </View>
        <TouchableOpacity
          testID="subscribe-focus-btn"
          style={[styles.focusButton, currentPlan === 'focus' && styles.focusButtonCurrent]}
          onPress={() => handleSubscribe('focus')}
          disabled={loading || currentPlan === 'focus'}
        >
          {processingPlan === 'focus' ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.focusButtonText}>
              {currentPlan === 'focus' ? 'Current Plan' : 'Subscribe Now'}
            </Text>
          )}
        </TouchableOpacity>
      </View>

      {/* Commit Plan - COMING SOON */}
      <View style={styles.commitCard}>
        <View style={styles.comingSoonBadge}>
          <Text style={styles.comingSoonText}>COMING SOON</Text>
        </View>
        <Ionicons name="trophy" size={32} color={COLORS.textSecondary} style={styles.planIcon} />
        <Text style={styles.commitName}>Commit (Coming Soon)</Text>
        <Text style={styles.commitTagline}>Top-tier plan is launching in next phase</Text>
        <View style={styles.priceRow}>
          <Text style={styles.originalPriceCommit}>{'\u20B9'}1,499</Text>
          <Text style={styles.commitPrice}>{'\u20B9'}450</Text>
        </View>
        <Text style={styles.commitPriceInfo}>/month  <Text style={styles.discountBadgeCommit}>70% OFF</Text></Text>
        <View style={styles.featuresList}>
          {['All Focus features', 'Priority match ranking', 'Higher visibility', 'Verified badge included', 'Smart match suggestions', 'Response probability insights', 'Highlighted profile in search'].map((f, i) => (
            <View key={i} style={styles.featureRow}>
              <Ionicons name="checkmark-circle" size={18} color={COLORS.textSecondary} />
              <Text style={styles.commitFeatureText}>{f}</Text>
            </View>
          ))}
        </View>
        <View style={styles.commitButton}>
          <Text style={styles.commitButtonText}>Coming Soon</Text>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FFF8E7' },
  content: { padding: SPACING.md, paddingBottom: SPACING.xxl },
  title: { fontSize: FONTS.sizes.title, fontWeight: '700', color: COLORS.text, textAlign: 'center', marginTop: SPACING.md },
  subtitle: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, textAlign: 'center', marginBottom: SPACING.xl },
  // Free
  freeCard: { backgroundColor: '#fff', borderRadius: 16, padding: SPACING.lg, marginBottom: SPACING.lg, borderWidth: 1, borderColor: COLORS.border },
  freeName: { fontSize: FONTS.sizes.xlarge, fontWeight: '700', color: COLORS.text },
  freeTagline: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, marginBottom: SPACING.md },
  currentPlanBadge: { backgroundColor: COLORS.surface, paddingVertical: SPACING.sm, borderRadius: 12, alignItems: 'center', marginTop: SPACING.md },
  currentPlanText: { fontSize: FONTS.sizes.medium, fontWeight: '600', color: COLORS.textSecondary },
  // Focus
  focusCard: { backgroundColor: '#8B0000', borderRadius: 20, padding: SPACING.xl, marginBottom: SPACING.lg, position: 'relative', overflow: 'visible' },
  popularBadge: { position: 'absolute', top: -14, left: SPACING.xl, backgroundColor: '#FFD700', paddingHorizontal: SPACING.lg, paddingVertical: 6, borderRadius: 12, zIndex: 10 },
  popularBadgeText: { fontSize: FONTS.sizes.small, fontWeight: '800', color: '#333' },
  planIcon: { alignSelf: 'center', marginTop: SPACING.md, marginBottom: SPACING.sm },
  focusName: { fontSize: FONTS.sizes.xxlarge, fontWeight: '700', color: '#fff', textAlign: 'center' },
  focusTagline: { fontSize: FONTS.sizes.medium, color: 'rgba(255,255,255,0.8)', textAlign: 'center', marginBottom: SPACING.md },
  priceRow: { flexDirection: 'row', justifyContent: 'center', alignItems: 'baseline', gap: SPACING.sm },
  originalPrice: { fontSize: FONTS.sizes.large, color: 'rgba(255,255,255,0.5)', textDecorationLine: 'line-through' },
  focusPrice: { fontSize: 42, fontWeight: '800', color: '#fff' },
  priceInfo: { fontSize: FONTS.sizes.medium, color: 'rgba(255,255,255,0.8)', textAlign: 'center', marginBottom: SPACING.lg },
  discountBadge: { backgroundColor: 'rgba(255,255,255,0.2)', paddingHorizontal: 8, borderRadius: 4, fontSize: FONTS.sizes.small, fontWeight: '700', color: '#fff' },
  focusFeatureText: { fontSize: FONTS.sizes.medium, color: 'rgba(255,255,255,0.9)', marginLeft: SPACING.sm, flex: 1 },
  focusButton: { backgroundColor: 'rgba(255,255,255,0.25)', paddingVertical: SPACING.md, borderRadius: 12, alignItems: 'center', marginTop: SPACING.lg },
  focusButtonCurrent: { backgroundColor: 'rgba(255,255,255,0.15)' },
  focusButtonText: { fontSize: FONTS.sizes.large, fontWeight: '700', color: '#fff' },
  // Commit
  commitCard: { backgroundColor: '#fff', borderRadius: 20, padding: SPACING.xl, marginBottom: SPACING.lg, borderWidth: 1, borderColor: COLORS.border, position: 'relative' },
  comingSoonBadge: { position: 'absolute', top: -14, right: SPACING.xl, backgroundColor: '#999', paddingHorizontal: SPACING.lg, paddingVertical: 6, borderRadius: 12, zIndex: 10 },
  comingSoonText: { fontSize: FONTS.sizes.small, fontWeight: '800', color: '#fff' },
  commitName: { fontSize: FONTS.sizes.xxlarge, fontWeight: '700', color: COLORS.text, textAlign: 'center', marginTop: SPACING.sm },
  commitTagline: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, textAlign: 'center', marginBottom: SPACING.md },
  originalPriceCommit: { fontSize: FONTS.sizes.large, color: COLORS.textSecondary, textDecorationLine: 'line-through' },
  commitPrice: { fontSize: 42, fontWeight: '800', color: COLORS.text },
  commitPriceInfo: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, textAlign: 'center', marginBottom: SPACING.lg },
  discountBadgeCommit: { backgroundColor: '#999', paddingHorizontal: 8, borderRadius: 4, fontSize: FONTS.sizes.small, fontWeight: '700', color: '#fff' },
  commitFeatureText: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, marginLeft: SPACING.sm, flex: 1 },
  commitButton: { backgroundColor: COLORS.surface, paddingVertical: SPACING.md, borderRadius: 12, alignItems: 'center', marginTop: SPACING.lg },
  commitButtonText: { fontSize: FONTS.sizes.large, fontWeight: '600', color: COLORS.textSecondary },
  // Shared
  featuresList: { marginTop: SPACING.md },
  featureRow: { flexDirection: 'row', alignItems: 'center', marginBottom: SPACING.sm },
  featureText: { fontSize: FONTS.sizes.medium, color: COLORS.text, marginLeft: SPACING.sm, flex: 1 },
  excludedText: { textDecorationLine: 'line-through', color: COLORS.textSecondary },
});

import React, { useState, useEffect } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TextInput, TouchableOpacity,
  Alert, KeyboardAvoidingView, Platform, Switch, Modal, FlatList,
} from 'react-native';
import { router } from 'expo-router';
import { useProfileStore } from '../src/stores/profileStore';
import { useAuthStore } from '../src/stores/authStore';
import { COLORS, SPACING, FONTS } from '../src/constants/theme';
import { pickImage } from '../src/utils/imagePicker';
import { Ionicons } from '@expo/vector-icons';
import {
  INDIAN_STATES, MAJOR_CITIES, RELIGIONS, CASTES, SUB_CASTES,
  MARITAL_STATUSES, EDUCATION_LEVELS, PROFESSIONS, INCOME_RANGES,
  HEIGHTS, MOTHER_TONGUES,
} from '../src/constants/indianData';

export default function EditProfileScreen() {
  const { profile, updateProfile, uploadPhoto, fetchProfile } = useProfileStore();
  const { updateUser } = useAuthStore();
  const [form, setForm] = useState<any>({});
  const [pp, setPP] = useState<any>({ ageMin: '20', ageMax: '35', religions: [], caste: '', subCaste: '', state: '', locations: '', professions: '' });
  const [loading, setLoading] = useState(false);
  const [photoVisibility, setPhotoVisibility] = useState(true);

  useEffect(() => {
    if (!profile) fetchProfile();
    else {
      const p = profile as any;
      setForm({
        name: p.name || '', dob: p.dob || '', gender: p.gender || 'Male',
        height: p.height || '', religion: p.religion || '', caste: p.caste || '',
        subCaste: p.sub_caste || p.subCaste || '', motherTongue: p.motherTongue || '',
        city: p.city || '', state: p.state || '', education: p.education || '',
        occupation: p.occupation || '', income: p.income || '', maritalStatus: p.maritalStatus || '',
        phone: p.phone || '', about: p.about || '', familyDetails: p.familyDetails || '',
      });
      setPhotoVisibility(p.photoVisibility !== 'no');
      const prefs = p.partnerPreferences || {};
      setPP({
        ageMin: prefs.ageMin?.toString() || '20', ageMax: prefs.ageMax?.toString() || '35',
        religions: prefs.religions || [], caste: prefs.caste || '', subCaste: prefs.subCaste || '',
        state: prefs.state || '', locations: prefs.locations || '', professions: prefs.professions || '',
      });
    }
  }, [profile]);

  const calcAge = (dob: string) => {
    if (!dob) return '';
    const parts = dob.split('-');
    if (parts.length !== 3) return '';
    const birthDate = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) age--;
    return age > 0 && age < 100 ? age.toString() : '';
  };

  const age = calcAge(form.dob);

  const handleSave = async () => {
    try {
      setLoading(true);
      const data: any = {
        ...form, age: parseInt(age) || undefined,
        photoVisibility: photoVisibility ? 'yes' : 'no',
        partnerPreferences: { ...pp, ageMin: parseInt(pp.ageMin) || 20, ageMax: parseInt(pp.ageMax) || 35 },
      };
      await updateProfile(data);
      updateUser({ name: form.name });
      Alert.alert('Success', 'Profile updated!');
      router.back();
    } catch { Alert.alert('Error', 'Failed to save profile'); }
    finally { setLoading(false); }
  };

  const handlePhoto = async () => {
    const photo = await pickImage();
    if (photo) { try { await uploadPhoto(photo); Alert.alert('Success', 'Photo uploaded!'); } catch { Alert.alert('Error', 'Upload failed'); } }
  };

  const update = (key: string, val: any) => setForm((p: any) => ({ ...p, [key]: val }));
  const togglePPReligion = (r: string) => setPP((p: any) => ({ ...p, religions: p.religions.includes(r) ? p.religions.filter((x: string) => x !== r) : [...p.religions, r] }));
  const castes = CASTES[form.religion] || [];
  const subCastes = SUB_CASTES[form.caste] || [];
  const cities = MAJOR_CITIES[form.state] || [];

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={{ flex: 1 }}>
      <ScrollView style={styles.container} contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">

        {/* Photo Upload + Visibility */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Profile Photos</Text>
          <TouchableOpacity testID="upload-photo-btn" style={styles.photoUpload} onPress={handlePhoto}>
            <Ionicons name="camera-outline" size={32} color={COLORS.primary} />
            <Text style={styles.photoUploadText}>Click to add photos</Text>
            <Text style={styles.photoUploadSub}>Up to 5 photos allowed</Text>
          </TouchableOpacity>
          <View style={styles.visibilityRow}>
            <View style={styles.visibilityInfo}>
              <Text style={styles.visibilityLabel}>Make photos visible?</Text>
              <Text style={styles.visibilityHint}>{photoVisibility ? 'Visible to matched connections (or Focus plan holders)' : 'Hidden from everyone except matched connections'}</Text>
            </View>
            <Switch value={photoVisibility} onValueChange={setPhotoVisibility} trackColor={{ false: '#ddd', true: COLORS.primary }} thumbColor="#fff" />
          </View>
        </View>

        {/* Basic Information */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Basic Information</Text>
          <Field label="Full Name" value={form.name} onChange={(v) => update('name', v)} />
          <Field label="Date of Birth (YYYY-MM-DD)" value={form.dob} onChange={(v) => update('dob', v)} placeholder="1995-06-15" />
          <View style={styles.row}>
            <View style={styles.fieldHalf}>
              <Text style={styles.label}>Age (auto-calculated)</Text>
              <View style={styles.disabledInput}><Text style={styles.disabledText}>{age || 'Enter DOB above'}</Text></View>
            </View>
            <DropdownField label="Height" value={form.height} options={HEIGHTS} onSelect={(v) => update('height', v)} />
          </View>
          <View style={styles.row}>
            <DropdownField label="Gender" value={form.gender} options={['Male', 'Female']} onSelect={(v) => update('gender', v)} />
            <DropdownField label="Marital Status" value={form.maritalStatus} options={MARITAL_STATUSES} onSelect={(v) => update('maritalStatus', v)} />
          </View>
          <Field label="Phone" value={form.phone} onChange={(v) => update('phone', v)} keyboardType="phone-pad" />
        </View>

        {/* Religious & Cultural */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Religious and Cultural</Text>
          <DropdownField label="Religion" value={form.religion} options={RELIGIONS} onSelect={(v) => { update('religion', v); update('caste', ''); update('subCaste', ''); }} />
          <View style={styles.row}>
            <DropdownField label="Caste" value={form.caste} options={castes} onSelect={(v) => { update('caste', v); update('subCaste', ''); }} />
            <DropdownField label="Sub Caste" value={form.subCaste} options={subCastes.length > 0 ? subCastes : ['Other']} onSelect={(v) => update('subCaste', v)} />
          </View>
          <DropdownField label="Mother Tongue" value={form.motherTongue} options={MOTHER_TONGUES} onSelect={(v) => update('motherTongue', v)} />
        </View>

        {/* Professional */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Professional Details</Text>
          <DropdownField label="Education" value={form.education} options={EDUCATION_LEVELS} onSelect={(v) => update('education', v)} />
          <DropdownField label="Profession" value={form.occupation} options={PROFESSIONS} onSelect={(v) => update('occupation', v)} />
          <DropdownField label="Annual Income" value={form.income} options={INCOME_RANGES} onSelect={(v) => update('income', v)} />
          <DropdownField label="State" value={form.state} options={INDIAN_STATES} onSelect={(v) => { update('state', v); update('city', ''); }} />
          <DropdownField label="City" value={form.city} options={cities.length > 0 ? cities : ['Other']} onSelect={(v) => update('city', v)} />
        </View>

        {/* About */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>About You</Text>
          <Text style={styles.label}>About Yourself</Text>
          <TextInput style={styles.textArea} value={form.about} onChangeText={(v) => update('about', v)} multiline numberOfLines={4} placeholder="Tell us about yourself..." placeholderTextColor={COLORS.textSecondary} />
          <Text style={styles.label}>Family Details</Text>
          <TextInput style={styles.textArea} value={form.familyDetails} onChangeText={(v) => update('familyDetails', v)} multiline numberOfLines={3} placeholder="Family background details..." placeholderTextColor={COLORS.textSecondary} />
        </View>

        {/* Partner Preferences */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Partner Preferences</Text>
          <View style={styles.row}>
            <Field label="Min Age" value={pp.ageMin} onChange={(v) => setPP((p: any) => ({ ...p, ageMin: v }))} keyboardType="numeric" />
            <Field label="Max Age" value={pp.ageMax} onChange={(v) => setPP((p: any) => ({ ...p, ageMax: v }))} keyboardType="numeric" />
          </View>
          <Text style={styles.label}>Preferred Religions</Text>
          <View style={styles.chipContainer}>
            {RELIGIONS.map((r) => (
              <TouchableOpacity key={r} style={[styles.chip, pp.religions.includes(r) && styles.chipActive]} onPress={() => togglePPReligion(r)}>
                <Text style={[styles.chipText, pp.religions.includes(r) && styles.chipTextActive]}>{r}</Text>
              </TouchableOpacity>
            ))}
          </View>
          <DropdownField label="Preferred Caste" value={pp.caste} options={[...new Set(Object.values(CASTES).flat())]} onSelect={(v) => setPP((p: any) => ({ ...p, caste: v }))} />
          <DropdownField label="Preferred State" value={pp.state} options={INDIAN_STATES} onSelect={(v) => setPP((p: any) => ({ ...p, state: v }))} />
          <Field label="Preferred Locations (comma separated)" value={pp.locations} onChange={(v) => setPP((p: any) => ({ ...p, locations: v }))} placeholder="Mumbai, Delhi, Pune" />
          <Field label="Preferred Professions" value={pp.professions} onChange={(v) => setPP((p: any) => ({ ...p, professions: v }))} placeholder="Engineer, Doctor" />
        </View>

        {/* Save */}
        <View style={styles.btnRow}>
          <TouchableOpacity testID="save-profile-btn" style={[styles.saveBtn, loading && { opacity: 0.6 }]} onPress={handleSave} disabled={loading}>
            <Ionicons name="save" size={20} color="#fff" />
            <Text style={styles.saveBtnText}>{loading ? ' Saving...' : ' Save Profile'}</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.cancelBtn} onPress={() => router.back()}>
            <Text style={styles.cancelBtnText}>Cancel</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

function Field({ label, value, onChange, placeholder, keyboardType }: any) {
  return (
    <View style={styles.fieldContainer}>
      <Text style={styles.label}>{label}</Text>
      <TextInput style={styles.input} value={value} onChangeText={onChange} placeholder={placeholder || `Enter ${label.toLowerCase()}`} keyboardType={keyboardType || 'default'} placeholderTextColor={COLORS.textSecondary} />
    </View>
  );
}

function DropdownField({ label, value, options, onSelect }: any) {
  const [visible, setVisible] = useState(false);
  return (
    <View style={styles.fieldHalf}>
      <Text style={styles.label}>{label}</Text>
      <TouchableOpacity style={styles.selectInput} onPress={() => setVisible(true)}>
        <Text style={value ? styles.selectText : styles.selectPlaceholder} numberOfLines={1}>{value || `Select`}</Text>
        <Ionicons name="chevron-down" size={16} color={COLORS.textSecondary} />
      </TouchableOpacity>
      <Modal visible={visible} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>{label}</Text>
              <TouchableOpacity onPress={() => setVisible(false)}><Ionicons name="close" size={24} color={COLORS.text} /></TouchableOpacity>
            </View>
            <FlatList
              data={options}
              keyExtractor={(item: string) => item}
              renderItem={({ item }: { item: string }) => (
                <TouchableOpacity style={[styles.modalItem, item === value && styles.modalItemActive]} onPress={() => { onSelect(item); setVisible(false); }}>
                  <Text style={[styles.modalItemText, item === value && styles.modalItemTextActive]}>{item}</Text>
                  {item === value && <Ionicons name="checkmark" size={20} color={COLORS.primary} />}
                </TouchableOpacity>
              )}
            />
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FFF8E7' },
  content: { padding: SPACING.md, paddingBottom: 120 },
  section: { backgroundColor: '#fff', borderRadius: 12, padding: SPACING.lg, marginBottom: SPACING.md, borderWidth: 1, borderColor: '#E8DCC8' },
  sectionTitle: { fontSize: FONTS.sizes.large, fontWeight: '700', color: '#8B0000', marginBottom: SPACING.md },
  row: { flexDirection: 'row', gap: SPACING.md },
  fieldContainer: { marginBottom: SPACING.md },
  fieldHalf: { flex: 1, marginBottom: SPACING.md },
  label: { fontSize: FONTS.sizes.small, fontWeight: '600', color: COLORS.text, marginBottom: 4 },
  input: { backgroundColor: '#FFFDF5', borderRadius: 8, padding: SPACING.sm, fontSize: FONTS.sizes.medium, color: COLORS.text, borderWidth: 1, borderColor: '#E8DCC8', height: 44 },
  disabledInput: { backgroundColor: '#f0ece4', borderRadius: 8, padding: SPACING.sm, borderWidth: 1, borderColor: '#E8DCC8', height: 44, justifyContent: 'center' },
  disabledText: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary },
  textArea: { backgroundColor: '#FFFDF5', borderRadius: 8, padding: SPACING.md, fontSize: FONTS.sizes.medium, color: COLORS.text, borderWidth: 1, borderColor: '#E8DCC8', minHeight: 80, textAlignVertical: 'top' },
  selectInput: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', backgroundColor: '#FFFDF5', borderRadius: 8, paddingHorizontal: SPACING.sm, borderWidth: 1, borderColor: '#E8DCC8', height: 44 },
  selectText: { fontSize: FONTS.sizes.medium, color: COLORS.text, flex: 1 },
  selectPlaceholder: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary },
  photoUpload: { backgroundColor: '#FFF0F0', borderRadius: 12, padding: SPACING.xl, alignItems: 'center', borderWidth: 2, borderStyle: 'dashed', borderColor: COLORS.primary },
  photoUploadText: { fontSize: FONTS.sizes.medium, color: COLORS.primary, fontWeight: '600', marginTop: SPACING.sm },
  photoUploadSub: { fontSize: FONTS.sizes.small, color: COLORS.textSecondary, marginTop: 4 },
  visibilityRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: SPACING.md, paddingTop: SPACING.md, borderTopWidth: 1, borderTopColor: '#f0ece4' },
  visibilityInfo: { flex: 1, marginRight: SPACING.md },
  visibilityLabel: { fontSize: FONTS.sizes.medium, fontWeight: '600', color: COLORS.text },
  visibilityHint: { fontSize: FONTS.sizes.small, color: COLORS.textSecondary, marginTop: 2 },
  chipContainer: { flexDirection: 'row', flexWrap: 'wrap', gap: SPACING.xs, marginBottom: SPACING.md },
  chip: { paddingHorizontal: SPACING.md, paddingVertical: SPACING.xs, borderRadius: 20, borderWidth: 1, borderColor: '#E8DCC8', backgroundColor: '#FFFDF5' },
  chipActive: { backgroundColor: '#FFD700', borderColor: '#FFD700' },
  chipText: { fontSize: FONTS.sizes.small, color: COLORS.text },
  chipTextActive: { color: '#333', fontWeight: '600' },
  btnRow: { flexDirection: 'row', gap: SPACING.md, marginTop: SPACING.lg },
  saveBtn: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', backgroundColor: '#8B0000', paddingVertical: SPACING.md, borderRadius: 12 },
  saveBtnText: { fontSize: FONTS.sizes.large, fontWeight: '600', color: '#fff' },
  cancelBtn: { flex: 1, backgroundColor: '#fff', paddingVertical: SPACING.md, borderRadius: 12, alignItems: 'center', borderWidth: 1, borderColor: COLORS.border },
  cancelBtnText: { fontSize: FONTS.sizes.large, fontWeight: '600', color: COLORS.text },
  // Modal
  modalOverlay: { flex: 1, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'flex-end' },
  modalContent: { backgroundColor: '#fff', borderTopLeftRadius: 20, borderTopRightRadius: 20, maxHeight: '70%' },
  modalHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: SPACING.lg, borderBottomWidth: 1, borderBottomColor: '#f0f0f0' },
  modalTitle: { fontSize: FONTS.sizes.large, fontWeight: '700', color: COLORS.text },
  modalItem: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: SPACING.md, borderBottomWidth: 1, borderBottomColor: '#f5f5f5' },
  modalItemActive: { backgroundColor: '#FFF0F0' },
  modalItemText: { fontSize: FONTS.sizes.medium, color: COLORS.text },
  modalItemTextActive: { color: '#8B0000', fontWeight: '600' },
});

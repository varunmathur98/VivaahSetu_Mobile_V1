import React, { useEffect, useState, useRef } from 'react';
import {
  View, Text, StyleSheet, FlatList, TextInput, TouchableOpacity,
  KeyboardAvoidingView, Platform, ActivityIndicator, Alert,
} from 'react-native';
import { useLocalSearchParams, router } from 'expo-router';
import { useAuthStore } from '../src/stores/authStore';
import { COLORS, SPACING, FONTS } from '../src/constants/theme';
import { Ionicons } from '@expo/vector-icons';
import api from '../src/config/api';
import storage from '../src/utils/storage';

export default function ChatScreen() {
  const { partnerId, partnerName } = useLocalSearchParams<{ partnerId: string; partnerName: string }>();
  const { user } = useAuthStore();
  const [messages, setMessages] = useState<any[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [wsConnected, setWsConnected] = useState(false);
  const wsRef = useRef<WebSocket | null>(null);
  const flatListRef = useRef<FlatList>(null);

  useEffect(() => {
    loadMessages();
    connectWebSocket();
    return () => { wsRef.current?.close(); };
  }, []);

  const loadMessages = async () => {
    try {
      const res = await api.get(`/chat/${partnerId}`);
      setMessages(res.data.messages || []);
    } catch (error: any) {
      if (error.response?.status === 403) {
        Alert.alert('Upgrade Required', 'Chat requires Focus or Commit plan', [
          { text: 'Upgrade', onPress: () => router.push('/subscription') },
          { text: 'Cancel', onPress: () => router.back() },
        ]);
      }
    } finally { setLoading(false); }
  };

  const connectWebSocket = async () => {
    try {
      const token = await storage.getItem('auth_token');
      if (!token) return;
      const backendUrl = process.env.EXPO_PUBLIC_BACKEND_URL || '';
      const wsUrl = backendUrl.replace('https://', 'wss://').replace('http://', 'ws://') + `/ws/chat/${token}`;
      const ws = new WebSocket(wsUrl);
      wsRef.current = ws;

      ws.onopen = () => {
        setWsConnected(true);
        // Mark messages as read
        ws.send(JSON.stringify({ action: 'mark_read', partnerId }));
      };
      ws.onmessage = (event) => {
        const data = JSON.parse(event.data);
        if (data.type === 'new_message') {
          const msg = data.message;
          if (msg.senderId === partnerId || msg.senderId === user?.id) {
            setMessages((prev) => [...prev, msg]);
            setTimeout(() => flatListRef.current?.scrollToEnd(), 100);
          }
        }
      };
      ws.onerror = () => setWsConnected(false);
      ws.onclose = () => setWsConnected(false);
    } catch (e) { console.log('WebSocket connect failed:', e); }
  };

  const sendMessage = async () => {
    if (!input.trim()) return;
    const content = input.trim();
    setInput('');

    // Try WebSocket first
    if (wsRef.current && wsConnected) {
      wsRef.current.send(JSON.stringify({ action: 'send_message', receiverId: partnerId, content }));
    } else {
      // Fallback to REST
      try {
        setSending(true);
        await api.post('/chat/send', { receiverId: partnerId, content });
        loadMessages();
      } catch (error: any) {
        Alert.alert('Error', error.response?.data?.detail || 'Failed to send');
        setInput(content);
      } finally { setSending(false); }
    }
  };

  const renderMessage = ({ item }: any) => {
    const isMe = item.senderId === user?.id;
    return (
      <View style={[styles.messageBubble, isMe ? styles.myMessage : styles.theirMessage]}>
        <Text style={[styles.messageText, isMe && styles.myMessageText]}>{item.content}</Text>
        <Text style={[styles.messageTime, isMe && styles.myMessageTime]}>
          {new Date(item.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          {isMe && item.read && <Text> ✓✓</Text>}
        </Text>
      </View>
    );
  };

  if (loading) return <View style={styles.center}><ActivityIndicator size="large" color={COLORS.primary} /></View>;

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={styles.container} keyboardVerticalOffset={90}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={24} color={COLORS.text} />
        </TouchableOpacity>
        <View style={styles.headerInfo}>
          <Text style={styles.headerName}>{partnerName || 'Chat'}</Text>
          <Text style={styles.headerStatus}>{wsConnected ? 'Online' : 'Connecting...'}</Text>
        </View>
        <View style={[styles.statusDot, wsConnected && styles.statusDotOnline]} />
      </View>

      {/* Messages */}
      <FlatList
        ref={flatListRef}
        data={messages}
        renderItem={renderMessage}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.messagesList}
        onContentSizeChange={() => flatListRef.current?.scrollToEnd()}
        ListEmptyComponent={
          <View style={styles.emptyChat}>
            <Ionicons name="chatbubble-ellipses-outline" size={48} color={COLORS.textSecondary} />
            <Text style={styles.emptyChatText}>Start a conversation!</Text>
          </View>
        }
      />

      {/* Input */}
      <View style={styles.inputContainer}>
        <TextInput
          testID="chat-input"
          style={styles.chatInput}
          value={input}
          onChangeText={setInput}
          placeholder="Type a message..."
          placeholderTextColor={COLORS.textSecondary}
          multiline
          maxLength={1000}
        />
        <TouchableOpacity testID="send-btn" style={[styles.sendBtn, !input.trim() && { opacity: 0.4 }]} onPress={sendMessage} disabled={!input.trim() || sending}>
          {sending ? <ActivityIndicator color="#fff" size="small" /> : <Ionicons name="send" size={20} color="#fff" />}
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FFF8E7' },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#fff', padding: SPACING.md, paddingTop: 50, borderBottomWidth: 1, borderBottomColor: '#E8DCC8' },
  backBtn: { padding: SPACING.sm },
  headerInfo: { flex: 1, marginLeft: SPACING.md },
  headerName: { fontSize: FONTS.sizes.large, fontWeight: '700', color: '#4A2C0A' },
  headerStatus: { fontSize: FONTS.sizes.small, color: COLORS.textSecondary },
  statusDot: { width: 10, height: 10, borderRadius: 5, backgroundColor: COLORS.textSecondary },
  statusDotOnline: { backgroundColor: COLORS.success },
  messagesList: { padding: SPACING.md, paddingBottom: SPACING.lg },
  messageBubble: { maxWidth: '75%', padding: SPACING.md, borderRadius: 16, marginBottom: SPACING.sm },
  myMessage: { alignSelf: 'flex-end', backgroundColor: '#8B0000', borderBottomRightRadius: 4 },
  theirMessage: { alignSelf: 'flex-start', backgroundColor: '#fff', borderBottomLeftRadius: 4, borderWidth: 1, borderColor: '#E8DCC8' },
  messageText: { fontSize: FONTS.sizes.medium, color: COLORS.text, lineHeight: 20 },
  myMessageText: { color: '#fff' },
  messageTime: { fontSize: 10, color: COLORS.textSecondary, marginTop: 4, textAlign: 'right' },
  myMessageTime: { color: 'rgba(255,255,255,0.7)' },
  emptyChat: { alignItems: 'center', paddingVertical: SPACING.xxl * 2 },
  emptyChatText: { fontSize: FONTS.sizes.medium, color: COLORS.textSecondary, marginTop: SPACING.md },
  inputContainer: { flexDirection: 'row', alignItems: 'flex-end', padding: SPACING.md, backgroundColor: '#fff', borderTopWidth: 1, borderTopColor: '#E8DCC8' },
  chatInput: { flex: 1, backgroundColor: '#FFFDF5', borderRadius: 20, paddingHorizontal: SPACING.lg, paddingVertical: SPACING.sm, fontSize: FONTS.sizes.medium, maxHeight: 100, borderWidth: 1, borderColor: '#E8DCC8', color: COLORS.text },
  sendBtn: { width: 44, height: 44, borderRadius: 22, backgroundColor: '#8B0000', justifyContent: 'center', alignItems: 'center', marginLeft: SPACING.sm },
});

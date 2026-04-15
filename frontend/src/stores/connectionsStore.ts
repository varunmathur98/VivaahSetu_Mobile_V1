import { create } from 'zustand';
import api from '../config/api';

export interface Connection {
  id: string;
  name: string;
  age?: number;
  city?: string;
  occupation?: string;
  photos?: string[];
  connectionId?: string;
  connectedAt?: string;
  expiresAt?: string;
}

interface ConnectionsState {
  connections: Connection[];
  pendingReceived: Connection[];
  pendingSent: Connection[];
  isLoading: boolean;
  count: number;
  max: number;
  fetchConnections: () => Promise<void>;
  sendRequest: (userId: string) => Promise<void>;
  acceptRequest: (userId: string) => Promise<void>;
  rejectRequest: (userId: string) => Promise<void>;
  cancelRequest: (userId: string) => Promise<void>;
  removeConnection: (userId: string) => Promise<void>;
}

export const useConnectionsStore = create<ConnectionsState>((set, get) => ({
  connections: [],
  pendingReceived: [],
  pendingSent: [],
  isLoading: false,
  count: 0,
  max: 5,

  fetchConnections: async () => {
    try {
      set({ isLoading: true });
      const response = await api.get('/connections');
      const { connections, pendingReceived, pendingSent, count, max } = response.data;
      set({
        connections: connections || [],
        pendingReceived: pendingReceived || [],
        pendingSent: pendingSent || [],
        count: count || 0,
        max: max || 5,
        isLoading: false,
      });
    } catch (error) {
      console.error('Fetch connections error:', error);
      set({ isLoading: false });
    }
  },

  sendRequest: async (userId) => {
    await api.post(`/connections/request/${userId}`);
    await get().fetchConnections();
  },

  acceptRequest: async (userId) => {
    await api.post(`/connections/accept/${userId}`);
    await get().fetchConnections();
  },

  rejectRequest: async (userId) => {
    await api.post(`/connections/reject/${userId}`);
    await get().fetchConnections();
  },

  cancelRequest: async (userId) => {
    await api.post(`/connections/cancel/${userId}`);
    await get().fetchConnections();
  },

  removeConnection: async (userId) => {
    await api.post(`/connections/remove/${userId}`);
    await get().fetchConnections();
  },
}));

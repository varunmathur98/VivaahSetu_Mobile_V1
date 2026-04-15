import { create } from 'zustand';
import storage from '../utils/storage';
import api from '../config/api';

interface User {
  id: string;
  email: string;
  name: string;
  photoUrl?: string;
  plan?: string;
  profileComplete?: boolean;
  gender?: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  signInWithEmail: (email: string, password: string) => Promise<void>;
  signUpWithEmail: (email: string, password: string, name: string, gender: string) => Promise<void>;
  signOut: () => Promise<void>;
  loadUser: () => Promise<void>;
  updateUser: (userData: Partial<User>) => void;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  token: null,
  isLoading: true,
  isAuthenticated: false,

  signInWithEmail: async (email: string, password: string) => {
    try {
      set({ isLoading: true });
      const response = await api.post('/auth/login', { email, password });
      const { token, user } = response.data;
      await storage.setItem('auth_token', token);
      await storage.setItem('user_data', JSON.stringify(user));
      set({ user, token, isAuthenticated: true, isLoading: false });
    } catch (error: any) {
      set({ isLoading: false });
      throw error;
    }
  },

  signUpWithEmail: async (email: string, password: string, name: string, gender: string) => {
    try {
      set({ isLoading: true });
      const response = await api.post('/auth/register', { email, password, name, gender });
      const { token, user } = response.data;
      await storage.setItem('auth_token', token);
      await storage.setItem('user_data', JSON.stringify(user));
      set({ user, token, isAuthenticated: true, isLoading: false });
    } catch (error: any) {
      set({ isLoading: false });
      throw error;
    }
  },

  signOut: async () => {
    try {
      await storage.multiRemove(['auth_token', 'user_data']);
      set({ user: null, token: null, isAuthenticated: false });
    } catch (error) {
      console.error('Sign out error:', error);
    }
  },

  loadUser: async () => {
    try {
      const token = await storage.getItem('auth_token');
      const userData = await storage.getItem('user_data');
      if (token && userData) {
        set({ token, user: JSON.parse(userData), isAuthenticated: true, isLoading: false });
      } else {
        set({ isLoading: false });
      }
    } catch (error) {
      console.error('Load user error:', error);
      set({ isLoading: false });
    }
  },

  updateUser: (userData) => {
    const currentUser = get().user;
    if (currentUser) {
      const updatedUser = { ...currentUser, ...userData };
      set({ user: updatedUser });
      storage.setItem('user_data', JSON.stringify(updatedUser));
    }
  },
}));

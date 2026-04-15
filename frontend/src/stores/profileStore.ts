import { create } from 'zustand';
import api from '../config/api';

export interface Profile {
  id: string;
  name: string;
  email: string;
  age?: number;
  gender?: string;
  height?: string;
  religion?: string;
  caste?: string;
  motherTongue?: string;
  city?: string;
  state?: string;
  education?: string;
  occupation?: string;
  income?: string;
  maritalStatus?: string;
  about?: string;
  photos?: string[];
  preferences?: {
    minAge?: number;
    maxAge?: number;
    religion?: string;
    caste?: string;
    education?: string;
    location?: string;
  };
}

interface ProfileState {
  profile: Profile | null;
  isLoading: boolean;
  fetchProfile: () => Promise<void>;
  updateProfile: (data: Partial<Profile>) => Promise<void>;
  uploadPhoto: (photoBase64: string) => Promise<void>;
}

export const useProfileStore = create<ProfileState>((set, get) => ({
  profile: null,
  isLoading: false,

  fetchProfile: async () => {
    try {
      set({ isLoading: true });
      const response = await api.get('/profile/me');
      set({ profile: response.data, isLoading: false });
    } catch (error) {
      console.error('Fetch profile error:', error);
      set({ isLoading: false });
    }
  },

  updateProfile: async (data) => {
    try {
      set({ isLoading: true });
      const response = await api.put('/profile/update', data);
      set({ profile: response.data, isLoading: false });
    } catch (error) {
      console.error('Update profile error:', error);
      set({ isLoading: false });
      throw error;
    }
  },

  uploadPhoto: async (photoBase64) => {
    try {
      const response = await api.post('/profile/upload-photo', {
        photo: photoBase64,
      });
      const currentProfile = get().profile;
      if (currentProfile) {
        set({ 
          profile: { 
            ...currentProfile, 
            photos: response.data.photos 
          } 
        });
      }
    } catch (error) {
      console.error('Upload photo error:', error);
      throw error;
    }
  },
}));
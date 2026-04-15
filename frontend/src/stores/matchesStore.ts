import { create } from 'zustand';
import api from '../config/api';
import { Profile } from './profileStore';

interface MatchFilters {
  minAge?: number;
  maxAge?: number;
  gender?: string;
  religion?: string;
  caste?: string;
  city?: string;
  education?: string;
}

interface MatchesState {
  matches: Profile[];
  filters: MatchFilters;
  isLoading: boolean;
  page: number;
  hasMore: boolean;
  fetchMatches: (reset?: boolean) => Promise<void>;
  updateFilters: (filters: MatchFilters) => void;
}

export const useMatchesStore = create<MatchesState>((set, get) => ({
  matches: [],
  filters: {},
  isLoading: false,
  page: 1,
  hasMore: true,

  fetchMatches: async (reset = false) => {
    try {
      const state = get();
      if (state.isLoading || (!reset && !state.hasMore)) return;

      set({ isLoading: true });
      const page = reset ? 1 : state.page;
      
      const response = await api.get('/matches', {
        params: {
          ...state.filters,
          page,
          limit: 20,
        },
      });

      const newMatches = response.data.matches || [];
      
      set({
        matches: reset ? newMatches : [...state.matches, ...newMatches],
        page: page + 1,
        hasMore: newMatches.length === 20,
        isLoading: false,
      });
    } catch (error) {
      console.error('Fetch matches error:', error);
      set({ isLoading: false });
    }
  },

  updateFilters: (filters) => {
    set({ filters });
  },
}));
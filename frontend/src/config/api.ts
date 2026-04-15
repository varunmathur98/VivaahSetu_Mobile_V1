import axios from 'axios';
import storage from '../utils/storage';

const RAW_API_URL = process.env.EXPO_PUBLIC_BACKEND_URL || 'https://api.vivaahsetu.in';
const API_URL = RAW_API_URL.replace(/\/+$/, '');

export const api = axios.create({
  baseURL: `${API_URL}/api`,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 15000,
});

// Add auth token to requests
api.interceptors.request.use(
  async (config) => {
    const token = await storage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Handle auth errors
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      await storage.multiRemove(['auth_token', 'user_data']);
    }
    return Promise.reject(error);
  }
);

export default api;

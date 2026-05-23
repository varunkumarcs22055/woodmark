import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:8000',
        changeOrigin: true,
      },
      '/social-auth': {
        target: 'http://127.0.0.1:8000',
        changeOrigin: true,
      },
    },
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          const normalizedId = id.replace(/\\/g, '/');
          if (normalizedId.includes('node_modules')) {
            if (
              normalizedId.includes('/node_modules/react/') ||
              normalizedId.includes('/node_modules/react-dom/') ||
              normalizedId.includes('/node_modules/react-router-dom/')
            ) {
              return 'vendor-react';
            }
            if (normalizedId.includes('/node_modules/swiper/')) {
              return 'vendor-swiper';
            }
            if (normalizedId.includes('/node_modules/react-icons/')) {
              return 'vendor-icons';
            }
            return 'vendor';
          }
          if (normalizedId.includes('/pages/admin/')) {
            return 'admin';
          }
          if (normalizedId.includes('/pages/dealer/')) {
            return 'dealer';
          }
          return undefined;
        },
      },
    },
  },
});

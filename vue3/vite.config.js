import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'
const isGitHubPagesBuild = process.env.GITHUB_ACTIONS === 'true'
const publicBase = isGitHubPagesBuild ? '/zhuzhu/' : '/'
const serverPort=8889
// https://vitejs.dev/config/
export default defineConfig({
  base: publicBase,
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  server: {
    port: 8800,
    open: true,
    compress:false,
    proxy: {
      '/api': {
        target: 'http://localhost:'+serverPort,
        changeOrigin: true,
        // rewrite: (path) => path.replace(/^\/api/, '')
      },
      '/files': {
        target: 'http://localhost:'+serverPort,
        changeOrigin: true,
        // rewrite: (path) => path.replace(/^\/file/, '')
      }
    }
  },
  css: {
    preprocessorOptions: {
      scss: {
        silenceDeprecations: ["legacy-js-api"],
        // 移除自动注入，防止循环导入
        api: 'modern-compiler' // 使用新的 Sass API
      }
    }
  },
  // GitHub Pages hosts this repository under /zhuzhu/, so prefix public URLs in Vue templates.
  build: {
    rollupOptions: {
      plugins: isGitHubPagesBuild ? [{
        name: 'github-pages-public-paths',
        generateBundle(_, bundle) {
          for (const output of Object.values(bundle)) {
            if (output.type !== 'chunk') continue
            output.code = output.code
              .replace(/([\"'`])\/(images|media|payment)\//g, '$1/zhuzhu/$2/')
              .replace(/([\"'`])\/favicon\.ico/g, '$1/zhuzhu/favicon.ico')
          }
        }
      }] : []
    }
  },
  // 定义环境变量
  define: {
    'import.meta.env.VITE_APP_BASE_API': JSON.stringify('/api')
  }
}) 

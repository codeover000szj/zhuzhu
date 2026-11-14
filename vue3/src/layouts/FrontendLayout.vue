<template>
  <a-config-provider :theme="portalTheme">
  <a-layout ref="portalRoot" class="frontend-layout">
    <!-- 顶部导航栏 -->
    <Navbar />

    <!-- 主要内容区域 -->
    <a-layout-content class="main-content">
      <div class="content-wrapper" :class="{ 'portal-interior': route.path !== '/home' }">
        <router-view v-slot="{ Component }">
          <Transition name="portal-route" mode="out-in">
            <component :is="Component" :key="route.path" />
          </Transition>
        </router-view>
      </div>
    </a-layout-content>

    <!-- 页脚 -->
    <a-layout-footer class="footer">
      <div class="footer-content">
        <div class="footer-main">
          <div class="footer-identity">
            <router-link
              to="/home"
              class="footer-brand"
            >
              <span>{{ siteConfig.name }}</span><i>印</i>
            </router-link>
            <p class="footer-tagline">
              记录文化记忆 · 连接当代生活
            </p>
            <p class="footer-description">
              从一件作品走近一门技艺，<br>让每一次相遇，都成为传承的开始。
            </p>
          </div>
          <nav
            class="footer-links"
            aria-label="页脚站点导航"
          >
            <h2>走进非遗</h2>
            <router-link to="/heritage">
              作品档案
            </router-link>
            <router-link to="/inheritor">
              传承人物
            </router-link>
            <router-link to="/activity">
              文化活动
            </router-link>
          </nav>
          <nav
            class="footer-links"
            aria-label="页脚学习导航"
          >
            <h2>一起传习</h2>
            <router-link to="/course">
              在线课程
            </router-link>
            <router-link to="/community">
              共学答疑
            </router-link>
            <router-link to="/ai-chat">
              非遗助手
            </router-link>
          </nav>
          <nav
            class="footer-links footer-resources"
            aria-label="非遗参考资源"
          >
            <h2>文化资源</h2>
            <a
              href="https://www.ihchina.cn/"
              target="_blank"
              rel="noopener noreferrer"
            >中国非物质文化遗产网 <span>↗</span></a>
            <a
              href="https://china-feiyi.cctv.cn/"
              target="_blank"
              rel="noopener noreferrer"
            >央视网 · 中国非遗 <span>↗</span></a>
            <span class="footer-resource-note">循着文化的脉络，发现更多精彩。</span>
          </nav>
        </div>
        <div class="footer-bottom">
          <p>{{ siteConfig.copyright.text }}</p>
          <span>保护 · 记录 · 传习 · 共创</span>
        </div>
      </div>
    </a-layout-footer>
  </a-layout>
  </a-config-provider>
</template>

<script setup>
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import { usePortalMotion } from '@/composables/usePortalMotion'
import { usePortalInteractions } from '@/composables/usePortalInteractions'
import '@/styles/portal-theme.css'
import '@/styles/portal-interactions.css'
import '@/styles/portal-surfaces.css'
import Navbar from '@/components/frontend/Navbar.vue'
import siteConfig from '@/config/site'
const route = useRoute()
const portalRoot = ref(null)
usePortalMotion(portalRoot)
usePortalInteractions(portalRoot)
const portalTheme = { token: { colorPrimary: '#a4362a', colorLink: '#8b4b37', borderRadius: 2, colorBorder: '#d9cfbd', fontFamily: '"PingFang SC", "Microsoft YaHei", sans-serif' } }
</script>

<style scoped>
.frontend-layout {
  position: relative;
  min-height: 100svh;
  background: #f5f1e8;
}

.frontend-layout a { text-decoration: none; }
.footer-brand, .footer-links a { text-decoration: none; }

.main-content {
  margin-top: 0;
  min-height: 60vh;
}

.content-wrapper {
  width: 100%;
  margin: 0 auto;
  padding: 0;
}

.footer {
  position: relative;
  padding: 64px 40px 0;
  background: #242626;
  color: #b8b6ad;
  text-align: left;
  border-top: 3px solid #ac302d;
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
}

.footer-main {
  display: grid;
  grid-template-columns: 1.6fr .8fr .8fr 1.3fr;
  gap: 48px;
  padding-bottom: 44px;
}

.footer-brand {
  display: inline-flex;
  align-items: center;
  flex-wrap: wrap;
  max-width: 100%;
  gap: 5px;
  color: #f1ece0;
  font: 30px/1.5 'Songti SC', 'STSong', serif;
  letter-spacing: .15em;
}

.footer-brand span { min-width: 0; color: #c6b28a; overflow-wrap: anywhere; }
.footer-brand i {
  margin-left: 8px;
  padding: 1px 3px;
  border: 1px solid #af5248;
  color: #cf766b;
  font: normal 15px/1.2 'Songti SC', serif;
  letter-spacing: 0;
}

.footer-tagline { margin: 14px 0 10px; font-size: 12px; letter-spacing: .12em; color: #c1b99f; }
.footer-description { margin: 0; font-size: 12px; line-height: 2; color: #8d918b; }
.footer-links { display: flex; flex-direction: column; align-items: flex-start; gap: 12px; }
.footer-links h2 { margin: 7px 0 7px; color: #e2d9c5; font: 17px/1.5 'Songti SC', 'STSong', serif; letter-spacing: .12em; }
.footer-links a { color: #a4aaa3; font-size: 12px; line-height: 1.8; transition: color .2s; }
.footer-links a:hover, .footer-brand:hover { color: #fff; }
.footer-resources a span { padding-left: 12px; color: #b89c6a; }
.footer-resource-note { margin-top: 2px; color: #727d76; font-size: 11px; line-height: 1.8; }
.footer-bottom { display: flex; align-items: center; justify-content: space-between; gap: 20px; padding: 22px 0; border-top: 1px solid #3a403a; font-size: 11px; color: #818b82; }
.footer-bottom p { margin: 0; }
.footer-bottom > span { white-space: nowrap; letter-spacing: .16em; }

/* 响应式设计 */
@media (max-width: 768px) {
  .content-wrapper {
    padding: 0;
  }

  .footer {
    padding: 40px 22px 0;
  }
  .footer-main { grid-template-columns: 1fr 1fr; gap: 30px 24px; padding-bottom: 30px; }
  .footer-identity, .footer-resources { grid-column: 1 / -1; }
  .footer-brand { font-size: 27px; }
  .footer-bottom { align-items: flex-start; flex-direction: column; gap: 10px; font-size: 10px; }
}
</style>

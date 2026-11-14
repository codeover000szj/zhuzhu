<template>
  <header
    class="heritage-header"
    :class="{ 'over-hero': isHome, 'menu-expanded': menuOpen }"
  >
    <div class="masthead">
      <router-link
        to="/home"
        class="site-brand"
        :aria-label="`${siteConfig.name}首页`"
      >
        <span class="brand-seal"><HeritageKnot /></span>
        <span class="brand-title">{{ siteConfig.name }}</span>
      </router-link>
      <div class="header-tools">
        <button
          class="icon-button search-toggle"
          aria-label="搜索作品档案"
          :aria-expanded="searchOpen"
          @click="searchOpen = !searchOpen"
        >
          <SearchOutlined />
        </button>
        <ChineseTimeBar />
        <a-dropdown
          v-if="userStore.isLoggedIn"
          :trigger="['click']"
        >
          <button class="account-button">
            <UserOutlined /><span>{{ userStore.userInfo.username || '个人中心' }}</span><DownOutlined />
          </button>
          <template #overlay>
            <a-menu>
              <a-menu-item key="profile">
                <router-link to="/profile">
                  个人中心
                </router-link>
              </a-menu-item>
              <a-menu-item key="learning">
                <router-link to="/learning">
                  学习中心
                </router-link>
              </a-menu-item>
              <a-menu-item
                v-if="userStore.isTeacher"
                key="workspace"
              >
                <router-link to="/workspace">
                  传承人工作区
                </router-link>
              </a-menu-item>
              <a-menu-item key="orders">
                <router-link to="/orders">
                  我的订单
                </router-link>
              </a-menu-item>
              <a-menu-divider />
              <a-menu-item
                key="logout"
                @click="handleLogout"
              >
                退出登录
              </a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>
        <router-link
          v-else
          to="/auth/login"
          class="account-button"
          aria-label="登录或注册"
        >
          <UserOutlined /><span>登录 / 注册</span>
        </router-link>
        <button
          class="icon-button mobile-toggle"
          :aria-expanded="menuOpen"
          aria-controls="site-navigation"
          :aria-label="menuOpen ? '关闭导航' : '展开导航'"
          @click="menuOpen = !menuOpen"
        >
          <CloseOutlined v-if="menuOpen" /><MenuOutlined v-else />
        </button>
      </div>
    </div>
    <nav
      id="site-navigation"
      class="site-navigation"
      :class="{ 'is-open': menuOpen }"
      aria-label="主导航"
    >
      <router-link
        v-for="link in links"
        :key="link.path"
        :to="link.path"
        class="nav-link"
        :class="{ 'is-current': isCurrent(link.path) }"
        :aria-current="isCurrent(link.path) ? 'page' : undefined"
      >
        <span>{{ link.label }}</span><HeritageKnot class="nav-ornament" />
      </router-link>
    </nav>
    <form
      v-if="searchOpen"
      class="header-search"
      role="search"
      @submit.prevent="searchArchive"
    >
      <label for="archive-search">寻一门技艺，读一段故事</label>
      <div class="search-field">
        <input
          id="archive-search"
          v-model="keyword"
          type="search"
          placeholder="输入作品名称，如苏绣、青花瓷"
          autofocus
        ><button type="submit">
          搜索档案 <ArrowRightOutlined />
        </button>
      </div>
      <button
        class="search-close icon-button"
        type="button"
        aria-label="关闭搜索"
        @click="searchOpen = false"
      >
        <CloseOutlined />
      </button>
    </form>
  </header>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Modal } from 'ant-design-vue'
import { SearchOutlined, UserOutlined, DownOutlined, MenuOutlined, CloseOutlined, ArrowRightOutlined } from '@ant-design/icons-vue'
import HeritageKnot from './HeritageKnot.vue'
import ChineseTimeBar from '@/components/common/ChineseTimeBar.vue'
import { useUserStore } from '@/store/user'
import siteConfig from '@/config/site'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const menuOpen = ref(false)
const searchOpen = ref(false)
const keyword = ref('')
const isHome = computed(() => route.path === '/home')
const links = computed(() => [
  { label: '首页', path: '/home' },
  { label: '作品档案', path: '/heritage' },
  { label: '传承人物', path: '/inheritor' },
  { label: '活动中心', path: '/activity' },
  { label: '在线课堂', path: '/course' },
  { label: '共学答疑', path: '/community' },
  { label: '文创商城', path: '/shop' },
  { label: 'AI 助手', path: '/ai-chat' }
])
const isCurrent = path => route.path === path || (path !== '/home' && route.path.startsWith(`${path}/`))
watch(() => route.fullPath, () => { menuOpen.value = false; searchOpen.value = false })
const searchArchive = () => {
  router.push({ path: '/heritage', query: keyword.value.trim() ? { title: keyword.value.trim() } : {} })
  searchOpen.value = false
}
const handleLogout = () => Modal.confirm({
  title: '确认退出', content: '确定要退出登录吗？', okText: '确定', cancelText: '取消',
  onOk: async () => { await userStore.logout(); router.push('/auth/login') }
})
</script>

<style scoped>
.heritage-header { position: relative; z-index: 30; width: 100%; padding: 0 3.4%; color: #fff; background: #292d29; font-family: 'Songti SC', 'STSong', 'SimSun', serif; }
.heritage-header a { text-decoration: none; }
.site-brand, .nav-link { text-decoration: none; }
.heritage-header.over-hero { position: absolute; top: 0; left: 0; background: linear-gradient(180deg, rgba(13, 21, 19, .65), rgba(13, 21, 19, .18) 75%, transparent); }
.masthead { max-width: 1800px; height: 76px; margin: auto; display: flex; flex-wrap: nowrap; align-items: center; justify-content: space-between; gap: 20px; border-bottom: 1px solid rgba(255,255,255,.22); }
.site-brand { display: flex; align-items: center; gap: 17px; color: inherit; white-space: nowrap; }
.brand-seal { display: grid; place-items: center; width: 48px; height: 48px; flex-shrink: 0; border: 2px solid #bd3026; border-radius: 50%; color: #d94436; }
.brand-seal svg { width: 37px; height: 37px; }
.brand-title { max-width: min(48vw, 560px); overflow-wrap: anywhere; font-size: 18px; letter-spacing: .05em; font-weight: 600; line-height: 1.35; }
.brand-divider { padding: 0 13px; font-weight: 400; }
.brand-subtitle { font-size: 15px; letter-spacing: .04em; }
.header-tools { display: flex; flex: 0 0 auto; flex-wrap: nowrap; align-items: center; gap: 17px; font: 12px/1.5 Arial, 'PingFang SC', sans-serif; white-space: nowrap; }
.icon-button { display: grid; place-items: center; color: inherit; border: 0; background: none; padding: 6px; cursor: pointer; font-size: 20px; }
.account-button { display: flex; align-items: center; gap: 8px; padding: 7px 0 7px 22px; border: 0; border-left: 1px solid rgba(255,255,255,.28); color: inherit; background: none; cursor: pointer; font-size: 12px; }
.account-button span:not(.anticon) { max-width: 110px; overflow: hidden; text-overflow: ellipsis; }
.site-navigation { max-width: 1150px; height: 54px; margin: auto; display: flex; align-items: stretch; justify-content: space-between; gap: 12px; }
.nav-link { position: relative; display: flex; align-items: center; gap: 10px; padding: 0 14px; color: rgba(255,255,255,.95); font-size: 19px; letter-spacing: .12em; white-space: nowrap; transition: color .25s; }
.nav-link:after { content: ''; position: absolute; bottom: 0; left: 14px; right: 23px; height: 3px; transform: scaleX(0); background: #cf3b2f; transition: transform .25s; }
.nav-link:hover:after, .nav-link.is-current:after { transform: scaleX(1); }
.nav-link:hover { color: #e9c994; }
.nav-ornament { width: 10px; height: 10px; color: rgba(255,255,255,.5); }
.mobile-toggle { display: none; }
.header-search { position: absolute; left: 3.4%; right: 3.4%; top: 76px; z-index: 4; padding: 30px 40px; color: #342e28; background: #f6f1e7; border-top: 3px solid #a33127; box-shadow: 0 12px 24px #0002; }
.header-search label { display: block; margin-bottom: 12px; font-size: 18px; letter-spacing: .1em; }
.search-field { display: flex; border-bottom: 1px solid #afa18c; }
.search-field input { flex: 1; min-width: 0; padding: 12px 0; border: 0; outline: none; background: transparent; font: 14px 'PingFang SC', sans-serif; }
.search-field button { display: flex; align-items: center; gap: 20px; border: 0; color: #9c2c24; background: none; cursor: pointer; }
.search-close { position: absolute; right: 16px; top: 16px; }
button:focus-visible, a:focus-visible { outline: 2px solid #d6b77e; outline-offset: 5px; }
@media (max-width: 1180px) {
  .heritage-header { padding: 0 4%; }
  .header-tools { gap: 12px; }
  .site-brand { gap: 11px; }.brand-title { max-width: 46vw; font-size: 15px; letter-spacing: .02em; }.brand-subtitle { font-size: 12px; }.brand-divider { padding: 0 8px; }
  .nav-link { font-size: 17px; padding: 0 8px; gap: 7px; }
}
@media (max-width: 980px) {
  .heritage-header { padding: 0 22px; }
  .masthead { height: 78px; gap: 12px; }.site-brand { gap: 10px; }.brand-seal { width: 40px; height: 40px; }.brand-seal svg { width: 29px; height: 29px; }
  .brand-title { max-width: 43vw; font-size: 13px; letter-spacing: .01em; }.brand-divider { display: none; }.brand-subtitle { display: block; margin-top: 2px; font-size: 10px; font-weight: 400; letter-spacing: .08em; }
  .header-tools { gap: 10px; }.account-button { padding: 4px; border: 0; font-size: 17px; }.account-button span:not(.anticon), .account-button .anticon-down { display: none; }.icon-button { padding: 4px; font-size: 19px; }
  .mobile-toggle { display: grid; }.site-navigation { display: none; }.site-navigation.is-open { display: grid; grid-template-columns: 1fr 1fr; height: auto; gap: 0; padding: 16px 0 20px; }
  .menu-expanded.over-hero { background: #252c28; }.nav-link { height: 56px; padding: 0 18px; justify-content: space-between; font-size: 17px; }.nav-link:after { left: 18px; right: 18px; bottom: 2px; height: 2px; }
  .header-search { left: 0; right: 0; top: 78px; padding: 30px 22px 24px; }.header-search label { font-size: 16px; }.search-field input { font-size: 12px; }.search-field button { gap: 8px; font-size: 12px; }
}
@media (max-width: 680px) {
  .heritage-header { padding: 0 14px; }
  .masthead { height: 66px; gap: 8px; }
  .site-brand { gap: 0; }.brand-title { display: none; }.brand-seal { width: 30px; height: 30px; border-width: 1px; }.brand-seal svg { width: 24px; height: 24px; }
  .header-tools { gap: 6px; }.icon-button, .account-button { padding: 0; font-size: 17px; }.account-button { gap: 0; }
  .header-search { top: 66px; }
}
@media (max-width: 380px) {
  .heritage-header { padding: 0 8px; }.masthead { gap: 3px; }.header-tools { gap: 3px; }.brand-seal { width: 22px; height: 22px; }.brand-seal svg { width: 17px; height: 17px; }.icon-button, .account-button { font-size: 15px; }.chinese-time-bar { gap: 3px; font-size: 8px; }.clock { min-width: 36px; }
}
</style>

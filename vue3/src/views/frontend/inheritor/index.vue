<template>
  <div class="inheritor-list-page">
    <PortalPageHeader
      eyebrow="THE PEOPLE BEHIND THE CRAFT"
      title="人物 · 匠心"
      description="见人，见技，见精神。让我们走近一位位传承人，听他们讲述与手艺相伴的时光。"
      mark="传"
      image="/images/hero-scene-4.jpg"
    />

    <!-- 筛选区域 -->
    <div class="filter-section">
      <a-space
        size="large"
        wrap
      >
        <a-input
          v-model:value="filters.name"
          placeholder="搜索传承人姓名"
          allow-clear
          style="width: 250px"
          @press-enter="handleSearch"
        >
          <template #prefix>
            <i class="fas fa-search" />
          </template>
        </a-input>

        <a-input
          v-model:value="filters.region"
          placeholder="地区"
          allow-clear
          style="width: 180px"
          @press-enter="handleSearch"
        />

        <a-button
          type="primary"
          @click="handleSearch"
        >
          搜索
        </a-button>

        <a-button @click="handleReset">
          重置
        </a-button>
      </a-space>
    </div>

    <div class="people-caption">
      <span>HERITAGE · PORTRAITS</span><h2>把一生的热爱，交给一门手艺</h2><p>这里记录着 {{ total }} 位传承人的技艺与故事</p>
    </div>

    <!-- 传承人列表 -->
    <div class="inheritor-grid">
      <div
        v-for="inheritor in inheritorList"
        :key="inheritor.id"
        class="inheritor-card"
        role="link"
        tabindex="0"
        @click="goToDetail(inheritor.id)"
        @keydown.enter="goToDetail(inheritor.id)"
      >
        <div class="card-avatar">
          <img
            class="avatar-photo"
            :src="getInheritorMedia(inheritor).src"
            :alt="`${inheritor.name || '传承人'}头像`"
            @error="handleAvatarError($event, inheritor)"
          >
        </div>
        
        <div class="card-content">
          <span class="portrait-label">传承人物 / PORTRAIT</span>
          <h3 class="inheritor-name">
            {{ inheritor.name }}
          </h3>
          
          <div
            v-if="inheritor.title"
            class="inheritor-title"
          >
            <i class="fas fa-award" />
            {{ inheritor.title }}
          </div>
          
          <div
            v-if="inheritor.region"
            class="inheritor-region"
          >
            <i class="fas fa-map-marker-alt" />
            {{ inheritor.region }}
          </div>
          
          <div
            v-if="inheritor.bio"
            class="inheritor-bio"
          >
            {{ getShortBio(inheritor.bio) }}
          </div>
          <span class="portrait-link">走近传承人 <i class="fas fa-arrow-right" /></span>
        </div>
      </div>
    </div>

    <!-- 空状态 -->
    <a-empty
      v-if="!loading && inheritorList.length === 0"
      description="暂无传承人信息"
      style="margin-top: 60px;"
    />

    <!-- 加载状态 -->
    <div
      v-if="loading"
      class="loading-container"
    >
      <a-spin size="large" />
    </div>

    <!-- 分页 -->
    <div
      v-if="total > 0"
      class="pagination-container"
    >
      <a-pagination
        v-model:current="currentPage"
        v-model:page-size="pageSize"
        :total="total"
        :show-size-changer="false"
        :show-total="total => `共 ${total} 位传承人`"
        @change="handlePageChange"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { getInheritorPage } from '@/api/InheritorApi';
import { getInheritorMedia, getInheritorFallbackMedia } from '@/config/heritageMedia';
import PortalPageHeader from '@/components/frontend/PortalPageHeader.vue';

const router = useRouter();

// 筛选条件
const filters = reactive({
  name: '',
  region: ''
});

// 传承人列表
const inheritorList = ref([]);
const loading = ref(false);
const currentPage = ref(1);
const pageSize = ref(12);
const total = ref(0);
const handleAvatarError = (event, inheritor) => {
  const image = event.currentTarget;
  image.onerror = null;
  image.src = getInheritorFallbackMedia(inheritor).src;
};

// 获取传承人列表
const fetchInheritors = () => {
  loading.value = true;
  const params = {
    current: currentPage.value,
    size: pageSize.value,
    name: filters.name,
    region: filters.region
  };

  getInheritorPage(params, {
    onSuccess: (res) => {
      inheritorList.value = res.records || [];
      total.value = res.total || 0;
      loading.value = false;
    },
    onError: () => {
      loading.value = false;
    }
  });
};

// 搜索
const handleSearch = () => {
  currentPage.value = 1;
  fetchInheritors();
};

// 重置
const handleReset = () => {
  Object.assign(filters, {
    name: '',
    region: ''
  });
  currentPage.value = 1;
  fetchInheritors();
};

// 分页变化
const handlePageChange = (page) => {
  currentPage.value = page;
  fetchInheritors();
  window.scrollTo({ top: 0, behavior: 'smooth' });
};

// 获取简短简介
const getShortBio = (bio) => {
  if (!bio) return '';
  return bio.length > 80 ? bio.substring(0, 80) + '...' : bio;
};

// 跳转到详情页
const goToDetail = (id) => {
  router.push(`/inheritor/${id}`);
};

// 初始化
onMounted(() => {
  fetchInheritors();
});
</script>

<style scoped>
.inheritor-list-page { min-height: 100vh; background: #f7f4ec; padding-bottom: 65px; }
.filter-section { width: min(1320px,calc(100% - 96px)); margin: 0 auto; border-bottom: 1px solid #d4c9b4; padding: 28px 0; display: flex; justify-content: space-between; }
.filter-section :deep(.ant-space) { width: 100%; }.filter-section :deep(.ant-input-affix-wrapper) { border-radius: 0; border-color: #c9c0ac; background: #fffdf6; height: 39px; }.filter-section :deep(.ant-input) { background: transparent; }.filter-section :deep(.ant-btn) { height: 39px; border-radius: 0; padding-inline: 25px; }.filter-section :deep(.ant-btn-primary) { background: #a43228; border-color: #a43228; }
.people-caption { text-align: center; padding: 46px 24px 35px; }.people-caption>span { color: #a98a62; letter-spacing: .2em; font: 10px Arial,sans-serif; }.people-caption h2 { margin: 15px 0 13px; color: #364238; font: 400 27px/1.6 'Songti SC','SimSun',serif; letter-spacing: .13em; }.people-caption p { color: #9d8e76; font-size: 11px; }
.inheritor-grid { width: min(1320px,calc(100% - 96px)); margin: 0 auto; display: grid; grid-template-columns: repeat(4,minmax(0,1fr)); gap: 35px 26px; }
.inheritor-card { position: relative; background: #fffdf6; border: 1px solid #ddd3c0; cursor: pointer; transition: transform .35s, box-shadow .35s; }.inheritor-card:hover { transform: translateY(-6px); box-shadow: 0 12px 25px #42382112; }.inheritor-card:focus-visible { outline: 2px solid #a43228; outline-offset: 4px; }
.card-avatar { height: 248px; overflow: hidden; margin: 10px 10px 0; background: #e5decf; }.avatar-photo { width: 100%; height: 100%; object-fit: cover; object-position: center 30%; filter: saturate(.72); transition: transform .6s, filter .6s; }.inheritor-card:hover .avatar-photo { transform: scale(1.045); filter: saturate(1); }
.card-content { padding: 24px 22px 22px; }.portrait-label { color: #b19b7c; font: 8px Arial,sans-serif; letter-spacing: .12em; }.inheritor-name { color: #364238; font: 400 25px/1.6 'Songti SC','SimSun',serif; letter-spacing: .15em; margin: 10px 0 9px; }.inheritor-title { font-size: 10px; color: #9d4434; line-height: 1.7; margin-bottom: 9px; }.inheritor-title i { margin-right: 5px; font-size: 10px; }.inheritor-region { color: #a39177; font-size: 10px; }.inheritor-region i { margin-right: 6px; }.inheritor-bio { margin-top: 17px; padding-top: 14px; border-top: 1px solid #e6ddcb; color: #928877; font-size: 11px; line-height: 2; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }.portrait-link { display: flex; align-items: center; justify-content: space-between; color: #82704e; font-size: 10px; margin-top: 22px; }.portrait-link i { font-size: 10px; }
.loading-container { display: flex; justify-content: center; padding: 70px; }.pagination-container { width: min(1320px,calc(100% - 96px)); margin: 42px auto 0; padding-top: 30px; border-top: 1px solid #d4c9b4; display: flex; justify-content: center; }.pagination-container :deep(.ant-pagination-item) { background: transparent; border-radius: 0; }.pagination-container :deep(.ant-pagination-item-active) { background: #a43228; border-color: #a43228; }.pagination-container :deep(.ant-pagination-item-active a) { color: #fff; }
@media(max-width:1050px) { .inheritor-grid { grid-template-columns: repeat(3,minmax(0,1fr)); }.card-avatar { height: 230px; } }
@media(max-width:800px) { .filter-section,.inheritor-grid,.pagination-container { width: calc(100% - 48px); }.inheritor-grid { grid-template-columns: repeat(2,minmax(0,1fr)); gap: 27px 20px; }.card-avatar { height: 260px; }.filter-section :deep(.ant-space) { gap: 12px !important; }.filter-section :deep(.ant-input-affix-wrapper) { max-width: 100%; } }
@media(max-width:540px) { .people-caption { padding: 35px 26px 27px; }.people-caption h2 { font-size: 23px; }.filter-section { padding: 24px 0; }.filter-section :deep(.ant-space-item:nth-child(1)),.filter-section :deep(.ant-space-item:nth-child(2)) { width: calc(50% - 6px); }.filter-section :deep(.ant-input-affix-wrapper) { width: 100% !important; }.filter-section :deep(.ant-btn) { padding-inline: 22px; font-size: 12px; }.inheritor-grid { gap: 23px 14px; }.card-avatar { height: 175px; margin: 7px 7px 0; }.card-content { padding: 17px 13px; }.portrait-label { font-size: 7px; letter-spacing: .05em; }.inheritor-name { font-size: 21px; }.inheritor-title { font-size: 9px; }.inheritor-bio { font-size: 10px; -webkit-line-clamp: 2; }.portrait-link { font-size: 9px; margin-top: 17px; } }
@media(prefers-reduced-motion:reduce) { .inheritor-card,.avatar-photo { transition: none; } }
</style>

<template>
  <div class="inheritor-detail-wrapper">
    <div class="inheritor-detail-page">
      <div
        v-if="loading"
        class="loading-container"
      >
        <a-spin size="large" />
      </div>

      <div
        v-else-if="inheritor"
        class="detail-container"
      >
        <PortalPageHeader
          eyebrow="PERSON · ARTISAN"
          :title="inheritor.name"
          :description="inheritor.title || '以一生守一艺，让古老技艺在当代继续生长。'"
          mark="传"
          :image="inheritorMedia?.src || '/images/hero-scene-4.jpg'"
        >
          <button
            class="back-link"
            @click="goBack"
          >
            <span aria-hidden="true">←</span> 返回人物名录
          </button>
        </PortalPageHeader>
        <!-- 基本信息区域 -->
        <div class="basic-info-section">
          <div class="avatar-column">
            <div class="avatar-wrapper">
              <a-avatar
                v-if="inheritorMedia?.src"
                :src="avatarSrc || inheritorMedia.src"
                :size="180"
                @error="handleAvatarError"
              />
              <a-avatar
                v-else
                :size="180"
                class="default-avatar"
              >
                {{ inheritor.name ? inheritor.name.charAt(0) : '?' }}
              </a-avatar>
            </div>
          </div>

          <div class="info-column">
            <p class="section-kicker">
              THE HANDS THAT KEEP THE CRAFT ALIVE
            </p>
            <h2 class="inheritor-name">
              一门手艺，一生相守
            </h2>
          
            <div class="info-items-container">
              <div
                v-if="inheritor.title"
                class="info-item title-item"
              >
                <i class="fas fa-award" />
                <span class="label">称号：</span>
                <span class="value">{{ inheritor.title }}</span>
              </div>

              <div
                v-if="inheritor.region"
                class="info-item"
              >
                <i class="fas fa-map-marker-alt" />
                <span class="label">地区：</span>
                <span class="value">{{ inheritor.region }}</span>
              </div>

              <div
                v-if="inheritor.createTime"
                class="info-item"
              >
                <i class="fas fa-calendar-alt" />
                <span class="label">入驻时间：</span>
                <span class="value">{{ formatDate(inheritor.createTime) }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 简介区域 -->
        <div
          v-if="inheritor.bio"
          class="bio-section"
        >
          <p class="section-kicker">
            A LIFE IN CRAFT
          </p>
          <h2 class="section-title">
            传承人简介
          </h2>
          <div class="bio-content">
            {{ inheritor.bio }}
          </div>
        </div>

        <!-- 关联作品区域 -->
        <div
          v-if="inheritor.heritageItems && inheritor.heritageItems.length > 0"
          class="works-section"
        >
          <p class="section-kicker">
            SELECTED COLLECTION
          </p>
          <h2 class="section-title">
            代表作品
            <span class="count">({{ inheritor.heritageItems.length }})</span>
          </h2>
        
          <div class="works-grid">
            <div
              v-for="item in inheritor.heritageItems"
              :key="item.id"
              class="work-card"
              role="link"
              tabindex="0"
              @click="goToItemDetail(item.id)"
              @keydown.enter="goToItemDetail(item.id)"
            >
              <div class="work-cover">
                <img
                  v-if="getRelatedItemCover(item)"
                  :src="getRelatedItemCover(item)"
                  :alt="item.title"
                  loading="lazy"
                >
                <span
                  v-else
                  class="work-cover-placeholder"
                >艺</span>
              </div>
              <div class="work-content">
                <h3 class="work-title">
                  {{ item.title }}
                </h3>
              
                <div class="work-meta">
                  <span class="work-category">
                    <i class="fas fa-tag" />
                    {{ item.category }}
                  </span>
                  <span
                    v-if="item.region"
                    class="work-region"
                  >
                    <i class="fas fa-map-marker-alt" />
                    {{ item.region }}
                  </span>
                </div>

                <div
                  v-if="item.summary"
                  class="work-summary"
                >
                  {{ getShortSummary(item.summary) }}
                </div>

                <div class="work-status">
                  <a-tag :color="getStatusColor(item.status)">
                    {{ item.statusName }}
                  </a-tag>
                  <span>查看作品档案 ↗</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div
          v-else
          class="empty-works"
        >
          <i class="fas fa-palette" />
          <p>暂无代表作品</p>
        </div>

        <!-- 返回按钮 -->
        <div class="action-section">
          <a-button
            size="large"
            @click="goBack"
          >
            <i class="fas fa-arrow-left" />
            返回列表
          </a-button>
        </div>
      </div>

      <div
        v-else
        class="empty-inheritor"
      >
        <i class="fas fa-user-slash" />
        <p>传承人信息不存在</p>
        <a-button
          type="primary"
          @click="goBack"
        >
          返回列表
        </a-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { getInheritorById } from '@/api/InheritorApi';
import { withDisplayYear } from '@/utils/dateUtils';
import { getInheritorMedia, getInheritorFallbackMedia, getCourseMedia } from '@/config/heritageMedia';
import PortalPageHeader from '@/components/frontend/PortalPageHeader.vue';

const router = useRouter();
const route = useRoute();

const inheritor = ref(null);
const loading = ref(false);
const avatarSrc = ref('');
const inheritorMedia = computed(() => getInheritorMedia(inheritor.value));

const handleAvatarError = () => {
  avatarSrc.value = getInheritorFallbackMedia(inheritor.value).src;
};

// 格式化日期
const formatDate = (dateStr) => {
  if (!dateStr) return '-';
  const date = withDisplayYear(dateStr);
  if (!date) return '-';
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
};

// 获取简短摘要
const getShortSummary = (summary) => {
  if (!summary) return '';
  return summary.length > 100 ? summary.substring(0, 100) + '...' : summary;
};

const relatedItemCovers = {
  曲艺: '/files/bussiness/heritage_item/cover_2026_001_suzhou_pingtan.jpg',
  民俗: '/files/bussiness/heritage_item/2026_folk_dragon_boat.jpg',
  手工艺: '/files/bussiness/heritage_item/2026_craft_suzhou_embroidery.jpg',
  戏曲: '/files/bussiness/heritage_item/2026_opera_kunqu.jpg',
  舞蹈: '/files/bussiness/heritage_item/2026_dance_miao_festival.jpg',
  饮食: '/files/bussiness/heritage_item/2026_food_lanzhou_beef_noodles.jpg',
  医药: '/files/bussiness/heritage_item/2026_medicine_acupuncture_chart.jpg',
  建筑: '/files/bussiness/heritage_item/2026_architecture_zhaoxing_drum_tower.jpg',
  音乐: '/files/bussiness/heritage_item/2026_music_guqin.jpg',
  文学: '/files/bussiness/heritage_item/2026_literature_miao_musicians.jpg'
};

// 优先使用接口封面；旧数据缺少封面关联时，按作品类别复用本地档案图片。
const getRelatedItemCover = (item) => item?.coverImage || relatedItemCovers[item?.category] || getCourseMedia(item?.title).cover;

// 获取状态颜色（使用新中式配色）
const getStatusColor = (status) => {
  const colorMap = {
    0: 'default',  // 草稿
    1: 'warning',  // 待审
    2: '',         // 已发布 - 使用默认样式
    3: 'error'     // 下架
  };
  return colorMap[status] || 'default';
};

// 跳转到作品详情
const goToItemDetail = (itemId) => {
  router.push(`/heritage/${itemId}`);
};

// 返回列表
const goBack = () => {
  router.push('/inheritor');
};

// 获取传承人详情
const fetchInheritorDetail = () => {
  const inheritorId = route.params.id;
  if (!inheritorId) {
    router.push('/inheritor');
    return;
  }

  loading.value = true;
  getInheritorById(inheritorId, {
    onSuccess: (res) => {
      inheritor.value = res;
      avatarSrc.value = '';
      loading.value = false;
    },
    onError: () => {
      loading.value = false;
    }
  });
};

// 初始化
onMounted(() => {
  fetchInheritorDetail();
});

watch(() => route.params.id, () => {
  if (route.path.startsWith('/inheritor/')) fetchInheritorDetail();
});
</script>

<style scoped>
.inheritor-detail-wrapper { min-height: 70vh; background: #f6f2e9; color: #41483b; }
.inheritor-detail-page { padding-bottom: 70px; }
.back-link { border: 1px solid #b7a58b80; padding: 11px 18px; color: #ece1c8; background: transparent; letter-spacing: 2px; font-size: 12px; cursor: pointer; }
.back-link span { margin-right: 9px; }
.back-link:hover { color: #fff9ec; border-color: #ece1c8; }
.basic-info-section, .bio-section, .works-section, .empty-works, .action-section { max-width: 1200px; width: calc(100% - 96px); margin-left: auto; margin-right: auto; }
.basic-info-section { display: grid; grid-template-columns: 240px 1fr; gap: 70px; padding: 60px 0; border-bottom: 1px solid #dbd1be; align-items: center; }
.avatar-column { position: relative; }
.avatar-column::after { content: '匠心 · 传承'; position: absolute; bottom: 25px; right: -18px; padding: 16px 9px; background: #a43b32; color: #fff6e4; writing-mode: vertical-rl; font: 15px 'Songti SC', 'SimSun', serif; letter-spacing: 5px; }
.avatar-wrapper { padding: 9px; border: 1px solid #cbbc9e; position: relative; }
.avatar-wrapper :deep(.ant-avatar) { display: flex; width: 100% !important; height: 270px !important; border-radius: 0; background: #e7decc; }
.avatar-wrapper :deep(.ant-avatar img) { object-fit: cover; }
.default-avatar { align-items: center; justify-content: center; font: 80px 'Songti SC', serif; color: #a08b65; }
.section-kicker { margin: 0 0 18px; font-size: 10px; color: #a43b32; letter-spacing: 3px; }
.inheritor-name { margin: 0 0 30px; font: 500 clamp(26px, 3.2vw, 40px)/1.5 'Songti SC', 'STSong', 'SimSun', serif; color: #2f4737; letter-spacing: 4px; }
.info-items-container { display: flex; flex-direction: column; gap: 16px; }
.info-item { display: flex; align-items: baseline; font-size: 13px; color: #756d5c; line-height: 1.8; }
.info-item i { width: 20px; margin-right: 8px; color: #a49479; font-size: 12px; }
.info-item .label { color: #a49479; margin-right: 12px; white-space: nowrap; }
.title-item { padding-bottom: 17px; border-bottom: 1px solid #dfd6c5; }
.title-item .value { color: #a43b32; }
.bio-section, .works-section { padding-top: 50px; }
.section-title { display: flex; align-items: baseline; gap: 14px; margin: 0 0 30px; font: 500 32px/1.5 'Songti SC', 'STSong', 'SimSun', serif; letter-spacing: 4px; color: #2f4737; }
.section-title::after { content: ''; height: 1px; background: #dbd1be; flex: 1; align-self: center; margin-left: 15px; }
.section-title .count { font-size: 15px; color: #aa9b82; letter-spacing: 1px; }
.bio-content { padding: 35px 45px; font-size: 15px; line-height: 2.4; white-space: pre-wrap; text-align: justify; color: #797263; background: #fffdf74d; border: 1px solid #e3d9c7; border-left: 3px solid #a43b32; }
.works-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 25px; }
.work-card { background: #fffdf7; border: 1px solid #e2d8c6; cursor: pointer; overflow: hidden; transition: transform .35s, box-shadow .35s; }
.work-card:hover, .work-card:focus-visible { transform: translateY(-5px); box-shadow: 0 16px 32px #463b2612; }
.work-card:focus-visible { outline: 2px solid #a43b32; outline-offset: 4px; }
.work-cover { height: 220px; margin: 9px 9px 0; overflow: hidden; background: #eae0cd; }
.work-cover img { width: 100%; height: 100%; object-fit: cover; transition: transform .65s; }
.work-card:hover img { transform: scale(1.04); }
.work-cover-placeholder { height: 100%; display: grid; place-items: center; font: 80px 'Songti SC', serif; color: #c3b28f; }
.work-content { padding: 23px; }
.work-title { margin: 0 0 14px; font: 500 24px/1.5 'Songti SC', 'STSong', 'SimSun', serif; color: #354b3b; letter-spacing: 2px; }
.work-meta { display: flex; flex-wrap: wrap; gap: 15px; color: #a39780; font-size: 11px; }
.work-meta i { font-size: 10px; margin-right: 3px; }
.work-category { color: #a43b32; }
.work-summary { margin: 17px 0; color: #8f8674; font-size: 13px; line-height: 1.9; }
.work-status { display: flex; justify-content: space-between; gap: 6px; margin-top: 20px; padding-top: 15px; border-top: 1px solid #e9e0cf; font-size: 11px; color: #a43b32; }
.work-status :deep(.ant-tag) { padding: 0; border: 0; background: transparent; color: #a99c84; font-size: 11px; }
.action-section { padding-top: 35px; margin-top: 50px; border-top: 1px solid #dcd1bd; text-align: center; }
.action-section :deep(.ant-btn), .empty-inheritor :deep(.ant-btn) { padding: 12px 28px; height: auto; background: #a43b32; border: 1px solid #a43b32; border-radius: 0; color: #fff5e5; font-size: 13px; letter-spacing: 2px; }
.action-section i { margin-right: 10px; }
.loading-container { min-height: 400px; display: grid; place-items: center; }
.empty-inheritor { text-align: center; padding: 100px 24px; }
.empty-inheritor i { font-size: 50px; color: #b7a78a; margin-bottom: 20px; }
.empty-inheritor p { font: 27px 'Songti SC', serif; color: #89795e; }
.empty-works { text-align: center; padding: 60px 20px; margin-top: 50px; border: 1px dashed #d5c6a9; color: #aa9a7d; }
.empty-works i { font-size: 35px; margin-bottom: 17px; }
.empty-works p { margin: 0; font-size: 14px; letter-spacing: 2px; }
@media (max-width: 1000px) {
  .basic-info-section { gap: 45px; grid-template-columns: 200px 1fr; }
  .avatar-wrapper :deep(.ant-avatar) { height: 235px !important; }
  .works-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 650px) {
  .basic-info-section, .bio-section, .works-section, .empty-works, .action-section { width: calc(100% - 48px); }
  .basic-info-section { grid-template-columns: 110px 1fr; gap: 24px; padding: 35px 0; align-items: start; }
  .avatar-wrapper { padding: 5px; }
  .avatar-wrapper :deep(.ant-avatar) { height: 145px !important; }
  .avatar-column::after { font-size: 10px; padding: 8px 4px; right: -10px; bottom: 15px; letter-spacing: 2px; }
  .inheritor-name { font-size: 24px; letter-spacing: 1px; margin-bottom: 17px; }
  .section-kicker { font-size: 8px; letter-spacing: 1.5px; line-height: 1.8; margin-bottom: 12px; }
  .info-item { font-size: 11px; flex-wrap: wrap; }
  .info-item i { width: 14px; margin-right: 3px; }
  .info-item .label { margin-right: 3px; }
  .info-items-container { gap: 10px; }
  .section-title { font-size: 26px; }
  .bio-content { padding: 22px; font-size: 14px; line-height: 2.2; }
  .works-grid { gap: 12px; }
  .work-cover { height: 155px; margin: 5px 5px 0; }
  .work-content { padding: 15px 12px; }
  .work-title { font-size: 20px; letter-spacing: 1px; }
  .work-summary { font-size: 11px; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
  .work-status { font-size: 10px; }
  .work-status :deep(.ant-tag) { display: none; }
}
@media (prefers-reduced-motion: reduce) { .work-card, .work-cover img { transition: none; } }
</style>

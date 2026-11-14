<template>
  <section class="portal-page-header">
    <div class="portal-header-image"><img :src="image" alt="" /></div>
    <div class="portal-header-grid"></div>
    <div class="portal-header-inner">
      <nav class="portal-breadcrumb" aria-label="当前位置"><router-link to="/home">首页</router-link><span>/</span><span>{{ title }}</span></nav>
      <div class="portal-header-copy"><p class="portal-header-eyebrow">{{ eyebrow }}</p><h1><HeritageKnot />{{ title }}<span v-if="mark" class="portal-header-seal" aria-hidden="true">{{ mark }}</span></h1><p class="portal-header-description">{{ description }}</p><div v-if="$slots.default" class="portal-header-actions"><slot /></div></div>
      <span class="portal-header-vertical">记录文化记忆 · 连接当代生活</span>
      <div class="portal-header-caption"><HeritageKnot /><span>保护 · 记录 · 传习 · 共创</span><i></i></div>
    </div>
  </section>
</template>
<script setup>
import HeritageKnot from './HeritageKnot.vue'
defineProps({
  eyebrow: { type: String, default: 'INTANGIBLE CULTURAL HERITAGE' },
  title: { type: String, required: true },
  description: { type: String, default: '' },
  mark: { type: String, default: '' },
  image: { type: String, default: '/images/portal-textile.jpg' }
})
</script>
<style scoped>
.portal-page-header { position: relative; min-height: 310px; overflow: hidden; color: #f6f1e4; background: #263a32; isolation: isolate; }
.portal-header-image { position: absolute; inset: 0 0 0 36%; z-index: -3; }
.portal-header-image img { width: 100%; height: 100%; object-fit: cover; object-position: center 49%; opacity: .66; }
.portal-page-header:before { content: ''; position: absolute; inset: 0; z-index: -2; background: linear-gradient(90deg,#26362e 15%,#26362ef0 34%,#26362e55 72%,#26362e65),linear-gradient(0deg,#12241f66,transparent); }
.portal-header-grid { position: absolute; inset: 0; z-index: -1; opacity: .16; background-image: repeating-linear-gradient(90deg,#fff1 0 1px,transparent 1px 4px),repeating-linear-gradient(0deg,#0002 0 1px,transparent 1px 4px); }
.portal-header-inner { position: relative; width: min(1280px,calc(100% - 96px)); margin: auto; padding: 21px 0 36px; }
.portal-breadcrumb { display: flex; gap: 13px; color: #e5dac391; font: 10px/1.8 'PingFang SC',sans-serif; letter-spacing: .08em; }.portal-breadcrumb a { color: #e9e0cfbd; }.portal-breadcrumb a:hover { color: #fff; }
.portal-header-copy { padding: 30px 0 22px; position: relative; }.portal-header-eyebrow { color: #c3ac83; font: 10px/1.8 Arial,sans-serif; letter-spacing: .22em; margin-bottom: 10px; }.portal-header-copy h1 { display: flex; align-items: center; gap: 19px; color: #f8f2e5; margin: 0 0 18px; font: 400 40px/1.5 'Songti SC','STSong','SimSun',serif; letter-spacing: .16em; }.portal-header-copy h1>svg { width: 21px; height: 21px; color: #d5c29f; }.portal-header-seal { display: inline-block; padding: 6px 4px; border: 1px solid #cf5847; color: #e19980; font: 12px 'Songti SC',serif; writing-mode: vertical-rl; letter-spacing: .18em; }
.portal-header-description { margin: 0; max-width: 640px; color: #e3e4d9b0; font: 12px/2 'PingFang SC',sans-serif; letter-spacing: .08em; }.portal-header-actions { margin-top: 20px; max-width: 580px; }.portal-header-vertical { position: absolute; top: 52px; right: 0; writing-mode: vertical-rl; font: 10px/1.8 'Songti SC',serif; letter-spacing: .26em; color: #e6dcc8a1; }
.portal-header-caption { display: flex; align-items: center; gap: 14px; max-width: 390px; margin-top: 6px; color: #c4b69c; font-size: 9px; letter-spacing: .15em; }.portal-header-caption svg { width: 13px; height: 13px; }.portal-header-caption i { width: 83px; height: 1px; background: #b7a58b59; }
.portal-page-header:after { content:''; position:absolute; bottom:0; left:0; right:0; height:1px; pointer-events:none; background:linear-gradient(90deg,transparent,#ddc28c91 22%,#ddc28c30 70%,transparent); }
.portal-header-image img { transition:filter .9s ease; }
.portal-header-caption i { transform-origin:left center; }
@media(hover:hover) and (pointer:fine) { .portal-page-header:hover .portal-header-image img { filter:saturate(1.12) brightness(1.04); }.portal-header-seal { transition:border-color .4s,color .4s,box-shadow .4s; }.portal-page-header:hover .portal-header-seal { border-color:#e88b70; color:#ffc0a6; box-shadow:0 0 18px #bc62402b; } }
@media(max-width:760px) { .portal-page-header { min-height: 280px; }.portal-header-inner { width: calc(100% - 44px); padding: 20px 0 30px; }.portal-header-image { left: 10%; }.portal-page-header:before { background: linear-gradient(90deg,#26362ee8,#26362e85); }.portal-header-copy { padding-top: 28px; padding-bottom: 22px; }.portal-header-eyebrow { font-size: 8px; letter-spacing: .12em; }.portal-header-copy h1 { gap: 12px; font-size: 30px; }.portal-header-copy h1>svg { width: 17px; height: 17px; }.portal-header-seal { font-size: 10px; }.portal-header-description { max-width: calc(100% - 27px); font-size: 10px; }.portal-header-vertical { top: 65px; font-size: 8px; }.portal-header-actions { max-width: 100%; }.portal-header-caption { font-size: 8px; } }
@media(prefers-reduced-motion:no-preference) { .portal-header-copy { animation: portal-copy-in .7s ease both; }.portal-header-image img { animation:portal-image-in 1.4s cubic-bezier(.2,.65,.3,1) both; }.portal-header-caption i { animation:portal-line-in 1.1s .15s cubic-bezier(.2,.65,.3,1) both; }@keyframes portal-copy-in { from { opacity:0; transform:translateY(9px); } to { opacity:1; transform:none; } }@keyframes portal-image-in { from { transform:scale(1.05); } to { transform:scale(1); } }@keyframes portal-line-in { from { transform:scaleX(0); } to { transform:scaleX(1); } } }
</style>

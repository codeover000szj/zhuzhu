<template>
  <Navbar />
  <main class="auth-layout">
    <section class="auth-story" :aria-label="`${siteConfig.name}文化影像`">
      <router-link to="/home" class="auth-brand"><HeritageKnot /><span>{{ siteConfig.name }}<small>数字档案与传习平台</small></span></router-link>
      <div class="story-copy"><span class="eyebrow">THE LIVING HERITAGE</span><h2>一门手艺<br />一生光阴</h2><p>让每一次相遇成为传承的开始。<br />在这里，记录文化记忆，连接当代生活。</p><router-link to="/home">返回首页 <span>↗</span></router-link></div>
      <span class="story-coordinate">保护 · 记录 · 传习 · 共创</span>
    </section>
    <section class="auth-panel">
      <div class="auth-container">
        <div class="auth-heading"><span class="eyebrow">WELCOME TO THE HERITAGE COMMUNITY</span><p>{{ siteDescription }}</p></div>
        <div class="auth-content">
          <router-view v-slot="{ Component }">
            <Transition name="auth-form-change" mode="out-in">
              <component :is="Component" :key="route.path" />
            </Transition>
          </router-view>
        </div>
        <div class="auth-footer"><HeritageKnot /><p>{{ siteConfig.copyright.text }}</p><router-link to="/home">先去浏览作品档案 ↗</router-link></div>
      </div>
    </section>
  </main>
</template>

<script setup>
import siteConfig from '@/config/site'
import HeritageKnot from '@/components/frontend/HeritageKnot.vue'
import Navbar from '@/components/frontend/Navbar.vue'
import { useRoute } from 'vue-router'
const route = useRoute()
const siteDescription = siteConfig.description
</script>

<style scoped>
.auth-layout { min-height: calc(100svh - 130px); display: grid; grid-template-columns: 1.08fr 1fr; background: #f6f2e9; color: #343b32; }
.auth-layout a { text-decoration: none; }
.auth-brand, .auth-footer a, .story-copy a { text-decoration: none; }
.auth-story,.auth-panel,.auth-container { min-width: 0; }.auth-heading,.auth-footer { overflow-wrap: anywhere; }
.auth-story { min-height: calc(100svh - 130px); position: relative; display: flex; flex-direction: column; padding: 45px 9%; overflow: hidden; color: #fff; background: linear-gradient(180deg,#10271d77,#15282033 40%,#11251be8),url('/images/hero-scene-3.jpg') 45% center/cover; }
.auth-story:after { content: ''; position: absolute; inset: 20px; border: 1px solid #ffffff36; pointer-events: none; }
.auth-brand { display: flex; gap: 16px; align-items: center; max-width: 100%; color: #fff; font: clamp(13px, 2.1vw, 24px) 'Songti SC',serif; letter-spacing: .06em; line-height: 1.4; overflow-wrap: anywhere; z-index: 1; }
.auth-brand > span { min-width: 0; }
.auth-brand svg { width: 45px; height: 45px; color: #dd6652; }
.auth-brand small { display: block; margin-top: 7px; font-size: 10px; letter-spacing: .15em; color: #e7dec8; }
.story-copy { margin-top: auto; padding: 120px 0 60px; position: relative; z-index: 1; }.eyebrow { font: 9px/1.8 Arial,sans-serif; letter-spacing: .2em; color: #b8a281; }.story-copy .eyebrow { color: #e0c597; }
.story-copy h2 { font: 400 clamp(46px,5vw,72px)/1.6 'Songti SC',serif; letter-spacing: .14em; color: #fff; margin: 25px 0; }.story-copy p { font-size: 12px; line-height: 2.2; letter-spacing: .08em; color: #e9e4d4; }
.story-copy a { display: flex; align-items: center; justify-content: space-between; max-width: 210px; margin-top: 35px; padding-bottom: 13px; border-bottom: 1px solid #c5b38b88; color: #e9e0cb; font: 12px 'Songti SC',serif; letter-spacing: .1em; }.story-coordinate { font-size: 9px; letter-spacing: .2em; color: #ded5c0; }
.auth-panel { display: flex; align-items: center; justify-content: center; padding: 65px 9%; background: linear-gradient(#f6f2e9e0,#f6f2e9f0),url('/images/heritage-detail.jpg') center/cover; }.auth-container { width: 100%; max-width: 420px; }.auth-heading { border-top: 1px solid #cbbba1; padding-top: 25px; margin-bottom: 42px; }.auth-heading p { color: #8d806b; font: 15px 'Songti SC',serif; letter-spacing: .12em; margin-top: 12px; }
.auth-content :deep(.auth-form) { background: transparent; }.auth-content :deep(h2), .auth-content :deep(.auth-title) { color: #344334; font-family: 'Songti SC',serif; font-weight: 400; letter-spacing: .14em; }.auth-content :deep(.ant-input-affix-wrapper) { background: #fffcf5; border-color: #d5c9b4; border-radius: 0; min-height: 48px; }.auth-content :deep(.ant-input) { background: transparent; }.auth-content :deep(.ant-btn-primary) { background: #9d342a; border-color: #9d342a; border-radius: 0; box-shadow: none; letter-spacing: .14em; }.auth-content :deep(.ant-btn-primary:hover) { background: #792b24; border-color: #792b24; }.auth-content :deep(a) { color: #987148; }
.auth-content :deep(.form-header) { text-align: left; margin-bottom: 28px; }.auth-content :deep(.form-header h2) { font-size: 29px; font-weight: 400; color: #344b38; letter-spacing: .16em; }.auth-content :deep(.input-wrapper input) { height: 50px; background: #fffcf6; border-color: #d7c8ad; border-radius: 0; color: #525d45; font-family: 'PingFang SC',sans-serif; font-size: 12px; }.auth-content :deep(.input-wrapper input:focus) { border-color: #aa8c5e; box-shadow: 0 0 0 2px #ac8b5820; }.auth-content :deep(.input-wrapper input::placeholder) { color: #b1a68e; font-size: 11px; }.auth-content :deep(.input-icon) { color: #a9916d; font-size: 15px; }.auth-content :deep(.submit-btn) { height: 49px; margin-top: 24px; background: #a0392d; border-radius: 0; color: #fff4e1; box-shadow: none; font: 15px 'Songti SC',serif; letter-spacing: .22em; }.auth-content :deep(.submit-btn:hover:not(:disabled)) { background: #832e25; box-shadow: 0 5px 15px #6b372222; transform: none; }.auth-content :deep(.form-links) { border-color: #d9cbb3; margin-top: 25px; padding-top: 15px; text-align: left; }.auth-content :deep(.link-item a) { color: #8e7752; font: 11px 'PingFang SC',sans-serif; }.auth-content :deep(.link-item a:hover) { color: #a13d2d; }.auth-content :deep(.link-item a:after) { background: #a13d2d; }.auth-content :deep(.form-item.has-error input) { border-color: #b2513b; }
.auth-footer { margin-top: 42px; padding-top: 25px; border-top: 1px solid #daceb9; display: flex; flex-wrap: wrap; align-items: center; gap: 10px; }.auth-footer svg { width: 20px; height: 20px; color: #ae8f67; }.auth-footer p { flex: 1; margin: 0; font-size: 9px; color: #a39784; line-height: 1.8; }.auth-footer a { flex-basis: 100%; margin-top: 10px; color: #6e7b60; font-size: 11px; }
.auth-content :deep(.input-wrapper input) { transition:border-color .25s,box-shadow .25s,background-color .25s; }
.auth-content :deep(.input-wrapper:focus-within input) { background:#fffefb; box-shadow:0 0 0 3px #ac8b5817; }
.auth-content :deep(.input-icon) { transition:color .25s; }
.auth-content :deep(.input-wrapper:focus-within .input-icon) { color:#8f6b38; }
.auth-content :deep(.submit-btn) { position:relative; overflow:hidden; isolation:isolate; transition:background-color .25s,box-shadow .25s,transform .2s; }
.auth-content :deep(.submit-btn:after) { content:''; position:absolute; inset:-120% 0; pointer-events:none; background:radial-gradient(ellipse at center,#e7ca8b55,transparent 66%); opacity:0; transform:scale(.6); transition:opacity .35s,transform .4s; }
.auth-content :deep(.submit-btn:not(:disabled):active) { transform:translateY(1px); box-shadow:inset 0 3px 9px #40150f40; }
.auth-content :deep(.submit-btn:not(:disabled):active:after) { opacity:1; transform:scale(1); }
.auth-layout :is(a,button,input):focus-visible,.auth-content :deep(:is(a,button):focus-visible) { outline:2px solid #ae8f67; outline-offset:4px; }
.auth-form-change-enter-active { transition:opacity .25s ease,transform .25s ease; }.auth-form-change-leave-active { transition:opacity .15s ease; }.auth-form-change-enter-from { opacity:0; transform:translateY(7px); }.auth-form-change-leave-to { opacity:0; }
@media(prefers-reduced-motion:no-preference) { .auth-brand,.story-copy,.auth-container { animation:auth-arrival .75s cubic-bezier(.22,.68,.2,1) both; }.story-copy { animation-delay:.08s; }.auth-container { animation-delay:.12s; }@keyframes auth-arrival { from { opacity:.2; transform:translateY(12px); }to { opacity:1; transform:translateY(0); } } }
@media(max-width:980px) { .auth-layout { grid-template-columns: .8fr 1fr; }.auth-story { padding-inline: 10%; }.auth-panel { padding-inline: 10%; }.story-copy h2 { font-size: 45px; } }
@media(max-width:680px) { .auth-layout { grid-template-columns: 1fr; }.auth-story { min-height: 310px; padding: 25px 28px; }.auth-story:after { inset: 12px; }.auth-brand { font-size: 14px; gap: 10px; }.auth-brand svg { width: 34px; height: 34px; }.story-copy { padding: 35px 0 0; }.story-copy h2 { font-size: 31px; margin: 12px 0; line-height: 1.5; }.story-copy h2 br { display: none; }.story-copy p { font-size: 10px; }.story-copy a,.story-coordinate { display: none; }.auth-panel { padding: 35px 28px 42px; }.auth-heading { margin-bottom: 28px; padding-top: 20px; }.auth-heading p { font-size: 13px; }.auth-footer { margin-top: 28px; } }
@media(prefers-reduced-motion:reduce) { *, .auth-content :deep(*) { animation: none !important; transition: none !important; }.auth-content :deep(.submit-btn:not(:disabled):active) { transform:none; } }
</style>

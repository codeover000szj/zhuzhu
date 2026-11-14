<template>
  <section
    v-if="slides.length"
    ref="root"
    class="portal-spotlight"
    role="region"
    aria-roledescription="轮播图"
    :aria-label="label"
    @mouseenter="hovered = true"
    @mouseleave="hovered = false"
    @focusin="focused = true"
    @focusout="onFocusOut"
    @keydown.left.prevent="move(-1)"
    @keydown.right.prevent="move(1)"
    @touchstart.passive="touchStart = $event.changedTouches[0].clientX"
    @touchend.passive="onTouchEnd"
  >
    <div class="spotlight-stage">
      <Transition name="spotlight-image">
        <img
          :key="current.image"
          class="spotlight-art"
          :src="current.image"
          :alt="current.alt || current.title"
          loading="lazy"
        >
      </Transition>
      <span class="spotlight-corner" aria-hidden="true">典藏<br>传习</span>
      <span class="spotlight-image-note">{{ current.meta || '记录文化记忆 · 连接当代生活' }}</span>
    </div>
    <div class="spotlight-panel">
      <div class="spotlight-topline"><span>{{ eyebrow }}</span><span>{{ padded(active + 1) }} / {{ padded(slides.length) }}</span></div>
      <div class="spotlight-copy" :aria-live="paused ? 'polite' : 'off'" aria-atomic="true">
        <Transition name="spotlight-copy" mode="out-in">
          <div :key="current.id || current.title">
            <span class="spotlight-category">{{ current.tag || '文化记忆' }}</span>
            <h3>{{ current.title }}</h3>
            <p>{{ current.description || '在一件作品中，看见技艺的温度；循着文化的脉络，走近传承的故事。' }}</p>
            <router-link :to="current.to" class="spotlight-entry">{{ actionText }}<span aria-hidden="true">↗</span></router-link>
          </div>
        </Transition>
      </div>
      <div class="spotlight-controls">
        <div class="spotlight-dots" aria-label="选择专题">
          <button
            v-for="(slide, index) in slides"
            :key="slide.id || slide.title"
            type="button"
            :class="{ 'is-active': active === index }"
            :aria-label="`查看第${index + 1}项：${slide.title}`"
            :aria-current="active === index ? 'true' : undefined"
            @click="select(index)"
          ><span /></button>
        </div>
        <div class="spotlight-arrows">
          <button v-if="slides.length > 1" type="button" :aria-label="paused ? '开启自动轮播' : '暂停自动轮播'" @click="paused = !paused"><span aria-hidden="true">{{ paused ? '▷' : 'Ⅱ' }}</span></button>
          <button type="button" aria-label="上一个专题" :disabled="slides.length < 2" @click="move(-1)"><span aria-hidden="true">←</span></button>
          <button type="button" aria-label="下一个专题" :disabled="slides.length < 2" @click="move(1)"><span aria-hidden="true">→</span></button>
        </div>
      </div>
      <div class="spotlight-track" aria-hidden="true"><span :style="{ transform: `scaleX(${(active + 1) / slides.length})` }" /></div>
    </div>
  </section>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount } from 'vue'

const props = defineProps({
  slides: { type: Array, default: () => [] },
  label: { type: String, default: '非遗精选专题' },
  eyebrow: { type: String, default: 'CURATED HERITAGE / 本期精选' },
  actionText: { type: String, default: '走进作品档案' }
})
const root = ref(null)
const active = ref(0)
const current = computed(() => props.slides[active.value] || props.slides[0] || {})
const hovered = ref(false)
const focused = ref(false)
const visible = ref(false)
const hidden = ref(false)
const reducedMotion = ref(window.matchMedia('(prefers-reduced-motion: reduce)').matches)
const paused = ref(reducedMotion.value)
let touchStart = 0
let timer, observer, motionQuery
const padded = value => String(value).padStart(2, '0')
const select = index => { active.value = index; schedule() }
const move = direction => select((active.value + direction + props.slides.length) % props.slides.length)
const onFocusOut = event => { focused.value = !!root.value?.contains(event.relatedTarget) }
const onTouchEnd = event => {
  const delta = event.changedTouches[0].clientX - touchStart
  if (Math.abs(delta) > 55 && props.slides.length > 1) { paused.value = true; move(delta > 0 ? -1 : 1) }
}
function schedule() {
  clearTimeout(timer)
  if (paused.value || reducedMotion.value || hovered.value || focused.value || hidden.value || !visible.value || props.slides.length < 2) return
  timer = window.setTimeout(() => move(1), 7500)
}
const updateVisibility = () => { hidden.value = document.hidden }
const updateMotion = event => { reducedMotion.value = event.matches; if (event.matches) paused.value = true }
watch([paused, hovered, focused, visible, hidden, reducedMotion], schedule)
watch(() => props.slides, () => { active.value = 0; schedule() })
watch(root, (element, previous) => { if (previous) observer?.unobserve(previous); if (element) observer?.observe(element) })
onMounted(() => {
  motionQuery = window.matchMedia('(prefers-reduced-motion: reduce)')
  motionQuery.addEventListener('change', updateMotion)
  document.addEventListener('visibilitychange', updateVisibility)
  updateVisibility()
  if ('IntersectionObserver' in window) {
    observer = new IntersectionObserver(entries => { visible.value = entries[0].isIntersecting }, { threshold: .25 })
    if (root.value) observer.observe(root.value)
  } else visible.value = true
})
onBeforeUnmount(() => {
  clearTimeout(timer)
  observer?.disconnect()
  motionQuery?.removeEventListener('change', updateMotion)
  document.removeEventListener('visibilitychange', updateVisibility)
})
</script>

<style scoped>
.portal-spotlight { display:grid; grid-template-columns:1.35fr 1fr; min-width:0; overflow:hidden; background:#26392f; color:#f6efdf; isolation:isolate; }
.spotlight-stage { min-height:440px; position:relative; overflow:hidden; background:#242e28; }
.spotlight-stage:after { content:''; position:absolute; inset:0; pointer-events:none; background:linear-gradient(0deg,#0e211b99,transparent 50%); }
.spotlight-art { position:absolute; inset:0; width:100%; height:100%; object-fit:cover; transition:transform 1.4s cubic-bezier(.2,.65,.2,1); }
.spotlight-corner { position:absolute; top:26px; left:26px; z-index:1; padding:10px 6px; color:#fff6dd; background:#a4392de8; border:1px solid #e0ae7d88; font:17px/1.35 'Songti SC',serif; letter-spacing:.15em; }
.spotlight-image-note { position:absolute; bottom:26px; left:28px; right:28px; z-index:1; color:#eee2cb; font-size:11px; letter-spacing:.12em; }
.spotlight-panel { position:relative; display:flex; min-width:0; flex-direction:column; padding:35px 10% 27px; background:radial-gradient(ellipse at 100% 0,#77845b22,transparent 70%),#26392f; }
.spotlight-topline { display:flex; justify-content:space-between; gap:15px; padding-bottom:22px; border-bottom:1px solid #c5b58940; color:#c5b589; font:9px/1.8 Arial,sans-serif; letter-spacing:.16em; }
.spotlight-copy { flex:1; display:flex; align-items:center; min-height:270px; padding:28px 0; }
.spotlight-copy>div { width:100%; }.spotlight-category { display:inline-block; padding:4px 10px; border:1px solid #b9a17866; color:#d6c297; font:11px 'Songti SC',serif; letter-spacing:.12em; }
.spotlight-copy h3 { margin:18px 0; color:#fff5df; font:400 clamp(24px,2.3vw,34px)/1.65 'Songti SC','STSong',serif; letter-spacing:.1em; text-wrap:balance; }
.spotlight-copy p { display:-webkit-box; -webkit-line-clamp:3; -webkit-box-orient:vertical; overflow:hidden; margin:0; color:#c0c4b1; font:12px/2.1 'PingFang SC',sans-serif; }
.spotlight-entry { display:flex; align-items:center; justify-content:space-between; width:100%; max-width:220px; margin-top:24px; padding:12px 0; border-bottom:1px solid #c8b48680; color:#f3dec0; font:12px 'Songti SC',serif; letter-spacing:.13em; transition:color .25s; }.spotlight-entry span { font-size:21px; transition:transform .3s; }.spotlight-entry:hover { color:#fff; }.spotlight-entry:hover span { transform:translate(3px,-3px); }
.spotlight-controls { display:flex; align-items:center; justify-content:space-between; gap:10px; }.spotlight-dots { display:flex; gap:5px; }.spotlight-dots button { display:grid; place-items:center; width:25px; height:30px; padding:0; border:0; background:transparent; cursor:pointer; }.spotlight-dots span { display:block; width:5px; height:5px; transform:rotate(45deg); border:1px solid #c2ab80; transition:background .25s,transform .25s; }.spotlight-dots .is-active span { background:#e0c39a; transform:rotate(45deg) scale(1.5); }
.spotlight-arrows { display:flex; gap:8px; }.spotlight-arrows button { display:grid; place-items:center; width:34px; height:34px; padding:0; border:1px solid #c6b28b55; border-radius:50%; color:#e3d4b7; background:transparent; font-size:15px; cursor:pointer; transition:color .25s,background .25s,border-color .25s; }.spotlight-arrows button:hover { color:#fff; background:#b4935f44; border-color:#c7ae82; }.spotlight-arrows button:disabled { opacity:.3; cursor:default; }
.spotlight-track { height:1px; margin-top:21px; background:#bfa37830; overflow:hidden; }.spotlight-track span { display:block; width:100%; height:100%; background:#ceb28b; transform-origin:left; transition:transform .65s cubic-bezier(.2,.8,.2,1); }
.portal-spotlight :is(a,button):focus-visible { outline:2px solid #f0d6ab; outline-offset:4px; }
.spotlight-image-enter-active,.spotlight-image-leave-active { transition:opacity .8s,transform 1.2s; }.spotlight-image-enter-from { opacity:0; transform:scale(1.055); }.spotlight-image-leave-to { opacity:0; }.spotlight-copy-enter-active,.spotlight-copy-leave-active { transition:opacity .22s,transform .22s; }.spotlight-copy-enter-from { opacity:0; transform:translateY(10px); }.spotlight-copy-leave-to { opacity:0; transform:translateY(-6px); }
@media(hover:hover) and (pointer:fine) { .portal-spotlight:hover .spotlight-art { transform:scale(1.035); } }
@media(max-width:900px) { .spotlight-panel { padding:25px 7% 22px; }.spotlight-stage { min-height:410px; }.spotlight-copy h3 { font-size:25px; }.spotlight-topline { font-size:8px; letter-spacing:.08em; } }
@media(max-width:600px) { .portal-spotlight { grid-template-columns:1fr; }.spotlight-stage { min-height:245px; }.spotlight-panel { padding:24px; }.spotlight-copy { min-height:0; padding:20px 0; }.spotlight-copy h3 { margin:13px 0; font-size:25px; }.spotlight-copy p { font-size:11px; -webkit-line-clamp:2; }.spotlight-entry { margin-top:14px; }.spotlight-corner { top:18px; left:18px; font-size:14px; }.spotlight-image-note { bottom:18px; left:20px; font-size:10px; }.spotlight-topline { padding-bottom:16px; }.spotlight-track { margin-top:14px; } }
@media(prefers-reduced-motion:reduce) { *,*:before,*:after { animation:none!important; transition:none!important; } }
</style>

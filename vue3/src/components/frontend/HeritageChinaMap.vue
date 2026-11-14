<template>
  <section id="heritage-map" class="heritage-atlas" aria-labelledby="heritage-map-title">
    <header class="atlas-title">
      <span class="atlas-eyebrow">A CULTURAL ATLAS OF CHINA</span>
      <h2 id="heritage-map-title">非物质文化遗产地图</h2>
      <p>山川为卷，匠心为笔。循着一方水土，遇见生生不息的文化。</p>
    </header>

    <div class="atlas-layout">
      <div class="atlas-cartography">
        <div class="china-map" @mouseleave="previewCode = ''">
          <img
            class="china-map-image"
            src="/images/heritage-map/china-map.png"
            alt="中国地图，包含各省级行政区、台湾省、海南省及南海诸岛附图"
            width="891"
            height="641"
            loading="lazy"
            draggable="false"
          >
          <button
            v-for="region in mapData.regions"
            :key="region.code"
            type="button"
            class="map-region"
            :class="{ 'is-selected': selectedCode === region.code, 'is-vertical': region.vertical, 'is-wrap': region.wrap }"
            :style="{ left: `${region.x / 891 * 100}%`, top: `${region.y / 641 * 100}%` }"
            :aria-label="`查看${region.name}非遗统计`"
            :aria-pressed="selectedCode === region.code"
            @mouseenter="previewCode = region.code"
            @focus="previewCode = region.code"
            @blur="previewCode = ''"
            @click="selectRegion(region.code)"
          >{{ region.name }}</button>
          <span class="map-approval">审图号：GS（2019）3443号</span>
        </div>
        <div class="map-toolbar">
          <span><i />悬停浏览 · 点击选择地区</span>
          <label class="region-picker">
            <span class="sr-only">选择地图地区</span>
            <select :value="selectedCode" @change="selectRegion($event.target.value)">
              <option value="">全国</option>
              <option v-for="region in mapData.regions" :key="region.code" :value="region.code">{{ region.name }}</option>
            </select>
          </label>
        </div>
      </div>

      <aside class="atlas-statistics" aria-label="非遗名录统计">
        <div class="statistics-topline">
          <span>文化的经纬 / HERITAGE ATLAS</span>
          <button v-if="selectedCode" type="button" @click="selectRegion('')">返回全国 ↗</button>
        </div>
        <h3>【 {{ currentRegion.name }} 】</h3>
        <div class="statistics-tabs" role="tablist" aria-label="非遗统计类型">
          <button id="map-project-tab" type="button" role="tab" :aria-selected="activeType === 'projects'" aria-controls="map-statistics-panel" :tabindex="activeType === 'projects' ? 0 : -1" @click="activeType = 'projects'" @keydown.right.prevent="switchTab('inheritors', $event)" @keydown.left.prevent="switchTab('inheritors', $event)">国家级代表性项目</button>
          <button id="map-inheritor-tab" type="button" role="tab" :aria-selected="activeType === 'inheritors'" aria-controls="map-statistics-panel" :tabindex="activeType === 'inheritors' ? 0 : -1" @click="activeType = 'inheritors'" @keydown.right.prevent="switchTab('projects', $event)" @keydown.left.prevent="switchTab('projects', $event)">国家级代表性传承人</button>
        </div>
        <div id="map-statistics-panel" role="tabpanel" :aria-labelledby="activeType === 'projects' ? 'map-project-tab' : 'map-inheritor-tab'">
          <Transition name="atlas-numbers" mode="out-in">
            <div :key="`${currentRegion.code}-${activeType}`" class="statistics-mosaic">
              <a
                v-for="(category, index) in mapData.categories"
                :key="category"
                :href="officialCategoryUrl(index)"
                target="_blank"
                rel="noopener noreferrer"
                class="statistic-tile"
                :aria-label="`${currentRegion.name}${category}${values[index]}${unit}，查看中国非遗网名录（新窗口）`"
              >
                <strong>{{ values[index] }}</strong><span>{{ category }}</span><i aria-hidden="true">↗</i>
              </a>
            </div>
          </Transition>
          <p class="statistics-source">说明：据中国非遗网公开名录统计，数据截至 {{ mapData.statisticsAsOf }}；台湾省暂无统计数据。<a :href="mapData.source" target="_blank" rel="noopener noreferrer">查看来源 ↗</a></p>
          <div class="statistics-total">总计：<strong>{{ total }}</strong>{{ unit }}</div>
        </div>
        <router-link class="atlas-archive-link" :to="archiveRoute">{{ selectedCode ? `走进${shortRegionName}的作品档案` : '循着地图，发现非遗作品' }}<span>↗</span></router-link>
      </aside>
    </div>
  </section>
</template>

<script setup>
import { ref, computed } from 'vue'
import mapData from '@/config/heritageMapData.json'

const selectedCode = ref('')
const previewCode = ref('')
const activeType = ref('projects')
const currentRegion = computed(() => mapData.regions.find(region => region.code === (previewCode.value || selectedCode.value)) || mapData.nation)
const values = computed(() => currentRegion.value[activeType.value])
const total = computed(() => values.value.reduce((sum, value) => sum + value, 0))
const unit = computed(() => activeType.value === 'projects' ? '项' : '人')
const selectedRegion = computed(() => mapData.regions.find(region => region.code === selectedCode.value))
const shortRegionName = computed(() => (selectedRegion.value?.name || '').replace(/维吾尔自治区|壮族自治区|回族自治区|自治区|省|市/g, ''))
const archiveRoute = computed(() => ({ path: '/heritage', query: selectedCode.value ? { region: shortRegionName.value } : {} }))

function selectRegion(code) {
  selectedCode.value = code
  previewCode.value = ''
}

function switchTab(type, event) {
  activeType.value = type
  const tabs = event.currentTarget.parentElement.querySelectorAll('[role="tab"]')
  tabs[type === 'projects' ? 0 : 1]?.focus()
}

function officialCategoryUrl(index) {
  const path = activeType.value === 'projects' ? 'project.html' : 'representative.html'
  const query = new URLSearchParams({ tid: String(index + 1) })
  if (currentRegion.value.code) query.set('cid', currentRegion.value.code)
  return `https://www.ihchina.cn/${path}?${query.toString()}`
}
</script>

<style scoped>
.heritage-atlas { position:relative; isolation:isolate; padding:66px 42px 52px; margin-top:68px; color:#fff9e9; background:#3d1511 url('/images/heritage-map/carving-background.jpg') center / cover no-repeat; scroll-margin-top:24px; }
.heritage-atlas::before { content:''; position:absolute; inset:0; z-index:-1; background:linear-gradient(0deg,#210d0999,transparent 45%,#130b0844); pointer-events:none; }
.atlas-title { text-align:center; margin:0 auto 28px; }
.atlas-eyebrow { color:#cbb691; font-size:9px; letter-spacing:.3em; }
.atlas-title h2 { position:relative; display:table; padding:0 42px; margin:11px auto 15px; color:#fff8e9; font:32px/1.5 'Songti SC','STSong','SimSun',serif; letter-spacing:.14em; }
.atlas-title h2::before,.atlas-title h2::after { content:''; position:absolute; top:50%; width:22px; height:32px; background:url('/images/heritage-map/title-ornament.png') no-repeat; transform:translateY(-50%); }
.atlas-title h2::before { left:0; background-position:left; }.atlas-title h2::after { right:0; background-position:right; }
.atlas-title p { margin:0; color:#cbbba5; font:11px/1.8 'PingFang SC',sans-serif; letter-spacing:.16em; }
.atlas-layout { display:grid; grid-template-columns:minmax(0,2.05fr) minmax(330px,1fr); gap:32px; align-items:center; max-width:1440px; margin:auto; }
.atlas-cartography { min-width:0; }
.china-map { position:relative; width:100%; aspect-ratio:891 / 641; container-type:inline-size; }
.china-map-image { display:block; width:100%; height:auto; user-select:none; }
.map-region { position:absolute; z-index:1; padding:2px 3px; border:0; border-radius:1px; background:transparent; color:#fffaf0; font:12px/1.3 'Microsoft YaHei',sans-serif; font-size:1.35cqw; white-space:nowrap; text-shadow:0 1px 3px #130402; cursor:pointer; transition:color .25s,background .25s,box-shadow .25s,transform .25s; }
.map-region.is-vertical { width:1.25em; padding:1px; white-space:normal; line-height:1.2; overflow-wrap:anywhere; }
.map-region.is-wrap { width:5em; white-space:normal; }
.map-region:hover,.map-region:focus-visible,.map-region.is-selected { z-index:3; outline:0; background:#8f3528; box-shadow:0 0 0 1px #dac7a2,0 4px 15px #1b090877; color:#fff4d3; transform:translateY(-2px); }
.map-region:focus-visible { outline:2px solid #fff0be; outline-offset:3px; }
.map-approval { position:absolute; left:10.1%; bottom:15.6%; color:#fff5e6; font:11px/1.4 'Microsoft YaHei',sans-serif; font-size:1.35cqw; white-space:nowrap; }
.map-toolbar { display:flex; align-items:center; justify-content:space-between; gap:12px; padding:16px 0 0; border-top:1px solid #c7aa6c30; color:#d8c6a8; font-size:10px; letter-spacing:.08em; }
.map-toolbar>span { display:flex; align-items:center; gap:8px; }.map-toolbar i { width:5px; height:5px; background:#c7ab72; transform:rotate(45deg); }
.region-picker select { width:160px; border:1px solid #b1986c77; border-radius:0; background:#38251e; color:#f0e1c8; padding:7px 10px; font:11px/1.4 'PingFang SC',sans-serif; cursor:pointer; }
.atlas-statistics { padding:23px 24px 18px; background:#9e8c73; box-shadow:0 10px 45px #16080566; color:#fff9ec; }
.statistics-topline { display:flex; align-items:center; justify-content:space-between; gap:5px; color:#f1e4c9; font:8px/1.4 'PingFang SC',sans-serif; letter-spacing:.1em; min-height:16px; }
.statistics-topline button { background:none; color:#fff9e9; padding:0; border:0; font-size:9px; cursor:pointer; white-space:nowrap; }
.atlas-statistics h3 { margin:16px 0 24px; text-align:center; font:26px/1.4 'Songti SC','STSong',serif; color:#fff9ec; }
.statistics-tabs { display:flex; justify-content:center; gap:18px; border-bottom:1px solid #c1ae91; margin-bottom:9px; }
.statistics-tabs button { position:relative; padding:0 0 15px; border:0; background:transparent; color:#eee3ce; font:12px/1.5 'PingFang SC',sans-serif; cursor:pointer; white-space:nowrap; }
.statistics-tabs button[aria-selected='true'] { color:#fff8e8; }.statistics-tabs button[aria-selected='true']::after { content:''; position:absolute; bottom:0; left:50%; transform:translateX(-50%); border:9px solid transparent; border-bottom-color:#c2ae8c; border-top:0; }
.statistics-mosaic { display:grid; grid-template-columns:repeat(6,minmax(0,1fr)); grid-template-rows:86px 102px 53px 53px; gap:5px; }
.statistic-tile { position:relative; grid-column:span 2; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:4px; padding:8px 5px; background:#b3a087; color:#fffdf5; text-align:center; overflow:hidden; transition:background .25s,color .25s,box-shadow .25s; }
.statistic-tile strong { font:condensed 700 29px/1.05 Impact,'Arial Narrow',sans-serif; letter-spacing:-.04em; font-variant-numeric:tabular-nums; }.statistic-tile>span { font:12px/1.6 'Microsoft YaHei',sans-serif; }
.statistic-tile>i { position:absolute; top:4px; right:5px; color:#fff7dd; font:normal 12px/1 sans-serif; opacity:0; transform:translate(-4px,4px); transition:opacity .25s,transform .25s; }
.statistic-tile:hover,.statistic-tile:focus-visible { background:#c6b08e; color:#fff; box-shadow:inset 0 0 0 1px #e9d4ae; }.statistic-tile:hover>i,.statistic-tile:focus-visible>i { opacity:1; transform:translate(0,0); }
.statistic-tile:nth-child(7),.statistic-tile:nth-child(8) { grid-row:3 / 5; }.statistic-tile:nth-child(9),.statistic-tile:nth-child(10) { grid-column:5 / 7; flex-direction:row; gap:10px; }.statistic-tile:nth-child(9)>span,.statistic-tile:nth-child(10)>span { font-size:11px; }.statistic-tile:nth-child(9) strong,.statistic-tile:nth-child(10) strong { font-size:25px; }
.statistics-source { margin:16px 8px 12px; font:10px/1.8 'PingFang SC',sans-serif; color:#fff9e8; }.statistics-source a { color:#fff4d8; white-space:nowrap; text-decoration:underline; text-underline-offset:3px; margin-left:5px; }
.statistics-total { position:relative; display:table; margin:0 auto 14px; padding:0 35px; font:13px/1.5 'PingFang SC',sans-serif; }.statistics-total strong { display:inline-block; margin:0 12px; font:700 31px/1 Impact,'Arial Narrow',sans-serif; vertical-align:middle; }
.statistics-total::before,.statistics-total::after { content:''; position:absolute; top:4px; width:24px; height:25px; background:url('/images/heritage-map/total-ornament.png') no-repeat; }.statistics-total::before { left:0; background-position:left; }.statistics-total::after { right:0; background-position:right; }
.atlas-archive-link { display:flex; align-items:center; justify-content:space-between; padding:13px 2px 0; border-top:1px solid #d8c3a266; color:#fff8e7; font:11px/1.5 'PingFang SC',sans-serif; letter-spacing:.08em; }.atlas-archive-link span { transition:transform .25s; }.atlas-archive-link:hover { color:#fff; }.atlas-archive-link:hover span { transform:translate(3px,-3px); }
.atlas-statistics :is(a,button):focus-visible,.region-picker select:focus-visible { outline:2px solid #fff2ba; outline-offset:3px; }
.atlas-numbers-enter-active,.atlas-numbers-leave-active { transition:opacity .13s,transform .13s; }.atlas-numbers-enter-from { opacity:0; transform:translateY(5px); }.atlas-numbers-leave-to { opacity:0; transform:translateY(-4px); }
.sr-only { position:absolute; width:1px; height:1px; padding:0; margin:-1px; overflow:hidden; clip:rect(0,0,0,0); white-space:nowrap; border:0; }
@media(min-width:1700px) { .heritage-atlas { padding-block:75px 65px; }.atlas-layout { max-width:1600px; }.atlas-title h2 { font-size:36px; }.atlas-statistics { padding:27px 27px 21px; }.statistics-tabs button { font-size:14px; }.statistics-mosaic { grid-template-rows:94px 111px 58px 58px; }.statistic-tile strong { font-size:34px; }.statistic-tile>span { font-size:14px; }.statistics-source { font-size:11px; } }
@media(max-width:1100px) { .heritage-atlas { padding:52px 32px 42px; }.atlas-layout { gap:22px; grid-template-columns:minmax(0,1.6fr) minmax(300px,1fr); }.atlas-statistics { padding:18px 17px 15px; }.statistics-topline { font-size:7px; }.atlas-statistics h3 { font-size:23px; margin-block:12px 20px; }.statistics-tabs { gap:13px; }.statistics-tabs button { font-size:10px; }.statistics-mosaic { grid-template-rows:74px 86px 47px 47px; }.statistic-tile strong { font-size:25px; }.statistic-tile>span { font-size:10px; }.statistics-source { font-size:9px; margin-inline:2px; }.statistics-total strong { font-size:28px; }.map-toolbar { font-size:9px; }.region-picker select { width:130px; } }
@media(max-width:820px) { .heritage-atlas { padding:44px 28px 35px; margin-top:50px; }.atlas-title h2 { font-size:27px; }.atlas-title p { font-size:10px; letter-spacing:.07em; }.atlas-layout { grid-template-columns:1fr; max-width:650px; gap:28px; }.atlas-statistics { width:min(100%,450px); justify-self:center; padding:23px; }.statistics-tabs button { font-size:12px; }.statistics-mosaic { grid-template-rows:86px 98px 50px 50px; }.statistic-tile>span { font-size:12px; }.statistic-tile strong { font-size:29px; }.statistics-source { font-size:10px; }.statistics-topline { font-size:8px; }.map-toolbar { font-size:10px; }.map-region { font-size:1.35cqw; } }
@media(max-width:480px) { .heritage-atlas { padding:36px 20px 28px; margin-top:40px; }.atlas-title h2 { padding-inline:29px; font-size:23px; letter-spacing:.06em; }.atlas-title h2::before,.atlas-title h2::after { transform:translateY(-50%) scale(.72); }.atlas-eyebrow { font-size:7px; letter-spacing:.2em; }.atlas-title p { font-size:9px; max-width:265px; margin:auto; line-height:1.9; }.atlas-layout { gap:24px; }.map-region { display:none; }.map-approval { font-size:6px; }.map-toolbar { font-size:9px; padding-top:11px; }.map-toolbar>span { max-width:160px; line-height:1.7; }.region-picker select { width:128px; padding:6px 7px; font-size:10px; }.atlas-statistics { padding:18px 15px 15px; }.atlas-statistics h3 { font-size:23px; margin-bottom:20px; }.statistics-tabs { gap:12px; }.statistics-tabs button { font-size:10px; }.statistics-mosaic { grid-template-rows:75px 88px 46px 46px; }.statistic-tile strong { font-size:26px; }.statistic-tile>span { font-size:11px; }.statistic-tile:nth-child(9),.statistic-tile:nth-child(10) { gap:6px; }.statistic-tile:nth-child(9) strong,.statistic-tile:nth-child(10) strong { font-size:23px; }.statistic-tile:nth-child(9)>span,.statistic-tile:nth-child(10)>span { font-size:10px; }.statistics-source { font-size:9px; }.statistics-topline { letter-spacing:.02em; font-size:7px; } }
@media(prefers-reduced-motion:reduce) { .heritage-atlas *, .heritage-atlas *::before,.heritage-atlas *::after { transition:none!important; animation:none!important; } }
</style>

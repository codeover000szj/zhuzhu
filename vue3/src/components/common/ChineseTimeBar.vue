<template>
  <span
    class="chinese-time-bar"
    role="group"
    aria-label="中国日期与时间"
    aria-live="off"
  >
      <span class="date">{{ calendar.gregorianDate }}</span>
      <span>{{ calendar.weekday }}</span>
      <span class="lunar">农历{{ calendar.lunarDate }}</span>
      <span class="solar-term">{{ calendar.solarTerm }}</span>
      <time
        class="clock"
        :datetime="machineDateTime"
        title="北京时间（UTC+8）"
      >{{ calendar.time }}</time>
  </span>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { getChineseCalendarSnapshot } from '@/utils/chineseCalendar'

const now = ref(new Date())
const calendar = computed(() => getChineseCalendarSnapshot(now.value))
const machineDateTime = computed(() => `${calendar.value.gregorianDate}T${calendar.value.time}+08:00`)

let timer
onMounted(() => {
  timer = window.setInterval(() => { now.value = new Date() }, 1000)
})
onUnmounted(() => window.clearInterval(timer))
</script>

<style scoped>
.chinese-time-bar {
  display: inline-flex;
  flex: 0 0 auto;
  align-items: center;
  gap: 12px;
  color: inherit;
  font: 14px/1.5 'Songti SC', 'STSong', 'SimSun', serif;
  white-space: nowrap;
  letter-spacing: .02em;
  font-variant-numeric: tabular-nums;
}

.date { letter-spacing: .02em; }
.clock { min-width: 59px; }

@media (max-width: 1280px) {
  .chinese-time-bar { gap: 8px; font-size: 12px; }
  .clock { min-width: 52px; }
}

@media (max-width: 680px) {
  .chinese-time-bar { gap: 5px; font-size: 10px; letter-spacing: 0; }
  .clock { min-width: 43px; }
}

@media (max-width: 380px) {
  .chinese-time-bar { gap: 3px; font-size: 8px; }
  .clock { min-width: 36px; }
}

</style>

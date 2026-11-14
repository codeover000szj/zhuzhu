import { onBeforeUnmount, onMounted } from 'vue'

const revealSelector = [
  '.portal-intro', '.section-header', '.collection-heading', '.shop-intro',
  '.heritage-item-card', '.item-card', '.inheritor-card', '.inheritor-avatar-card',
  '.course-card', '.activity-card', '.product-card', '.book-spine', '.work-card',
  '.portal-spotlight', '.activity-spotlight', '.summary-strip', '.workspace-stats',
  '.task-record', '.submission-row',
  '.recommend-card', '.discussion-item', '.forum-aside', '.course-record',
  '.work-section', '.order-card', '.section-card', '.bio-section',
  '.archive-grid', '.detail-description', '.related-section'
].join(',')

/** Optional decoration only: content stays visible if a browser lacks animation APIs. */
export function usePortalMotion(rootRef) {
  let root
  let observer
  let mutations
  let motionQuery
  let frame = 0
  const pendingNodes = new Set()
  const seen = new WeakSet()
  const animations = new Set()
  const feedback = new Map()

  const reducedMotion = () => motionQuery?.matches ?? true

  function reveal(entries) {
    entries.forEach(({ target, isIntersecting }) => {
      if (!isIntersecting) return
      observer.unobserve(target)
      if (reducedMotion() || !target.animate) return
      // A small stagger follows each visible row without delaying content access.
      const siblings = target.parentElement?.children
      const index = siblings ? Array.prototype.indexOf.call(siblings, target) : 0
      const animation = target.animate([
        { opacity: 0.45, transform: 'translateY(14px)' },
        { opacity: 1, transform: 'translateY(0)' }
      ], { duration: 620, delay: Math.min(index % 4, 3) * 55, easing: 'cubic-bezier(.2,.65,.25,1)' })
      animations.add(animation)
      animation.onfinish = animation.oncancel = () => animations.delete(animation)
    })
  }

  function observeTree(node) {
    if (!observer || !(node instanceof Element)) return
    const candidates = node.matches(revealSelector) ? [node] : []
    candidates.push(...node.querySelectorAll(revealSelector))
    candidates.forEach(element => {
      if (seen.has(element)) return
      seen.add(element)
      observer.observe(element)
    })
  }

  function unobserveTree(node) {
    if (!observer || !(node instanceof Element) || node.isConnected) return
    const candidates = node.matches(revealSelector) ? [node] : []
    candidates.push(...node.querySelectorAll(revealSelector))
    candidates.forEach(element => {
      observer.unobserve(element)
      seen.delete(element)
    })
  }

  function clearFeedback(layer) {
    clearTimeout(feedback.get(layer))
    feedback.delete(layer)
    layer.remove()
  }

  function showFeedback(event) {
    if (reducedMotion() || !(event.target instanceof Element)) return
    const target = event.target.closest('button, a.ant-btn, [role="button"]')
    if (!target || !root.contains(target) || target.matches(':disabled, [aria-disabled="true"], .ant-btn-loading')) return
    const rect = target.getBoundingClientRect()
    if (!rect.width || !rect.height || rect.width > 640 || rect.height > 160) return
    const diameter = Math.hypot(rect.width, rect.height) * 2
    const x = event.detail ? event.clientX - rect.left : rect.width / 2
    const y = event.detail ? event.clientY - rect.top : rect.height / 2
    const layer = document.createElement('span')
    const ring = document.createElement('span')
    layer.className = 'portal-click-light'
    layer.setAttribute('aria-hidden', 'true')
    Object.assign(layer.style, {
      top: `${rect.top}px`, left: `${rect.left}px`, width: `${rect.width}px`,
      height: `${rect.height}px`, borderRadius: getComputedStyle(target).borderRadius
    })
    ring.className = 'portal-click-ring'
    Object.assign(ring.style, {
      width: `${diameter}px`, height: `${diameter}px`,
      left: `${x - diameter / 2}px`, top: `${y - diameter / 2}px`
    })
    layer.appendChild(ring)
    root.appendChild(layer)
    ring.addEventListener('animationend', () => clearFeedback(layer), { once: true })
    feedback.set(layer, setTimeout(() => clearFeedback(layer), 800))
    if (feedback.size > 6) clearFeedback(feedback.keys().next().value)
  }

  function syncMotionPreference() {
    if (!reducedMotion()) return
    animations.forEach(animation => animation.cancel())
    Array.from(feedback.keys()).forEach(clearFeedback)
  }

  function clearAllFeedback() {
    Array.from(feedback.keys()).forEach(clearFeedback)
  }

  onMounted(() => {
    root = rootRef.value?.$el || rootRef.value
    if (!(root instanceof Element)) return
    motionQuery = window.matchMedia('(prefers-reduced-motion: reduce)')
    motionQuery.addEventListener?.('change', syncMotionPreference)
    root.addEventListener('click', showFeedback, true)
    window.addEventListener('scroll', clearAllFeedback, { capture: true, passive: true })
    if (!window.IntersectionObserver || !window.MutationObserver) return
    observer = new IntersectionObserver(reveal, { threshold: 0.06, rootMargin: '0px 0px -24px 0px' })
    observeTree(root)
    mutations = new MutationObserver(records => {
      records.forEach(record => {
        record.removedNodes.forEach(unobserveTree)
        record.addedNodes.forEach(node => {
          if (node instanceof Element && !node.classList.contains('portal-click-light')) pendingNodes.add(node)
        })
      })
      if (!pendingNodes.size || frame) return
      frame = requestAnimationFrame(() => {
        pendingNodes.forEach(observeTree)
        pendingNodes.clear()
        frame = 0
      })
    })
    mutations.observe(root, { childList: true, subtree: true })
  })

  onBeforeUnmount(() => {
    root?.removeEventListener('click', showFeedback, true)
    window.removeEventListener('scroll', clearAllFeedback, true)
    motionQuery?.removeEventListener?.('change', syncMotionPreference)
    observer?.disconnect()
    mutations?.disconnect()
    cancelAnimationFrame(frame)
    pendingNodes.clear()
    animations.forEach(animation => animation.cancel())
    Array.from(feedback.keys()).forEach(clearFeedback)
  })
}

import { onBeforeUnmount, onMounted } from 'vue'

const cardSelector = [
  '.heritage-item-card', '.inheritor-card', '.course-card', '.activity-card',
  '.product-card', '.work-card', '.recommend-card'
].join(',')

/** One delegated listener, no animation loop at rest and no extra DOM elements. */
export function usePortalInteractions(rootRef) {
  let root
  let motionQuery
  let pointerQuery
  let activeCard
  let frame = 0
  let pointerX = 0
  let pointerY = 0

  function clearCard() {
    cancelAnimationFrame(frame)
    frame = 0
    if (!activeCard) return
    activeCard.classList.remove('portal-edge-active')
    activeCard.style.removeProperty('--portal-glow-x')
    activeCard.style.removeProperty('--portal-glow-y')
    activeCard = undefined
  }

  function clearOnMotionPreference() {
    clearCard()
  }

  function paintLight() {
    frame = 0
    if (!activeCard?.isConnected) {
      clearCard()
      return
    }
    const rect = activeCard.getBoundingClientRect()
    if (!rect.width || !rect.height) {
      clearCard()
      return
    }
    activeCard.style.setProperty('--portal-glow-x', `${Math.round(pointerX - rect.left)}px`)
    activeCard.style.setProperty('--portal-glow-y', `${Math.round(pointerY - rect.top)}px`)
    activeCard.classList.add('portal-edge-active')
  }

  function moveLight(event) {
    if (motionQuery.matches || !pointerQuery.matches || event.pointerType !== 'mouse' || event.buttons) {
      clearCard()
      return
    }
    if (!(event.target instanceof Element)) return
    const card = event.target.closest(cardSelector)
    if (!card || !root.contains(card) || !card.closest('.portal-interior') || card.matches('[aria-disabled="true"]')) {
      clearCard()
      return
    }
    if (card !== activeCard) {
      clearCard()
      activeCard = card
    }
    pointerX = event.clientX
    pointerY = event.clientY
    if (!frame) frame = requestAnimationFrame(paintLight)
  }

  function leaveCard(event) {
    if (!activeCard || (event.relatedTarget instanceof Node && activeCard.contains(event.relatedTarget))) return
    clearCard()
  }

  onMounted(() => {
    root = rootRef.value?.$el || rootRef.value
    if (!(root instanceof Element)) return
    motionQuery = window.matchMedia('(prefers-reduced-motion: reduce)')
    pointerQuery = window.matchMedia('(hover: hover) and (pointer: fine)')
    root.addEventListener('pointermove', moveLight, { passive: true })
    root.addEventListener('pointerout', leaveCard, { passive: true })
    root.addEventListener('pointerleave', clearCard, { passive: true })
    window.addEventListener('blur', clearCard)
    window.addEventListener('scroll', clearCard, { capture: true, passive: true })
    motionQuery.addEventListener?.('change', clearOnMotionPreference)
    pointerQuery.addEventListener?.('change', clearOnMotionPreference)
  })

  onBeforeUnmount(() => {
    clearCard()
    root?.removeEventListener('pointermove', moveLight)
    root?.removeEventListener('pointerout', leaveCard)
    root?.removeEventListener('pointerleave', clearCard)
    window.removeEventListener('blur', clearCard)
    window.removeEventListener('scroll', clearCard, true)
    motionQuery?.removeEventListener?.('change', clearOnMotionPreference)
    pointerQuery?.removeEventListener?.('change', clearOnMotionPreference)
  })
}

import { atom, read, update } from 'claude-code'
import type { Register, Timer } from 'claude-code'

const FRAMES = ['·', '✢', '✳', '✶', '✻', '✽']

const label = atom({ plugin: 'spinner-to-status', key: 'label' } as const, null)

function formatElapsed(ms: number): string {
  const total = Math.floor(ms / 1000)
  const m = Math.floor(total / 60)
  const s = total % 60

  return m > 0 ? `${m}m ${s}s` : `${s}s`
}

function formatClock(ms: number): string {
  const d = new Date(ms)
  const h = d.getHours()
  const min = String(d.getMinutes()).padStart(2, '0')

  return `${h % 12 || 12}:${min} ${h < 12 ? 'AM' : 'PM'}`
}

export const register: Register = on => {
  let timer: Timer | undefined
  let startedAt = 0
  let frame = 0

  on('session.start', async ($, e, next) => {
    // Clean up after an older version that used the status line, or a reload mid-turn.
    $.ui.status(undefined)
    await update($, label, () => null)

    return next(e)
  })

  on('turn.start', async ($, e, next) => {
    if (e.agentId !== undefined) {
      return next(e)
    }

    timer?.cancel()
    startedAt = await $.clock.now()
    frame = 0
    await update($, label, () => `${FRAMES[0]} Working…`)
    timer = $.clock.every(1000, async () => {
      frame = (frame + 1) % FRAMES.length
      const elapsed = (await $.clock.now()) - startedAt
      await update($, label, () => `${FRAMES[frame]} Working… ${formatElapsed(elapsed)}`)
    })

    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    if (e.agentId === undefined) {
      timer?.cancel()
      timer = undefined
      const doneAt = await $.clock.now()
      const verb = e.isAborted ? 'Interrupted after' : 'Worked for'
      await update(
        $,
        label,
        () => `✻ ${verb} ${formatElapsed(e.durationMs)} · done ${formatClock(doneAt)}`,
      )
    }

    return next(e)
  })

  // Show the timer at the right end of the prompt footer, beside the mode labels.
  on('ui.render', { component: 'SessionMode' }, async ($, e, next) => {
    const text = await read($, label)

    return next(text === null ? e : { ...e, props: { ...e.props, modes: [...e.props.modes, text] } })
  })

  // Hide the "Churned for 2m 35s · done 9:28 AM" line in the transcript; ctrl+o still shows it.
  on('ui.render', { component: 'TurnDuration' }, ($, e, next) => {
    if (e.props.isExpanded) {
      return next(e)
    }
    const { Box } = $.ui.resolve(e)

    return <Box />
  })

  // Hide the built-in spinner row above the prompt.
  on('ui.render', { component: 'Spinner' }, ($, e) => {
    const { Box } = $.ui.resolve(e)

    return <Box />
  })
}

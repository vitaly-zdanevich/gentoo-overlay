export type SpinnerLabel = string | null

declare module 'claude-code' {
  interface PluginState {
    'spinner-to-status': { label: SpinnerLabel }
  }
}

import { toast } from 'vue-sonner'

declare global {
  interface Window {
    showError: (message: string, description?: string) => void
    showSuccess: (message: string, description?: string) => void
    showWarning: (message: string, description?: string) => void
  }
}

const toastApi = {
  error: (message: string, description?: string): void => {
    toast.error(message, { description })
  },
  success: (message: string, description?: string): void => {
    toast.success(message, { description })
  },
  warning: (message: string, description?: string): void => {
    toast.warning(message, { description })
  },
}

export function setupToastApi() {
  window.showError = toastApi.error
  window.showSuccess = toastApi.success
  window.showWarning = toastApi.warning
}

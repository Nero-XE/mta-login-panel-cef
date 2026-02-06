import { toast } from 'vue-sonner'

declare global {
  interface Window {
    showInfo: (message: string, description?: string) => void
    showSuccess: (message: string, description?: string) => void
    showError: (message: string, description?: string) => void
    showWarning: (message: string, description?: string) => void
  }
}

const toastApi = {
  info: (message: string, description?: string): void => {
    toast.info(message, { description })
  },
  success: (message: string, description?: string): void => {
    toast.success(message, { description })
  },
  error: (message: string, description?: string): void => {
    toast.error(message, { description })
  },
  warning: (message: string, description?: string): void => {
    toast.warning(message, { description })
  },
}

export function setupToastApi() {
  window.showInfo = toastApi.info
  window.showSuccess = toastApi.success
  window.showError = toastApi.error
  window.showWarning = toastApi.warning
}

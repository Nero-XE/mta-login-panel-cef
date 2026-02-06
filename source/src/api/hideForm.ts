import { ref } from "vue";

declare global {
  interface Window {
    hideForm: () => void
  }
}

const formState = ref<boolean>(true);

function hideForm(): void {
    formState.value = false
}

export { formState }

export function setupHideFormApi() {
  window.hideForm = hideForm
}

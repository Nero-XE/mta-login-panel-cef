import { toast } from 'vue-sonner'

export function createToastApi() {
    function showSuccessToast(message: string, description?: string): void {
        toast.success(message, { description })
    };

    function showInfoToast(message: string, description?: string): void {
        toast.info(message, { description })
    };

    function showWarningToast(message: string, description?: string): void {
        toast.warning(message, { description })
    };

    function showErrorToast(message: string, description?: string): void {
        toast.error(message, { description })
    };

    return {
        showSuccessToast,
        showInfoToast,
        showWarningToast,
        showErrorToast,
    };
};

declare global {
    interface Window {
        toastApi: ReturnType<typeof createToastApi>;
    }
};

import { ref } from "vue";

type SignInFormValues = {
    login: string
    password: string,
    rememberMe: boolean,
}

const isFormVisible = ref<boolean>(true);
const isFormLoading = ref<boolean>(false);
let setValuesFunction: ((fields: SignInFormValues) => void) | null = null;

export function registerSetValues(fn: (fields: SignInFormValues) => void): void {
    setValuesFunction = fn;
};

export function createFormApi() {
    function setSignInFormValues(login: string, password: string): void {
        setValuesFunction?.({
            login,
            password,
            rememberMe: true
        });
    };

    function setLoading(state: boolean): void {
        isFormLoading.value = state;
    }

    function hideForm(): void {
        isFormVisible.value = false;
    };

    return {
        setSignInFormValues,
        setLoading,
        hideForm,
    };
};

export { isFormVisible, isFormLoading }

declare global {
    interface Window {
        formApi: ReturnType<typeof createFormApi>;
    }
}


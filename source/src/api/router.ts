import router from '@/router'

export function createRouterApi() {
    function navigateToSignInPage(): void {
        router.push('/sign-in');
    };

    function navigateToSignUpPage(): void {
        router.push('/sign-up');
    };

    function navigateToVerificationPage(): void {
        router.push('/verification');
    };

    return {
        navigateToSignInPage,
        navigateToSignUpPage,
        navigateToVerificationPage,
    };
};

declare global {
    interface Window {
        routerApi: ReturnType<typeof createRouterApi>;
    }
};

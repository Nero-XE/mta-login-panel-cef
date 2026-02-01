import router from '@/router'

declare global {
  interface Window {
    goToSignInPage: () => void
    goToSignUpPage: () => void
    goToVerificationPage: () => void
  }
}

const routerApi = {
  signInPage: (): void => {
    router.push('/')
  },
  signUpPage: (): void => {
    router.push('/sign-up')
  },
  verificationPage: (): void => {
    router.push('/verification')
  },
}

export function setupRouterApi() {
  window.goToSignInPage = routerApi.signInPage
  window.goToSignUpPage = routerApi.signUpPage
  window.goToVerificationPage = routerApi.verificationPage
}

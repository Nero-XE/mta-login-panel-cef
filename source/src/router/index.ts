import { createRouter, createWebHistory } from 'vue-router'
import SignInView from '@/views/SignInView.vue'
import SignUpView from '@/views/SignUpView.vue'
import VerificationView from '@/views/VerificationView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', component: SignInView },
    { path: '/sign-up', component: SignUpView },
    { path: '/verification', component: VerificationView },
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
})

export default router

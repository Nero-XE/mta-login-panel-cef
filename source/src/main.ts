import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import './styles/global.css'
import { createToastApi } from './api/toast'
import { createRouterApi } from './api/router'
import { createFormApi } from './api/form'

const app = createApp(App)

window.toastApi = createToastApi()
window.routerApi = createRouterApi()
window.formApi = createFormApi()

app.use(router)
app.mount('#app')

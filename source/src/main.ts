import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import './styles/global.css'
import { setupToastApi } from './api/toast'
import { setupRouterApi } from './api/router'

const app = createApp(App)

setupToastApi()
setupRouterApi()

app.use(router)
app.mount('#app')

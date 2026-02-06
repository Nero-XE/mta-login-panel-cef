<script setup lang="ts">
import { useColorMode } from '@vueuse/core'
import { RouterView } from 'vue-router'
import { Toaster } from '@/components/ui/sonner'
import 'vue-sonner/style.css'
import { onMounted } from 'vue'
import { formState, setupHideFormApi } from './api/hideForm'

const mode = useColorMode()
mode.value = 'dark'

onMounted(() => {
    setupHideFormApi()
});
</script>

<template>
  <RouterView v-if="formState" />
  <Toaster position="top-center" theme="dark" rich-colors />
</template>

<script setup lang="ts">
import { useColorMode } from '@vueuse/core'
import { RouterView } from 'vue-router'
import { Toaster } from '@/components/ui/sonner'
import 'vue-sonner/style.css'
import { isFormVisible } from './api/form'

const mode = useColorMode()
mode.value = 'dark'

</script>

<template>
  <RouterView v-if="isFormVisible" />
  <Toaster position="top-center" theme="dark" rich-colors />
</template>

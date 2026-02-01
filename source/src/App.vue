<script setup lang="ts">
import { useColorMode } from '@vueuse/core'
import { RouterView } from 'vue-router'
import { Toaster } from '@/components/ui/sonner'
import 'vue-sonner/style.css'

const mode = useColorMode()
mode.value = 'dark'
</script>

<template>
  <RouterView />
  <Toaster position="top-center" theme="dark" rich-colors />
</template>

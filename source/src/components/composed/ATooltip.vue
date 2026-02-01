<script setup lang="ts">
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'
import type { TooltipContentProps } from 'reka-ui'

interface Props {
  text?: string
  align?: TooltipContentProps['align']
  side?: TooltipContentProps['side']
}

defineProps<Props>()
</script>

<template>
  <TooltipProvider>
    <Tooltip>
      <TooltipTrigger as-child>
        <slot name="trigger"></slot>
      </TooltipTrigger>
      <TooltipContent :align :side>
        <p v-if="text">{{ text }}</p>
        <slot name="content"></slot>
      </TooltipContent>
    </Tooltip>
  </TooltipProvider>
</template>

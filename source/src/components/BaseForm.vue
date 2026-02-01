<script setup lang="ts">
import {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'

interface Props {
  title: string
  description: string
}

defineProps<Props>()
</script>

<template>
  <Card>
    <CardHeader>
      <CardTitle class="text-xl">{{ title }}</CardTitle>
      <CardDescription v-if="description">{{ description }}</CardDescription>
      <CardAction>
        <slot name="action"></slot>
      </CardAction>
    </CardHeader>

    <CardContent>
      <slot name="content"></slot>
    </CardContent>

    <CardFooter>
      <slot name="footer"></slot>
    </CardFooter>
  </Card>
</template>

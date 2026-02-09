<script setup lang="ts">
import { isFormLoading } from '@/api/form';
import {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { Spinner } from '@/components/ui/spinner'

interface Props {
  title: string
  description: string
}

defineProps<Props>()
</script>

<template>
  <Card class="relative overflow-hidden shadow-2xl">
    <div
      v-if="isFormLoading"
      class="absolute top-0 left-0 z-2 flex h-full w-full items-center justify-center bg-black/75"
    >
      <span>
        <Spinner class="center size-8" />
      </span>
    </div>
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

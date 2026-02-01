<script setup lang="ts">
import { Field as VeeField } from 'vee-validate'
import { Field, FieldContent, FieldDescription, FieldLabel } from '@/components/ui/field'
import { Checkbox } from '@/components/ui/checkbox'

interface Props {
  name: string
  label: string
  description?: string
}

defineProps<Props>()
</script>

<template>
  <VeeField v-slot="{ field, value }" :name type="checkbox">
    <Field orientation="horizontal">
      <Checkbox :id="name" v-bind="field" :model-value="value" />
      <FieldContent>
        <FieldLabel :for="name" class="font-normal">{{ label }}</FieldLabel>
        <FieldDescription v-if="description">{{ description }}</FieldDescription>
      </FieldContent>
    </Field>
  </VeeField>
</template>

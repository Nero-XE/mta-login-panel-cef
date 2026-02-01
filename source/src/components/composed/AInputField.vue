<script setup lang="ts">
import { Field, FieldDescription, FieldError, FieldLabel } from '@/components/ui/field'
import { InputGroup, InputGroupAddon, InputGroupInput } from '@/components/ui/input-group'
import { Field as VeeField } from 'vee-validate'

interface Props {
  name: string
  label: string
  placeholder?: string
  type?: HTMLInputElement['type']
  description?: string
}

withDefaults(defineProps<Props>(), {
  type: 'text',
})
</script>

<template>
  <VeeField v-slot="{ field, errors }" :name>
    <Field>
      <FieldLabel :for="name">{{ label }}</FieldLabel>
      <InputGroup>
        <InputGroupAddon>
          <slot name="addon-start"></slot>
        </InputGroupAddon>
        <InputGroupInput
          :id="name"
          v-bind="field"
          :placeholder
          :type
          autocomplete="off"
          :aria-invalid="!!errors.length"
        />
        <InputGroupAddon align="inline-end">
          <slot name="addon-end"></slot>
        </InputGroupAddon>
      </InputGroup>
      <FieldError v-if="!!errors.length" :errors="errors" />
      <FieldDescription v-else-if="description">{{ description }}</FieldDescription>
    </Field>
  </VeeField>
</template>

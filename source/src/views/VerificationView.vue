<script setup lang="ts">
import BaseForm from '@/components/BaseForm.vue'
import { toTypedSchema } from '@vee-validate/zod'
import { useForm } from 'vee-validate'
import * as zod from 'zod'
import { AInputField } from '@/components/composed'
import { Field, FieldGroup } from '@/components/ui/field'
import { Button } from '@/components/ui/button'
import router from '@/router'

const formSchema = toTypedSchema(
  zod.object({
    secretPhrase: zod.string().min(1, 'Кодовая фраза должна быть заполнена'),
  }),
)

const { handleSubmit } = useForm({
  validationSchema: formSchema,
  initialValues: {
    secretPhrase: '',
  },
})

const onSubmit = handleSubmit((data) => {
  mta.triggerEvent('requestCheck2FA', data.secretPhrase);
})
</script>

<template>
  <BaseForm
    title="Введите кодовую фразу"
    description="Обнаружена попытка входа с нового устройства. Для подтверждения введите кодовое слово, указанное при регистрации."
    class="absolute top-1/2 left-1/2 w-md -translate-1/2 transform"
  >
    <template v-slot:content>
      <form @submit="onSubmit" id="verification-form">
        <AInputField name="secretPhrase" label="Кодовая фраза">
          <template v-slot:addon-start>
            <UserRound />
          </template>
        </AInputField>
      </form>
    </template>

    <template v-slot:footer>
      <FieldGroup class="flex flex-row gap-4">
        <Field>
          <Button
            type="reset"
            form="verification-form"
            variant="secondary"
            @click="() => router.push('/')"
          >Отмена</Button>
        </Field>
        <Field>
          <Button type="submit" form="verification-form">Войти</Button>
        </Field>
      </FieldGroup>
    </template>
  </BaseForm>
</template>

<script setup lang="ts">
import { Button } from '@/components/ui/button'
import { Field, FieldDescription, FieldGroup } from '@/components/ui/field'
import { BookKey, BrushCleaning, KeyRound, UserRound } from 'lucide-vue-next'
import { useForm } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import * as zod from 'zod'
import { AInputField } from '@/components/composed'
import BaseForm from '@/components/BaseForm.vue'
import { ATooltip } from '@/components/composed'

const formSchema = toTypedSchema(
  zod.object({
    login: zod
      .string()
      .min(4, 'Логин должен содержать минимум 4 символа')
      .max(30, 'Максимальная длинна логина может составлять 30 символов'),
    password: zod
      .string()
      .min(8, 'Пароль должен содержать минимум 8 символов')
      .max(30, 'Максимальная длинна пароля может составлять 30 символов'),
    secretPhrase: zod
      .string()
      .min(3, 'Кодовая фраза должна содержать минимум 3 символа')
      .max(30, 'Максимальная длинна кодовой фразы может составлять 30 символов'),
  }),
)

const { handleSubmit, resetForm } = useForm({
  validationSchema: formSchema,
  initialValues: {
    login: '',
    password: '',
    secretPhrase: '',
  },
})

const onSubmit = handleSubmit((data) => {
  mta.triggerEvent('requestSignUp', JSON.stringify(data));
})
</script>

<template>
  <BaseForm
    title="Регистрация аккаунта"
    description="Заполните форму ниже, чтобы зарегистрироваться"
    class="absolute top-1/2 left-1/2 w-sm -translate-1/2 transform"
  >
    <template v-slot:action>
      <ATooltip text="Очистить форму" side="bottom">
        <template v-slot:trigger>
          <Button size="icon" variant="secondary" @click="resetForm">
            <BrushCleaning />
          </Button>
        </template>
      </ATooltip>
    </template>

    <template v-slot:content>
      <form @submit="onSubmit" id="sign-in-form">
        <FieldGroup class="gap-4">
          <AInputField
            name="login"
            label="Логин"
            description="Логин должен содержать минимум 4 символа"
          >
            <template v-slot:addon-start>
              <UserRound />
            </template>
          </AInputField>
          <AInputField
            name="password"
            label="Пароль"
            type="password"
            description="Пароль должен содержать минимум 8 символов"
          >
            <template v-slot:addon-start>
              <KeyRound />
            </template>
          </AInputField>
          <AInputField
            name="secretPhrase"
            label="Кодовая фраза"
            description="Кодовое фраза должна содержать минимум 3 символа"
          >
            <template v-slot:addon-start>
              <BookKey />
            </template>
          </AInputField>
        </FieldGroup>
      </form>
    </template>

    <template v-slot:footer>
      <FieldGroup class="gap-4">
        <Field>
          <Button type="submit" form="sign-in-form">Зарегистрироваться</Button>
        </Field>
        <Field class="w-full text-center">
          <FieldDescription>
            Уже есть аккаунт?
            <RouterLink to="/">Войдите!</RouterLink>
          </FieldDescription>
        </Field>
      </FieldGroup>
    </template>
  </BaseForm>
</template>

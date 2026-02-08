<script setup lang="ts">
import { Button } from '@/components/ui/button'
import { Field, FieldDescription, FieldGroup } from '@/components/ui/field'
import { KeyRound, UserRound } from 'lucide-vue-next'
import { useForm } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import * as zod from 'zod'
import { ACheckbox, AInputField } from '@/components/composed'
import BaseForm from '@/components/BaseForm.vue'
import { onMounted } from 'vue'
import { registerSetValues } from '@/api/form'

const formSchema = toTypedSchema(
  zod.object({
    login: zod.string().min(1, 'Логин должен быть заполнен'),
    password: zod.string().min(1, 'Пароль должен быть заполнен'),
    rememberMe: zod.boolean().default(false),
  }),
)

const { handleSubmit, setValues } = useForm({
  validationSchema: formSchema,
  initialValues: {
    login: '',
    password: '',
    rememberMe: false,
  },
})

onMounted(() => { registerSetValues(setValues) })

const onSubmit = handleSubmit((data) => {
  mta.triggerEvent('requestSignIn', JSON.stringify(data))
})
</script>

<template>
  <BaseForm
    title="Добро пожаловать!"
    description="Войдите в аккаунт или зарегистрируйте новый"
    class="absolute top-1/2 left-1/2 w-sm -translate-1/2 transform"
  >
    <template v-slot:content>
      <form @submit="onSubmit" id="sign-in-form">
        <FieldGroup class="gap-4">
          <AInputField name="login" label="Логин">
            <template v-slot:addon-start>
              <UserRound />
            </template>
          </AInputField>
          <AInputField name="password" label="Пароль" type="password">
            <template v-slot:addon-start>
              <KeyRound />
            </template>
          </AInputField>
          <ACheckbox name="rememberMe" label="Запомнить меня" />
        </FieldGroup>
      </form>
    </template>

    <template v-slot:footer>
      <FieldGroup class="gap-4">
        <Field>
          <Button type="submit" form="sign-in-form">Войти</Button>
        </Field>
        <Field class="w-full text-center">
          <FieldDescription>
            Еще нет аккаунта?
            <RouterLink to="/sign-up">Зарегистрируетесь!</RouterLink>
          </FieldDescription>
        </Field>
      </FieldGroup>
    </template>
  </BaseForm>
</template>

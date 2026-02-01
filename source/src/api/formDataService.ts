declare global {
  interface Window {
    setFormValues: (login?: string, password?: string, rememberMe?: boolean) => void
  }
}

let setValuesFn: ((values: { login?: string; password?: string; rememberMe?: boolean }) => void) | null = null

export function setupFormApi(setValues: (values: { login?: string; password?: string; rememberMe?: boolean }) => void) {
  setValuesFn = setValues

  window.setFormValues = (login?: string, password?: string, rememberMe?: boolean) => {
    if (!setValuesFn) return

    const values: { login?: string; password?: string; rememberMe?: boolean } = {}

    if (login !== undefined) values.login = login
    if (password !== undefined) values.password = password
    if (rememberMe !== undefined) values.rememberMe = rememberMe

    setValuesFn(values)
  }
}

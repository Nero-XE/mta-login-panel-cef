/// <reference types="vite/client" />

declare let mta: {
  triggerEvent(event: string): void;
  triggerEvent(event: string, ...args: (string | number | boolean | object)[]): void;
}

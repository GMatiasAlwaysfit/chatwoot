<template>
  <div class="h-auto overflow-auto flex flex-col">
    <woot-modal-header header-title="Observação (opcional)" />
    <form class="w-full" @submit.prevent="onSubmit">
      <div class="w-full">
        <label :class="{ error: $v.observation.$error }">
          Observação de transferência
          <textarea
            v-model.trim="observation"
            rows="5"
            :placeholder="'Insira uma observação (opcional)'"
            @input="$v.observation.$touch"
          />
        </label>
      </div>
      <div class="flex flex-row justify-end gap-2 py-2 px-0 w-full">
        <woot-submit-button
          button-text="Transferir"
          :disabled="$v.observation.$invalid"
        />
        <button class="button clear" @click.prevent="onClose">Cancelar</button>
      </div>
    </form>
  </div>
</template>

<script>
import { minLength } from 'vuelidate/lib/validators';

export default {
  props: {
    currentInbox: {
      type: Object,
      default: () => ({}),
    },
  },
  data() {
    return {
      observation: null,
    };
  },
  validations: {
    observation: {
      minLength: minLength(3),
    },
  },
  methods: {
    onClose() {
      this.$emit('close');
    },
    onSubmit() {
      this.$emit('submit', this.observation);
      this.onClose();
    },
  },
};
</script>

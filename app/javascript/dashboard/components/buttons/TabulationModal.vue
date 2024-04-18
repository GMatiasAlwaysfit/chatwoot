<!-- eslint-disable vue/no-mutating-props -->
<template>
  <div class="h-auto overflow-auto flex flex-col">
    <woot-modal-header header-title="Selecione uma tabulação" />
    <form class="w-full" @submit.prevent="onSubmit">
      <div class="w-full">
        <label>
          Tabulações
          <select v-model="tabulationModel">
            <option
              v-for="tabulation in currentInbox.tabulations"
              :key="tabulation.id"
              :value="tabulation.id"
            >
              {{ tabulation.name }}
            </option>
          </select>
        </label>
      </div>
      <div class="flex flex-row justify-end gap-2 py-2 px-0 w-full">
        <woot-submit-button button-text="Salvar" :disabled="!tabulationModel" />
        <button class="button clear" @click.prevent="onClose">Cancelar</button>
      </div>
    </form>
  </div>
</template>

<script>
export default {
  props: {
    currentInbox: {
      type: Object,
      default: () => ({}),
    },
  },
  data() {
    return {
      tabulationModel: null,
    };
  },
  methods: {
    onClose() {
      this.$emit('close');
    },
    onSubmit() {
      this.$emit('submit', this.tabulationModel);
      this.onClose();
    },
  },
};
</script>

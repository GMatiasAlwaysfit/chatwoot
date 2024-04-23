<template>
  <div>
    <div class="h-auto overflow-auto flex flex-col">
      <woot-modal-header :header-title="'Adicionar tabulação'" />
      <div class="h-auto overflow-auto flex flex-col">
        <form class="flex flex-col w-full" @submit.prevent="addTabulation()">
          <div class="w-full">
            <label :class="{ error: $v.name.$error }">
              Nome
              <input
                v-model.trim="name"
                type="text"
                :placeholder="'Por favor, insira um nome'"
                @input="$v.name.$touch"
              />
            </label>
          </div>

          <div class="w-full">
            <label :class="{ error: $v.description.$error }">
              Descrição
              <input
                v-model.trim="description"
                type="text"
                :placeholder="'Por favor, insira uma descrição'"
                @input="$v.description.$touch"
              />
            </label>
          </div>

          <div class="w-full">
            <label :class="{ error: $v.endPhrase.$error }">
              Frase de encerramento
              <input
                v-model.trim="endPhrase"
                type="text"
                :placeholder="'Por favor, insira uma frase de encerramento'"
                @input="$v.endPhrase.$touch"
              />
            </label>
          </div>

          <div class="w-full">
            <label :class="{ error: $v.tabType.$error }">
              Tipo de tabulação
              <input
                v-model.trim="tabType"
                type="text"
                :placeholder="'Por favor, insira um tipo de tabulação'"
                @input="$v.tabType.$touch"
              />
            </label>
          </div>
          <div class="flex flex-row justify-end gap-2 py-2 px-0 w-full">
            <woot-submit-button
              :disabled="$v.name.$invalid || addTabulations.showLoading"
              :button-text="'Enviar'"
              :loading="addTabulations.showLoading"
            />
            <button class="button clear" @click.prevent="onClose">
              Cancelar
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import { required, minLength } from 'vuelidate/lib/validators';

export default {
  props: {
    onClose: {
      type: Function,
      default: () => {},
    },
  },
  data() {
    return {
      name: '',
      description: '',
      endPhrase: '',
      tabType: '',
      addTabulations: {
        showLoading: false,
        message: '',
      },
    };
  },
  validations: {
    name: {
      required,
      minLength: minLength(3),
    },
    description: {},
    endPhrase: {},
    tabType: {},
  },
  computed: {
    ...mapGetters({
      uiFlags: 'tabulation/getUIFlags',
    }),
  },
  methods: {
    resetForm() {
      this.name = '';
      this.description = '';
      this.endPhrase = '';
      this.tabType = '';
      this.$v.name.$reset();
      this.$v.description.$reset();
      this.$v.endPhrase.$reset();
      this.$v.tabType.$reset();
    },
    async addTabulation() {
      this.addTabulations.showLoading = true;
      try {
        await this.$store.dispatch('tabulation/createTabulation', {
          name: this.name,
          description: this.description,
          end_phrase: this.endPhrase,
          tab_type: this.tabType,
        });
        this.addTabulations.showLoading = false;
        bus.$emit('newToastMessage', 'Tabulação adicionada com sucesso');
        this.resetForm();
        this.$store.dispatch('tabulation/getTabulations');
        this.onClose();
      } catch (error) {
        this.addTabulations.showLoading = false;
        const errorMessage =
          error.message || 'Ocorreu um erro ao criar a tabulação';
        bus.$emit('newToastMessage', errorMessage);
      }
    },
  },
};
</script>

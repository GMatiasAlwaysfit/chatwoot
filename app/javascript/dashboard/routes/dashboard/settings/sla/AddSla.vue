<template>
  <div>
    <div class="h-auto overflow-auto flex flex-col">
      <woot-modal-header :header-title="'Adicionar SLA'" />
      <div class="h-auto overflow-auto flex flex-col">
        <form class="flex flex-col w-full" @submit.prevent="addSla()">
          <div class="w-full">
            <label :class="{ error: $v.name.$error }">
              Nome
              <input
                v-model.trim="name"
                type="text"
                :placeholder="'Por favor, insira um nome.'"
                @input="$v.name.$touch"
              />
            </label>
          </div>

          <div class="w-full">
            <label :class="{ error: $v.alertTime.$error }">
              Tempo de alerta
              <input
                v-model.trim="alertTime"
                type="number"
                :placeholder="'Por favor, insira o tempo de alerta.'"
                @input="$v.alertTime.$touch"
              />
            </label>
          </div>

          <div class="w-full">
            <label :class="{ error: $v.limitTime.$error }">
              Tempo limite
              <input
                v-model.trim="limitTime"
                type="number"
                :placeholder="'Por favor, insira o tempo limite.'"
                @input="$v.limitTime.$touch"
              />
            </label>
          </div>

          <div class="w-full">
            <label :class="{ error: $v.maxTime.$error }">
              Tempo máximo
              <input
                v-model.trim="maxTime"
                type="number"
                :placeholder="'Por favor, insira o tempo maximo.'"
                @input="$v.maxTime.$touch"
              />
            </label>
          </div>
          <div class="flex flex-row justify-end gap-2 py-2 px-0 w-full">
            <woot-submit-button
              :disabled="
                $v.name.$invalid ||
                $v.alertTime.$invalid ||
                $v.limitTime.$invalid ||
                $v.maxTime.$invalid ||
                addSlas.showLoading
              "
              :button-text="'Enviar'"
              :loading="addSlas.showLoading"
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
      alertTime: '',
      limitTime: '',
      maxTime: '',
      addSlas: {
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
    alertTime: {
      required,
    },
    limitTime: {
      required,
    },
    maxTime: {
      required,
    },
  },
  computed: {
    ...mapGetters({
      uiFlags: 'sla/getUIFlags',
    }),
  },
  methods: {
    resetForm() {
      this.name = '';
      this.alertTime = '';
      this.limitTime = '';
      this.maxTime = '';
      this.$v.name.$reset();
      this.$v.alertTime.$reset();
      this.$v.limitTime.$reset();
      this.$v.maxTime.$reset();
    },
    async addSla() {
      this.addSlas.showLoading = true;
      try {
        await this.$store.dispatch('sla/createSla', {
          name: this.name,
          alert_time: this.alertTime,
          limit_time: this.limitTime,
          max_time: this.maxTime,
        });
        this.addSlas.showLoading = false;
        bus.$emit('newToastMessage', 'SLA adicionada com sucesso.');
        this.resetForm();
        this.$store.dispatch('sla/getSla');
        this.onClose();
      } catch (error) {
        this.addSlas.showLoading = false;
        const errorMessage = error.message || 'Ocorreu um erro ao criar SLA';
        bus.$emit('newToastMessage', errorMessage);
      }
    },
  },
};
</script>

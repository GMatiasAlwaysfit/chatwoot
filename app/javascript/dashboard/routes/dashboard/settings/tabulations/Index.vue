<template>
  <div class="flex-1 overflow-auto p-4">
    <woot-button
      color-scheme="success"
      class-names="button--fixed-top"
      icon="add-circle"
      @click="openAddPopup()"
    >
      Adicionar Tabulação
    </woot-button>

    <div class="flex flex-row gap-4">
      <div class="w-[60%]">
        <p
          v-if="!uiFlags.fetchingList && !records.length"
          class="flex h-full items-center flex-col justify-center"
        >
          Não há tabulações disponíveis nesta conta.
        </p>
        <woot-loading-state
          v-if="uiFlags.fetchingList"
          :message="'Buscando Tabulações...'"
        />

        <table
          v-if="!uiFlags.fetchingList && records.length"
          class="woot-table"
        >
          <thead>
            <th v-for="thHeader in headerContent" :key="thHeader">
              {{ thHeader }}
            </th>
          </thead>

          <tbody>
            <tr v-for="(tabulation, index) in records" :key="tabulation.name">
              <!-- Short Code  -->
              <td class="w-[8.75rem]">
                {{ tabulation.name }}
              </td>
              <!-- Content -->
              <td class="break-all whitespace-normal">
                {{ tabulation.description }}
              </td>
              <td class="break-all whitespace-normal">
                {{ tabulation.end_phrase }}
              </td>
              <td class="break-all whitespace-normal">
                {{ tabulation.tab_type }}
              </td>
              <!-- Action Buttons -->
              <td class="button-wrapper">
                <woot-button
                  v-tooltip.top="'Alterar'"
                  variant="smooth"
                  size="tiny"
                  color-scheme="secondary"
                  icon="edit"
                  @click="openEditPopup(tabulation)"
                />
                <woot-button
                  v-tooltip.top="'Excluir'"
                  variant="smooth"
                  color-scheme="alert"
                  size="tiny"
                  icon="dismiss-circle"
                  class-names="grey-btn"
                  :is-loading="loading[tabulation.id]"
                  @click="openDeletePopup(tabulation, index)"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <woot-modal :show.sync="showAddPopup" :on-close="hideAddPopup">
      <add-tabulation :on-close="hideAddPopup" />
    </woot-modal>

    <!-- Edit Canned Response -->
    <woot-modal :show.sync="showEditPopup" :on-close="hideEditPopup">
      <edit-tabulation
        v-if="showEditPopup"
        :id="selectedTabulation.id"
        :edname="selectedTabulation.name"
        :eddescription="selectedTabulation.description"
        :edend-phrase="selectedTabulation.end_phrase"
        :edtab-type="selectedTabulation.tab_type"
        :on-close="hideEditPopup"
      />
    </woot-modal>

    <woot-delete-modal
      :show.sync="showDeletePopup"
      :on-close="closeDeletePopup"
      :on-confirm="confirmDeletion"
      :title="'Confirmar exclusão'"
      :message="'Você tem certeza que deseja excluir '"
      :message-value="deleteMessage"
      :confirm-text="deleteConfirmText"
      :reject-text="deleteRejectText"
    />
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import AddTabulation from './AddTabulation.vue';
import EditTabulation from './EditTabulations.vue';

export default {
  components: {
    AddTabulation,
    EditTabulation,
  },
  data() {
    return {
      loading: {},
      showAddPopup: false,
      showEditPopup: false,
      showDeletePopup: false,
      selectedTabulation: {},
      tabulationAPI: {
        message: '',
      },
      headerContent: [
        'Nome',
        'Descrição',
        'Frase de encerramento',
        'Tipo de tabulação',
        'Ações',
      ],
    };
  },
  computed: {
    ...mapGetters({
      records: 'tabulation/getTabulations',
      uiFlags: 'tabulation/getUIFlags',
    }),
    // Delete Modal
    deleteConfirmText() {
      return `Sim, excluir ${this.selectedTabulation.name}`;
    },
    deleteRejectText() {
      return `Não, manter ${this.selectedTabulation.name}`;
    },
    deleteMessage() {
      return ` ${this.selectedTabulation.name}?`;
    },
  },
  mounted() {
    this.$store.dispatch('tabulation/getTabulations');
  },
  methods: {
    showAlert(message) {
      // Reset loading, current selected sla
      this.loading[this.selectedTabulation.id] = false;
      this.selectedTabulation = {};
      // Show message
      this.tabulationAPI.message = message;
      bus.$emit('newToastMessage', message);
    },
    openAddPopup() {
      this.showAddPopup = true;
    },
    hideAddPopup() {
      this.showAddPopup = false;
    },
    openEditPopup(tabulation) {
      this.showEditPopup = true;
      this.selectedTabulation = tabulation;
    },
    hideEditPopup() {
      this.showEditPopup = false;
    },
    openDeletePopup(tabulation) {
      this.showDeletePopup = true;
      this.selectedTabulation = tabulation;
    },
    closeDeletePopup() {
      this.showDeletePopup = false;
    },
    confirmDeletion() {
      this.loading[this.selectedTabulation.id] = true;
      this.closeDeletePopup();
      this.deleteTabulation(this.selectedTabulation.id);
    },
    deleteTabulation(id) {
      this.$store
        .dispatch('tabulation/deteteTabulation', id)
        .then(() => {
          this.showAlert('Tabulação excluída com sucesso');
        })
        .catch(error => {
          const errorMessage =
            error?.message || 'Ocorreu um erro ao excluir a tabulação';
          this.showAlert(errorMessage);
        });
    },
  },
};
</script>

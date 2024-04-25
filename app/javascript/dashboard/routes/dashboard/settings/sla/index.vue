<template>
  <div class="flex-1 overflow-auto p-4">
    <woot-button
      color-scheme="success"
      class-names="button--fixed-top"
      icon="add-circle"
      @click="openAddPopup()"
    >
      Adicionar SLA
    </woot-button>

    <div class="flex flex-row gap-4">
      <div class="w-[60%]">
        <p
          v-if="!uiFlags.fetchingList && !records.length"
          class="flex h-full items-center flex-col justify-center"
        >
          Não há SLAs disponíveis nesta conta.
        </p>
        <woot-loading-state
          v-if="uiFlags.fetchingList"
          :message="'Buscando SLAs...'"
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
            <tr v-for="(sla, index) in records" :key="sla.name">
              <!-- Short Code  -->
              <td class="w-[8.75rem]">
                {{ sla.name }}
              </td>
              <!-- Content -->
              <td class="break-all whitespace-normal">
                {{ sla.alert_time }}
              </td>
              <td class="break-all whitespace-normal">
                {{ sla.limit_time }}
              </td>
              <td class="break-all whitespace-normal">
                {{ sla.max_time }}
              </td>
              <!-- Action Buttons -->
              <td class="button-wrapper">
                <woot-button
                  v-tooltip.top="'Alterar'"
                  variant="smooth"
                  size="tiny"
                  color-scheme="secondary"
                  icon="edit"
                  @click="openEditPopup(sla)"
                />
                <woot-button
                  v-tooltip.top="'Excluir'"
                  variant="smooth"
                  color-scheme="alert"
                  size="tiny"
                  icon="dismiss-circle"
                  class-names="grey-btn"
                  :is-loading="loading[sla.id]"
                  @click="openDeletePopup(sla, index)"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <woot-modal :show.sync="showAddPopup" :on-close="hideAddPopup">
      <add-sla :on-close="hideAddPopup" />
    </woot-modal>

    <woot-modal :show.sync="showEditPopup" :on-close="hideEditPopup">
      <edit-sla
        v-if="showEditPopup"
        :id="selectedSla.id"
        :edname="selectedSla.name"
        :edalert-time="selectedSla.alert_time"
        :edlimit-time="selectedSla.limit_time"
        :edmax-time="selectedSla.max_time"
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
import AddSla from './AddSla.vue';
import EditSla from './EditSla.vue';

export default {
  components: { EditSla, AddSla },
  data() {
    return {
      loading: {},
      showAddPopup: false,
      showEditPopup: false,
      showDeletePopup: false,
      selectedSla: {},
      slaAPI: {
        message: '',
      },
      headerContent: [
        'Nome',
        'Tempo de alerta (em segundos)',
        'Tempo limite (em segundos)',
        'Tempo máximo (em segundos)',
        'Ações',
      ],
    };
  },
  computed: {
    ...mapGetters({
      records: 'sla/getSla',
      uiFlags: 'sla/getUIFlags',
    }),
    // Delete Modal
    deleteConfirmText() {
      return `Sim, excluir ${this.selectedSla.name}`;
    },
    deleteRejectText() {
      return `Não, manter ${this.selectedSla.name}`;
    },
    deleteMessage() {
      return ` ${this.selectedSla.name}?`;
    },
  },
  mounted() {
    this.$store.dispatch('sla/getSla');
  },
  methods: {
    showAlert(message) {
      // Reset loading, current selected sla
      this.loading[this.selectedSla.id] = false;
      this.selectedSla = {};
      // Show message
      this.slaAPI.message = message;
      bus.$emit('newToastMessage', message);
    },
    openAddPopup() {
      this.showAddPopup = true;
    },
    hideAddPopup() {
      this.showAddPopup = false;
    },
    openEditPopup(sla) {
      this.showEditPopup = true;
      this.selectedSla = sla;
    },
    hideEditPopup() {
      this.showEditPopup = false;
    },
    openDeletePopup(sla) {
      this.showDeletePopup = true;
      this.selectedSla = sla;
    },
    closeDeletePopup() {
      this.showDeletePopup = false;
    },
    confirmDeletion() {
      this.loading[this.selectedSla.id] = true;
      this.closeDeletePopup();
      this.deleteSla(this.selectedSla.id);
    },
    deleteSla(id) {
      this.$store
        .dispatch('sla/deleteSla', id)
        .then(() => {
          this.showAlert('SLA excluído com sucesso');
        })
        .catch(error => {
          const errorMessage =
            error?.message || 'Ocorreu um erro ao excluir SLA';
          this.showAlert(errorMessage);
        });
    },
  },
};
</script>

<template>
  <modal :show.sync="show" :on-close="onClose">
    <div class="h-auto overflow-auto flex flex-col">
      <woot-modal-header :header-title="pageTitle" />
      <form class="flex flex-col w-full" @submit.prevent="editCannedResponse()">
        <div class="w-full">
          <label :class="{ error: $v.shortCode.$error }">
            {{ $t('CANNED_MGMT.EDIT.FORM.SHORT_CODE.LABEL') }}
            <input
              v-model.trim="shortCode"
              type="text"
              :placeholder="$t('CANNED_MGMT.EDIT.FORM.SHORT_CODE.PLACEHOLDER')"
              @input="$v.shortCode.$touch"
            />
          </label>
        </div>

        <div class="w-full">
          <label :class="{ error: $v.content.$error }">
            {{ $t('CANNED_MGMT.EDIT.FORM.CONTENT.LABEL') }}
          </label>
          <div class="editor-wrap">
            <woot-message-editor
              v-model="content"
              class="message-editor"
              :class="{ editor_warning: $v.content.$error }"
              :enable-variables="true"
              :enable-canned-responses="false"
              :placeholder="$t('CANNED_MGMT.EDIT.FORM.CONTENT.PLACEHOLDER')"
              @blur="$v.content.$touch"
            />
          </div>
        </div>
        <div class="flex flex-col items-center mt-2">
          <h2 class="self-start flex justify-center items-center">
            Imagens
            <div class="tooltip ml-2">
              <span>?</span>
              <span class="tooltiptext">Extensões suportadas: JPEG e PNG</span>
            </div>
          </h2>
          <div
            v-if="images.length > 0"
            class="p-3 mb-3 w-full rounded-md flex flex-row flex-wrap justify-center item-center mx-auto text-center size-full border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-900 text-slate-700"
          >
            <div v-for="(file, index) in images" :key="index">
              <img
                class="p-2 rounded-xl items-center mx-auto text-center max-w-64 max-h-32"
                :src="file.url"
                alt="Canned Image"
              />
            </div>
          </div>
          <div v-if="images.length" class="avatar-delete-btn mb-3">
            <woot-button
              type="button"
              color-scheme="alert"
              variant="hollow"
              size="small"
              @click="removeImage()"
            >
              {{ images.length > 1 ? 'Remover imagens' : 'Remover imagem' }}
            </woot-button>
            <input
              ref="fileImage"
              type="file"
              multiple
              accept="image/png, image/jpeg"
              style="display: none"
              @change="handleAddMoreImages"
            />
            <woot-button
              type="button"
              color-scheme="primary"
              variant="hollow"
              size="small"
              class="ml-1"
              @click.prevent="$refs.fileImage.click()"
            >
              +
            </woot-button>
          </div>
        </div>
        <div v-if="images.length == 0">
          <input
            id="file"
            ref="file"
            type="file"
            label="Imagem do template"
            accept="image/png, image/jpeg"
            multiple
            @change="handleImageUpload"
            @click="onInputClick"
          />
        </div>
        <div class="flex flex-col items-center mt-4">
          <h2 class="self-start flex justify-center items-center">
            Anexos
            <div class="tooltip ml-2">
              <span>?</span>
              <span class="tooltiptext">
                Extensões suportadas: arquivos de texto, audio/aac, audio/mp4,
                audio/mpeg, audio/amr, audio/oga, video/mp4
              </span>
            </div>
          </h2>
          <div v-if="attachments.length == 0" class="self-start">
            <input
              ref="fileInput"
              type="file"
              multiple
              accept="audio/aac, audio/mp4, audio/mpeg, audio/amr, audio/ogg, text/plain, application/pdf, application/vnd.ms-powerpoint, application/msword, application/vnd.ms-excel, application/vnd.openxmlformats-officedocument.wordprocessingml.document, application/vnd.openxmlformats-officedocument.presentationml.presentation, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, video/mp4"
              @change="handleFileUpload"
              @click="onInputClick"
            />
          </div>
          <div v-if="attachments.length > 0" class="w-full">
            <div v-for="(file, index) in attachments" :key="index">
              <div
                v-if="file.type.includes('audio')"
                class="p-3 mb-3 rounded-md flex justify-center items-center mx-auto text-center size-full max-h-80 border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-900 text-slate-700"
              >
                <audio class="rounded-none" controls :src="file.url" />
              </div>
              <div
                v-else-if="file.type.includes('video')"
                class="p-3 mb-3 flex rounded-md items-center justify-center mx-auto text-center size-full max-h-80 border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-900 text-slate-700"
              >
                <video class="rounded-md max-h-72" controls :src="file.url" />
              </div>
              <div
                v-else
                class="p-3 mb-3 rounded-md items-center mx-auto text-center size-full max-h-80 border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-900 text-slate-700"
              >
                <a target="_blank" download :href="file.url">{{ file.name }}</a>
              </div>
            </div>
          </div>
          <div v-if="attachments.length">
            <woot-button
              type="button"
              color-scheme="alert"
              variant="hollow"
              size="small"
              @click.prevent="removeAttachment()"
            >
              {{ attachments.length > 1 ? 'Remover anexos' : 'Remover anexo' }}
            </woot-button>
            <input
              ref="fileAttachment"
              type="file"
              multiple
              accept="audio/aac, audio/mp4, audio/mpeg, audio/amr, audio/ogg, text/plain, application/pdf, application/vnd.ms-powerpoint, application/msword, application/vnd.ms-excel, application/vnd.openxmlformats-officedocument.wordprocessingml.document, application/vnd.openxmlformats-officedocument.presentationml.presentation, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, video/mp4"
              style="display: none"
              @change="handleAddMoreAttachments"
            />
            <woot-button
              type="button"
              color-scheme="primary"
              variant="hollow"
              class="ml-1"
              size="small"
              @click.prevent="$refs.fileAttachment.click()"
            >
              +
            </woot-button>
          </div>
        </div>
        <div class="flex flex-row justify-end gap-2 py-2 px-0 w-full">
          <woot-submit-button
            :disabled="
              $v.content.$invalid ||
              $v.shortCode.$invalid ||
              editCanned.showLoading
            "
            :button-text="$t('CANNED_MGMT.EDIT.FORM.SUBMIT')"
            :loading="editCanned.showLoading"
          />
          <button class="button clear" @click.prevent="onClose">
            {{ $t('CANNED_MGMT.EDIT.CANCEL_BUTTON_TEXT') }}
          </button>
        </div>
      </form>
    </div>
  </modal>
</template>

<script>
/* eslint no-console: 0 */
import { required, minLength } from 'vuelidate/lib/validators';
import WootMessageEditor from 'dashboard/components/widgets/WootWriter/Editor.vue';
import WootSubmitButton from '../../../../components/buttons/FormSubmitButton.vue';
import alertMixin from 'shared/mixins/alertMixin';
import Modal from '../../../../components/Modal.vue';

export default {
  components: {
    WootSubmitButton,
    Modal,
    WootMessageEditor,
  },
  mixins: [alertMixin],
  props: {
    id: { type: Number, default: null },
    edcontent: { type: String, default: '' },
    edshortCode: { type: String, default: '' },
    edimage: { type: Array, default: () => {} },
    edattachments: { type: Array, default: () => {} },
    onClose: { type: Function, default: () => {} },
  },
  data() {
    return {
      editCanned: {
        showAlert: false,
        showLoading: false,
      },
      shortCode: this.edshortCode,
      content: this.edcontent,
      images: this.edimage,
      imageFile: null,
      attachments: this.edattachments,
      show: true,
      imageRemoved: false,
      attachmentRemoved: false,
    };
  },
  validations: {
    shortCode: {
      required,
      minLength: minLength(2),
    },
    content: {
      required,
    },
  },
  computed: {
    pageTitle() {
      return `${this.$t('CANNED_MGMT.EDIT.TITLE')} - ${this.edshortCode}`;
    },
  },
  methods: {
    handleAddMoreAttachments(event) {
      const files = event.target.files;

      files.forEach(file => {
        file.url = URL.createObjectURL(file);
        this.attachments.push(file);
      });
    },
    handleAddMoreImages(event) {
      const files = event.target.files;

      files.forEach(file => {
        file.url = URL.createObjectURL(file);
        this.images.push(file);
      });
    },
    onInputClick(event) {
      event.target.value = '';
    },
    handleImageUpload(event) {
      const files = event.target.files;

      files.forEach(file => {
        file.url = URL.createObjectURL(file);
      });

      this.images = Array.from(files);
    },
    handleFileUpload(event) {
      const files = event.target.files;

      files.forEach(file => {
        file.url = URL.createObjectURL(file);
      });

      this.attachments = Array.from(files);
    },
    removeAttachment() {
      this.attachments = [];
      this.attachmentRemoved = true;
    },
    removeImage() {
      this.images = [];
      this.imageRemoved = true;
    },
    setPageName({ name }) {
      this.$v.content.$touch();
      this.content = name;
    },
    resetForm() {
      this.shortCode = '';
      this.content = '';
      this.images = [];
      this.attachments = [];
      this.$v.shortCode.$reset();
      this.$v.content.$reset();
    },
    editCannedResponse() {
      // Show loading on button
      this.editCanned.showLoading = true;
      // Make API Calls

      const formData = new FormData();
      formData.append('short_code', this.shortCode);
      formData.append('content', this.content);

      const filteredImageFiles = this.images.filter(file => file.lastModified);

      if (this.imageRemoved) {
        formData.append('prune_image', true);
      }
      if (this.attachmentRemoved) {
        formData.append('prune_attachment', true);
      }

      if (
        this.images &&
        this.images.length > 0 &&
        filteredImageFiles.length === 0
      ) {
        formData.append('no_image_alteration', true);
        formData.append('images[]', '');
      } else if (this.images && this.images.length > 0) {
        filteredImageFiles.forEach(file => {
          formData.append('images[]', file);
        });
      }

      const filteredAttachmentFiles = this.attachments.filter(
        file => file.lastModified
      );

      if (
        this.attachments &&
        this.attachments.length > 0 &&
        filteredAttachmentFiles.length === 0
      ) {
        formData.append('no_attachment_change', true);
        formData.append('attachments[]', '');
      } else if (this.attachments && this.attachments.length > 0) {
        filteredAttachmentFiles.forEach(file => {
          formData.append('attachments[]', file);
        });
      }

      this.$store
        .dispatch('updateCannedResponse', { id: this.id, formData })
        .then(() => {
          // Reset Form, Show success message
          this.editCanned.showLoading = false;
          this.showAlert(this.$t('CANNED_MGMT.EDIT.API.SUCCESS_MESSAGE'));
          this.resetForm();
          this.$store.dispatch('getCannedResponse');
          setTimeout(() => {
            this.onClose();
          }, 10);
        })
        .catch(error => {
          this.editCanned.showLoading = false;
          const errorMessage =
            error?.message || this.$t('CANNED_MGMT.EDIT.API.ERROR_MESSAGE');
          this.showAlert(errorMessage);
        });
    },
  },
};
</script>
<style scoped lang="scss">
::v-deep {
  .ProseMirror-menubar {
    @apply hidden;
  }

  .ProseMirror-woot-style {
    @apply min-h-[12.5rem];

    p {
      @apply text-base;
    }
  }
}

audio::-webkit-media-controls-enclosure {
  border-radius: 4px;
}
.tooltip {
  position: relative;
  border: 1px solid black;
  width: 15px;
  height: 18px;
  display: flex;
  justify-content: center;
  align-items: center;
}

/* Tooltip text */
.tooltiptext {
  visibility: hidden;
  width: 120px;
  background-color: #555;
  color: #fff;
  text-align: center;
  padding: 5px 0;
  border-radius: 6px;

  /* Position the tooltip text */
  position: absolute;
  z-index: 1;
  bottom: 125%;
  left: 50%;
  margin-left: -60px;

  /* Fade in tooltip */
  opacity: 0;
  transition: opacity 0.3s;
}

/* Tooltip arrow */
.tooltip .tooltiptext::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  margin-left: -5px;
  border-width: 5px;
  border-style: solid;
  border-color: #555 transparent transparent transparent;
}

/* Show the tooltip text when you mouse over the tooltip container */
.tooltip:hover .tooltiptext {
  visibility: visible;
  opacity: 1;
}
</style>

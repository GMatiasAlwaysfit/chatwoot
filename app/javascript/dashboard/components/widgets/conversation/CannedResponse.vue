<template>
  <mention-box
    v-if="items.length"
    :items="items"
    @mention-select="handleMentionClick"
  >
    <template slot-scope="{ item }">
      <strong>{{ item.label }}</strong> - {{ item.description }}
    </template>
  </mention-box>
</template>

<script>
import { mapGetters } from 'vuex';
import MentionBox from '../mentions/MentionBox.vue';

export default {
  components: { MentionBox },
  props: {
    searchKey: {
      type: String,
      default: '',
    },
  },
  computed: {
    ...mapGetters({
      cannedMessages: 'getCannedResponses',
    }),
    items() {
      return this.cannedMessages.map(cannedMessage => ({
        label: cannedMessage.short_code,
        key: cannedMessage.short_code,
        description: cannedMessage.content,
        image_url: cannedMessage.image_url,
        images: cannedMessage.images,
        attachments: cannedMessage.attachments,
      }));
    },
  },
  watch: {
    searchKey() {
      this.fetchCannedResponses();
    },
  },
  mounted() {
    this.fetchCannedResponses();
  },
  methods: {
    fetchCannedResponses() {
      this.$store.dispatch('getCannedResponse', { searchKey: this.searchKey });
    },
    handleMentionClick(item = {}) {
      this.$emit('click', item);
    },
  },
};
</script>

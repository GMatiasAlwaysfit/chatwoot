<template>
  <div>
    <p>{{ timer }}</p>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import { differenceInSeconds } from 'date-fns';

export default {
  props: {
    chat: {
      type: Object,
      default: () => {},
    },
  },
  data() {
    return {
      timer: '',
    };
  },
  computed: {
    ...mapGetters({
      slaAttached: 'sla/getSlaById',
    }),
    slaId() {
      return this.chat?.sla_id;
    },
    sla() {
      if (!this.slaId) return null;
      return this.slaAttached(this.slaId);
    },
  },
  watch: {
    chat() {
      this.updateTimer();
    },
  },
  async mounted() {
    this.updateTimer();
    setInterval(this.updateTimer, 1000);
  },
  methods: {
    updateTimer() {
      const createdAt = new Date(this.chat.created_at * 1000);
      const now = new Date();
      const difference = differenceInSeconds(now, createdAt);
      this.timer = this.formatDuration(difference);
    },
    formatDuration(seconds) {
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      const remainingSeconds = seconds % 60;
      return `${this.pad(hours)}:${this.pad(minutes)}:${this.pad(
        remainingSeconds
      )}`;
    },
    pad(value) {
      return value.toString().padStart(2, '0');
    },
  },
};
</script>

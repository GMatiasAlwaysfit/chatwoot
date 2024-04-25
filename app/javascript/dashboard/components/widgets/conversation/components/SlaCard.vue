<template>
  <div>
    <div
      :class="`status-badge status-badge__${status} rounded-full w-3 h-3 mr-0.5 rtl:mr-0 rtl:ml-0.5 inline-flex`"
    />
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
      timer: null,
      status: '',
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
  mounted() {
    this.updateTimer();
  },
  beforeDestroy() {
    clearInterval(this.timer);
  },
  methods: {
    updateTimer() {
      if (!this.chat.waiting_since) {
        clearInterval(this.timer);
        this.timer = null;
        this.status = '';
        return;
      }

      if (this.timer) return;

      this.timer = setInterval(() => {
        const waiting_since = new Date(this.chat.waiting_since * 1000);
        const now = new Date();
        const difference = differenceInSeconds(now, waiting_since);

        if (difference > this.sla.alert_time) {
          this.status = 'warning';
        }

        if (difference > this.sla.limit_time) {
          this.status = 'missed';
        }
      }, 1000);
    },
  },
};
</script>

<style lang="scss" scoped>
.status-badge {
  &__warning {
    @apply bg-yellow-500;
  }
  &__missed {
    @apply bg-red-700;
  }
}
</style>

<template>
  <div><h1>Sla</h1></div>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  data() {
    return {
      slas: [],
    };
  },
  computed: {
    ...mapGetters({
      records: 'sla/getSla',
      uiFlags: 'sla/getUIFlags',
    }),
  },
  mounted() {
    this.$store.dispatch('sla/getSla');
  },
};
</script>

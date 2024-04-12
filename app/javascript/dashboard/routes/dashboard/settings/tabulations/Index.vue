<template>
  <div><h1>Tabulation</h1></div>
</template>

<script>
import { mapGetters } from 'vuex';
export default {
  data() {
    return {
      tabulations: [],
    };
  },
  computed: {
    ...mapGetters({
      records: 'tabulation/getTabulations',
      uiFlags: 'tabulation/getUIFlags',
    }),
  },
  mounted() {
    this.$store.dispatch('tabulation/getTabulations');
  },
};
</script>

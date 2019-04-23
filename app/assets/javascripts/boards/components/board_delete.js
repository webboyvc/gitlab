import $ from 'jquery';
import Vue from 'vue';

export default Vue.extend({
  props: {
    list: {
      type: Object,
      default: () => ({}),
    },
  },
  methods: {
    deleteBoard() {
      $(this.$el).tooltip('hide');

      // eslint-disable-next-line no-alert
      if (window.confirm('您确定要删除这个列表？')) {
        this.list.destroy();
      }
    },
  },
});

import TurbolinksAdapter from 'vue-turbolinks';
import Vue from 'vue/dist/vue.esm';
import Results from '../../vue/results/results.vue';

Vue.use(TurbolinksAdapter);
Vue.prototype.i18n = window.I18n;

new Vue({
  el: '#results',
  components: {
    Results
  }
});
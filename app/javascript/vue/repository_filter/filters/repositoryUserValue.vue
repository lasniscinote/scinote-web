<template>
  <div class="filter-attributes">
    <div class="operator-selector">
      <DropdownSelector
        :disableSearch="true"
        :options="this.operators"
        :selectedValue="this.operator"
        :selectorId="`OperatorSelector${this.filter.id}`"
        @dropdown:changed="updateOperator"
      />
    </div>
    <div v-if="users" class="users-filter-dropdown">
      <DropdownSelector
        :optionClass="'checkbox-icon'"
        :dataCombineTags="true"
        :noEmptyOption="false"
        :singleSelect="false"
        :closeOnSelect="false"
        :selectedValue="this.value"
        :optionLabel="renderOption"
        :options="this.users"
        :dataSelectMultipleName="this.i18n.t('repositories.show.repository_filter.filters.types.RepositoryUserValue.multiple_selected')"
        :dataSelectMultipleAllSelected="this.i18n.t('repositories.show.repository_filter.filters.types.RepositoryUserValue.all_selected')"
        :selectorId="`UserSelector${this.filter.id}`"
        :placeholder="this.i18n.t('repositories.show.repository_filter.filters.types.RepositoryUserValue.select_placeholder')"
        @dropdown:changed="updateValue"
      />
    </div>
  </div>
</template>

<script>
  import FilterMixin from '../mixins/filter.js'
  import DropdownSelector from '../../shared/dropdown_selector.vue'
  export default {
    name: 'RepositoryUserValue',
    mixins: [FilterMixin],
    data() {
      return {
        operators: [
          { value: 'any_of', label: this.i18n.t('repositories.show.repository_filter.filters.operators.any_of') },
          { value: 'none_of', label: this.i18n.t('repositories.show.repository_filter.filters.operators.none_of') }
        ],
        operator: 'any_of',
        value: [],
        users: null
      }
    },
    components: {
      DropdownSelector
    },
    mounted() {
      let params = {}
      if (this.filter.column.id === 'archived_by') params.archived_by = true
      $.get($('#filterContainer').data('users-url'), params, (data) => {
        this.users = data.users;
      });
    },
    watch: {
      value() {
        this.parameters = { user_ids: this.value };
        this.updateFilter();
      }
    },
    methods: {
      updateValue(value) {
        this.value = value
      },
      renderOption(data) {
        return `<span class="user-filter-option" title="${data.label.trim()} | ${data.params.email}">
                  <img class="item-avatar" src="${data.params.avatar_url}"/>
                  ${data.label}
                </span>`;
      }
    },
    computed: {
      isBlank(){
        return (this.operator === 'any_of' && this.value.length === 0) ||
               (this.filter.column.id === 'archived_by' && $('.repository-show').hasClass('active') ) ;
      }
    }
  }
</script>

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
    <DropdownSelector
      :optionClass="'checkbox-icon'"
      :dataCombineTags="true"
      :noEmptyOption="false"
      :singleSelect="false"
      :closeOnSelect="false"
      :selectedValue="this.value"
      :options="this.filter.column.items"
      :dataSelectMultipleName="this.i18n.t('repositories.show.repository_filter.filters.types.RepositoryChecklistValue.multiple_selected')"
      :dataSelectMultipleAllSelected="this.i18n.t('repositories.show.repository_filter.filters.types.RepositoryChecklistValue.all_selected')"
      :selectorId="`ChecklistSelector${this.filter.id}`"
      :placeholder="this.i18n.t('repositories.show.repository_filter.filters.types.RepositoryChecklistValue.select_placeholder', {name: this.filter.column.name})"
      @dropdown:changed="updateValue"
    />
  </div>
</template>

<script>
  import FilterMixin from '../mixins/filter.js'
  import DropdownSelector from '../../shared/dropdown_selector.vue'
  export default {
    name: 'RepositoryChecklistValue',
    mixins: [FilterMixin],
    data() {
      return {
        operators: [
          { value: 'any_of', label: this.i18n.t('repositories.show.repository_filter.filters.operators.any_of') },
          { value: 'all_of', label: this.i18n.t('repositories.show.repository_filter.filters.operators.all_of') },
          { value: 'none_of', label: this.i18n.t('repositories.show.repository_filter.filters.operators.none_of') }
        ],
        operator: 'any_of',
        value: []
      }
    },
    components: {
      DropdownSelector
    },
    watch: {
      value() {
        this.parameters = { item_ids: this.value };
        this.updateFilter();
      }
    },
    methods: {
      updateValue(value) {
        this.value = value
      }
    },
    computed: {
      isBlank(){
        return this.operator == 'any_of' && this.value.length == 0;
      }
    }
  }
</script>

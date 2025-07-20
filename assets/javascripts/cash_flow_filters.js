// cash_flow_filters.js
document.addEventListener('DOMContentLoaded', function() {
  // Botão para limpar filtros individuais
  document.querySelectorAll('.remove-filter').forEach(button => {
    button.addEventListener('click', function(e) {
      e.preventDefault();
      const filterName = this.dataset.filter;
      const url = new URL(window.location);
      url.searchParams.delete(`query[${filterName}]`);
      window.location = url.toString();
    });
  });

  // Botão "Limpar" dentro dos dropdowns de filtro
  document.querySelectorAll('.clear-filter').forEach(button => {
    button.addEventListener('click', function() {
      const form = this.closest('.dropdown-form');
      form.querySelectorAll('input, select').forEach(field => {
        if (field.type !== 'submit') field.value = '';
      });
      form.closest('form').submit();
    });
  });

  // Atualizar contador de filtros ativos
  function updateActiveFiltersCount() {
    const count = document.querySelectorAll('.filter-tag').length;
    const counter = document.querySelector('.active-filters-count');
    if (counter) {
      counter.textContent = count;
      counter.style.display = count > 0 ? 'block' : 'none';
    }
  }
  
  updateActiveFiltersCount();
});
// cash_flow.js
document.addEventListener('DOMContentLoaded', function() {
  // Atualizar nome do arquivo no formulário de importação
  const fileInput = document.getElementById('csv_file');
  if (fileInput) {
    fileInput.addEventListener('change', function() {
      const fileName = this.files[0] ? this.files[0].name : 'Nenhum arquivo selecionado';
      document.getElementById('file-name').textContent = fileName;
    });
  }
  
  // Tooltips (se estiver usando Bootstrap)
  if (typeof bootstrap !== 'undefined') {
    const tooltips = [].slice.call(document.querySelectorAll('[data-toggle="tooltip"]'));
    tooltips.map(tooltip => new bootstrap.Tooltip(tooltip));
  }
});
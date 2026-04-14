var animalesApp = {
  confirmarEliminar: function (id, onConfirm) {
    if (typeof Swal === 'undefined') {
      if (confirm('¿Eliminar este animal?')) onConfirm();
      return;
    }
    Swal.fire({
      title: '¿Eliminar animal?',
      text: 'Esta acción no se puede deshacer.',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#dc3545',
      cancelButtonText: 'Cancelar',
      confirmButtonText: 'Sí, eliminar',
    }).then(function (result) {
      if (result.isConfirmed && onConfirm) onConfirm();
    });
  },
};

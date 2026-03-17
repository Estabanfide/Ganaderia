window.app = window.app || {};
window.app.flash = function (type, msg) {
  if (typeof Swal !== 'undefined') {
    Swal.fire({ icon: type === 'error' ? 'error' : 'success', title: type === 'error' ? 'Error' : 'Éxito', text: msg });
  }
};

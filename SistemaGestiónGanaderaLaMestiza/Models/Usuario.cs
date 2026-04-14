using System;

namespace SistemaGestiónGanaderaLaMestiza.Models
{
    public class Usuario
    {
        public decimal IdUsuario { get; set; }
        public string Nombre { get; set; }
        public string Email { get; set; }
        public DateTime? FechaRegistro { get; set; }
        public string Clave { get; set; }
    }
}

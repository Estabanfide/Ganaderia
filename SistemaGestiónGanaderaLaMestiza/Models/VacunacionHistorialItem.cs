using System;

namespace SistemaGestiónGanaderaLaMestiza.Models
{
    public class VacunacionHistorialItem
    {
        public decimal IdAnimal { get; set; }
        public string NombreAnimal { get; set; }
        public string NombreVacuna { get; set; }
        public DateTime? FechaAplicacion { get; set; }
    }
}

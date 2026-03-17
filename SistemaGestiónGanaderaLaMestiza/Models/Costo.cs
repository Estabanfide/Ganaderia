using System;

namespace SistemaGestiónGanaderaLaMestiza.Models
{
    public class Costo
    {
        public decimal IdCosto { get; set; }
        public decimal IdAnimal { get; set; }
        public decimal? Monto { get; set; }
        public DateTime? FechaCosto { get; set; }
        public string NombreAnimal { get; set; }
    }
}

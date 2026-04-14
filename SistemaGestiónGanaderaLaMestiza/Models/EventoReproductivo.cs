using System;

namespace SistemaGestiónGanaderaLaMestiza.Models
{
    public class EventoReproductivo
    {
        public decimal IdEvento { get; set; }
        public decimal IdAnimal { get; set; }
        public DateTime? FechaEvento { get; set; }
        public string TipoEvento { get; set; }
        public string NombreAnimal { get; set; }
    }
}

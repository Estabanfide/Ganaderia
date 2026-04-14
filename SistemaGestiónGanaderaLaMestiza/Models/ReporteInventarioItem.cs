using System;

namespace SistemaGestiónGanaderaLaMestiza.Models
{
    public class ReporteInventarioItem
    {
        public decimal IdAnimal { get; set; }
        public string Nombre { get; set; }
        public DateTime? FechaNac { get; set; }
        public string Raza { get; set; }
        public string Sexo { get; set; }
        public string Tipo { get; set; }
        public string Salud { get; set; }
        public string NombrePotrero { get; set; }
        public string NombreFinca { get; set; }
        public int? Edad { get; set; }
    }
}

namespace SistemaGestiónGanaderaLaMestiza.Models
{
    public class Potrero
    {
        public decimal IdPotrero { get; set; }
        public decimal? IdFinca { get; set; }
        public string Nombre { get; set; }
        public decimal? Capacidad { get; set; }
        public string NombreFinca { get; set; }
        public int CantidadAnimales { get; set; }
    }
}

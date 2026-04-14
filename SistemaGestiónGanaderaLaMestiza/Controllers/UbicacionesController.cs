using System.Text;
using System.Web.Mvc;
using SistemaGestiónGanaderaLaMestiza.Filters;
using SistemaGestiónGanaderaLaMestiza.Repositorios;

namespace SistemaGestiónGanaderaLaMestiza.Controllers
{
    [RequireAuth]
    public class UbicacionesController : Controller
    {
        private readonly PotrerosRepository _repo = new PotrerosRepository();

        public ActionResult Index()
        {
            ViewBag.Potreros = _repo.FindAllWithCount();
            return View();
        }

        public ActionResult Exportar()
        {
            var potreros = _repo.FindAllWithCount();
            var sb = new StringBuilder();
            sb.AppendLine("Nombre,Nombre Finca,Capacidad,Cantidad Animales");
            foreach (var p in potreros)
                sb.AppendLine($"{p.Nombre},{p.NombreFinca ?? ""},{p.Capacidad},{p.CantidadAnimales}");
            var bytes = Encoding.UTF8.GetBytes(sb.ToString());
            return File(bytes, "text/csv", "ubicaciones.csv");
        }
    }
}

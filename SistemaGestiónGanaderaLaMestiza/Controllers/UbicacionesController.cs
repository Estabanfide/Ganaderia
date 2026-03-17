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

        [HttpGet]
        public ActionResult Nuevo()
        {
            ViewBag.Fincas = _repo.FindFincas();
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Nuevo(string nombre, decimal id_finca, decimal? capacidad)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(nombre))
                    throw new System.Exception("El nombre del potrero es obligatorio.");

                _repo.Create(nombre, id_finca, capacidad);
                TempData["Success"] = "Potrero creado correctamente.";
                return RedirectToAction("Index");
            }
            catch (System.Exception ex)
            {
                TempData["Error"] = ex.Message;
                ViewBag.Fincas = _repo.FindFincas();
                return View();
            }
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

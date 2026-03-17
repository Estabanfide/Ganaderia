using System.Text;
using System.Web.Mvc;
using SistemaGestiónGanaderaLaMestiza.Filters;
using SistemaGestiónGanaderaLaMestiza.Repositorios;

namespace SistemaGestiónGanaderaLaMestiza.Controllers
{
    [RequireAuth]
    public class ReportesController : Controller
    {
        private readonly ReportesRepository _repo = new ReportesRepository();
        private readonly PotrerosRepository _potrerosRepo = new PotrerosRepository();

        public ActionResult Index(string raza, decimal? id_potrero, decimal? id_finca, string salud, string rango_edad)
        {
            var filtros = new ReportesFiltros { Raza = raza, IdPotrero = id_potrero, IdFinca = id_finca, Salud = salud, RangoEdad = rango_edad };
            ViewBag.Inventario = _repo.GetInventarioFiltrado(filtros);
            ViewBag.DistribucionSalud = _repo.GetDistribucionPorSalud();
            ViewBag.Potreros = _potrerosRepo.FindAllWithCount();
            return View();
        }

        public ActionResult Exportar(string raza, decimal? id_potrero, decimal? id_finca, string salud, string rango_edad)
        {
            var filtros = new ReportesFiltros { Raza = raza, IdPotrero = id_potrero, IdFinca = id_finca, Salud = salud, RangoEdad = rango_edad };
            var lista = _repo.GetInventarioFiltrado(filtros);
            var sb = new StringBuilder();
            sb.AppendLine("IdAnimal,Nombre,FechaNac,Raza,Sexo,Tipo,Salud,NombrePotrero,NombreFinca,Edad");
            foreach (var i in lista)
                sb.AppendLine($"{i.IdAnimal},{i.Nombre},{i.FechaNac?.ToString("yyyy-MM-dd") ?? ""},{i.Raza},{i.Sexo},{i.Tipo},{i.Salud},{i.NombrePotrero},{i.NombreFinca},{i.Edad}");
            var bytes = Encoding.UTF8.GetBytes(sb.ToString());
            return File(bytes, "text/csv", "reporte-inventario.csv");
        }
    }
}

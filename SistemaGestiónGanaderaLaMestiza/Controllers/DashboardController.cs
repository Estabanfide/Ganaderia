using System.Web.Mvc;
using SistemaGestiónGanaderaLaMestiza.Filters;
using SistemaGestiónGanaderaLaMestiza.Repositorios;

namespace SistemaGestiónGanaderaLaMestiza.Controllers
{
    [RequireAuth]
    public class DashboardController : Controller
    {
        private readonly DashboardRepository _repo = new DashboardRepository();

        public ActionResult Index()
        {
            ViewBag.Metricas = _repo.GetMetricas();
            ViewBag.AnimalesRecientes = _repo.GetAnimalesRecientes(8);
            return View();
        }
    }
}

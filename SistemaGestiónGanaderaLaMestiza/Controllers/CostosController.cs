using System;
using System.Web.Mvc;
using SistemaGestiónGanaderaLaMestiza.Filters;
using SistemaGestiónGanaderaLaMestiza.Repositorios;

namespace SistemaGestiónGanaderaLaMestiza.Controllers
{
    [RequireAuth]
    public class CostosController : Controller
    {
        private readonly CostosRepository _repo = new CostosRepository();
        private readonly AnimalesRepository _animalesRepo = new AnimalesRepository();

        public ActionResult Index(decimal? id_animal, string desde, string hasta)
        {
            var filtros = new CostosFiltros { IdAnimal = id_animal, Desde = desde, Hasta = hasta };
            ViewBag.Costos = _repo.FindByFiltros(filtros);
            ViewBag.Animales = _animalesRepo.FindAll(null);
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Registrar(decimal id_animal, decimal monto)
        {
            try
            {
                _repo.Registrar(id_animal, monto);
                TempData["Success"] = "Costo registrado.";
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
                return RedirectToAction("Index");
            }
        }
    }
}

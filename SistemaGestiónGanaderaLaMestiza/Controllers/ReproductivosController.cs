using System;
using System.Web.Mvc;
using SistemaGestiónGanaderaLaMestiza.Filters;
using SistemaGestiónGanaderaLaMestiza.Repositorios;

namespace SistemaGestiónGanaderaLaMestiza.Controllers
{
    [RequireAuth]
    public class ReproductivosController : Controller
    {
        private readonly ReproductivosRepository _repo = new ReproductivosRepository();
        private readonly AnimalesRepository _animalesRepo = new AnimalesRepository();

        public ActionResult Index(decimal? id_animal, string desde, string hasta)
        {
            var filtros = new ReproductivosFiltros { IdAnimal = id_animal, Desde = desde, Hasta = hasta };
            ViewBag.Eventos = _repo.FindByFiltros(filtros);
            ViewBag.Animales = _animalesRepo.FindAll(null);
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Registrar(decimal id_animal, DateTime? fecha_evento, string tipo_evento)
        {
            try
            {
                _repo.Registrar(id_animal, fecha_evento, tipo_evento);
                TempData["Success"] = "Evento reproductivo registrado.";
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

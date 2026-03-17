using System;
using System.Web.Mvc;
using SistemaGestiónGanaderaLaMestiza.Filters;
using SistemaGestiónGanaderaLaMestiza.Repositorios;

namespace SistemaGestiónGanaderaLaMestiza.Controllers
{
    [RequireAuth]
    public class VacunasController : Controller
    {
        private readonly VacunasRepository _repo = new VacunasRepository();
        private readonly AnimalesRepository _animalesRepo = new AnimalesRepository();

        public ActionResult Index()
        {
            ViewBag.Vacunas = _repo.FindAllVacunas();
            ViewBag.Historial = _repo.GetHistorialGlobal(100);
            ViewBag.Animales = _animalesRepo.FindAll(null);
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Registrar(decimal id_animal, decimal id_vacuna, DateTime? fecha_aplicacion)
        {
            try
            {
                _repo.RegistrarVacunacion(id_animal, id_vacuna, fecha_aplicacion);
                TempData["Success"] = "Vacunación registrada.";
                return RedirectToAction("Index");
            }
            catch (Oracle.ManagedDataAccess.Client.OracleException ex) when (ex.Number == 20001)
            {
                TempData["Error"] = "No puede aplicar la misma vacuna en el mismo mes.";
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

using System;
using System.Web.Mvc;
using SistemaGestiónGanaderaLaMestiza.Filters;
using SistemaGestiónGanaderaLaMestiza.Models;
using SistemaGestiónGanaderaLaMestiza.Repositorios;

namespace SistemaGestiónGanaderaLaMestiza.Controllers
{
    [RequireAuth]
    public class AnimalesController : Controller
    {
        private readonly AnimalesRepository _repo = new AnimalesRepository();
        private readonly PotrerosRepository _potrerosRepo = new PotrerosRepository();

        public ActionResult Index(string nombre, string raza, string sexo, string tipo, string salud, decimal? id_potrero)
        {
            var filtros = new AnimalesFiltros { Nombre = nombre, Raza = raza, Sexo = sexo, Tipo = tipo, Salud = salud, IdPotrero = id_potrero };
            ViewBag.Animales = _repo.FindAll(filtros);
            ViewBag.Potreros = _potrerosRepo.FindAll();
            return View();
        }

        [HttpGet]
        public ActionResult Nuevo()
        {
            ViewBag.Potreros = _potrerosRepo.FindAll();
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Nuevo(Animal model)
        {
            try
            {
                _repo.Create(model);
                TempData["Success"] = "Animal registrado correctamente.";
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
                ViewBag.Potreros = _potrerosRepo.FindAll();
                return View(model);
            }
        }

        public ActionResult Detalle(decimal id)
        {
            var animal = _repo.FindById(id);
            if (animal == null) return HttpNotFound();
            ViewBag.Animal = animal;
            ViewBag.Edad = _repo.GetEdad(id);
            ViewBag.TotalCostos = _repo.GetTotalCostos(id);
            ViewBag.HistorialVacunacion = _repo.GetHistorialVacunacion(id);
            ViewBag.Costos = _repo.GetCostos(id);
            ViewBag.EventosReproductivos = _repo.GetEventosReproductivos(id);
            return View();
        }

        [HttpGet]
        public ActionResult Editar(decimal id)
        {
            var animal = _repo.FindById(id);
            if (animal == null) return HttpNotFound();
            ViewBag.Potreros = _potrerosRepo.FindAll();
            return View(animal);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Editar(decimal id, Animal model)
        {
            try
            {
                _repo.Update(id, model);
                TempData["Success"] = "Animal actualizado correctamente.";
                return RedirectToAction("Detalle", new { id });
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
                ViewBag.Potreros = _potrerosRepo.FindAll();
                return View(model);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Eliminar(decimal id)
        {
            try
            {
                _repo.Remove(id);
                TempData["Success"] = "Animal eliminado.";
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
                return RedirectToAction("Detalle", new { id });
            }
        }
    }
}

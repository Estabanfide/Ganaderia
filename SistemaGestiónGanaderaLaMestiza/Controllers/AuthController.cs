using System.Web.Mvc;
using SistemaGestiónGanaderaLaMestiza.Models;
using SistemaGestiónGanaderaLaMestiza.Servicios;

namespace SistemaGestiónGanaderaLaMestiza.Controllers
{
    public class AuthController : Controller
    {
        private readonly AuthService _authService = new AuthService();

        [HttpGet]
        public ActionResult Login()
        {
            if (Session["User"] != null)
                return RedirectToAction("Index", "Dashboard");
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(string email, string password)
        {
            if (Session["User"] != null)
                return RedirectToAction("Index", "Dashboard");
            try
            {
                var user = _authService.Login(email, password);
                Session["User"] = user;
                return RedirectToAction("Index", "Dashboard");
            }
            catch (System.Exception ex)
            {
                TempData["Error"] = ex.Message;
                return View();
            }
        }

        [HttpGet]
        public ActionResult Register()
        {
            if (Session["User"] != null)
                return RedirectToAction("Index", "Dashboard");
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Register(string nombre, string email, string password)
        {
            if (Session["User"] != null)
                return RedirectToAction("Index", "Dashboard");
            try
            {
                var user = _authService.Register(nombre, email, password);
                Session["User"] = user;
                TempData["Success"] = "Cuenta creada correctamente.";
                return RedirectToAction("Index", "Dashboard");
            }
            catch (System.Exception ex)
            {
                TempData["Error"] = ex.Message;
                return View();
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Logout()
        {
            Session.Remove("User");
            Session.Abandon();
            return RedirectToAction("Login");
        }
    }
}

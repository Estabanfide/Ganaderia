using System.Web.Mvc;

namespace SistemaGestiónGanaderaLaMestiza.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            if (Session["User"] != null)
                return RedirectToAction("Index", "Dashboard");
            return RedirectToAction("Login", "Auth");
        }
    }
}

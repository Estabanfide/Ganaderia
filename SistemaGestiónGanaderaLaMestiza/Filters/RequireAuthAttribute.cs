using System.Web.Mvc;

namespace SistemaGestiónGanaderaLaMestiza.Filters
{
    public class RequireAuthAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var user = filterContext.HttpContext.Session?["User"];
            if (user == null)
            {
                filterContext.Result = new RedirectResult("~/Auth/Login");
                return;
            }
            base.OnActionExecuting(filterContext);
        }
    }
}

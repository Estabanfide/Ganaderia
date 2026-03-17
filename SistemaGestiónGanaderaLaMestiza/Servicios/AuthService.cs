using SistemaGestiónGanaderaLaMestiza.Models;
using SistemaGestiónGanaderaLaMestiza.Repositorios;

namespace SistemaGestiónGanaderaLaMestiza.Servicios
{
    public class AuthService
    {
        private readonly AuthRepository _authRepo = new AuthRepository();

        public Usuario Register(string nombre, string email, string password)
        {
            var existing = _authRepo.FindByEmail(email);
            if (existing != null)
                throw new System.Exception("Ya existe un usuario con ese correo electrónico.");
            var hash = BCrypt.Net.BCrypt.HashPassword(password ?? "", 10);
            var id = _authRepo.CreateUser(nombre ?? email, email, hash);
            return new Usuario { IdUsuario = id, Nombre = nombre ?? email, Email = email };
        }

        public Usuario Login(string email, string password)
        {
            var user = _authRepo.FindByEmail(email);
            if (user == null)
                throw new System.Exception("Correo o contraseña incorrectos.");
            if (string.IsNullOrEmpty(user.Clave))
                throw new System.Exception("Este usuario no tiene contraseña configurada. Ejecute el script scripts/add-clave-usuarios.sql y registre de nuevo.");
            if (!BCrypt.Net.BCrypt.Verify(password ?? "", user.Clave))
                throw new System.Exception("Correo o contraseña incorrectos.");
            return new Usuario { IdUsuario = user.IdUsuario, Nombre = user.Nombre, Email = user.Email };
        }
    }
}

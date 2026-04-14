using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using SistemaGestiónGanaderaLaMestiza.Datos;
using SistemaGestiónGanaderaLaMestiza.Models;

namespace SistemaGestiónGanaderaLaMestiza.Repositorios
{
    public class AuthRepository
    {
        public Usuario FindByEmail(string email)
        {
            const string sql = "SELECT id_usuario, nombre, email, fecha_registro, clave FROM usuarios WHERE UPPER(TRIM(email)) = UPPER(TRIM(:email))";
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text, new OracleParameter("email", email ?? "")))
            {
                if (!rdr.Read()) return null;
                return new Usuario
                {
                    IdUsuario = OracleHelper.GetValue<decimal>(rdr["ID_USUARIO"]),
                    Nombre = OracleHelper.GetValue<string>(rdr["NOMBRE"]),
                    Email = OracleHelper.GetValue<string>(rdr["EMAIL"]),
                    FechaRegistro = OracleHelper.GetDate(rdr["FECHA_REGISTRO"]),
                    Clave = rdr["CLAVE"]?.ToString()
                };
            }
        }

        public decimal CreateUser(string nombre, string email, string claveHash)
        {
            using (var conn = OracleHelper.GetConnection())
            {
                using (var cmd = new OracleCommand("INSERT INTO usuarios (id_usuario, nombre, email, clave, fecha_registro) VALUES (seq_usuario.NEXTVAL, :nombre, :email, :clave, SYSDATE)", conn))
                {
                    cmd.Parameters.Add(new OracleParameter("nombre", nombre ?? (object)DBNull.Value));
                    cmd.Parameters.Add(new OracleParameter("email", (email ?? "").Trim()));
                    cmd.Parameters.Add(new OracleParameter("clave", claveHash ?? (object)DBNull.Value));
                    cmd.ExecuteNonQuery();
                }
                using (var cmd = new OracleCommand("SELECT seq_usuario.CURRVAL FROM dual", conn))
                {
                    var id = cmd.ExecuteScalar();
                    return Convert.ToDecimal(id);
                }
            }
        }
    }
}

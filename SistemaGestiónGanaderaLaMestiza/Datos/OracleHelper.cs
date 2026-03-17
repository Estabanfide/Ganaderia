using System;
using System.Configuration;
using System.Data;
using Oracle.ManagedDataAccess.Client;

namespace SistemaGestiónGanaderaLaMestiza.Datos
{
    public static class OracleHelper
    {
        private static string ConnectionString => ConfigurationManager.ConnectionStrings["OracleLaMestiza"]?.ConnectionString ?? "";

        public static OracleConnection CreateConnection()
        {
            var cs = ConnectionString?.Trim() ?? "";
            if (string.IsNullOrWhiteSpace(cs))
                throw new Exception("No hay cadena de conexión configurada. Revisa Web.config → connectionStrings → OracleLaMestiza.");

            OracleConnectionStringBuilder b;
            try
            {
                b = new OracleConnectionStringBuilder(cs);
            }
            catch (Exception)
            {
                throw new Exception("La cadena de conexión de Oracle no es válida. Revisa Web.config → OracleLaMestiza (User Id, Password y Data Source).");
            }

            if (string.IsNullOrWhiteSpace(b.UserID) || string.IsNullOrWhiteSpace(b.Password) || string.IsNullOrWhiteSpace(b.DataSource))
            {
                throw new Exception(
                    "Conexión a Oracle sin configurar. Edita Web.config → OracleLaMestiza y completa User Id, Password y Data Source " +
                    "(ej. localhost:1521/XE o localhost:1521/XEPDB1 según tu instalación)."
                );
            }

            try
            {
                var conn = new OracleConnection(cs);
                conn.Open();
                return conn;
            }
            catch (OracleException ex)
            {
                throw new Exception($"Comunicación con Oracle fallida: {ex.Message}");
            }
        }

        public static OracleConnection GetConnection()
        {
            return CreateConnection();
        }

        public static int ExecuteNonQuery(string commandText, CommandType commandType = CommandType.Text, params OracleParameter[] parameters)
        {
            using (var conn = CreateConnection())
            using (var cmd = new OracleCommand(commandText, conn) { CommandType = commandType })
            {
                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);
                return cmd.ExecuteNonQuery();
            }
        }

        public static object ExecuteScalar(string commandText, CommandType commandType = CommandType.Text, params OracleParameter[] parameters)
        {
            using (var conn = CreateConnection())
            using (var cmd = new OracleCommand(commandText, conn) { CommandType = commandType })
            {
                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);
                return cmd.ExecuteScalar();
            }
        }

        public static OracleDataReader ExecuteReader(string commandText, CommandType commandType = CommandType.Text, params OracleParameter[] parameters)
        {
            var conn = CreateConnection();
            var cmd = new OracleCommand(commandText, conn) { CommandType = commandType };
            if (parameters != null)
                cmd.Parameters.AddRange(parameters);
            return cmd.ExecuteReader(CommandBehavior.CloseConnection);
        }

        public static T GetValue<T>(object value)
        {
            if (value == null || value == DBNull.Value) return default(T);
            if (value is T t) return t;
            try { return (T)Convert.ChangeType(value, typeof(T)); }
            catch { return default(T); }
        }

        public static DateTime? GetDate(object value)
        {
            if (value == null || value == DBNull.Value) return null;
            if (value is DateTime dt) return dt;
            try { return Convert.ToDateTime(value); }
            catch { return null; }
        }

        public static decimal? GetDecimal(object value)
        {
            if (value == null || value == DBNull.Value) return null;
            return Convert.ToDecimal(value);
        }
    }
}

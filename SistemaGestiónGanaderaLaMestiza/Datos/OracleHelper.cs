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
            var conn = new OracleConnection(ConnectionString);
            conn.Open();
            return conn;
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

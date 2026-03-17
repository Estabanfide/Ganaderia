using System.Collections.Generic;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using SistemaGestiónGanaderaLaMestiza.Datos;
using SistemaGestiónGanaderaLaMestiza.Models;

namespace SistemaGestiónGanaderaLaMestiza.Repositorios
{
    public class DashboardRepository
    {
        public DashboardMetricas GetMetricas()
        {
            int total = 0, vacas = 0, toros = 0, terneros = 0, terneras = 0;
            using (var rdr = OracleHelper.ExecuteReader("SELECT COUNT(*) AS C FROM animales", CommandType.Text))
            {
                if (rdr.Read()) total = OracleHelper.GetValue<int>(rdr["C"]); // Oracle: C
            }
            const string vacasSql = "SELECT COUNT(*) AS C FROM animales WHERE sexo = 'H' AND MONTHS_BETWEEN(SYSDATE, fecha_nac) / 12 >= 1";
            using (var rdr = OracleHelper.ExecuteReader(vacasSql, CommandType.Text))
            {
                if (rdr.Read()) vacas = OracleHelper.GetValue<int>(rdr["C"]);
            }
            const string torosSql = "SELECT COUNT(*) AS C FROM animales WHERE sexo = 'M' AND MONTHS_BETWEEN(SYSDATE, fecha_nac) / 12 >= 1";
            using (var rdr = OracleHelper.ExecuteReader(torosSql, CommandType.Text))
            {
                if (rdr.Read()) toros = OracleHelper.GetValue<int>(rdr["C"]);
            }
            const string ternerosSql = "SELECT COUNT(*) AS C FROM animales WHERE sexo = 'M' AND MONTHS_BETWEEN(SYSDATE, fecha_nac) / 12 < 1";
            using (var rdr = OracleHelper.ExecuteReader(ternerosSql, CommandType.Text))
            {
                if (rdr.Read()) terneros = OracleHelper.GetValue<int>(rdr["C"]);
            }
            const string ternerasSql = "SELECT COUNT(*) AS C FROM animales WHERE sexo = 'H' AND MONTHS_BETWEEN(SYSDATE, fecha_nac) / 12 < 1";
            using (var rdr = OracleHelper.ExecuteReader(ternerasSql, CommandType.Text))
            {
                if (rdr.Read()) terneras = OracleHelper.GetValue<int>(rdr["C"]);
            }
            return new DashboardMetricas { Total = total, Vacas = vacas, Toros = toros, Terneros = terneros, Terneras = terneras };
        }

        public List<AnimalResumen> GetAnimalesRecientes(int limite = 8)
        {
            var lista = new List<AnimalResumen>();
            const string sql = @"SELECT * FROM (
                SELECT a.id_animal, a.nombre, a.raza, a.sexo, a.tipo, p.nombre AS nombre_potrero
                FROM animales a
                LEFT JOIN potreros p ON a.id_potrero = p.id_potrero
                ORDER BY a.id_animal DESC
            ) WHERE ROWNUM <= :limite";
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text, new OracleParameter("limite", limite)))
            {
                while (rdr.Read())
                {
                    lista.Add(new AnimalResumen
                    {
                        IdAnimal = OracleHelper.GetValue<decimal>(rdr["ID_ANIMAL"]),
                        Nombre = OracleHelper.GetValue<string>(rdr["NOMBRE"]),
                        Raza = OracleHelper.GetValue<string>(rdr["RAZA"]),
                        Sexo = OracleHelper.GetValue<string>(rdr["SEXO"]),
                        Tipo = OracleHelper.GetValue<string>(rdr["TIPO"]),
                        NombrePotrero = OracleHelper.GetValue<string>(rdr["NOMBRE_POTRERO"])
                    });
                }
            }
            return lista;
        }
    }
}

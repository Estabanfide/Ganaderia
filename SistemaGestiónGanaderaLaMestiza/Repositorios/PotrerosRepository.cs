using System.Collections.Generic;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using SistemaGestiónGanaderaLaMestiza.Datos;
using SistemaGestiónGanaderaLaMestiza.Models;

namespace SistemaGestiónGanaderaLaMestiza.Repositorios
{
    public class PotrerosRepository
    {
        public List<Potrero> FindAll()
        {
            const string sql = @"SELECT p.id_potrero, p.id_finca, p.nombre, p.capacidad, f.nombre AS nombre_finca
                FROM potreros p LEFT JOIN fincas f ON p.id_finca = f.id_finca ORDER BY f.nombre, p.nombre";
            var lista = new List<Potrero>();
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text))
            {
                while (rdr.Read())
                {
                    lista.Add(new Potrero
                    {
                        IdPotrero = OracleHelper.GetValue<decimal>(rdr["ID_POTRERO"]),
                        IdFinca = OracleHelper.GetValue<decimal?>(rdr["ID_FINCA"]),
                        Nombre = OracleHelper.GetValue<string>(rdr["NOMBRE"]),
                        Capacidad = OracleHelper.GetDecimal(rdr["CAPACIDAD"]),
                        NombreFinca = OracleHelper.GetValue<string>(rdr["NOMBRE_FINCA"])
                    });
                }
            }
            return lista;
        }

        public List<Potrero> FindAllWithCount()
        {
            const string sql = @"SELECT p.id_potrero, p.id_finca, p.nombre, p.capacidad, f.nombre AS nombre_finca,
                (SELECT COUNT(*) FROM animales a WHERE a.id_potrero = p.id_potrero) AS cantidad_animales
                FROM potreros p LEFT JOIN fincas f ON p.id_finca = f.id_finca ORDER BY f.nombre, p.nombre";
            var lista = new List<Potrero>();
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text))
            {
                while (rdr.Read())
                {
                    lista.Add(new Potrero
                    {
                        IdPotrero = OracleHelper.GetValue<decimal>(rdr["id_potrero"]),
                        IdFinca = OracleHelper.GetValue<decimal?>(rdr["id_finca"]),
                        Nombre = OracleHelper.GetValue<string>(rdr["nombre"]),
                        Capacidad = OracleHelper.GetDecimal(rdr["capacidad"]),
                        NombreFinca = OracleHelper.GetValue<string>(rdr["nombre_finca"]),
                        CantidadAnimales = OracleHelper.GetValue<int>(rdr["CANTIDAD_ANIMALES"])
                    });
                }
            }
            return lista;
        }
    }
}

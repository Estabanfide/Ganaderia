using System;
using System.Collections.Generic;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using SistemaGestiónGanaderaLaMestiza.Datos;
using SistemaGestiónGanaderaLaMestiza.Models;

namespace SistemaGestiónGanaderaLaMestiza.Repositorios
{
    public class CostosRepository
    {
        public void Registrar(decimal idAnimal, decimal monto)
        {
            using (var conn = OracleHelper.GetConnection())
            {
                var cmd = new OracleCommand("BEGIN sp_registrar_costo(:pid, :pmonto); END;", conn);
                cmd.Parameters.Add(new OracleParameter("pid", idAnimal));
                cmd.Parameters.Add(new OracleParameter("pmonto", monto));
                cmd.ExecuteNonQuery();
            }
        }

        public List<Costo> FindByFiltros(CostosFiltros filtros)
        {
            var sql = @"SELECT c.id_costo, c.id_animal, c.monto, c.fecha_costo, a.nombre AS nombre_animal
                FROM costos c JOIN animales a ON c.id_animal = a.id_animal WHERE 1=1";
            var prms = new List<OracleParameter>();
            if (filtros?.IdAnimal != null)
            {
                sql += " AND c.id_animal = :id_animal";
                prms.Add(new OracleParameter("id_animal", filtros.IdAnimal.Value));
            }
            if (!string.IsNullOrWhiteSpace(filtros?.Desde))
            {
                sql += " AND c.fecha_costo >= TO_DATE(:desde, 'YYYY-MM-DD')";
                prms.Add(new OracleParameter("desde", filtros.Desde));
            }
            if (!string.IsNullOrWhiteSpace(filtros?.Hasta))
            {
                sql += " AND c.fecha_costo <= TO_DATE(:hasta, 'YYYY-MM-DD')";
                prms.Add(new OracleParameter("hasta", filtros.Hasta));
            }
            sql += " ORDER BY c.fecha_costo DESC";

            var lista = new List<Costo>();
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text, prms.ToArray()))
            {
                while (rdr.Read())
                    lista.Add(new Costo
                    {
                        IdCosto = OracleHelper.GetValue<decimal>(rdr["ID_COSTO"]),
                        IdAnimal = OracleHelper.GetValue<decimal>(rdr["ID_ANIMAL"]),
                        Monto = OracleHelper.GetDecimal(rdr["MONTO"]),
                        FechaCosto = OracleHelper.GetDate(rdr["FECHA_COSTO"]),
                        NombreAnimal = OracleHelper.GetValue<string>(rdr["NOMBRE_ANIMAL"])
                    });
            }
            return lista;
        }
    }

    public class CostosFiltros
    {
        public decimal? IdAnimal { get; set; }
        public string Desde { get; set; }
        public string Hasta { get; set; }
    }
}

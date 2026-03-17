using System;
using System.Collections.Generic;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using SistemaGestiónGanaderaLaMestiza.Datos;
using SistemaGestiónGanaderaLaMestiza.Models;

namespace SistemaGestiónGanaderaLaMestiza.Repositorios
{
    public class ReproductivosRepository
    {
        public void Registrar(decimal idAnimal, DateTime? fechaEvento, string tipoEvento)
        {
            const string sql = "INSERT INTO eventos_reproductivos (id_evento, id_animal, fecha_evento, tipo_evento) VALUES (seq_evento.NEXTVAL, :id_animal, :fecha_evento, :tipo_evento)";
            OracleHelper.ExecuteNonQuery(sql, CommandType.Text,
                new OracleParameter("id_animal", idAnimal),
                new OracleParameter("fecha_evento", fechaEvento.HasValue ? (object)fechaEvento.Value : DBNull.Value),
                new OracleParameter("tipo_evento", (object)tipoEvento ?? DBNull.Value));
        }

        public List<EventoReproductivo> FindByFiltros(ReproductivosFiltros filtros)
        {
            var sql = @"SELECT e.id_evento, e.id_animal, e.fecha_evento, e.tipo_evento, a.nombre AS nombre_animal
                FROM eventos_reproductivos e JOIN animales a ON e.id_animal = a.id_animal WHERE 1=1";
            var prms = new List<OracleParameter>();
            if (filtros?.IdAnimal != null)
            {
                sql += " AND e.id_animal = :id_animal";
                prms.Add(new OracleParameter("id_animal", filtros.IdAnimal.Value));
            }
            if (!string.IsNullOrWhiteSpace(filtros?.Desde))
            {
                sql += " AND e.fecha_evento >= TO_DATE(:desde, 'YYYY-MM-DD')";
                prms.Add(new OracleParameter("desde", filtros.Desde));
            }
            if (!string.IsNullOrWhiteSpace(filtros?.Hasta))
            {
                sql += " AND e.fecha_evento <= TO_DATE(:hasta, 'YYYY-MM-DD')";
                prms.Add(new OracleParameter("hasta", filtros.Hasta));
            }
            sql += " ORDER BY e.fecha_evento DESC";

            var lista = new List<EventoReproductivo>();
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text, prms.ToArray()))
            {
                while (rdr.Read())
                    lista.Add(new EventoReproductivo
                    {
                        IdEvento = OracleHelper.GetValue<decimal>(rdr["ID_EVENTO"]),
                        IdAnimal = OracleHelper.GetValue<decimal>(rdr["ID_ANIMAL"]),
                        FechaEvento = OracleHelper.GetDate(rdr["FECHA_EVENTO"]),
                        TipoEvento = OracleHelper.GetValue<string>(rdr["TIPO_EVENTO"]),
                        NombreAnimal = OracleHelper.GetValue<string>(rdr["NOMBRE_ANIMAL"])
                    });
            }
            return lista;
        }
    }

    public class ReproductivosFiltros
    {
        public decimal? IdAnimal { get; set; }
        public string Desde { get; set; }
        public string Hasta { get; set; }
    }
}

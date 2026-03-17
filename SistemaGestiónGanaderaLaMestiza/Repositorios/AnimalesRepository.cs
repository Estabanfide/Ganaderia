using System;
using System.Collections.Generic;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using SistemaGestiónGanaderaLaMestiza.Datos;
using SistemaGestiónGanaderaLaMestiza.Models;

namespace SistemaGestiónGanaderaLaMestiza.Repositorios
{
    public class AnimalesRepository
    {
        private static Animal MapAnimal(OracleDataReader rdr)
        {
            return new Animal
            {
                IdAnimal = OracleHelper.GetValue<decimal>(rdr["ID_ANIMAL"]),
                Nombre = OracleHelper.GetValue<string>(rdr["NOMBRE"]),
                FechaNac = OracleHelper.GetDate(rdr["FECHA_NAC"]),
                Raza = OracleHelper.GetValue<string>(rdr["RAZA"]),
                Sexo = OracleHelper.GetValue<string>(rdr["SEXO"]),
                Tipo = OracleHelper.GetValue<string>(rdr["TIPO"]),
                Salud = OracleHelper.GetValue<string>(rdr["SALUD"]),
                IdPotrero = OracleHelper.GetValue<decimal?>(rdr["ID_POTRERO"]),
                NombrePotrero = OracleHelper.GetValue<string>(rdr["NOMBRE_POTRERO"]),
                NombreFinca = OracleHelper.GetValue<string>(rdr["NOMBRE_FINCA"])
            };
        }

        public List<Animal> FindAll(AnimalesFiltros filtros)
        {
            var sql = @"SELECT a.id_animal, a.nombre, a.fecha_nac, a.raza, a.sexo, a.tipo, a.salud, a.id_potrero,
                p.nombre AS nombre_potrero, f.nombre AS nombre_finca
                FROM animales a
                LEFT JOIN potreros p ON a.id_potrero = p.id_potrero
                LEFT JOIN fincas f ON p.id_finca = f.id_finca
                WHERE 1=1";
            var prms = new List<OracleParameter>();
            if (!string.IsNullOrWhiteSpace(filtros?.Nombre))
            {
                sql += " AND UPPER(a.nombre) LIKE UPPER(:nombre)";
                prms.Add(new OracleParameter("nombre", "%" + (filtros.Nombre ?? "").Trim() + "%"));
            }
            if (!string.IsNullOrWhiteSpace(filtros?.Raza))
            {
                sql += " AND UPPER(TRIM(a.raza)) = UPPER(TRIM(:raza))";
                prms.Add(new OracleParameter("raza", filtros.Raza));
            }
            if (!string.IsNullOrWhiteSpace(filtros?.Sexo))
            {
                sql += " AND a.sexo = :sexo";
                prms.Add(new OracleParameter("sexo", filtros.Sexo));
            }
            if (!string.IsNullOrWhiteSpace(filtros?.Tipo))
            {
                sql += " AND UPPER(TRIM(a.tipo)) = UPPER(TRIM(:tipo))";
                prms.Add(new OracleParameter("tipo", filtros.Tipo));
            }
            if (!string.IsNullOrWhiteSpace(filtros?.Salud))
            {
                sql += " AND UPPER(TRIM(a.salud)) = UPPER(TRIM(:salud))";
                prms.Add(new OracleParameter("salud", filtros.Salud));
            }
            if (filtros?.IdPotrero != null && filtros.IdPotrero.HasValue)
            {
                sql += " AND a.id_potrero = :id_potrero";
                prms.Add(new OracleParameter("id_potrero", filtros.IdPotrero.Value));
            }
            sql += " ORDER BY a.nombre";

            var lista = new List<Animal>();
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text, prms.ToArray()))
            {
                while (rdr.Read())
                    lista.Add(MapAnimal(rdr));
            }
            return lista;
        }

        public Animal FindById(decimal id)
        {
            const string sql = @"SELECT a.id_animal, a.nombre, a.fecha_nac, a.raza, a.sexo, a.tipo, a.salud, a.id_potrero,
                p.nombre AS nombre_potrero, f.nombre AS nombre_finca
                FROM animales a LEFT JOIN potreros p ON a.id_potrero = p.id_potrero LEFT JOIN fincas f ON p.id_finca = f.id_finca
                WHERE a.id_animal = :id";
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text, new OracleParameter("id", id)))
            {
                if (rdr.Read()) return MapAnimal(rdr);
            }
            return null;
        }

        public decimal Create(Animal model)
        {
            using (var conn = OracleHelper.GetConnection())
            {
                var cmd = new OracleCommand("BEGIN sp_insertar_animal(:pn, :pf, :pr, :ps, :pt, :psl, :pidp); END;", conn);
                cmd.Parameters.Add(new OracleParameter("pn", (object)model.Nombre ?? DBNull.Value));
                cmd.Parameters.Add(new OracleParameter("pf", model.FechaNac.HasValue ? (object)model.FechaNac.Value : DBNull.Value));
                cmd.Parameters.Add(new OracleParameter("pr", (object)model.Raza ?? DBNull.Value));
                cmd.Parameters.Add(new OracleParameter("ps", (object)model.Sexo ?? DBNull.Value));
                cmd.Parameters.Add(new OracleParameter("pt", (object)model.Tipo ?? DBNull.Value));
                cmd.Parameters.Add(new OracleParameter("psl", (object)model.Salud ?? DBNull.Value));
                cmd.Parameters.Add(new OracleParameter("pidp", model.IdPotrero.HasValue ? (object)model.IdPotrero.Value : DBNull.Value));
                cmd.ExecuteNonQuery();

                using (var cmd2 = new OracleCommand("SELECT seq_animal.CURRVAL FROM dual", conn))
                {
                    return Convert.ToDecimal(cmd2.ExecuteScalar());
                }
            }
        }

        public void Update(decimal id, Animal model)
        {
            const string sql = "UPDATE animales SET nombre = :nombre, fecha_nac = :fecha_nac, raza = :raza, sexo = :sexo, tipo = :tipo, salud = :salud, id_potrero = :id_potrero WHERE id_animal = :id";
            OracleHelper.ExecuteNonQuery(sql, CommandType.Text,
                new OracleParameter("id", id),
                new OracleParameter("nombre", (object)model.Nombre ?? DBNull.Value),
                new OracleParameter("fecha_nac", model.FechaNac.HasValue ? (object)model.FechaNac.Value : DBNull.Value),
                new OracleParameter("raza", (object)model.Raza ?? DBNull.Value),
                new OracleParameter("sexo", (object)model.Sexo ?? DBNull.Value),
                new OracleParameter("tipo", (object)model.Tipo ?? DBNull.Value),
                new OracleParameter("salud", (object)model.Salud ?? DBNull.Value),
                new OracleParameter("id_potrero", model.IdPotrero.HasValue ? (object)model.IdPotrero.Value : DBNull.Value));
        }

        public void Remove(decimal id)
        {
            OracleHelper.ExecuteNonQuery("DELETE FROM animales WHERE id_animal = :id", CommandType.Text, new OracleParameter("id", id));
        }

        public int? GetEdad(decimal idAnimal)
        {
            const string sql = "SELECT fn_calcular_edad((SELECT fecha_nac FROM animales WHERE id_animal = :id)) AS edad FROM dual";
            var o = OracleHelper.ExecuteScalar(sql, CommandType.Text, new OracleParameter("id", idAnimal));
            if (o == null || o == DBNull.Value) return null;
            return Convert.ToInt32(o);
        }

        public List<VacunacionRegistro> GetHistorialVacunacion(decimal idAnimal)
        {
            const string sql = "SELECT v.nombre AS nombre_vacuna, va.fecha_aplicacion FROM vacunacion va JOIN vacunas v ON va.id_vacuna = v.id_vacuna WHERE va.id_animal = :id ORDER BY va.fecha_aplicacion DESC";
            var lista = new List<VacunacionRegistro>();
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text, new OracleParameter("id", idAnimal)))
            {
                while (rdr.Read())
                    lista.Add(new VacunacionRegistro { NombreVacuna = OracleHelper.GetValue<string>(rdr["NOMBRE_VACUNA"]), FechaAplicacion = OracleHelper.GetDate(rdr["FECHA_APLICACION"]) });
            }
            return lista;
        }

        public List<Costo> GetCostos(decimal idAnimal)
        {
            const string sql = "SELECT id_costo, monto, fecha_costo FROM costos WHERE id_animal = :id ORDER BY fecha_costo DESC";
            var lista = new List<Costo>();
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text, new OracleParameter("id", idAnimal)))
            {
                while (rdr.Read())
                    lista.Add(new Costo { IdCosto = OracleHelper.GetValue<decimal>(rdr["ID_COSTO"]), Monto = OracleHelper.GetDecimal(rdr["MONTO"]), FechaCosto = OracleHelper.GetDate(rdr["FECHA_COSTO"]) });
            }
            return lista;
        }

        public decimal GetTotalCostos(decimal idAnimal)
        {
            var o = OracleHelper.ExecuteScalar("SELECT fn_total_costos(:id) AS total FROM dual", CommandType.Text, new OracleParameter("id", idAnimal));
            return OracleHelper.GetDecimal(o) ?? 0;
        }

        public List<EventoReproductivo> GetEventosReproductivos(decimal idAnimal)
        {
            const string sql = "SELECT id_evento, fecha_evento, tipo_evento FROM eventos_reproductivos WHERE id_animal = :id ORDER BY fecha_evento DESC";
            var lista = new List<EventoReproductivo>();
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text, new OracleParameter("id", idAnimal)))
            {
                while (rdr.Read())
                    lista.Add(new EventoReproductivo { IdEvento = OracleHelper.GetValue<decimal>(rdr["ID_EVENTO"]), FechaEvento = OracleHelper.GetDate(rdr["FECHA_EVENTO"]), TipoEvento = OracleHelper.GetValue<string>(rdr["TIPO_EVENTO"]) });
            }
            return lista;
        }
    }

    public class AnimalesFiltros
    {
        public string Nombre { get; set; }
        public string Raza { get; set; }
        public string Sexo { get; set; }
        public string Tipo { get; set; }
        public string Salud { get; set; }
        public decimal? IdPotrero { get; set; }
    }
}

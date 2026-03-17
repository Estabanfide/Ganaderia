using System;
using System.Collections.Generic;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using SistemaGestiónGanaderaLaMestiza.Datos;
using SistemaGestiónGanaderaLaMestiza.Models;

namespace SistemaGestiónGanaderaLaMestiza.Repositorios
{
    public class VacunasRepository
    {
        public List<Vacuna> FindAllVacunas()
        {
            const string sql = "SELECT id_vacuna, nombre FROM vacunas ORDER BY nombre";
            var lista = new List<Vacuna>();
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text))
            {
                while (rdr.Read())
                    lista.Add(new Vacuna { IdVacuna = OracleHelper.GetValue<decimal>(rdr["ID_VACUNA"]), Nombre = OracleHelper.GetValue<string>(rdr["NOMBRE"]) });
            }
            return lista;
        }

        public void RegistrarVacunacion(decimal idAnimal, decimal idVacuna, DateTime? fechaAplicacion)
        {
            const string sql = "INSERT INTO vacunacion (id_animal, id_vacuna, fecha_aplicacion) VALUES (:id_animal, :id_vacuna, :fecha_aplicacion)";
            OracleHelper.ExecuteNonQuery(sql, CommandType.Text,
                new OracleParameter("id_animal", idAnimal),
                new OracleParameter("id_vacuna", idVacuna),
                new OracleParameter("fecha_aplicacion", fechaAplicacion.HasValue ? (object)fechaAplicacion.Value : DBNull.Value));
        }

        public List<VacunacionHistorialItem> GetHistorialGlobal(int limite = 100)
        {
            const string sql = @"SELECT * FROM (
                SELECT a.id_animal, a.nombre AS nombre_animal, v.nombre AS nombre_vacuna, va.fecha_aplicacion
                FROM vacunacion va JOIN animales a ON va.id_animal = a.id_animal JOIN vacunas v ON va.id_vacuna = v.id_vacuna
                ORDER BY va.fecha_aplicacion DESC
            ) WHERE ROWNUM <= :limite";
            var lista = new List<VacunacionHistorialItem>();
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text, new OracleParameter("limite", limite)))
            {
                while (rdr.Read())
                    lista.Add(new VacunacionHistorialItem
                    {
                        IdAnimal = OracleHelper.GetValue<decimal>(rdr["ID_ANIMAL"]),
                        NombreAnimal = OracleHelper.GetValue<string>(rdr["NOMBRE_ANIMAL"]),
                        NombreVacuna = OracleHelper.GetValue<string>(rdr["NOMBRE_VACUNA"]),
                        FechaAplicacion = OracleHelper.GetDate(rdr["FECHA_APLICACION"])
                    });
            }
            return lista;
        }
    }
}

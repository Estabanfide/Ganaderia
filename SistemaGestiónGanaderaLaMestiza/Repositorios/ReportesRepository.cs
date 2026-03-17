using System.Collections.Generic;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using SistemaGestiónGanaderaLaMestiza.Datos;
using SistemaGestiónGanaderaLaMestiza.Models;

namespace SistemaGestiónGanaderaLaMestiza.Repositorios
{
    public class ReportesRepository
    {
        public List<ReporteInventarioItem> GetInventarioFiltrado(ReportesFiltros filtros)
        {
            var sql = @"SELECT a.id_animal, a.nombre, a.fecha_nac, a.raza, a.sexo, a.tipo, a.salud, p.nombre AS nombre_potrero, f.nombre AS nombre_finca,
                TRUNC(MONTHS_BETWEEN(SYSDATE, a.fecha_nac) / 12) AS edad
                FROM animales a LEFT JOIN potreros p ON a.id_potrero = p.id_potrero LEFT JOIN fincas f ON p.id_finca = f.id_finca WHERE 1=1";
            var prms = new List<OracleParameter>();
            if (!string.IsNullOrWhiteSpace(filtros?.Raza))
            {
                sql += " AND UPPER(TRIM(a.raza)) = UPPER(:raza)";
                prms.Add(new OracleParameter("raza", filtros.Raza.Trim()));
            }
            if (filtros?.IdPotrero != null)
            {
                sql += " AND a.id_potrero = :id_potrero";
                prms.Add(new OracleParameter("id_potrero", filtros.IdPotrero.Value));
            }
            if (filtros?.IdFinca != null)
            {
                sql += " AND p.id_finca = :id_finca";
                prms.Add(new OracleParameter("id_finca", filtros.IdFinca.Value));
            }
            if (!string.IsNullOrWhiteSpace(filtros?.Salud))
            {
                sql += " AND UPPER(TRIM(a.salud)) = UPPER(:salud)";
                prms.Add(new OracleParameter("salud", filtros.Salud.Trim()));
            }
            if (!string.IsNullOrWhiteSpace(filtros?.RangoEdad))
            {
                if (filtros.RangoEdad == "Cachorro") sql += " AND TRUNC(MONTHS_BETWEEN(SYSDATE, a.fecha_nac) / 12) < 1";
                else if (filtros.RangoEdad == "Juvenil") sql += " AND TRUNC(MONTHS_BETWEEN(SYSDATE, a.fecha_nac) / 12) >= 1 AND TRUNC(MONTHS_BETWEEN(SYSDATE, a.fecha_nac) / 12) < 3";
                else if (filtros.RangoEdad == "Adulto") sql += " AND TRUNC(MONTHS_BETWEEN(SYSDATE, a.fecha_nac) / 12) >= 3 AND TRUNC(MONTHS_BETWEEN(SYSDATE, a.fecha_nac) / 12) <= 10";
                else if (filtros.RangoEdad == "Anciano") sql += " AND TRUNC(MONTHS_BETWEEN(SYSDATE, a.fecha_nac) / 12) > 10";
            }
            sql += " ORDER BY a.nombre";

            var lista = new List<ReporteInventarioItem>();
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text, prms.ToArray()))
            {
                while (rdr.Read())
                {
                    lista.Add(new ReporteInventarioItem
                    {
                        IdAnimal = OracleHelper.GetValue<decimal>(rdr["ID_ANIMAL"]),
                        Nombre = OracleHelper.GetValue<string>(rdr["NOMBRE"]),
                        FechaNac = OracleHelper.GetDate(rdr["FECHA_NAC"]),
                        Raza = OracleHelper.GetValue<string>(rdr["RAZA"]),
                        Sexo = OracleHelper.GetValue<string>(rdr["SEXO"]),
                        Tipo = OracleHelper.GetValue<string>(rdr["TIPO"]),
                        Salud = OracleHelper.GetValue<string>(rdr["SALUD"]),
                        NombrePotrero = OracleHelper.GetValue<string>(rdr["NOMBRE_POTRERO"]),
                        NombreFinca = OracleHelper.GetValue<string>(rdr["NOMBRE_FINCA"]),
                        Edad = OracleHelper.GetValue<int?>(rdr["EDAD"])
                    });
                }
            }
            return lista;
        }

        public List<DistribucionSalud> GetDistribucionPorSalud()
        {
            const string sql = "SELECT NVL(TRIM(salud), 'Sin dato') AS salud, COUNT(*) AS cantidad FROM animales GROUP BY TRIM(salud) ORDER BY cantidad DESC";
            var lista = new List<DistribucionSalud>();
            using (var rdr = OracleHelper.ExecuteReader(sql, CommandType.Text))
            {
                while (rdr.Read())
                    lista.Add(new DistribucionSalud { Salud = OracleHelper.GetValue<string>(rdr["SALUD"]), Cantidad = OracleHelper.GetValue<int>(rdr["CANTIDAD"]) });
            }
            return lista;
        }
    }

    public class ReportesFiltros
    {
        public string Raza { get; set; }
        public decimal? IdPotrero { get; set; }
        public decimal? IdFinca { get; set; }
        public string Salud { get; set; }
        public string RangoEdad { get; set; }
    }
}

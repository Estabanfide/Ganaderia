# La Mestiza - Sistema de Gestión Ganadera

Aplicación web para gestión de fincas ganaderas (ASP.NET MVC 5, C#, Oracle, Razor, Bootstrap 5).

**¿Primera vez?** Usa la **[Guía paso a paso (primera vez)](GUIA_PRIMERA_VEZ.md)**.

## Cómo ejecutar

- **Visual Studio:** Abre **SistemaGestionGanaderaLaMestiza.sln**, establece el proyecto **SistemaGestiónGanaderaLaMestiza** como proyecto de inicio y pulsa **F5**. La app se abre en IIS Express (por ejemplo https://localhost:44374).
- La raíz `/` redirige a **Dashboard** si hay sesión, o a **Login** si no.

## Requisitos

- Visual Studio 2019 o superior con carga de trabajo **Desarrollo web y ASP.NET**
- .NET Framework 4.8.1
- Oracle Database (esquema creado con el script SQL del proyecto)
- **Oracle.ManagedDataAccess** y **BCrypt.Net-Next** (NuGet; se restauran al abrir la solución)

## Configuración de Oracle

En **Web.config** hay una cadena de conexión `OracleLaMestiza`:

```xml
<connectionStrings>
  <add name="OracleLaMestiza" connectionString="User Id=;Password=;Data Source=localhost:1521/XE" providerName="Oracle.ManagedDataAccess.Client" />
</connectionStrings>
```

Edítala con tu **User Id**, **Password** y **Data Source** (ej. `localhost:1521/XE` o `servidor:1521/NOMBRE_SERVICIO`).

## Autenticación

La tabla `usuarios` del esquema Oracle puede no incluir la columna de contraseña. Para login y registro:

1. Ejecute en Oracle el script opcional que agrega la columna:
   - Archivo: **Scripts/scripts/add-clave-usuarios.sql**
   - Contenido: `ALTER TABLE usuarios ADD clave VARCHAR2(255);`
2. Después del script, el registro guarda el hash de la contraseña (BCrypt) y el login la valida.

## Estructura del proyecto

- **Controllers/** — Auth, Dashboard, Animales, Vacunas, Ubicaciones, Costos, Reproductivos, Reportes, Error
- **Models/** — Entidades (Usuario, Animal, Potrero, Vacuna, Costo, etc.)
- **Repositorios/** — Acceso a Oracle (Auth, Dashboard, Animales, Vacunas, Costos, etc.)
- **Datos/OracleHelper.cs** — Conexión y ejecución Oracle
- **Views/** — Vistas Razor (Auth, Dashboard, Animales, Vacunas, etc.)
- **Filters/RequireAuthAttribute.cs** — Protección de rutas por sesión

## Rutas principales

- **Auth:** `/Auth/Login`, `/Auth/Register`, `POST /Auth/Logout`
- **Dashboard:** `/Dashboard`
- **Animales:** `/Animales`, `/Animales/Nuevo`, `/Animales/Detalle/{id}`, `/Animales/Editar/{id}`
- **Vacunas:** `/Vacunas`
- **Ubicaciones:** `/Ubicaciones`, `/Ubicaciones/Exportar` (CSV)
- **Costos:** `/Costos`
- **Reproductivos:** `/Reproductivos`
- **Reportes:** `/Reportes`, `/Reportes/Exportar` (CSV)

Esquema Oracle: mismas tablas y procedimientos (`sp_insertar_animal`, `sp_registrar_costo`, `fn_calcular_edad`, `fn_total_costos`, trigger de vacunación ORA-20001, etc.).

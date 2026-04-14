# Guía paso a paso — Primera vez con La Mestiza (MVC)

Esta guía explica **qué es cada cosa** y **qué hacer en orden** para ejecutar la aplicación web La Mestiza (ASP.NET MVC).

---

## 1. ¿Qué es este proyecto?

- **La Mestiza** es una aplicación web para gestionar una finca ganadera (animales, vacunas, costos, reportes, etc.).
- Está hecha con **ASP.NET MVC 5** (C#, .NET Framework 4.8.1) y se conecta a una base de datos **Oracle**.
- Al abrir la solución **SistemaGestionGanaderaLaMestiza.sln** verás un único proyecto: **SistemaGestiónGanaderaLaMestiza**.

---

## 2. Qué necesitas

| Requisito | Descripción |
|-----------|-------------|
| **Visual Studio** | 2019 o superior, con la carga de trabajo "Desarrollo web y ASP.NET". |
| **Oracle Database** | Base de datos con el esquema creado (tablas, secuencias, procedimientos del proyecto). |
| **NuGet** | Visual Studio restaura los paquetes (Oracle.ManagedDataAccess, BCrypt.Net-Next, etc.) al abrir la solución. |

---

## 3. Paso 1: Configurar la conexión a Oracle

1. Abre la solución **SistemaGestionGanaderaLaMestiza.sln** en Visual Studio.
2. En el **Explorador de soluciones**, abre **Web.config** (está en la raíz del proyecto).
3. Busca la sección **connectionStrings** y edita **OracleLaMestiza**:
   - **User Id:** tu usuario de Oracle
   - **Password:** la contraseña
   - **Data Source:** ej. `localhost:1521/XE` o `servidor:1521/NOMBRE_SERVICIO`
4. Guarda el archivo.

Sin una conexión válida, la aplicación no podrá conectarse a Oracle al iniciar sesión o al usar cualquier módulo.

---

## 4. Paso 2: Ejecutar scripts SQL oficiales

Para usar la base de datos del proyecto:

1. Abre **SQL*Plus**, **SQL Developer** o tu herramienta Oracle.
2. Conéctate con el mismo usuario que configuraste en Web.config.
3. Ejecuta el script base **Scripts/scripts/granja_lbd_final_1.sql**.
4. Ejecuta el parche incremental **Scripts/scripts/V2026_04_14_001_auth_patch.sql**.
5. A partir de ahí la aplicación podrá guardar contraseñas al registrarse y comprobarlas al iniciar sesión.

Si no ejecutas ambos scripts, algunas funciones del sistema pueden fallar.

---

## 5. Paso 3: Ejecutar la aplicación

1. En Visual Studio, asegúrate de que **SistemaGestiónGanaderaLaMestiza** sea el **proyecto de inicio** (clic derecho en el proyecto → **Establecer como proyecto de inicio**).
2. Pulsa **F5** (o **Ctrl+F5** para ejecutar sin depurar).
3. Se abrirá el navegador en la URL de IIS Express (ej. **https://localhost:44374**).
4. La raíz redirige a **Login**. Tras iniciar sesión o crear cuenta, accederás al **Dashboard**.

---

## 6. Resumen rápido (después de la primera vez)

1. Abre **SistemaGestionGanaderaLaMestiza.sln** en Visual Studio.
2. Pulsa **F5**.
3. Abre la URL que muestre Visual Studio (ej. https://localhost:44374).

No hace falta volver a configurar Web.config cada vez (solo si cambias de base de datos o de usuario).

---

## 7. Si algo falla

| Problema | Qué revisar |
|----------|-------------|
| Error de compilación / paquetes faltantes | Clic derecho en la solución → **Restaurar paquetes NuGet**. |
| Error de conexión a Oracle | Revisa **Web.config** (connectionStrings): User Id, Password y Data Source correctos. Comprueba que Oracle esté en ejecución. |
| Error al registrarse / "invalid identifier" en clave | Verifica que ejecutaste **granja_lbd_final_1.sql** y luego **V2026_04_14_001_auth_patch.sql**. |
| "Seleccione un elemento de inicio válido" | Asegúrate de que el proyecto **SistemaGestiónGanaderaLaMestiza** esté establecido como proyecto de inicio (clic derecho → Establecer como proyecto de inicio). |

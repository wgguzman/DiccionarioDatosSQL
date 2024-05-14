USE [master]
GO

CREATE DATABASE [EjemploDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'EjemploDB', FILENAME = N'C:\Temp\EjemploDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'EjemploDB_log', FILENAME = N'C:\Temp\EjemploDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [EjemploDB] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [EjemploDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [EjemploDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [EjemploDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [EjemploDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [EjemploDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [EjemploDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [EjemploDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [EjemploDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [EjemploDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [EjemploDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [EjemploDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [EjemploDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [EjemploDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [EjemploDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [EjemploDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [EjemploDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [EjemploDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [EjemploDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [EjemploDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [EjemploDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [EjemploDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [EjemploDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [EjemploDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [EjemploDB] SET RECOVERY FULL 
GO
ALTER DATABASE [EjemploDB] SET  MULTI_USER 
GO
ALTER DATABASE [EjemploDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [EjemploDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [EjemploDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [EjemploDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [EjemploDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [EjemploDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'EjemploDB', N'ON'
GO
ALTER DATABASE [EjemploDB] SET QUERY_STORE = ON
GO
ALTER DATABASE [EjemploDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [EjemploDB]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ObtenerSalarioAnual]    Script Date: 14/05/2024 09:43:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Función
CREATE FUNCTION [dbo].[fn_ObtenerSalarioAnual]
    (@SalarioMensual DECIMAL(10, 2))
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN (@SalarioMensual * 12);
END;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Empleados](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](100) NULL,
	[FechaNacimiento] [date] NULL,
	[Salario] [decimal](10, 2) NOT NULL,
	[Activo] [bit] NOT NULL,
	[Departamento] [int] NOT NULL,
	[Unidad] [int] NOT NULL,
	[Clave] [varchar](50) MASKED WITH (FUNCTION = 'default()') NULL,
 CONSTRAINT [PK_Empleado] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* Vista*/
CREATE VIEW [dbo].[VistaEmpleadosActivos]
AS
SELECT        Nombre, Salario, Clave AS Password
FROM            dbo.Empleados
WHERE        (Activo = 1)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Departamentos](
	[DeptID] [int] IDENTITY(1,1) NOT NULL,
	[IDUnidad] [int] NOT NULL,
	[Nombre] [nvarchar](100) NULL,
	[Ubicacion] [nvarchar](100) NULL,
 CONSTRAINT [PK_Departamentos] PRIMARY KEY CLUSTERED 
(
	[DeptID] ASC,
	[IDUnidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Unidades](
	[IDUnidad] [int] IDENTITY(10,10) NOT NULL,
	[NombreUnidad] [varchar](100) NOT NULL,
	[PrimerRegistro]  AS (case when [IDUnidad]=(10) then (1) else (0) end),
 CONSTRAINT [PK_Unidades] PRIMARY KEY CLUSTERED 
(
	[IDUnidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Departamentos] ON [dbo].[Departamentos]
(
	[Ubicacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_Departamentos] ON [dbo].[Departamentos]
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Empleados] ADD  CONSTRAINT [DF_Empleados_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[Departamentos]  WITH CHECK ADD  CONSTRAINT [FK_Departamentos_Unidades] FOREIGN KEY([IDUnidad])
REFERENCES [dbo].[Unidades] ([IDUnidad])
GO
ALTER TABLE [dbo].[Departamentos] CHECK CONSTRAINT [FK_Departamentos_Unidades]
GO
ALTER TABLE [dbo].[Empleados]  WITH CHECK ADD  CONSTRAINT [FK_Empleados_Departamentos] FOREIGN KEY([Departamento], [Unidad])
REFERENCES [dbo].[Departamentos] ([DeptID], [IDUnidad])
GO
ALTER TABLE [dbo].[Empleados] CHECK CONSTRAINT [FK_Empleados_Departamentos]
GO
ALTER TABLE [dbo].[Empleados]  WITH CHECK ADD  CONSTRAINT [CK_Empleados_Salario] CHECK  (([Salario]>(0)))
GO
ALTER TABLE [dbo].[Empleados] CHECK CONSTRAINT [CK_Empleados_Salario]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_amenta_salario] 
    @EmpleadoID INT,
	@Aumento decimal(10,2) = 1
AS
BEGIN
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	update Empleados
	 set Salario = Salario + (Salario * @Aumento /100)
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Procedimiento Almacenado
CREATE PROCEDURE [dbo].[sp_ObtenerEmpleado]
    @EmpleadoID INT
AS
BEGIN
    SELECT * FROM Empleados WHERE ID = @EmpleadoID;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Procedimiento Almacenado
CREATE PROCEDURE [dbo].[sp_ObtenerSalarioEmpleado]
    @EmpleadoID INT, @salario DECIMAL(10,2) OUT
AS
BEGIN
    SELECT Salario FROM Empleados WHERE ID = @EmpleadoID;
END;
GO
EXEC [EjemploDB].sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Base de datos de ejemplo para diccionario de datos generado mediante etiquetas en las propiedades extendidas.' 
GO
EXEC [EjemploDB].sys.sp_addextendedproperty @name=N'Autor', @value=N'Walter Guzmán Sánchez' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Aumenta el salario de un colaborador en un porcentaje recibido como parámetro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_amenta_salario'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Procedimiento que consulta la informarción de un colaborador.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_ObtenerEmpleado'
GO
EXEC sys.sp_addextendedproperty @name=N'Autor', @value=N'Walter Guzmán Sánchez' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_ObtenerSalarioEmpleado'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Retorna el salario de un colaborador mediente un parámetro de salida.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_ObtenerSalarioEmpleado'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Retorna el salario anual de un colaborador.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fn_ObtenerSalarioAnual'
GO
EXEC sys.sp_addextendedproperty @name=N'Descripción', @value=N'Identificador único del departamento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Departamentos', @level2type=N'COLUMN',@level2name=N'DeptID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Consecutivo de los departamentos de empleados.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Departamentos', @level2type=N'COLUMN',@level2name=N'DeptID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del departamento del empleado.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Departamentos', @level2type=N'COLUMN',@level2name=N'Nombre'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ubicación del departamento del empleado.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Departamentos', @level2type=N'COLUMN',@level2name=N'Ubicacion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Llave primaria de la tabla Departamentos.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Departamentos', @level2type=N'CONSTRAINT',@level2name=N'PK_Departamentos'
GO
EXEC sys.sp_addextendedproperty @name=N'Nota', @value=N'Segundo comentario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Departamentos', @level2type=N'CONSTRAINT',@level2name=N'PK_Departamentos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indice de la tabla de departamentos por ubicación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Departamentos', @level2type=N'INDEX',@level2name=N'IX_Departamentos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Llave única del nombre del departamento de los empleados.X' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Departamentos', @level2type=N'INDEX',@level2name=N'UK_Departamentos'
GO
EXEC sys.sp_addextendedproperty @name=N'Nota', @value=N'Segundo comentario de indice' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Departamentos', @level2type=N'INDEX',@level2name=N'UK_Departamentos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Departamentos de los empleados.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Departamentos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Enlace entre las unidades y los departamentos.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Departamentos', @level2type=N'CONSTRAINT',@level2name=N'FK_Departamentos_Unidades'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID del empleado.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del colaborador.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'COLUMN',@level2name=N'Nombre'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de nacimiento.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'COLUMN',@level2name=N'FechaNacimiento'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Salrio mensual en colones.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'COLUMN',@level2name=N'Salario'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si el colaborador está activo.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'COLUMN',@level2name=N'Activo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Departamento del colaborador.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'COLUMN',@level2name=N'Departamento'
GO
EXEC sys.sp_addextendedproperty @name=N'Autor', @value=N'Walter Guzmán Sánchez' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'COLUMN',@level2name=N'Clave'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave de ingreso al sistema de autoconsulas.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'COLUMN',@level2name=N'Clave'
GO
EXEC sys.sp_addextendedproperty @name=N'Notas', @value=N'Se enmascara los valores.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'COLUMN',@level2name=N'Clave'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LLave primaria de empleados.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'CONSTRAINT',@level2name=N'PK_Empleado'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Datos de colaboradores.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados'
GO
EXEC sys.sp_addextendedproperty @name=N'Notas', @value=N'Tabla de empleado y Salarios' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Enlace entre emplaedos y  departamentos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'CONSTRAINT',@level2name=N'FK_Empleados_Departamentos'
GO
EXEC sys.sp_addextendedproperty @name=N'Nota', @value=N'Enlace entre empledos y  departamentos segundo comentario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'CONSTRAINT',@level2name=N'FK_Empleados_Departamentos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valida que el salario es mayor a cero.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Empleados', @level2type=N'CONSTRAINT',@level2name=N'CK_Empleados_Salario'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la unidad.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Unidades', @level2type=N'COLUMN',@level2name=N'IDUnidad'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de la unidad' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Unidades', @level2type=N'COLUMN',@level2name=N'NombreUnidad'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si es el primer registro con formula computada.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Unidades', @level2type=N'COLUMN',@level2name=N'PrimerRegistro'
GO
EXEC sys.sp_addextendedproperty @name=N'Nota', @value=N'Segundo comentario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Unidades', @level2type=N'CONSTRAINT',@level2name=N'PK_Unidades'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unidades operativas.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Unidades'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del colaborador en la vista' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VistaEmpleadosActivos', @level2type=N'COLUMN',@level2name=N'Nombre'
GO
EXEC sys.sp_addextendedproperty @name=N'Autor', @value=N'Segundo comentario en campo de vista' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VistaEmpleadosActivos', @level2type=N'COLUMN',@level2name=N'Salario'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Salario del colaborador en la vista.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VistaEmpleadosActivos', @level2type=N'COLUMN',@level2name=N'Salario'
GO
EXEC sys.sp_addextendedproperty @name=N'Autor', @value=N'Walter Guzmán Sánchez' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VistaEmpleadosActivos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vista con datos de lo colaboradores.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VistaEmpleadosActivos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Empleados"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 250
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1995
         Table = 1380
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VistaEmpleadosActivos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VistaEmpleadosActivos'
GO
USE [master]
GO
ALTER DATABASE [EjemploDB] SET  READ_WRITE 
GO

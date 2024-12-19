
CREATE DATABASE conafe_local;
DROP DATABASE conafe_local;

USE conafe_local;
SELECT *FROM Usuario_rol;
SELECT *FROM usuario;


USE conafe_local;  -- Selecciona la base de datos

SELECT 
	usuario.id, 
    usuario.usuario, 
    usuario.contrasenia, 
    usuario.usuario_rol_id,
    Usuario_rol.role, 
    datos_personales.id,
    datos_personales.nombre, 
    datos_personales.apellidopa,
    datos_personales.apellidoma, 
    datos_personales.curp, 
    datos_personales.usuario_id,
    documentos_personales.id,
    documentos_personales.identificacion_oficial,
    documentos_personales.comprobante_domicilio,
    documentos_personales.datos_personales_id
FROM
    usuario
INNER JOIN 
    Usuario_rol ON usuario.usuario_rol_id = Usuario_rol.id  -- Nombre correcto de la tabla
INNER JOIN
    datos_personales ON usuario.id = datos_personales.usuario_id
INNER JOIN 
    documentos_personales ON datos_personales.id = documentos_personales.datos_personales_id;


		
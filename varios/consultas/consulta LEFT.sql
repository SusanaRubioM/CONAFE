USE conafe_local;
SELECT 
    usuario.*, 
    datos_personales.*, 
    residencia.*, 
    aspirante.*, 
    participacion.*, 
    informacion_gestion.*
FROM 
    usuario
LEFT JOIN 
    aspirante ON usuario.id = aspirante.usuario_id  -- Relación entre usuario y aspirante
LEFT JOIN 
    datos_personales ON usuario.id = datos_personales.usuario_id  -- Relación entre usuario y datos_personales
LEFT JOIN 
    residencia ON aspirante.id = residencia.aspirante_id  -- Relación entre aspirante y residencia
LEFT JOIN 
    participacion ON aspirante.id = participacion.aspirante_id  -- Relación entre aspirante y participacion
LEFT JOIN 
    informacion_gestion ON aspirante.id = informacion_gestion.aspirante_id;  -- Relación con aspirante en informacion_gestion

SELECT 
    usuario.id AS usuario_id,
    datos_personales.nombre,
    datos_personales.apellidopa,
    datos_personales.apellidoma,
    datos_personales.correo,
    usuario.usuario AS nombre_usuario,
    usuario.rol,
    aspirante.folio
FROM
    usuario
LEFT JOIN
    datos_personales ON usuario.id = datos_personales.usuario_id
LEFT JOIN
    aspirante ON datos_personales.id = aspirante.datos_personales_id;






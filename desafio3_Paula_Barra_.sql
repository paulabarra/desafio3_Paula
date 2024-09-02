CREATE TABLE usuarios (id SERIAL PRIMARY KEY, 
 email VARCHAR(255) NOT NULL, 
 nombre VARCHAR(100) NOT NULL, 
 apellido VARCHAR(100) NOT NULL, 
 rol VARCHAR(50) NOT NULL);

INSERT INTO usuarios (email, nombre, apellido, rol) VALUES
('carlos.marquez@pbc.com', 'Carlos', 'Marquez', 'administrador'),
('ana.garcia@pbc.com', 'Ana', 'García', 'usuario'),
('andres.rodriguez@pbc.com', 'Andres', 'Rodríguez', 'usuario'),
('maria.campos@pbc.com', 'María', 'Campos', 'usuario'),
('Luis.martinez@pbc.com', 'Luis', 'Martínez', 'usuario');

CREATE TABLE posts (
 id SERIAL PRIMARY KEY, 
 título VARCHAR(255) NOT NULL, 
 contenido TEXT NOT NULL, 
 fecha_creaciON TIMESTAMP NOT NULL, 
 fecha_actualizaciON TIMESTAMP NOT NULL, 
 destacado BOOLEAN NOT NULL, 
 usuario_id BIGINT, 
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id));

INSERT INTO posts (título, contenido, fecha_creacion, fecha_actualizacion, destacado, usuario_id) VALUES
('Post del AdministradOR 1', 'Contenido del primer post del administrador.', NOW(), NOW(), true, 1),
('Post del AdministradOR 2', 'Contenido del segundo post del administrador.', NOW(), NOW(), false, 1),
('Post de Usuario', 'Contenido del post de un usuario normal.', NOW(), NOW(), true, 2),
('Otro Post de Usuario', 'Otro contenido del post de un usuario normal.', NOW(), NOW(), false, 3),
('Post SIN Usuario', 'Contenido de un post sIN usuario asignado.', NOW(), NOW(), false, NULL);

CREATE TABLE comentarios (
 id SERIAL PRIMARY KEY, 
 contenido TEXT NOT NULL, 
 fecha_creacion TIMESTAMP NOT NULL, 
 usuario_id BIGINT NOT NULL, 
 post_id BIGINT NOT NULL, 
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id), 
 FOREIGN KEY (post_id) REFERENCES posts(id));


INSERT INTO comentarios (contenido, fecha_creacion, usuario_id, post_id) VALUES
('Primer comentario en el primer post', NOW(), 1, 1), 
('Segundo comentario en el primer post', NOW(), 2, 1), 
('Tercer comentario en el primer post', NOW(), 3, 1), 
('Cuarto comentario en el segundo post', NOW(), 1, 2), 
('Quinto comentario en el segundo post', NOW(), 2, 2);

-------------------------------------------------------------------------------
también ayuda a identificar inconsistencias presentes en el código.

Ningún archivo seleccionado
--1.1. Mostrar todos los usuarios y sus roles
SELECT * FROM usuarios;

--1.2. Mostrar todos los posts con información de los usuarios
SELECT p.id AS post_id,   
 p.título,       
 p.contenido,      
 p.fecha_creacion,       
 p.fecha_actualizacion,   
 p.destacado,     
 u.nombre AS nombre_usuario,      
 u.apellido AS apellido_usuario,      
 u.rol
FROM posts p
LEFT JOIN usuarios u
ON p.usuario_id = u.id;

-- 1.3. Mostrar todos los comentarios cON información de los usuarios y posts asociados
SELECT c.id AS comentario_id,
 c.contenido AS comentario_contenido,
 c.fecha_creacion,
 u.nombre AS nombre_usuario,
 u.apellido AS apellido_usuario,
 p.título AS titulo_post
FROM comentarios c
LEFT 
JOIN usuarios u
ON c.usuario_id = u.id
LEFT JOIN posts p
ON c.post_id = p.id;

-- 1.4. Mostrar los posts del administrador con sus comentarios
SELECT 
 p.título,
 p.contenido,
 c.contenido AS comentario_contenido,
 c.fecha_creaciON AS comentario_fecha,
 u.nombre AS nombre_comentador,
 u.apellido AS apellido_comentador
FROM posts p
LEFT 
JOIN comentarios c
ON p.id = c.post_id
LEFT JOIN usuarios u
ON c.usuario_id = u.id
WHERE p.usuario_id = 1;

--1.5. Contar la cantidad de posts y comentarios por usuario
SELECT u.id,u.nombre,u.apellido,       
COUNT(DISTINCT p.id) AS total_posts,
COUNT(DISTINCT c.id) AS total_comentarios
FROM usuarios u
LEFT
JOIN posts p
ON u.id = p.usuario_id
LEFT JOIN comentarios c
ON u.id = c.usuario_id
GROUP BY u.id, u.nombre, u.apellido;

-----------------------------------------------------------------------------------
--2. Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas:
-- nombre y email del usuario junto al título y contenido del post.
-- Consulta para cruzar los datos de usuarios y posts
SELECT u.nombre,
        u.email,
        p.título,
        p.contenido
FROM posts p
JOIN usuarios u 
ON p.usuario_id = u.id;

-------------------------------------------------------------------------------------
--3. Muestra el id,título y contenido de los posts de los administradores.
--a. El administradOR puede ser cualquier id.
-- Consulta para mostrar los posts de los administradores
SELECT p.id,     
 		p.título,    
 		p.contenido
FROM posts p
JOIN usuarios u
ON p.usuario_id = u.id
WHERE u.rol = 'administrador';
--------------------------------------------------------------------------------------
--4. Cuenta la cantidad de posts de cada usuario.
--a. La tabla resultante debe mostrar el id e email del usuario junto con la
--cantidad de posts de cada usuario.
-- Consulta para contar la cantidad de posts de cada usuario
SELECT u.id,
        u.email,
COUNT(p.id) AS cantidad_posts
FROM usuarios u
LEFT 
JOIN 
 posts p
	ON u.id = p.usuario_id
GROUP BY u.id, u.email;
---------------------------------------------------------------------------------------
--5 Muestra el email del usuario que ha creado más posts.
--a. Aquí la tabla resultante tiene un único registro y muestra solo el email.
-- Consulta para mostrar el email del usuario que ha creado más posts
SELECT u.email
FROM usuarios u
LEFT
JOIN 
 posts p
    ON u.id = p.usuario_id
GROUP BY 
 u.id, 
 u.email
ORDER BY 
 COUNT(p.id) DESC
LIMIT 1;
---------------------------------------------------------------------------------------
--6. Muestra la fecha del último post de cada usuario.
-- Consulta para mostrar la fecha del último post de cada usuario
SELECT u.id,       
 	u.email,      
 MAX(p.fecha_creacion) AS fecha_ultimo_post
FROM 
 usuarios u
LEFT
JOIN 
 posts p
    ON u.id = p.usuario_id
GROUP BY 
 u.id, 
 u.email;
----------------------------------------------------------------------------------------------
-- 7.Muestra el título y contenido del post (artículo) con más comentarios.
-- Consulta para mostrar el título y contenido del post con más comentarios
SELECT p.título,       
 	p.contenido
FROM 
 posts p
JOIN 
 comentarios c
    ON p.id = c.post_id
GROUP BY 
 p.id, 
 p.título, 
 p.contenido
ORDER BY 
 COUNT(c.id) DESC
LIMIT 1;
-------------------------------------------------------------------------------------------------------
--8. Muestra en una tabla el título de cada post,el contenido de cada post y el contenido
--de cada comentario asociado a los posts mostrados,junto con el email del usuario
--que lo escribió.
-- Consulta para mostrar el título y contenido de cada post junto cON los comentarios y el email del usuario
SELECT 
 p.título AS titulo_post,       
 p.contenido AS contenido_post,       
 c.contenido AS contenido_comentario,       
 u.email AS email_usuario
FROM 
 posts p
LEFT
JOIN 
 comentarios c
    ON p.id = c.post_id
LEFT
JOIN 
 usuarios u
    ON c.usuario_id = u.id;
---------------------------------------------------------------------------------------------------
--9. Muestra el contenido del último comentario de cada usuario.
-- Consulta para mostrar el contenido del último comentario de cada usuario
SELECT c.usuario_id,     
 		u.email,
 		c.contenido AS contenido_ultimo_comentario
FROM 
 comentarios c
JOIN 
 usuarios u
    ON c.usuario_id = u.id
WHERE 
 c.fecha_creacion = (
SELECT 
 MAX(c2.fecha_creacion)
    FROM 
 comentarios c2
    WHERE 
 c2.usuario_id = c.usuario_id
 );
----------------------------------------------------------------------------------------------------
-- 10. Muestra los emails de los usuarios que no han escrito ningún comentario.
-- Consulta para mostrar los emails de los usuarios que no han escrito ningún comentario
SELECT u.email
    FROM usuarios u
LEFT JOIN comentarios c
    ON u.id = c.usuario_id
    GROUP BY  u.id, u.email
HAVING COUNT(c.id) = 0;




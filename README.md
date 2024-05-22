# Buscador de Imágenes


### Instalacion

Para instalar hay que hacer solo un `mix deps.get`, para bajar las dependencias

Que pasa si recibo un error como el siguiente?


```
{:failed_connect, [{:to_address, {'repo.hex.pm', 443}}, {:inet, [:inet], {:option, :server_only, :honor_cipher_order}}]}
```

Vamos a tener que ejecutar el siguiente comando -> `mix local.hex` y despues ejecutar el primer comando.

## Como pruebo los cambios desde iex??

Cargando las dependencias y el modulo mediante mix, ejecutando el siguiente comando:

`iex -S mix`

## Introducción

Este repositorio contiene el código de una aplicación `elixir/otp`, que permite extraer de un archivo de texto plano links a imágenes (en formato `png`, `jpg` o `gif`), y descargarlas en un directorio. 

Para ello, se expone un módulo `ImageFinder` y una función `fetch`, que toma la ruta del archivo de links y el directorio en el cual se descargarán. Ambas rutas pueden ser relativas al proyecto o absolutas. Por ejemplo: 

```elixir
ImageFinder.fetch("sample2.txt", "./out")


:ok
```

## El ejercicio

Este proyecto funciona, pero tiene algunos problemas notables:

* El modulo `ImageFinder` es totalmente bloqueante: no liberará el control hasta que haya terminado de descargar todas las imágenes. Lo que es más grave, no se pueden extraer links de más de un archivo al mismo tiempo. 
* El throughput es muy limitado, dado que procesa las imágenes de a una por vez, y no empieza hasta haber terminado de leer todo el archivo
* Su manejo de errores es muy limitado: 
  * Si la descarga de una imágen falla, falla todo el proceso
  * Si la lectura del archivo falla, no extraerá ningún link
  
### Primera parte
  
El primer objetivo es mejorar el diseño del módulo `ImageFinder`, separando convenintemente las tareas en diferentes actores, y diseñando una jerarquía de supervisión adecuada.

Recomendamos ir solucionando los problemas mencionados anteriormente de a uno. Por ejemplo:
* descargar más de una imagen en simultaneo (se pueden ir descargando sin límite a medida que se obtienen los links, o tener cierta cantidad fija de descargas "en paralelo")
* asegurarse de que el error en una descarga no haga fallar todo el proceso
* poder invocar a nuestro módulo varias veces con varios archivos distintos, aún cuando el proceso anterior no se haya terminado de ejecutar
* ir descargando links a medida que se leen del archivo (en vez de esperar a que se termine de leer completamente)

### Segunda parte

Contemplar los siguientes requerimientos: 

  * `ImageFinder` debería poder procesar el archivo aún si no entra en memoria
  * `ImageFinder` debería poder manejar gran cantidad de links
  * Si la descarga de una imagen falla, se debería reintentar hasta 3 veces.
  * El proceso de descarga debería ser _polite_, es decir, no debería sobrecargar a los servidores de imágenes. Para eso, los links de un mismo dominio deberían ser descargado de a uno por vez. 
  * Si la descarga de links del dominio falla frecuentemente (por ejemplo, más de 5 veces por minuto), se debería excluir al dominio del proceso de descarga
